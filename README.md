# CustomShell - Enhanced Zsh Configuration

This repository contains a comprehensive Zsh configuration with Oh My Zsh, custom aliases, functions, and dependency management.

## Features

- **Modern Tools Integration**: Conditional aliases for exa, bat, and other modern CLI tools
- **Dependency Management**: Automatic installation of optional tools via the install script
- **Tmux Integration**: Smart session management with aliases
- **Docker Support**: Convenient aliases for container management
- **Git Workflow**: Extensive git aliases for efficient version control
- **System Monitoring**: Enhanced system information display with banner
- **Python Development**: Aliases for Python and pip operations

## Installation Scripts

### Bash Install Script (Linux/macOS)
```bash
./install.sh
```

### PowerShell Install Script (Cross-platform)
```powershell
# Windows PowerShell
.\install.ps1

# PowerShell Core (cross-platform)
pwsh -ExecutionPolicy Bypass -File install.ps1

# With options
.\install.ps1 -Force -SkipConfirmation
```

The PowerShell script supports:
- **Cross-platform**: Windows, Linux, and macOS
- **Automatic detection**: Platform and architecture detection
- **PATH management**: Automatically adds tools to system PATH on Windows
- **Confirmation prompts**: Optional skip with `-SkipConfirmation`
- **Force reinstall**: Use `-Force` to reinstall existing tools

## Included Tools and Aliases

### Modern CLI Tools
- **exa**: Modern replacement for `ls` (aliases: `ls`, `ll`, `la`, `l`, `lt`)
- **bat**: Modern replacement for `cat` (alias: `cat`)

### Development Tools
- **Git**: Comprehensive aliases (`gs`, `ga`, `gc`, `gp`, `gl`, etc.)
- **Docker**: Container management (`dk`, `dkc`, `dki`, `dkr`, etc.)
- **Python**: Package management (`py3`, `pipi`, `pipu`, etc.)

### System Tools
- **Tmux**: Session management (`tmux`, `tma`, `tms`, `tx`, etc.)
- **System Monitoring**: Enhanced commands (`top` → `htop`, `df -h`, etc.)

### Custom Functions
- `mkcd`: Create directory and cd into it
- `extract`: Extract various archive formats
- `tmux-start`: Smart tmux session starter
- `banner`: Display system information on shell start

## Configuration Structure

The `.zshrc` is organized into:
- **Utility Functions**: Package manager detection, dependency installation
- **Alias Setup Functions**: Modular alias definitions
- **Custom Functions**: Enhanced shell operations
- **Environment Setup**: Development tool configurations
- **Plugin Configurations**: Oh My Zsh plugin settings
- **Welcome Banner**: System information display

## Customization

Edit the alias functions in `.oh-my-zsh/.zshrc` to add or modify aliases. The modular structure makes it easy to enable/disable specific tool integrations.

## Requirements

- Zsh shell
- Oh My Zsh
- Supported package manager (apt, brew, yum, dnf, pacman)

## Docker Environment

A Dockerfile is provided to create a containerized environment with all Kubernetes tools pre-installed.

### Build and Run

```bash
# Build the image
docker build -t k8s-tools .

# Run the container
docker run -it --rm k8s-tools

# Run with kubeconfig mounted
docker run -it --rm -v ~/.kube:/root/.kube k8s-tools
```

### Included Tools

The Docker image includes:

- **kubectl**: Kubernetes CLI
- **talosctl**: Talos OS management
- **helm**: Kubernetes package manager
- **k9s**: Terminal UI for Kubernetes
- **kubectx/kubens**: Context and namespace switching
- **stern**: Multi-pod log tailing
- **kustomize**: Kubernetes manifest customization
- **flux**: GitOps continuous delivery
- **argocd**: GitOps continuous delivery
- **velero**: Kubernetes backup/restore
- **kubeconform**: Kubernetes manifest validation
- **kubeseal**: Sealed Secrets CLI
- **krew**: kubectl plugin manager with plugins (ctx, ns, view-secret, get-all, tree)

Plus bash completion and useful aliases for common kubectl commands.