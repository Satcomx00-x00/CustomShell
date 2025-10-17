# CustomShell

A comprehensive Zsh configuration with Oh My Zsh, Powerlevel10k theme, and 200+ plugins for an enhanced terminal experience.

## Features

- **Zsh Shell**: Modern, powerful shell with advanced features
- **Oh My Zsh**: Framework for managing Zsh configuration
- **Powerlevel10k**: Fast, flexible theme with beautiful prompts
- **Essential Plugins**: Key plugins like zsh-autosuggestions, zsh-syntax-highlighting, fast-syntax-highlighting, zsh-completions, and fzf-tab
- **Custom Configuration**: Pre-configured aliases, functions, and settings for 200+ tools
- **Additional Tools**: Modern replacements like `eza` (ls) and `bat` (cat)

## Installation

### Option 1: Clone and Install

```bash
git clone https://github.com/Satcomx00-x00/CustomShell.git
cd CustomShell
./install.sh
```

### Option 2: Direct Download and Install

```bash
curl -fsSL https://raw.githubusercontent.com/Satcomx00-x00/CustomShell/main/install.sh | bash
```

### Option 3: Install Only Dependencies

If you want to install only the basic dependencies (zsh, git, curl) without the full CustomShell setup:

```bash
./install.sh --deps-only
# or
./install.sh -d
```

This is useful for:
- CI/CD environments
- Manual setup scenarios
- Installing prerequisites before custom configuration

## Command Line Options

```bash
./install.sh [OPTIONS]

Options:
  -d, --deps-only    Install only dependencies (zsh, git, curl)
  -h, --help         Show help message
```

## What Gets Installed

The installation script will:

1. **Backup existing configuration** (if any)
2. **Install prerequisites** (zsh, git, curl)
3. **Install Oh My Zsh** framework
4. **Install Powerlevel10k** theme
5. **Install essential Zsh plugins** (zsh-autosuggestions, zsh-syntax-highlighting, etc.)
6. **Install additional tools** (eza, bat)
7. **Copy configuration files** (.zshrc, .p10k.zsh)
8. **Set Zsh as default shell**

## Included Plugins

The configuration includes essential plugins for:

- **Terminal/Tmux**: Enhanced terminal and tmux session management
- **Docker**: Container development and management
- **Kubernetes**: K8s cluster management and tools
- **Python**: Python development with virtual environments
- **Node.js**: JavaScript/TypeScript development
- **Bun**: Fast JavaScript runtime
- **Git**: Comprehensive Git workflow tools
- **Navigation**: Smart directory jumping and navigation

Plus essential Zsh enhancements:
- Syntax highlighting and auto-suggestions
- Better completions and tab completion
- History management
- Colored man pages

## Configuration Files

- `.oh-my-zsh/.zshrc`: Main Zsh configuration with aliases, functions, and plugin settings
- `.p10k.zsh`: Powerlevel10k theme configuration
- `zsh_plugins_clean.txt`: List of all plugins to install

## Docker Usage

You can also run CustomShell in a Docker container:

```bash
# Build the image
docker build -t customshell .

# Run the container
docker run -it --rm customshell
```

The Docker image includes Kubernetes tools and is based on Debian.

## Post-Installation

After installation:

1. **Log out and back in** or run `exec zsh` to start using Zsh
2. **Customize the prompt** by running `p10k configure`
3. **Explore the features** using the built-in help: `help`

## Available Commands and Aliases

The configuration includes many useful aliases and functions:

- **Navigation**: `..`, `...`, `....`
- **Git**: `gs` (status), `ga` (add), `gc` (commit), `gp` (push), etc.
- **Docker**: `dk` (docker), `dki` (images), `dkc` (compose), etc.
- **System**: `ll` (detailed list), `df` (disk free), `du` (disk usage), etc.
- **Functions**: `mkcd` (mkdir + cd), `extract` (extract archives), `banner` (system info)

Run `help` in the shell for a complete list.

## Troubleshooting

If you encounter issues:

1. Check the backup directory created during installation
2. Restore from backup if needed: `cp ~/.zsh_backup_*/.zshrc.backup ~/.zshrc`
3. Run `p10k configure` to reconfigure the prompt
4. Check plugin compatibility if some features don't work

## Requirements

- Unix-like operating system (Linux, macOS)
- Package manager (apt, yum, dnf, pacman, or brew)
- Internet connection for downloading components

## License

This project is open source. Feel free to modify and distribute.