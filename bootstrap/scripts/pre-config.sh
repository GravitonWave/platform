#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

# Variables for SSH key path and configuration
SSH_KEY_PATH="../ssh/sshkey"
SSH_CONFIG_FILE="$HOME/.ssh/config"
SSH_KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts"
GITEA_HOSTNAME="gitea.172.18.255.1.nip.io"  # Replace with the actual server domain or IP
SSH_KEY_COMMENT="bootstrap-key"  # Unique identifier for this SSH key

generate_ssh_keypair() {
    printf "${BLUE}===== Generating SSH Key Pair =====${NC}\n"
    printf "${YELLOW}Ensuring SSH key directory exists...${NC}\n"
    mkdir -p ../ssh

    # Generate the SSH key pair with a custom comment
    printf "${YELLOW}Generating SSH key pair with comment '${SSH_KEY_COMMENT}'...${NC}\n"
    ssh-keygen -t rsa -f "$SSH_KEY_PATH" -C "$SSH_KEY_COMMENT" -q -N "" <<<y >/dev/null

    printf "${GREEN}SSH key pair generated successfully.${NC}\n\n"
}

update_ssh_config() {
    printf "${BLUE}===== Configuring SSH for Gitea Access =====${NC}\n"
    mkdir -p "$HOME/.ssh"

    # Update SSH configuration entry for the specific host
    SSH_CONFIG_ENTRY="# Configuration for Gitea access in Kind bootstrap environment
Host gitea.172.18.255.1.nip.io
    HostName gitea.172.18.255.1.nip.io
    User git
    IdentityFile $(realpath $SSH_KEY_PATH)
    IdentitiesOnly yes"

    # Ensure idempotency by removing existing entries for this host
    sed -i.bak "/Host gitea.172.18.255.1.nip.io/,+4d" "$SSH_CONFIG_FILE"
    
    # Append the updated configuration
    printf "${YELLOW}Adding SSH configuration for host 'gitea.172.18.255.1.nip.io'...${NC}\n"
    echo -e "\n$SSH_CONFIG_ENTRY" >> "$SSH_CONFIG_FILE"
    printf "${GREEN}SSH configuration added for host 'gitea.172.18.255.1.nip.io'.${NC}\n\n"
}



update_known_hosts() {
    printf "${BLUE}===== Updating SSH Known Hosts =====${NC}\n"

    # Use ssh-keygen -R to remove the old host entry for both hashed and unhashed entries
    printf "${YELLOW}Removing existing known host entry for $GITEA_HOSTNAME...${NC}\n"
    ssh-keygen -R "$GITEA_HOSTNAME" -f "$SSH_KNOWN_HOSTS_FILE" >/dev/null 2>&1

    # Add the correct host key to known_hosts
    printf "${YELLOW}Adding updated host key for $GITEA_HOSTNAME to known hosts...${NC}\n"
    ssh-keyscan -H "$GITEA_HOSTNAME" >> "$SSH_KNOWN_HOSTS_FILE" 2>/dev/null
    printf "${GREEN}Known hosts updated with the correct key for $GITEA_HOSTNAME.${NC}\n\n"
}

configure_argocd() {
    printf "${BLUE}===== Configuring ArgoCD with SSH Key =====${NC}\n"
    printf "${YELLOW}Ensuring ArgoCD configuration directory exists...${NC}\n"
    mkdir -p ../k8s_base/argocd

    printf "${YELLOW}Copying SSH private key to ArgoCD configuration...${NC}\n"
    cp "$SSH_KEY_PATH" ../k8s_base/argocd/sshPrivateKey
    printf "${GREEN}ArgoCD configured with SSH private key successfully.${NC}\n"
}

# Execute functions
printf "${CYAN}Starting pre-install configuration...${NC}\n"
generate_ssh_keypair
update_ssh_config
update_known_hosts
configure_argocd
printf "${CYAN}Pre-install configuration completed successfully.${NC}\n\n"
