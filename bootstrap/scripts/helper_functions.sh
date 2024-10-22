#!/bin/bash

# Function to get the cluster name from kind configuration.
get_cluster_name_from_config() {
  if [ -f ./kind-config.yaml ]; then
    cluster_name=$(grep -Po '(?<=name: ).*' kind-config.yaml | head -1)
    [ -z "$cluster_name" ] && cluster_name="kind"
  else
    echo "kind-config.yaml not found!"
    exit 1
  fi
}

# Function to detect the package manager
detect_package_manager() {
  if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt-get"
    PACKAGE_UPDATE="sudo apt-get update -qq"
    INSTALL_CMD="sudo apt-get install -y -qq"
  elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    PACKAGE_UPDATE="sudo dnf check-update -q || true"
    INSTALL_CMD="sudo dnf install -y -q"
  elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    PACKAGE_UPDATE="sudo yum check-update -q || true"
    INSTALL_CMD="sudo yum install -y -q"
  elif command -v zypper &> /dev/null; then
    PKG_MANAGER="zypper"
    PACKAGE_UPDATE="sudo zypper refresh -q"
    INSTALL_CMD="sudo zypper install -y -q"
  else
    echo "Error: Unsupported Linux distribution or package manager."
    exit 1
  fi
}

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}
