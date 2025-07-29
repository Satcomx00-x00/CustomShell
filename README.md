# CustomShell

CustomShell provides a modern configuration for Zsh, Powerlevel10k, and tmux, optimized for development on Linux and macOS.  
It includes themes, plugins, aliases, and an enhanced terminal experience (RAM, load, IP display, etc).

## Main Features

- Zsh with Oh My Zsh and many useful plugins
- Modern, purple, ASCII-friendly Powerlevel10k theme
- Advanced tmux configuration with plugin manager
- Handy aliases for git, docker, tmux, and more
- Automatic detection of modern tools (`exa`, `bat`, etc.)
- French locale support (`fr_FR.UTF-8`)

## Quick Install

```bash
git clone https://github.com/Satcomx00-x00/CustomShell
cd CustomShell
./scripts/install.sh
```

> **Tip:** To update the Powerlevel10k configuration after modification:
> ```bash
> ./scripts/update-p10k.sh
> ```

## Uninstall

```bash
./scripts/uninstall.sh
```

## Customization

- Edit files in `config/` to adapt aliases, prompt, or tmux to your needs.
- Restart your terminal or run `exec zsh` to apply changes.

---

License: Apache 2.0
