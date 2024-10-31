#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Function to retrieve the cluster name from the Kind configuration file
get_cluster_name_from_config() {
  if [ -f ../kind-config.yaml ]; then
    cluster_name=$(grep -Po '(?<=name: ).*' ../kind-config.yaml | head -1)
    [ -z "$cluster_name" ] && cluster_name="kind"
    printf "${GREEN}Using cluster name: $cluster_name${NC}\n"
  else
    printf "${RED}Error: ../kind-config.yaml not found!${NC}\n"
    exit 1
  fi
}

install_kind() {
  printf "${BLUE}===== Kind Installation =====${NC}\n"
  if command_exists kind; then
    printf "${GREEN}Kind is already installed. Skipping installation.${NC}\n"
  else
    printf "${YELLOW}Installing Kind without root permissions...${NC}\n"
    KIND_INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$KIND_INSTALL_DIR"

    # Determine architecture and download the appropriate binary
    if [ "$(uname -m)" = "x86_64" ]; then
      curl -Lo "$KIND_INSTALL_DIR/kind" https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
    elif [ "$(uname -m)" = "aarch64" ]; then
      curl -Lo "$KIND_INSTALL_DIR/kind" https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-arm64
    else
      printf "${RED}Error: Unsupported architecture. Only x86_64 and aarch64 are supported.${NC}\n"
      exit 1
    fi

    chmod +x "$KIND_INSTALL_DIR/kind"
    printf "${GREEN}Kind binary downloaded and set as executable.${NC}\n"

    # Add KIND_INSTALL_DIR to PATH if not already present
    if ! echo "$PATH" | grep -q "$KIND_INSTALL_DIR"; then
      printf "${YELLOW}Adding $KIND_INSTALL_DIR to PATH in .bashrc...${NC}\n"
      echo "export PATH=\$PATH:$KIND_INSTALL_DIR" >> "$HOME/.bashrc"
      export PATH="$PATH:$KIND_INSTALL_DIR"
      printf "${GREEN}Kind installed successfully. You may need to restart your terminal or run 'source ~/.bashrc' to update your PATH.${NC}\n"
    fi
  fi
  printf "\n"
}

create_kind_cluster() {
  printf "${BLUE}===== Bootstrap Cluster Setup =====${NC}\n"
  # Retrieve cluster name from configuration
  get_cluster_name_from_config

  # Check if the cluster already exists
  if kind get clusters | grep -q "$cluster_name"; then
    printf "${YELLOW}Cluster '$cluster_name' already exists.${NC}\n"
    read -p "Do you want to recreate it? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      printf "${YELLOW}Deleting existing Kind cluster '$cluster_name'...${NC}\n"
      kind delete cluster --name "$cluster_name"
      printf "${YELLOW}Creating a new Kind cluster named '$cluster_name'...${NC}\n"
      kind create cluster --config ../kind-config.yaml
      printf "${GREEN}Kind cluster '$cluster_name' recreated successfully.${NC}\n"
    else
      printf "${YELLOW}Skipping cluster recreation.${NC}\n"
    fi
  else
    printf "${YELLOW}Creating a new Kind cluster named '$cluster_name'...${NC}\n"
    kind create cluster --config ../kind-config.yaml
    printf "${GREEN}Kind cluster '$cluster_name' created successfully.${NC}\n"
  fi
}

# Main execution flow
printf "${CYAN}Starting Kind installation...${NC}\n"
install_kind
create_kind_cluster
printf "${CYAN}Kind setup completed.${NC}\n\n"
