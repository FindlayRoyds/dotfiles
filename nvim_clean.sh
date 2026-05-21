#!/usr/bin/env bash
set -e

echo "Removing installed nvim packages..."
rm -rf ~/.local/share/nvim/site/pack/core/opt/

echo "Removing pack lock file..."
rm -f "$(dirname "$0")/nvim/.config/nvim/nvim-pack-lock.json"

echo "Done."
