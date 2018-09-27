#!/bin/sh

ingress_chart_version=0.25.1

d=`dirname $0`

echo $d

kubectl --context $CONTEXT apply -f $d/resources/manifests/tiller.yaml

# nginx-ingress
bin/helm upgrade \
    --kube-context $CONTEXT \
    -i ingress-nginx \
    --version $ingress_chart_version \
    stable/nginx-ingress

# vault
