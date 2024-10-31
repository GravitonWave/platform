#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

# Starting message
printf "${CYAN}Starting Kubernetes configuration and deployment...${NC}\n"

# Deploy MetalLB and wait for readiness
printf "${BLUE}===== Deploying MetalLB =====${NC}\n"
printf "${YELLOW}Applying MetalLB configuration...${NC}\n"
kubectl apply --kustomize ../k8s_base/metallb

printf "${YELLOW}Waiting for MetalLB controller to be ready...${NC}\n"
kubectl rollout status deployment controller -n metallb-system --timeout=300s

printf "${YELLOW}Checking if MetalLB webhook service endpoints are ready...${NC}\n"
while [[ -z $(kubectl get endpoints metallb-webhook-service -n metallb-system -o jsonpath='{.subsets[*].addresses[*].ip}') ]]; do
  printf "${YELLOW} - Waiting for MetalLB webhook service endpoints...${NC}\n"
  sleep 5
done
printf "${GREEN}MetalLB webhook service endpoints are now ready.${NC}\n\n"

# Deploy Ingress NGINX and wait for readiness
printf "${BLUE}===== Deploying Ingress NGINX =====${NC}\n"
printf "${YELLOW}Applying Ingress NGINX configuration...${NC}\n"
kubectl kustomize --enable-helm ../k8s_base/ingress-nginx | kubectl apply -f -

printf "${YELLOW}Waiting for Ingress NGINX controller to be ready...${NC}\n"
kubectl rollout status deployment ingress-nginx-controller -n ingress-nginx --timeout=300s

printf "${YELLOW}Checking if Ingress NGINX controller admission endpoints are ready...${NC}\n"
while [[ -z $(kubectl get endpoints ingress-nginx-controller-admission -n ingress-nginx -o jsonpath='{.subsets[*].addresses[*].ip}') ]]; do
  printf "${YELLOW} - Waiting for Ingress NGINX controller admission endpoints...${NC}\n"
  sleep 5
done
printf "${GREEN}Ingress NGINX controller admission endpoints are now ready.${NC}\n\n"

# Deploy Gitea and wait for readiness
printf "${BLUE}===== Deploying Gitea =====${NC}\n"
printf "${YELLOW}Applying Gitea configuration...${NC}\n"
kubectl kustomize --enable-helm ../k8s_base/gitea | kubectl apply -f -

printf "${YELLOW}Waiting for Gitea components to be ready...${NC}\n"
kubectl rollout status deployment gitea-postgresql-ha-pgpool -n gitea --timeout=1500s
kubectl rollout status deployment gitea -n gitea --timeout=1500s
printf "${GREEN}Gitea components are now ready.${NC}\n\n"

# Deploy ArgoCD and wait for readiness
printf "${BLUE}===== Deploying ArgoCD =====${NC}\n"
printf "${YELLOW}Applying ArgoCD configuration...${NC}\n"
kubectl apply --kustomize ../k8s_base/argocd

printf "${YELLOW}Waiting for ArgoCD components to be ready...${NC}\n"
kubectl rollout status deployment argocd-applicationset-controller -n argocd --timeout=1500s
kubectl rollout status deployment argocd-dex-server -n argocd --timeout=1500s
kubectl rollout status deployment argocd-notifications-controller -n argocd --timeout=1500s
kubectl rollout status deployment argocd-redis -n argocd --timeout=1500s
kubectl rollout status deployment argocd-repo-server -n argocd --timeout=1500s
kubectl rollout status deployment argocd-server -n argocd --timeout=1500s
printf "${GREEN}ArgoCD components are now ready.${NC}\n\n"

# Apply additional MetalLB configurations
printf "${BLUE}===== Applying Additional MetalLB Configurations =====${NC}\n"
kubectl apply -f ../k8s_base/metallb/ip_address_pool.yaml
kubectl apply -f ../k8s_base/metallb/l2_advertisement.yaml
printf "${GREEN}MetalLB IP address pool and L2 advertisement configuration applied.${NC}\n"

# Completion message
printf "${CYAN}Kubernetes configuration and deployment completed successfully.${NC}\n\n"
