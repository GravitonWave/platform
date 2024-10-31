#!/bin/bash

# Define color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

# Define necessary variables
GITEA_USER="gitea_admin"
GITEA_PASS="bootstrap"
GITEA_BASE_URL="https://gitea.172.18.255.1.nip.io/api/v1"
KEY_TITLE="Bootstrap Environment Key"
PUBLIC_KEY=$(< ../ssh/sshkey.pub) # Ensure the public key is generated before running

# Check for jq command
if ! command -v jq &> /dev/null; then
    printf "${RED}Error: jq is required but not installed. Please install jq and try again.${NC}\n"
    exit 1
fi

update_gitea_ssh() {
    printf "${BLUE}===== Updating Gitea SSH Key =====${NC}\n"
    printf "${YELLOW}Checking for existing keys with title: $KEY_TITLE...${NC}\n"
    EXISTING_KEY_ID=$(curl -k -s -u "$GITEA_USER:$GITEA_PASS" \
        -H "accept: application/json" \
        "$GITEA_BASE_URL/user/keys" | \
        jq -r ".[] | select(.title == \"$KEY_TITLE\") | .id")

    if [ -n "$EXISTING_KEY_ID" ]; then
        printf "${YELLOW}Existing key found with ID $EXISTING_KEY_ID. Deleting it...${NC}\n"
        DELETE_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -X DELETE \
            -u "$GITEA_USER:$GITEA_PASS" \
            "$GITEA_BASE_URL/user/keys/$EXISTING_KEY_ID")
        if [ "$DELETE_STATUS" -ne 204 ]; then
            printf "${RED}Error: Failed to delete existing key (status code: $DELETE_STATUS).${NC}\n"
            exit 1
        fi
        sleep 2
        printf "${GREEN}Old key deleted successfully.${NC}\n"
    else
        printf "${GREEN}No existing key found with title $KEY_TITLE.${NC}\n"
    fi

    printf "${YELLOW}Creating new SSH key in Gitea...${NC}\n"
    CREATE_KEY_STATUS=$(curl -k -s -o /dev/null -w "%{http_code}" -u "$GITEA_USER:$GITEA_PASS" \
        -H "Content-Type: application/json" \
        -X POST \
        -d "{\"key\": \"$PUBLIC_KEY\", \"title\": \"$KEY_TITLE\"}" \
        "$GITEA_BASE_URL/user/keys")
    if [ "$CREATE_KEY_STATUS" -ne 201 ]; then
        printf "${RED}Error: Failed to create new SSH key (status code: $CREATE_KEY_STATUS).${NC}\n"
        exit 1
    fi
    printf "${GREEN}New SSH key created in Gitea.${NC}\n\n"
}

configure_argocd() {
    printf "${BLUE}===== Configuring ArgoCD =====${NC}\n"
    ARGOCD_PASSWORD=$(argocd account bcrypt --password bootstrap)

    printf "${YELLOW}Updating ArgoCD admin password...${NC}\n"
    kubectl -n argocd patch secret argocd-secret \
        -p "{\"stringData\": {
            \"admin.password\": \"$ARGOCD_PASSWORD\",
            \"admin.passwordMtime\": \"$(date +%FT%T%Z)\"
        }}"
    printf "${GREEN}ArgoCD admin password updated.${NC}\n"
}

create_bootstrap_repo() {
    printf "${BLUE}===== Creating Bootstrap Repository in Gitea =====${NC}\n"
    printf "${YELLOW}Checking if Gitea repository 'bootstrap' exists...${NC}\n"
    REPO_EXISTS=$(curl -s -u "$GITEA_USER:$GITEA_PASS" \
        "$GITEA_BASE_URL/user/repos" | \
        jq -r ".[] | select(.name == \"bootstrap\") | .name")

    if [ -z "$REPO_EXISTS" ]; then
        printf "${YELLOW}Creating Gitea repository 'bootstrap'...${NC}\n"
        CREATE_REPO_STATUS=$(curl -s -k -o /dev/null -w "%{http_code}" -u "$GITEA_USER:$GITEA_PASS" \
            -H "Content-Type: application/json" \
            -X POST \
            -d '{
                "auto_init": true,
                "description": "Bootstrap",
                "name": "bootstrap"
            }' \
            "$GITEA_BASE_URL/user/repos")

        if [ "$CREATE_REPO_STATUS" -ne 201 ]; then
            printf "${RED}Error: Failed to create repository 'bootstrap' (status code: $CREATE_REPO_STATUS).${NC}\n"
            exit 1
        fi
        printf "${GREEN}Repository 'bootstrap' created successfully.${NC}\n"
    else
        printf "${GREEN}Repository 'bootstrap' already exists. Skipping creation.${NC}\n"
    fi
}

# Execute functions
printf "${CYAN}Starting post-install configuration...${NC}\n"
update_gitea_ssh
create_bootstrap_repo
configure_argocd
printf "${CYAN}Post-install configuration completed successfully.${NC}\n\n"
