#!/bin/sh

d=`dirname $0`

$HELM repo add banzaicloud-stable http://kubernetes-charts.banzaicloud.com/branch/master
$HELM upgrade -i \
    --kube-context $CONTEXT \
    -f $d/vault.yaml \
    vault banzaicloud-stable/vault
