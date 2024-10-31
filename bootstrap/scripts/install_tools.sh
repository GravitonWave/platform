#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

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
    printf "${RED}Error: Unsupported Linux distribution or package manager.${NC}\n"
    exit 1
  fi
}

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Function to prompt for installation and install if confirmed
prompt_and_install() {
  local tool_name="$1"
  local install_cmd="$2"

  if command_exists "$tool_name"; then
    printf "${GREEN}$tool_name is already installed. Skipping installation.${NC}\n"
    return 0
  fi

  read -p "$tool_name not found. Would you like to install it? (y/n): " response
  if [[ "$response" == "y" || "$response" == "Y" ]]; then
    printf "${CYAN}Installing $tool_name...${NC}\n"
    eval "$install_cmd"

    # Check if the installation was successful
    if command_exists "$tool_name"; then
      printf "${GREEN}$tool_name has been successfully installed.${NC}\n"
    else
      printf "${RED}Failed to install $tool_name.${NC}\n"
    fi
  else
    printf "${YELLOW}$tool_name will not be installed.${NC}\n"
  fi
}

# Function to install ArgoCD CLI with user prompt
install_argocd_cli() {
  if command_exists argocd; then
    printf "${GREEN}ArgoCD CLI is already installed. Skipping installation.${NC}\n"
    return
  fi

  read -p "ArgoCD CLI not found. Would you like to install it? (y/n): " response
  if [[ "$response" == "y" || "$response" == "Y" ]]; then
    printf "${CYAN}Installing ArgoCD CLI manually...${NC}\n"
    ARGOCD_VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    ARGOCD_INSTALL_DIR="$HOME/.local/bin"
    mkdir -p "$ARGOCD_INSTALL_DIR"

    curl -sSL -o "$ARGOCD_INSTALL_DIR/argocd" "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-amd64"
    
    chmod +x "$ARGOCD_INSTALL_DIR/argocd"

    # Check if ARGOCD_INSTALL_DIR is in PATH
    if ! echo "$PATH" | grep -q "$ARGOCD_INSTALL_DIR"; then
      printf "${YELLOW}Adding $ARGOCD_INSTALL_DIR to your PATH in .bashrc${NC}\n"
      echo "export PATH=\$PATH:$ARGOCD_INSTALL_DIR" >> "$HOME/.bashrc"
      export PATH="$PATH:$ARGOCD_INSTALL_DIR"
    fi

    printf "${GREEN}ArgoCD CLI installed successfully. You may need to restart your terminal or run 'source ~/.bashrc' to update your PATH.${NC}\n"
  else
    printf "${YELLOW}ArgoCD CLI will not be installed.${NC}\n"
  fi
}

# Function to install Helm
install_helm() {
  prompt_and_install "helm" "$PACKAGE_UPDATE && $INSTALL_CMD helm"
}

# Function to install kubectl
install_kubectl() {
  prompt_and_install "kubectl" "$PACKAGE_UPDATE && $INSTALL_CMD kubectl"
}

# Function to install jq
install_jq() {
  prompt_and_install "jq" "$PACKAGE_UPDATE && $INSTALL_CMD jq"
}

# Main script execution
detect_package_manager

# Ensure each installation is only prompted once
printf "\n${CYAN}Starting tools installation...${NC}\n"
install_jq
install_argocd_cli
install_helm
install_kubectl
printf "${CYAN}Tools installation completed.${NC}\n\n"
