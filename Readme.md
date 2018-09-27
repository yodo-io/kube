# My First Kops Cluster

<!-- TOC -->

- [My First Kops Cluster](#my-first-kops-cluster)
  - [Initialise Kops](#initialise-kops)
  - [First Cluster (Single-AZ)](#first-cluster-single-az)
  - [Deploy Sample Webapp](#deploy-sample-webapp)
  - [Generate TF Config](#generate-tf-config)
  - [Delete the Cluster](#delete-the-cluster)
  - [Networking](#networking)
    - [Private Network](#private-network)
  - [Bootstrap](#bootstrap)
  - [OpenVPN](#openvpn)
  - [Vault](#vault)
- [Port forward](#port-forward)
- [Root token when using default k8s secret backend](#root-token-when-using-default-k8s-secret-backend)

<!-- /TOC -->

1. Set up Terraform config
1. Create IAM User, access keys
1. Setup a (sub)-domain (using mykube.example.com)
1. Create bucket to store kops-state

## Initialise Kops

```sh
terraform apply -target module.kops
```

## First Cluster (Single-AZ)

Set some global vars for easier reference:

```sh
export NAME=lab.kube.yodo.io                 # must match kops_subdomain from TF output
export KOPS_STATE_STORE=s3://kops-state-XYZ  # must match kops_state_store from TF output
```

Create a cluster:

```sh
aws ec2 describe-availability-zones --region ap-southeast-1 # pick one...

kops create cluster \
    --zones ap-southeast-1a \
    --master-size t3.small \
    --node-count 3 \
    --node-size t3.small \
    ${NAME}
```

Edit cluster as needed:

```sh
# list clusters
kops get cluster

# edit cluster manifest, e.g. change CIDR to 10.35.0.0/16, subnet to 10.35.10.0/19
kops edit cluster $NAME

# list instance groups
kops get ig --name $NAME

# edit instance group for nodes (e.g. change max instances to 5)
kops edit ig --name $NAME nodes

# edit instance group for the single master (e.g. change instance type to t2.medium)
kops edit ig --name $NAME master-ap-southeast-1a
```

Actually create the cluster. Skip this if you want to [generate TF configs](#generate-tf-config) instead:

```sh
kops update cluster $NAME --yes
```

It will take a few minutes for all instances to launch and the k8s components to come online. Grab a coffee and relax. After ~10 mins start exploring the cluster:

```sh
kubectl get nodes # list nodes
kubectl describe node kubectl describe node ip-10-35-14-93.ap-southeast-1.compute.internal
kubectl get namespaces # list namespaces
kubens kube-system # switch namespace (kubens is part of https://github.com/ahmetb/kubectx)
kubectl get pods # system pods
```

## Deploy Sample Webapp

- Simple nginx webapp with custom index page, served through a LoadBalancer
- See [examples/nginx](./examples/nginx)
- To deploy it into the cluster:

```sh
kubectl apply -f examples/nginx/deployment.yaml -n default
```

- It will take a few minutes for the LB to be deployed and it's DNS record to be published
- Once it's deployed (install [jq][1] via `brew install jq`):

```sh
$ LB_URL=`kubectl get service nginx-demo -o json | jq -r '.status.loadBalancer.ingress[0].hostname'`
$ curl $LB_URL && echo
<h1>Hello Kubernetes!</h1>
```

- LBs cost money, so let's delete the webapp:

```sh
kubectl delete -f examples/nginx/deployment.yaml
```

## Generate TF Config

Follow the steps for creating a cluster as above, but don't run `kops update`. Instead, generate terraform configs into output dir `clusters/cluster-one`:

```sh
kops update cluster --target=terraform $NAME --out modules/clusters/$NAME
```

Or just create the cluster directly:

```sh
kops create cluster \
    --zones ap-southeast-1a \
    --master-size t2.small \
    --node-count 3 \
    --node-size t2.small \
    --authorization RBAC \
    --target terraform \
    --out modules/clusters/$NAME \
    --network-cidr 10.20.0.0/16 \
    ${NAME}
```

To import the config as TF module edit `main.tf`:

```hcl
module "cluster-staging" {
  source = "./clusters/<NAME>"
}
```

Initialise TF with the new module, then inspect planned changes:

```sh
terraform init
terraform plan
```

Run `terraform apply` if you want, but delete the existing cluster first (see below)

Kops won't generate a kubecfg if the cluster was created this way, to export it:

```sh
kops export kubecfg $NAME
```

To delete the cluster resource (but retain the kops-state):

```sh
terraform destroy -target module.cluster-staging
```

## Delete the Cluster

Warning: _this will delete the entire cluster definition from kops-state_! To get rid of resources associated with the cluster:

```sh
kops delete cluster --name ${NAME}          # preview
kops delete cluster --name ${NAME} --yes    # do all the things
```

## Networking

### Private Network

- Theoretically possible, but not with default `kubenet`
- Explained [here][2] (I don't quite get it tho)

Route tables:

- Multiple rtbs per subnet - cannot (one rtb can multi subnet, but not vice versa)
- Max 50 routes per rtb, minus masters, other igw, local, vpc peerings, etc.
- Leaves realistically ~40 nodes per cluster

## Bootstrap

- So far: tiller, ingress controller
- Tiller using plain kube manifests
- Using helm for the rest
- Make bootstrap, see `modules/bootstrap/charts.sh`

## OpenVPN

- OpenVPN is bootstrapped into the cluster via [stable/openvpn](https://github.com/helm/charts/tree/master/stable/openvpn)
- Cluster DNS is forwarded
- Generate a client config as below and connect using you favourite client:

```sh
./scripts/openvpn.sh <NAME> default openvpn
```

- Test DNS resolution:

```sh
$ dig openvpn.default.svc.cluster.local +short
100.x.y.z
```

## Vault

- Using Banzai Clouds vault operator
- Helm chart, operator, CRD
- Automatic unseal
- Secret storage in S3 for now, Consul etc. also can
- Unseal keys stored as k8s secret, not good for prod, better us KMS or similar

```sh
# Install vault
helm repo add banzaicloud-stable http://kubernetes-charts.banzaicloud.com/branch/master
helm install -f modules/bootstrap/resources/values/vault.yaml --name vault banzaicloud-stable/vault
```

- Connect to vault via port forwarding:

# Port forward
POD=`kubectl get pod -l app=vault -o name | awk -F '/' '{ print $2 }'`
kubectl port-forward $POD 8200
export VAULT_ADDR=`https://127.0.0.1:8200`

# Root token when using default k8s secret backend
export VAULT_TOKEN=`kubectl get secret bank-vaults -o json | jq -r '.data["vault-root"]' | base64 -D`
vault token lookup -tls-skip-verify # ignore self-signed cert for now
```

- Or via [OpenVPN](#openvpn):

```sh
export VAULT_ADDR=`https://vault-vault.default.svc.cluster.local:8200`
```

- UI: https://vault-vault.default.svc.cluster.local:8200/ui :tada:

TODO:

- Generate vault config based on TF output
- Use KMS as backend for storing vault unseal keys and root token
- Ingress for vault (undocumented, but supported by helm chart)

References:

- https://banzaicloud.com/bank-vaults/
- https://github.com/banzaicloud/bank-vaults
- https://github.com/banzaicloud/banzai-charts/tree/master/vault

## Next

- Can we make the masters, nodes & dns private?
- Try different networking plugin
- Generate SSH keys

[1]:https://stedolan.github.io/jq/
[2]:https://github.com/kubernetes/kops/blob/master/docs/networking.md#kops-default-networking
