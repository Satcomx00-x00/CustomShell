# Custom Starship Zsh Shell

Custom Starship Zsh Shell provides a modern, professional configuration for Zsh with Starship prompt, oh-my-zsh, and useful plugins. It features the Dracula theme for a sleek, dark terminal experience optimized for development on Linux.

## Main Features

- Zsh with Oh My Zsh and essential plugins (autosuggestions, syntax highlighting, completions)
- Starship prompt with Dracula theme
- Professional installer script for Linux
- Docker container based on Debian:latest
- Custom aliases and functions
- Optimized for development workflows

## Installation

### Linux Installer

1. Clone the repository:
   ```bash
   git clone https://github.com/Satcomx00-x00/CustomShell.git
   cd CustomShell
   ```

2. Run the installer:
   ```bash
   ./install.sh
   ```

   **Options:**
   - `--no-plugins`: Skip installation of Zsh plugins (zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions)
   - `--help`, `-h`: Show help message

   **Examples:**
   ```bash
   ./install.sh                    # Install everything (default)
   ./install.sh --no-plugins       # Install without plugins
   ./install.sh --help             # Show help
   ```

3. Restart your terminal or run `exec zsh` to apply changes.

### Docker Container

1. Build the container:
   ```bash
   docker build -t custom-starship-zsh .
   ```

2. Run the container:
   ```bash
   docker run -it --rm custom-starship-zsh
   ```

   Or with volume mounting for persistent data:
   ```bash
   docker run -it --rm -v $(pwd):/workspace custom-starship-zsh
   ```

3. Using Docker Compose (recommended):
   ```bash
   docker-compose up --build
   ```

## Configuration

- **Starship config**: `~/.config/starship/starship.toml`
- **Zsh config**: `~/.zshrc`
- **Oh My Zsh**: `~/.oh-my-zsh/`

## Customization

- Edit `~/.config/starship/starship.toml` to modify the Starship prompt
- Add custom aliases or functions to `~/.zshrc`
- Install additional plugins in `~/.oh-my-zsh/custom/plugins/`

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
