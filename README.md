# Talos Kubernetes Admin Container

This repository provides a Docker container with all essential tools for administering Talos OS Kubernetes clusters.

## Features

- **Talos OS Management**: Complete talosctl installation for cluster operations
- **Kubernetes CLI**: kubectl with bash completion and aliases
- **Package Management**: Helm for deploying applications
- **Terminal UI**: k9s for interactive Kubernetes management
- **Context Switching**: kubectx and kubens for easy cluster/namespace switching
- **Log Tailing**: stern for multi-pod log streaming
- **Enhanced Prompt**: kube-ps1 for Kubernetes-aware shell prompt
- **Useful Aliases**: Shortcuts for common kubectl operations

## Docker Container

### Create Persistent Volumes

```bash
# Create named volumes for persistent storage
docker volume create talos-kubeconfig
docker volume create talos-config
```

### Build the Image

```bash
docker build -t talos-admin .
```

### Run the Container

```bash
# Run with persistent named volumes
docker run -it --rm \
  -v talos-kubeconfig:/root/.kube \
  -v talos-config:/root/.talos \
  talos-admin

# Or with bind mounts to host directories (for local development)
docker run -it --rm \
  -v ~/.kube:/root/.kube \
  -v ~/.talos:/root/.talos \
  talos-admin
```

### Managing Volumes

```bash
# List volumes
docker volume ls

# Inspect volume contents
docker run --rm -v talos-kubeconfig:/data alpine ls -la /data

# Copy files to/from volumes
docker run --rm -v talos-kubeconfig:/data -v $(pwd):/host alpine cp /host/config /data/

# Remove volumes when no longer needed
docker volume rm talos-kubeconfig talos-config
```

### Included Tools

- **talosctl**: Talos OS cluster management
- **kubectl**: Kubernetes command-line tool
- **helm**: Kubernetes package manager
- **k9s**: Terminal-based UI for Kubernetes
- **kubectx**: Switch between Kubernetes contexts
- **kubens**: Switch between Kubernetes namespaces
- **stern**: Multi-pod log tailing
- **kube-ps1**: Kubernetes-aware shell prompt

### Useful Aliases

- `k` → `kubectl`
- `kg` → `kubectl get`
- `kgp` → `kubectl get pods`
- `kgn` → `kubectl get nodes`
- `kgs` → `kubectl get svc`
- `kga` → `kubectl get all`
- `kd` → `kubectl describe`
- `kl` → `kubectl logs`
- `ke` → `kubectl exec -it`
- `kx` → `kubectx`
- `kn` → `kubens`
- `ks` → `stern`

## Usage Examples

### Talos Operations
```bash
# Check cluster health
talosctl health

# Get cluster info
talosctl cluster info

# Access Talos dashboard
talosctl dashboard
```

### Kubernetes Operations
```bash
# Get cluster status
kubectl cluster-info

# List nodes
kubectl get nodes

# Use k9s for interactive management
k9s
```

### Context Management
```bash
# List available contexts
kubectx

# Switch context
kubectx my-cluster

# List namespaces
kubens

# Switch namespace
kubens kube-system
```

## Configuration

Mount your local configuration directories to persist settings:

- `~/.kube`: Kubernetes configuration
- `~/.talos`: Talos configuration

The container includes bash completion for all tools and an enhanced prompt showing the current Kubernetes context.