# Bootstrap Project

This project provides a streamlined setup for initializing a Kubernetes environment using [Kind](https://kind.sigs.k8s.io/) and installing essential tools and services. The setup includes core services like ArgoCD, Gitea, and MetalLB, with automation for configuration and management tasks.

## Project Structure

- `k8s_base/`: Contains Kubernetes manifests for deploying essential services.
  - `argocd/`: Manifests for deploying ArgoCD, a continuous delivery tool for Kubernetes.
  - `crossplane/`: Manifests for deploying Crossplane, a Kubernetes-based control plane.
  - `gitea/`: Manifests for deploying Gitea, a lightweight Git service.
  - `ingress-nginx/`: Manifests for deploying the NGINX Ingress Controller.
  - `metallb/`: Manifests for deploying MetalLB, a load-balancer for bare metal clusters.

- `scripts/`: Shell scripts to automate various setup and teardown tasks.
  - `install_tools.sh`: Installs necessary tools on the local machine (e.g., Helm, kubectl, jq).
  - `pre-config.sh`: Pre-configuration script for generating SSH keys and setting up necessary configurations.
  - `init_kind.sh`: Initializes the Kind cluster using the provided configuration.
  - `install_k8s_core_services.sh`: Installs core services in the Kind cluster (e.g., ArgoCD, Gitea, MetalLB).
  - `post-config.sh`: Post-configuration script for tasks like updating ArgoCD and Gitea configurations.
  - `remove_kind.sh`: Destroys the Kind cluster and removes related configurations.

- `ssh/`: Contains SSH keys used for authentication with Gitea.
  - `sshkey`: Private SSH key for accessing Gitea.
  - `sshkey.pub`: Public SSH key for accessing Gitea.

- `bootstrap.sh`: Main script to manage the Kind cluster setup and teardown.
- `kind-config.yaml`: Configuration file for initializing the Kind cluster.

## Getting Started

### Prerequisites

Ensure the following tools are installed on your system:
- [Docker](https://docs.docker.com/get-docker/): Required for Kind to run Kubernetes clusters.
- [jq](https://stedolan.github.io/jq/): Required for JSON parsing.
- [kubectl](https://kubernetes.io/docs/tasks/tools/): CLI for interacting with Kubernetes clusters.
- [Helm](https://helm.sh/): Package manager for Kubernetes.

These tools can be installed using the `install_tools.sh` script, which will prompt you for installation if they are not found.

### Usage

The main `bootstrap.sh` script supports the following commands:

```bash
./bootstrap.sh {create|add|install|destroy|remove|uninstall|help}
```

- **create, add, install**: Creates or recreates a Kind cluster and installs core services.
- **destroy, remove, uninstall**: Removes the Kind cluster and cleans up configurations.
- **help**: Displays usage information.

### Example Commands

1. **Initialize the Kind Cluster**:
   ```bash
   ./bootstrap.sh create
   ```

2. **Remove the Kind Cluster**:
   ```bash
   ./bootstrap.sh destroy
   ```

### Script Descriptions

1. **install_tools.sh**: Installs essential tools such as `kubectl`, `jq`, and `Helm`. If any of these tools are missing, the script will prompt you to install them.
   
2. **pre-config.sh**: Prepares the environment by generating SSH keys, configuring Gitea SSH settings, and creating a bootstrap repository in Gitea if it doesn't exist. It also updates the ArgoCD admin password.

3. **init_kind.sh**: Initializes the Kind cluster using the configuration provided in `kind-config.yaml`.

4. **install_k8s_core_services.sh**: Deploys core services like ArgoCD, Gitea, and MetalLB in the Kind cluster.

5. **post-config.sh**: Updates ArgoCD and Gitea configurations with new SSH keys or repository settings.

6. **remove_kind.sh**: Destroys the Kind cluster, removes configurations, and performs clean-up tasks.

## Access and Authentication

- **Gitea**: The Gitea service is accessible at [https://gitea.172.18.255.1.nip.io](https://gitea.172.18.255.1.nip.io). The default admin user is `gitea_admin`, and the default password is `bootstrap`.
- **ArgoCD**: The ArgoCD service is accessible at [https://argocd.172.18.255.1.nip.io](https://argocd.172.18.255.1.nip.io). The default admin user is `admin`, and the default password is `bootstrap`.
- **SSH Keys**: The SSH keys used for internal access to Gitea are automatically generated and configured during the setup process. Since these are internal keys, they need to be accepted when prompted.

## SSH Key Management

The `ssh/` directory contains the SSH keys used for authentication with Gitea. The `pre-config.sh` script generates these keys if they do not already exist and adds them to Gitea automatically. If an existing key with the same title is found, it will be deleted and replaced with the newly generated key.

## Networking

To configure the network for the Kind cluster and MetalLB, it is important to align the IP ranges between the Docker bridge network and the Kubernetes services.

### Inspecting the Kind Network

Kind uses Docker to create a bridge network for managing container communications. To determine the subnet used by Kind, you can inspect the Docker network with the following command:

```bash
docker network inspect kind
```

This command will output information about the `kind` network, including the subnet and gateway, similar to the following:

```json
{
    "Subnet": "172.18.0.0/16",
    "Gateway": "172.18.0.1"
}
```

The `Subnet` value (`172.18.0.0/16` in this example) represents the IP range used by the Kind network. It is important that the IP addresses used by MetalLB for load balancing fall within this range.

### Configuring MetalLB

In the `k8s_base/metallb/ip_address_pool.yaml` file, set the `addresses` field to a range within the Kind network subnet. For example:

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default
  namespace: metallb-system
spec:
  addresses:
  - 172.18.255.1-172.18.255.250
```

This configuration ensures that the IP addresses assigned by MetalLB for load balancing are within the same subnet as the Kind network.

### Configuring Ingress Endpoints

The Gitea and ArgoCD services are exposed using IP addresses from the MetalLB pool. To access these services, the endpoints are configured using [nip.io](https://nip.io), which provides wildcard DNS for any IP address.

- **Gitea**: [https://gitea.172.18.255.1.nip.io](https://gitea.172.18.255.1.nip.io)
- **ArgoCD**: [https://argocd.172.18.255.1.nip.io](https://argocd.172.18.255.1.nip.io)

These endpoints allow you to easily access the services using the IP addresses assigned by MetalLB, without the need for additional DNS configuration.

## Troubleshooting

- If you encounter issues with `curl` commands failing in the scripts, ensure the provided Gitea credentials are correct and the Gitea server is reachable.
- Use `GIT_SSH_COMMAND="ssh -v"` with Git commands for verbose SSH output if there are issues with SSH key authentication.
- The `pre-config.sh` script includes error handling for operations like updating SSH keys and creating repositories in Gitea. If any of these steps fail, the script will output an error message with the HTTP status code and exit.

## License

This project is licensed under the MIT License.
