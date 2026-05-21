#!/usr/bin/env bash
set -e

echo "Checking Homebrew installation..."
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    
    # NONINTERACTIVE=1 prevents the script from pausing to prompt for Enter
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # 2. Add brew to the current session's PATH so subsequent commands work
    OS="$(uname -s)"
    ARCH="$(uname -m)"
    
    if [ "$OS" = "Linux" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    elif [ "$OS" = "Darwin" ]; then
        if [ "$ARCH" = "arm64" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)" # Apple Silicon
        else
            eval "$(/usr/local/bin/brew shellenv)"    # Intel Mac
        fi
    fi
    echo "Homebrew installed successfully."
else
    echo "Homebrew is already installed."
fi

echo "Installing dependencies from Brewfile..."
cd "$(dirname "$0")" # Ensure we are in the directory containing the Brewfile
brew bundle # brew bundle automatically skips packages that are already installed

echo "Setup complete."
