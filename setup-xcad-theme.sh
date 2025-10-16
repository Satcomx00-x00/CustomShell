#!/bin/bash
# XCAD Color Scheme Setup Script
# This script applies the xcad color scheme to your shell environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

echo "🎨 Setting up XCAD color scheme..."

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR/terminal-colors"

# Copy color scheme files
echo "📁 Copying color scheme files..."
cp -f "$SCRIPT_DIR/.config/terminal-colors/"* "$CONFIG_DIR/terminal-colors/" 2>/dev/null || true

# Setup Starship with xcad theme
if command -v starship &> /dev/null; then
    echo "⭐ Configuring Starship with XCAD theme..."
    mkdir -p "$CONFIG_DIR/starship"
    
    # Backup existing config if it exists
    if [ -f "$CONFIG_DIR/starship/starship.toml" ]; then
        cp "$CONFIG_DIR/starship/starship.toml" "$CONFIG_DIR/starship/starship.toml.backup.$(date +%Y%m%d_%H%M%S)"
        echo "   ✓ Backed up existing Starship config"
    fi
    
    # Copy new xcad-themed config
    cp -f "$SCRIPT_DIR/.config/starship/starship-xcad.toml" "$CONFIG_DIR/starship/starship.toml"
    echo "   ✓ Applied XCAD Starship theme"
else
    echo "⚠️  Starship not found. Skipping Starship configuration."
fi

# Apply Xresources if on X11
if [ -n "$DISPLAY" ]; then
    echo "🖥️  Applying Xresources..."
    if command -v xrdb &> /dev/null; then
        xrdb -merge "$CONFIG_DIR/terminal-colors/xcad.Xresources"
        echo "   ✓ Xresources applied"
    fi
fi

# Instructions for different terminals
echo ""
echo "✅ XCAD color scheme installed!"
echo ""
echo "📋 Next steps for your terminal:"
echo ""
echo "For VS Code:"
echo "  1. Open Settings (Ctrl+,)"
echo "  2. Search for 'terminal.integrated.colorScheme'"
echo "  3. Or manually add to settings.json:"
echo "     \"workbench.colorCustomizations\": {"
echo "       \"terminal.background\": \"#1A1A1A\","
echo "       \"terminal.foreground\": \"#F1F1F1\""
echo "     }"
echo ""
echo "For Windows Terminal:"
echo "  1. Open Settings (Ctrl+,)"
echo "  2. Go to 'Color schemes' → 'Add new'"
echo "  3. Copy content from: $CONFIG_DIR/terminal-colors/xcad-windows-terminal.json"
echo ""
echo "For iTerm2:"
echo "  1. Preferences → Profiles → Colors"
echo "  2. Import the color preset from xcad.json"
echo ""
echo "For Alacritty:"
echo "  Add the colors to ~/.config/alacritty/alacritty.yml"
echo ""
echo "The Starship prompt has been updated to match the XCAD theme!"
echo "Restart your terminal or run: exec \$SHELL"
