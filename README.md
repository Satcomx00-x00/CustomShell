# Custom Starship Zsh Shell

Custom Starship Zsh Shell provides a modern, professional configuration for Zsh with Starship prompt, oh-my-zsh, and useful plugins. It features the Dracula theme for a sleek, dark terminal experience optimized for development on Linux.

## 📁 Project Structure

```
CustomShell/
├── config/           # 📂 Configuration files
│   ├── .zshrc       # Full Zsh configuration
│   ├── .zshrc.minimal # Minimal Zsh configuration
│   └── starship.toml # Starship prompt configuration
├── scripts/          # 🛠️ Installation and utility scripts
│   ├── install.sh   # Main installer
│   ├── install_packages.sh # Multi-distro package installer
│   └── update-zsh.sh # Configuration updater
├── docker/           # Container setup
│   ├── Dockerfile   # Debian-based container
│   └── docker-compose.yml
├── install.sh       # Root-level installer (convenience)
├── README.md
└── LICENSE
```

## ✨ Main Features

- **Multi-Distro Support**: Works on Debian/Ubuntu, RHEL/CentOS/Fedora, Arch, openSUSE, Alpine, Gentoo
- **Zsh with Oh My Zsh**: Essential plugins (autosuggestions, syntax highlighting, completions)
- **Starship Prompt**: Dracula theme with comprehensive tool support
- **Docker Integration**: Container based on Debian:latest
- **Extensive Tool Support**:
  - **Git**: Complete workflow aliases and functions
  - **Python**: Virtual environments, pip, development shortcuts
  - **Docker**: Container lifecycle, compose, cleanup utilities
  - **Kubernetes**: Pod/service/deployment management, context switching
  - **Helm**: Chart management and repository operations
  - **Go**: Build, run, test, module management
  - **Rust**: Cargo operations and project management
- **Terraform**: Infrastructure as code operations
- **Bun**: JavaScript runtime and package management
- **fzf Integration**: Fuzzy finder with syntax highlighting and custom functions
- **Smart Helper Functions**: `pyenv`, `dshell`, `kctx`, `gacp`, `fh`, `fe`, `fd`, etc.
- **Optimized Workflow**: Tailored for Python, Bun, Docker, and Kubernetes development## 🚀 Installation

### Linux Installer

1. Clone the repository:
   ```bash
   git clone https://github.com/Satcomx00-x00/CustomShell.git
   cd CustomShell
   ```

2. Run the installer:
   ```bash
   ./install.sh              # Full installation with plugins
   ./install.sh --no-plugins # Minimal installation
   ```

   **Options:**
   - `--no-plugins`: Skip installation of Zsh plugins (zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions)
   - `--help`, `-h`: Show help message

3. Restart your terminal or run `exec zsh` to apply changes.

### Update Configuration

To update your Zsh configuration without reinstalling everything:
```bash
./scripts/update-zsh.sh          # Update to latest full config
./scripts/update-zsh.sh --minimal # Update to minimal config
./scripts/update-zsh.sh --no-backup # Update without backup
./scripts/update-zsh.sh --help   # Show help
```

### Docker Container

1. Build the container:
   ```bash
   docker build -f docker/Dockerfile -t custom-starship-zsh .
   ```

2. Run the container:
   ```bash
   docker run -it --rm custom-starship-zsh
   ```

3. Using Docker Compose (recommended):
   ```bash
   docker-compose -f docker/docker-compose.yml up --build
   ```

## Configuration

- **Starship config**: `~/.config/starship.toml`
- **Zsh config**: `~/.zshrc`
- **Oh My Zsh**: `~/.oh-my-zsh/`

## Available Aliases & Functions

### Git Aliases
- `gs` - git status
- `ga` - git add
- `gc` - git commit
- `gp` - git push
- `gl` - git log --oneline
- `gd` - git diff
- `gco` - git checkout
- `gb` - git branch
- `gpl` - git pull

### Python Aliases
- `py` - python3
- `pip` - python3 -m pip
- `venv` - python3 -m venv
- `act` - source venv/bin/activate
- `deact` - deactivate

### Docker Aliases
- `d` - docker
- `dc` - docker-compose
- `dcu` - docker-compose up
- `dcd` - docker-compose down
- `dcb` - docker-compose build
- `dcl` - docker-compose logs
- `dps` - docker ps
- `di` - docker images
- `dex` - docker exec -it
- `dlf` - docker logs -f

### Kubernetes Aliases
- `k` - kubectl
- `kg` - kubectl get
- `kgp` - kubectl get pods
- `kgs` - kubectl get services
- `kgd` - kubectl get deployments
- `kga` - kubectl get all
- `kdp` - kubectl describe pod
- `kl` - kubectl logs
- `klf` - kubectl logs -f
- `kex` - kubectl exec -it

### Helper Functions
- `pyenv <name>` - Create and activate Python virtual environment
- `pyact` - Activate existing virtual environment
- `dshell <container>` - Shell into running Docker container
- `dclean` - Clean up Docker resources
- `kctx [context]` - Switch/list Kubernetes contexts
- `kns [namespace]` - Switch/list Kubernetes namespaces
- `klogs <pod> [container]` - View pod logs
- `gacp <message>` - Git add all, commit, push
- `gbranch <name>` - Create and switch to new branch
- `serve [port]` - Start HTTP server (default port 8000)

## 📁 Configuration Files

- **`config/.zshrc`** - Full Zsh configuration with all plugins and aliases
- **`config/.zshrc.minimal`** - Minimal Zsh configuration (used with `--no-plugins`)
- **`config/starship.toml`** - Starship prompt configuration with Dracula theme
- **`scripts/install_packages.sh`** - Multi-distro package installation script
- **`scripts/update-zsh.sh`** - Configuration update utility

## ⚙️ Customization

- **Starship Prompt**: Edit `config/starship.toml` (template) or `~/.config/starship.toml` (installed)
- **Zsh Config**: Modify `config/.zshrc` or `config/.zshrc.minimal` (templates)
- **Add Plugins**: Install to `~/.oh-my-zsh/custom/plugins/`
- **Local Config**: Add customizations to `~/.zshrc.local` (auto-sourced)
- **Update Config**: Use `scripts/update-zsh.sh` to apply changes

## VS Code Settings

For optimal experience in VS Code, add to your settings:

```json
{
  "terminal.integrated.fontFamily": "Fira Code, DroidSansMono Nerd Font, monospace",
  "terminal.integrated.shell.linux": "/bin/zsh"
}
```

## Requirements

- Linux (Debian/Ubuntu, RHEL/CentOS/Fedora, Arch, openSUSE, Alpine, Gentoo)
- curl, wget, git
- Internet connection for downloads
- Supported package managers: apt, dnf, yum, pacman, zypper, apk, emerge

## License

Apache 2.0
