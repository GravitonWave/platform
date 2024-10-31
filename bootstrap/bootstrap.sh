#!/bin/bash

# Function to show help
show_help() {
  echo "Usage: $0 {create|add|install|destroy|remove|uninstall|help}"
  echo ""
  echo "Options:"
  echo "  create, add, install       Create or recreate a Kind cluster"
  echo "  destroy, remove, uninstall Remove the Kind cluster defined in the config file"
  echo "  help                       Show this help message"
  exit 1
}

# Check for arguments
if [ $# -eq 0 ]; then
  show_help
fi

cd scripts
case "$1" in
  create | add | install)
    ./install_tools.sh
    ./pre-config.sh
    ./init_kind.sh
    ./install_k8s_core_services.sh
    ./post-config.sh
    ;;
  destroy | remove | uninstall)
    ./remove_kind.sh
    ;;
  help)
    show_help
    ;;
  *)
    echo "Invalid option: $1"
    show_help
    ;;
esac
