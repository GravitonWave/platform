# Kind Cluster Bootstrap Script

This script bootstraps a **Kind** (Kubernetes in Docker) cluster, which can be used to host Kubernetes-based infrastructure tools. It is designed to configure a local Kubernetes environment that can be used to create and manage local or cloud resources.

## Purpose

The primary goal of this script is to help users set up a Kind cluster for use with Kubernetes infrastructure management tools. The Kind cluster can be used to deploy and manage tools such as CI/CD pipelines, monitoring systems, local development environments, or any Kubernetes-based infrastructure.

## Folder Structure

```
BOOTSTRAP/
  ├── base/
  │     ├── argo-cd/
  │     ├── crossplane/
  │     ├── gitea/
  │     └── metallb/
  │           ├── addresspool.yaml
  │           └── values.yaml
  ├── bootstrap.sh
  ├── get_helm.sh
  ├── kind-config.yaml
  ├── scripts/
  │     ├── helper_functions.sh
  │     ├── init_kind.sh
  │     ├── remove_kind.sh
  │     └── install_k8s_core_services.sh
  └── README.md
```

## Script Descriptions

- **bootstrap.sh**: The main entry point for managing the Kind cluster. Supports the following commands:
  - `create`: Create or recreate the Kind cluster based on the `kind-config.yaml` file.
  - `remove`: Remove the existing Kind cluster.
  - `help`: Display usage information.

- **get_helm.sh**: A script to install Helm, which is used for managing Kubernetes packages.

- **kind-config.yaml**: The configuration file for the Kind cluster, defining cluster settings such as networking and node configurations.

- **scripts/helper_functions.sh**: Contains shared functions that are used across multiple scripts, such as package manager detection and command existence checks.

- **scripts/init_kind.sh**: Initializes the Kind cluster. It installs dependencies, installs Kind, and creates the cluster as defined in `kind-config.yaml`.

- **scripts/remove_kind.sh**: Removes an existing Kind cluster based on the configuration in `kind-config.yaml`.

- **scripts/install_k8s_core_services.sh**: A placeholder script for installing and configuring Kubernetes core services, such as Helm, Ingress controllers, and other components.

## Prerequisites

Before executing this script, ensure that the following prerequisites are met:

- Docker installed and running.
- Your local user has access to the Docker daemon (without requiring `sudo`):
  - You can add your user to the Docker group with the following command:
    ```bash
    sudo usermod -aG docker $USER
    ```
  - After running this command, **log out and log back in** or reboot the system for the changes to take effect.

## Compatible Linux Distributions

The script has been tested on and is compatible with the following Linux distributions:

- **Ubuntu** 18.04/20.04/22.04
- **Debian** 10/11
- **Fedora** 33/34/35
- **CentOS** 7/8
- **RHEL** 7/8
- **openSUSE** Leap 15.x

## Usage

To get started, navigate to the `BOOTSTRAP` directory and run the `bootstrap.sh` script.

### Create the Kind Cluster

```sh
./bootstrap.sh create
```

This command will:
1. Ensure required dependencies are installed.
2. Install Kind if it's not already installed.
3. Create a Kubernetes Kind cluster based on `kind-config.yaml`.

### Remove the Kind Cluster

```sh
./bootstrap.sh remove
```

This command will remove the Kind cluster as defined in the `kind-config.yaml` file.

### Help

To display help information:

```sh
./bootstrap.sh help
```

## Installing Helm

To install Helm, run the provided script:

```sh
./get_helm.sh
```

This will install Helm version 3, which is required for managing Kubernetes packages.

## Customizing the Setup

- **Kind Configuration**: Modify `kind-config.yaml` to customize the Kind cluster (e.g., node count, cluster name, networking settings).
- **Kubernetes Core Services**: Update `scripts/install_k8s_core_services.sh` to add your desired Kubernetes components, such as ingress controllers, monitoring tools, or other resources.
- **Additional Configurations**: The `base/` directory contains configurations for additional tools (e.g., Argo CD, Crossplane, Gitea, MetalLB). Modify or extend these configurations to suit your requirements.

## Notes

- Ensure that your `$HOME/.local/bin` directory is in your `PATH` if installing Kind without root access. This script will attempt to add it if it's not already there.
- After modifying `.bashrc`, make sure to run `source ~/.bashrc` to apply the changes.

## Troubleshooting

- **Permission Denied**: If you encounter permission errors, ensure that the scripts have executable permissions. You can make them executable by running:
  ```sh
  chmod +x bootstrap.sh scripts/*.sh get_helm.sh
  ```
- **Docker Not Running**: The scripts require Docker to be running. Make sure Docker is installed and the daemon is running.

## License

This project is licensed under the MIT License.
