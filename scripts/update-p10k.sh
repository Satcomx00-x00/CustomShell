#!/bin/bash

set -e

P10K_SRC="$(dirname "$0")/../config/.p10k.zsh"
P10K_DEST="$HOME/.p10k.zsh"

if [[ ! -f "$P10K_SRC" ]]; then
    echo "Source .p10k.zsh not found at $P10K_SRC"
    exit 1
fi

if [[ -f "$P10K_DEST" ]]; then
    cp "$P10K_DEST" "$P10K_DEST.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backed up existing .p10k.zsh to $P10K_DEST.backup.*"
fi

cp "$P10K_SRC" "$P10K_DEST"
echo "Updated $P10K_DEST with the latest .p10k.zsh"


exec zsh

