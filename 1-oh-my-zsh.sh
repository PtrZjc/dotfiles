#!/bin/sh

# Install zsh if not present (Linux)
if ! command -v zsh >/dev/null 2>&1; then
    echo "zsh not found, installing..."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y zsh
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y zsh
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y zsh
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm zsh
    else
        echo "Could not detect package manager. Please install zsh manually."
        exit 1
    fi
fi

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
