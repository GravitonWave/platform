#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

# Function to get the cluster name from kind configuration
get_cluster_name_from_config() {
  if [ -f ../kind-config.yaml ]; then
    cluster_name=$(grep -Po '(?<=name: ).*' ../kind-config.yaml | head -1)
    [ -z "$cluster_name" ] && cluster_name="kind"
    printf "${GREEN}Using cluster name: $cluster_name${NC}\n"
  else
    printf "${RED}Error: kind-config.yaml not found!${NC}\n"
    exit 1
  fi
}

remove_cluster() {
  get_cluster_name_from_config
  if kind get clusters | grep -q "$cluster_name"; then
    printf "${YELLOW}Deleting Kind cluster '$cluster_name'...${NC}\n"
    kind delete cluster --name "$cluster_name"
    printf "${GREEN}Kind cluster '$cluster_name' deleted successfully.${NC}\n"
  else
    printf "${YELLOW}Cluster '$cluster_name' does not exist. Skipping deletion.${NC}\n"
  fi
}

# Execute cluster removal
printf "\n${CYAN}Starting kind cluster removal...${NC}\n"
remove_cluster
printf "${CYAN}Kind cluster removal completed.${NC}\n\n"
