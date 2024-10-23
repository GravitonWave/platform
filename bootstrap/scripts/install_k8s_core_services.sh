#!/bin/bash

kubectl apply --kustomize ../k8s_base/metallb
kubectl rollout status deployment controller  -n metallb-system  --timeout=300s

kubectl kustomize --enable-helm ../k8s_base/ingress-nginx | kubectl apply -f -

kubectl kustomize --enable-helm ../k8s_base/gitea | kubectl apply -f -

kubectl apply --kustomize ../k8s_base/argocd

kubectl apply -f ../k8s_base/metallb/ip_address_pool.yaml
kubectl apply -f ../k8s_base/metallb/l2_advertisement.yaml