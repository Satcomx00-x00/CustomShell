# CustomShell - Enhanced Zsh with Starship Prompt

This repository provides a complete Zsh shell configuration with Oh My Zsh framework, Starship prompt, and essential development tools.

## Features

- **Zsh Shell**: Modern shell with powerful scripting capabilities
- **Oh My Zsh**: Framework with hundreds of plugins and themes
- **Starship Prompt**: Fast, customizable cross-shell prompt
- **OS Detection**: Banner shows your Linux distribution (Debian, Ubuntu, Alpine, etc.)
- **Enhanced Tools**: Modern replacements for common commands
- **Development Tools**: Git, Docker, Python, and more
- **Smart Aliases**: Shortcuts for common operations

## Quick Start

### Automatic Installation

```bash
# Clone the repository
git clone https://github.com/Satcomx00-x00/CustomShell.git
cd CustomShell

# Run the installer (installs zsh, oh-my-zsh, starship, and tools)
./install.sh
```

### Manual Installation

If you prefer manual setup:

```bash
# Install zsh and essential tools
sudo apt update && sudo apt install -y zsh curl wget git

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Install starship
curl -sS https://starship.rs/install.sh | sh

# Copy configuration
cp .oh-my-zsh/.zshrc ~/.zshrc
cp -r .config/starship ~/.config/

# Set zsh as default shell
chsh -s $(which zsh)
```

## What's Included

### Core Components
- **Zsh**: The Z shell
- **Oh My Zsh**: Plugin framework with 300+ plugins
- **Starship**: Cross-shell prompt written in Rust

### Enhanced Commands
- `eza` → Modern `ls` replacement
- `bat` → Modern `cat` replacement with syntax highlighting
- `tmux` → Terminal multiplexer with smart session management

### Development Tools
- **Git**: Version control with enhanced aliases
- **Docker**: Container runtime with convenience aliases
- **Python**: Interpreter and pip with virtualenv support
- **Node.js**: JavaScript runtime with nvm support

### Aliases and Functions

#### Git Aliases
- `gs` → `git status`
- `ga` → `git add`
- `gc` → `git commit -m`
- `gp` → `git push`
- `gpl` → `git pull`

#### Docker Aliases
- `dk` → `docker`
- `dkc` → `docker-compose`
- `dki` → `docker images`
- `dkr` → `docker run`
- `dkp` → `docker ps`

#### Distrobox Aliases (if installed)
- `db` → `distrobox`
- `dbc` → `distrobox create`
- `dbe` → `distrobox enter`
- `dbl` → `distrobox list`

#### Utility Functions
- `mkcd <dir>` → Create directory and cd into it
- `extract <file>` → Extract various archive formats
- `tmux-smart` → Interactive tmux session manager
- `banner` → Display system information banner

## Configuration

### Starship Prompt

The starship configuration is located in `.config/starship/starship.toml`. Customize it to your liking:

```toml
# Example customizations
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"

[git_branch]
symbol = "🌱 "
```

### Zsh Configuration

The main configuration is in `.oh-my-zsh/.zshrc`. Key features:

- **OS Detection**: Banner shows your Linux distribution
- **Plugin System**: Modular loading of aliases and functions
- **Smart Completion**: Enhanced tab completion
- **History Management**: Improved command history

## OS Support

The banner automatically detects and displays:
- Debian, Ubuntu, Alpine Linux
- Arch Linux, Manjaro
- Fedora, CentOS, Rocky Linux
- SUSE/openSUSE
- And many more...

## Requirements

- Linux distribution (Ubuntu, Debian, Arch, Fedora, etc.)
- Internet connection for installation
- sudo access for package installation

## Troubleshooting

### Starship icons not showing
Install a Nerd Font:
```bash
# Download and install a Nerd Font
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip
unzip FiraCode.zip -d ~/.fonts
fc-cache -fv
```

### Permission issues
If you get permission errors during installation:
```bash
# Run with sudo
sudo ./install.sh
```

### Zsh not available after installation
```bash
# Set zsh as default shell
chsh -s $(which zsh)

# Then log out and back in, or run:
zsh
```

## Contributing

Feel free to submit issues and pull requests to improve the configuration.

## License

This project is open source and available under the MIT License.