#!/bin/bash
# Quick Apply XCAD Theme
# This script quickly applies the XCAD color scheme to your current session

# Apply to Starship if available
if command -v starship &> /dev/null; then
    export STARSHIP_CONFIG="/workspaces/CustomShell/.config/starship/starship-xcad.toml"
    echo "✓ Starship XCAD theme loaded"
fi

# Source the updated shell config if it exists
if [ -f "/workspaces/CustomShell/.oh-my-zsh/.zshrc" ]; then
    source /workspaces/CustomShell/.oh-my-zsh/.zshrc
    echo "✓ Shell configuration reloaded"
fi

echo ""
echo "🎨 XCAD theme applied to current session!"
echo ""
echo "To make this permanent, run:"
echo "  ./setup-xcad-theme.sh"
echo ""
echo "To preview colors, run:"
echo "  ./preview-colors.sh"
