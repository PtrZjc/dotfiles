#!/bin/bash
# Ubuntu/Debian package installation script
# Equivalent to brew/Brewfile for Linux systems

set -e

echo "=== Installing Ubuntu packages ==="

sudo apt update

# Core shell and utilities
echo "Installing core packages..."
sudo apt install -y \
    zsh \
    neovim \
    curl \
    wget \
    git \
    unzip

# Shell enhancements
echo "Installing shell enhancement tools..."
sudo apt install -y \
    fzf \
    ripgrep \
    fd-find \
    jq

# Development tools
echo "Installing development tools..."
sudo apt install -y \
    shellcheck \
    gh \
    libpq-dev

# Data processing
echo "Installing data processing tools..."
sudo apt install -y \
    miller \
    gnuplot \
    python3-pip

# Image processing
echo "Installing image processing tools..."
sudo apt install -y \
    tesseract-ocr \
    tesseract-ocr-eng \
    tesseract-ocr-pol \
    imagemagick

# File management and misc
echo "Installing misc utilities..."
sudo apt install -y \
    qrencode \
    pandoc \
    texlive-latex-base \
    texlive-fonts-recommended

# System monitoring
echo "Installing system monitoring tools..."
sudo apt install -y \
    btop

# Clipboard tools (X11 and Wayland)
echo "Installing clipboard tools..."
sudo apt install -y xclip wl-clipboard

# Create symlinks for differently-named packages (Ubuntu naming quirks)
echo "Creating compatibility symlinks..."
mkdir -p "$HOME/.local/bin"

# fd is named fdfind on Ubuntu
if command -v fdfind &>/dev/null && [ ! -f "$HOME/.local/bin/fd" ]; then
    ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
    echo "  Created fd -> fdfind symlink"
fi

# bat is named batcat on Ubuntu
if command -v batcat &>/dev/null && [ ! -f "$HOME/.local/bin/bat" ]; then
    ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
    echo "  Created bat -> batcat symlink"
fi

echo ""
echo "=== Installing tools not available via apt ==="

# eza (modern ls replacement)
if ! command -v eza &>/dev/null; then
    echo "Installing eza..."
    sudo apt install -y gpg
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg
    sudo apt update && sudo apt install -y eza
else
    echo "eza already installed"
fi

# zoxide (directory jumper)
if ! command -v zoxide &>/dev/null; then
    echo "Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
else
    echo "zoxide already installed"
fi

# bat (if not available via apt)
if ! command -v bat &>/dev/null && ! command -v batcat &>/dev/null; then
    echo "Installing bat..."
    sudo apt install -y bat || {
        # Fallback: download from GitHub releases
        wget -O /tmp/bat.deb "https://github.com/sharkdp/bat/releases/latest/download/bat_0.24.0_amd64.deb"
        sudo dpkg -i /tmp/bat.deb
    }
else
    echo "bat already installed"
fi

# delta (git diff viewer)
if ! command -v delta &>/dev/null; then
    echo "Installing git-delta..."
    wget -O /tmp/delta.deb "https://github.com/dandavison/delta/releases/download/0.16.5/git-delta_0.16.5_amd64.deb"
    sudo dpkg -i /tmp/delta.deb || sudo apt install -f -y
else
    echo "delta already installed"
fi

# sd (sed replacement) - requires cargo
if ! command -v sd &>/dev/null; then
    echo "Installing sd..."
    if command -v cargo &>/dev/null; then
        cargo install sd
    else
        echo "  SKIP: cargo not installed. Install with: sudo apt install cargo && cargo install sd"
    fi
else
    echo "sd already installed"
fi

# NVM (Node Version Manager)
if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
else
    echo "NVM already installed"
fi

# SDKMAN (Java SDK Manager)
if [ ! -d "$HOME/.sdkman" ]; then
    echo "Installing SDKMAN..."
    curl -s "https://get.sdkman.io" | bash
else
    echo "SDKMAN already installed"
fi

# pyenv (Python version manager)
if ! command -v pyenv &>/dev/null && [ ! -d "$HOME/.pyenv" ]; then
    echo "Installing pyenv..."
    # Install pyenv dependencies first
    sudo apt install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
    curl https://pyenv.run | bash
else
    echo "pyenv already installed"
fi

# tldr (simplified man pages)
if ! command -v tldr &>/dev/null; then
    echo "Installing tldr..."
    pip3 install --user tldr
else
    echo "tldr already installed"
fi

# yq (YAML processor)
if ! command -v yq &>/dev/null; then
    echo "Installing yq..."
    pip3 install --user yq
else
    echo "yq already installed"
fi

echo ""
echo "=== Optional: GUI applications ==="
echo "Install these manually if needed:"
echo "  - WezTerm: https://wezfurlong.org/wezterm/install/linux.html"
echo "  - VS Code: https://code.visualstudio.com/docs/setup/linux"
echo "  - KeePassXC: sudo apt install keepassxc"
echo "  - IntelliJ IDEA: sudo snap install intellij-idea-ultimate --classic"
echo ""
echo "=== Done ==="
echo "Make sure ~/.local/bin is in your PATH"
