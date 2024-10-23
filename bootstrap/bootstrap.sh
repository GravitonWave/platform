#!/bin/bash

# Source helper functions
source ./scripts/helper_functions.sh

# Function to show help
show_help() {
  echo "Usage: $0 {create|remove|help}"
  echo ""
  echo "Options:"
  echo "  create   Create or recreate a Kind cluster"
  echo "  remove   Remove the Kind cluster defined in the config file"
  echo "  help     Show this help message"
  exit 1
}

# Check for arguments
if [ $# -eq 0 ]; then
  show_help
fi

# Handle arguments for create, and remove
case "$1" in
  create)
    ./scripts/init_kind.sh
    cd scripts
    ./install_k8s_core_services.sh
    ;;
  remove)
    ./scripts/remove_kind.sh
    ;;
  help)
    show_help
    ;;
  *)
    echo "Invalid option: $1"
    show_help
    ;;
esac
