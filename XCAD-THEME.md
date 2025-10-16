# XCAD Shell Theme

A custom shell color scheme featuring a purple/blue gradient aesthetic with high contrast and modern styling.

## Color Palette

- **Background**: `#1A1A1A` - Deep charcoal
- **Foreground**: `#F1F1F1` - Bright white
- **Cursor**: `#FFFFFF` - Pure white

### Standard Colors
- Black: `#121212` / Bright: `#666666`
- Red: `#A52AFF` / Bright: `#BA5AFF` (Purple-tinted)
- Green: `#7129FF` / Bright: `#905AFF` (Purple-tinted)
- Yellow: `#3D2AFF` / Bright: `#685AFF` (Blue-tinted)
- Blue: `#2B4FFF` / Bright: `#5C78FF`
- Purple: `#2883FF` / Bright: `#5EA2FF`
- Cyan: `#28B9FF` / Bright: `#5AC8FF`
- White: `#F1F1F1` / Bright: `#FFFFFF`

## Installation

### Quick Setup
```bash
chmod +x setup-xcad-theme.sh
./setup-xcad-theme.sh
```

### Manual Setup

#### Starship Prompt
```bash
cp .config/starship/starship-xcad.toml ~/.config/starship/starship.toml
```

#### VS Code
Add to your `settings.json`:
```json
{
  "workbench.colorCustomizations": {
    "terminal.background": "#1A1A1A",
    "terminal.foreground": "#F1F1F1",
    "terminal.ansiBlack": "#121212",
    "terminal.ansiRed": "#A52AFF",
    "terminal.ansiGreen": "#7129FF",
    "terminal.ansiYellow": "#3D2AFF",
    "terminal.ansiBlue": "#2B4FFF",
    "terminal.ansiMagenta": "#2883FF",
    "terminal.ansiCyan": "#28B9FF",
    "terminal.ansiWhite": "#F1F1F1",
    "terminal.ansiBrightBlack": "#666666",
    "terminal.ansiBrightRed": "#BA5AFF",
    "terminal.ansiBrightGreen": "#905AFF",
    "terminal.ansiBrightYellow": "#685AFF",
    "terminal.ansiBrightBlue": "#5C78FF",
    "terminal.ansiBrightMagenta": "#5EA2FF",
    "terminal.ansiBrightCyan": "#5AC8FF",
    "terminal.ansiBrightWhite": "#FFFFFF"
  }
}
```

#### Windows Terminal
1. Open Windows Terminal Settings (Ctrl+,)
2. Click "Open JSON file"
3. Add the color scheme from `.config/terminal-colors/xcad-windows-terminal.json` to the `schemes` array

#### Alacritty
```bash
cp .config/terminal-colors/xcad-alacritty.yml ~/.config/alacritty/
```

Then in your `~/.config/alacritty/alacritty.yml`, add:
```yaml
import:
  - ~/.config/alacritty/xcad-alacritty.yml
```

#### X Terminal (xterm, urxvt, etc.)
```bash
xrdb -merge .config/terminal-colors/xcad.Xresources
```

Add to `~/.xinitrc` or `~/.xprofile` to apply on login:
```bash
xrdb -merge ~/.config/terminal-colors/xcad.Xresources
```

## Files Included

- `.config/terminal-colors/xcad.json` - Generic JSON format
- `.config/terminal-colors/xcad-windows-terminal.json` - Windows Terminal format
- `.config/terminal-colors/xcad.Xresources` - X Resources format
- `.config/terminal-colors/xcad-alacritty.yml` - Alacritty format
- `.config/starship/starship-xcad.toml` - Starship prompt configuration
- `setup-xcad-theme.sh` - Automated setup script

## Features

- **High Contrast**: Excellent readability with #F1F1F1 text on #1A1A1A background
- **Purple/Blue Gradient**: Unique color scheme with purple-tinted reds and greens
- **Starship Integration**: Custom Starship configuration with matching gradient segments
- **Wide Compatibility**: Support for VS Code, Windows Terminal, Alacritty, and X terminals

## Preview

The Starship prompt features a beautiful gradient from bright blue (#5C78FF) through blue (#2B4FFF), cyan (#2883FF), purple (#7129FF), to magenta (#A52AFF), creating a cohesive visual experience that matches the terminal colors.

## Customization

Feel free to modify the colors in any of the configuration files to suit your preferences. The color values are clearly documented in each file.

## License

Free to use and modify as needed.
