#!/bin/bash

echo "Installing Kubernetes core services..."


# Install Cilium using Helm

helm repo add cilium https://helm.cilium.io/

helm install cilium cilium/cilium --version 1.13.2 \
    --set k8sServiceHost=$CONTROL_PLANE_IP \
    -f ../k8s_base/cillium/values.yaml