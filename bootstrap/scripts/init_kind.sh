#!/bin/bash

source ./scripts/helper_functions.sh

install_kind() {
  if command_exists kind; then
    echo "Kind is already installed, skipping installation."
    return
  fi

  echo "Installing Kind without root permission..."
  KIND_INSTALL_DIR="$HOME/.local/bin"
  mkdir -p "$KIND_INSTALL_DIR"

  if [ $(uname -m) = "x86_64" ]; then
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
  elif [ $(uname -m) = "aarch64" ]; then
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-arm64
  else
    echo "Unsupported architecture. Only x86_64 and aarch64 are supported."
    exit 1
  fi

  chmod +x ./kind
  mv ./kind "$KIND_INSTALL_DIR/kind"

  if ! echo "$PATH" | grep -q "$KIND_INSTALL_DIR"; then
    echo "Adding $KIND_INSTALL_DIR to your PATH in .bashrc"
    echo "export PATH=\$PATH:$KIND_INSTALL_DIR" >> "$HOME/.bashrc"
    export PATH=$PATH:$KIND_INSTALL_DIR
  fi
}

create_kind_cluster() {
  get_cluster_name_from_config

  if ! kind get clusters | grep -q "$cluster_name"; then
    kind create cluster --config kind-config.yaml
  else
    read -p "Cluster exists. Recreate? (y/n): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      kind delete cluster --name "$cluster_name"
      kind create cluster --config kind-config.yaml
    fi
  fi
}

install_kind
create_kind_cluster
