#!/bin/sh

ingress_chart_version=0.25.1

d=`dirname $0`

echo $d

# helm/tiller
kubectl --context $CONTEXT apply -f $d/resources/manifests/tiller.yaml

# stable charts
helm repo add stable http://storage.googleapis.com/kubernetes-charts

# nginx-ingress
$HELM upgrade \
    --kube-context $CONTEXT \
    --install \
    --version $ingress_chart_version \
    ingress-nginx stable/nginx-ingress

# openvpn
$HELM upgrade \
    --kube-context $CONTEXT \
    --install \
    openvpn stable/openvpn
    # --version $ingress_chart_version \
