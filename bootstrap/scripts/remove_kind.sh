#!/bin/bash

source ./scripts/helper_functions.sh

remove_cluster() {
  get_cluster_name_from_config
  if kind get clusters | grep -q "$cluster_name"; then
    kind delete cluster --name "$cluster_name"
  else
    echo "Cluster '$cluster_name' does not exist."
  fi
}

remove_cluster
