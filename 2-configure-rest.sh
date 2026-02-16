#!/bin/bash
set -e

DOTFILES_DIR=$(cd -- $(dirname -- ${BASH_SOURCE[0]}) &>/dev/null && pwd)

# OS detection
IS_MACOS=$([[ "$OSTYPE" == "darwin"* ]] && echo true || echo false)
IS_LINUX=$([[ "$OSTYPE" == "linux"* ]] && echo true || echo false)

# Helper: create symlink with status feedback
create_symlink() {
    local src="$1"
    local dest="$2"

    if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
        echo "  [skip] $dest (already linked)"
    else
        ln -sf "$src" "$dest"
        echo "  [link] $dest -> $src"
    fi
}

# Helper: clone git repo if not exists, or update if exists
clone_or_update() {
    local repo="$1"
    local dest="$2"
    local name=$(basename "$dest")

    if [ -d "$dest" ]; then
        echo "  [skip] $name (already installed)"
    else
        echo "  [install] $name"
        git clone --depth=1 "$repo" "$dest"
    fi
}

######################
# PACKAGE INSTALLATION
######################

if $IS_MACOS; then
    echo "Detected macOS - installing Homebrew packages..."

    # install homebrew if not present
    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    export HOMEBREW_BUNDLE_FILE="${DOTFILES_DIR}/brew/Brewfile"
    echo 'Installing brew packages...'
    brew bundle
elif $IS_LINUX; then
    echo "Detected Linux - installing packages..."
    "${DOTFILES_DIR}/linux/packages.sh"
else
    echo "Unknown OS: $OSTYPE"
    echo "Skipping package installation..."
fi

######################
# FONT CONFIGURATION #
######################

if $IS_MACOS; then
    FONT_DIR="$HOME/Library/Fonts"
else
    FONT_DIR="$HOME/.local/share/fonts"
fi

mkdir -p "$FONT_DIR"

# Check if fonts are already installed
FONTS_INSTALLED=true
if ! ls "$FONT_DIR"/JetBrainsMonoNerdFont*.ttf &>/dev/null; then
    FONTS_INSTALLED=false
fi
if ! ls "$FONT_DIR"/MesloLGSNerdFont*.ttf &>/dev/null; then
    FONTS_INSTALLED=false
fi

if $FONTS_INSTALLED; then
    echo "Fonts already installed in $FONT_DIR, skipping..."
else
    echo "Installing fonts to $FONT_DIR..."
    curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip --output /tmp/font-jb.zip
    curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip --output /tmp/font-meslo.zip
    unzip -o /tmp/font-jb.zip -d /tmp/font-jb
    unzip -o /tmp/font-meslo.zip -d /tmp/font-meslo
    mv /tmp/font-jb/*.ttf "$FONT_DIR/" 2>/dev/null || true
    mv /tmp/font-meslo/MesloLGSNerdFont-*.ttf "$FONT_DIR/" 2>/dev/null || true
    rm -rf /tmp/font-jb /tmp/font-meslo /tmp/font-jb.zip /tmp/font-meslo.zip

    # Rebuild font cache on Linux
    if $IS_LINUX; then
        fc-cache -fv
    fi
fi

######################
# NVIM CONFIGURATION #
######################

echo 'Configuring nvim...'
mkdir -p "${HOME}/.config/nvim"
create_symlink "${DOTFILES_DIR}/nvim/init.lua" "$HOME/.config/nvim/init.lua"

#####################
# ZSH CONFIGURATION #
#####################

echo 'Configuring zsh...'

# Ensure ZSH_CUSTOM is set
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

## symlinks to dotfiles
create_symlink "${DOTFILES_DIR}/zsh/.zshrc" "$HOME/.zshrc"

for zsh_file in "${DOTFILES_DIR}/zsh"/*.zsh; do
    create_symlink "$zsh_file" "$ZSH_CUSTOM/$(basename "$zsh_file")"
done

# git
create_symlink "${DOTFILES_DIR}/other/.gitconfig" "$HOME/.gitconfig"

# powerlevel10k theme
create_symlink "${DOTFILES_DIR}/other/.p10k.zsh" "$HOME/.p10k.zsh"

# wezterm
mkdir -p "${HOME}/.config/wezterm"
create_symlink "${DOTFILES_DIR}/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

# github copilot
mkdir -p "$HOME/.config/github-copilot/intellij"
create_symlink "$DOTFILES_DIR/ai/copilot/mcp.json" "$HOME/.config/github-copilot/intellij/mcp.json"
create_symlink "$DOTFILES_DIR/ai/copilot/global-copilot-instructions.md" "$HOME/.config/github-copilot/intellij/global-copilot-instructions.md"

######################
# ZSH PLUGINS        #
######################

echo 'Installing zsh plugins...'

# theme
clone_or_update "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k"

# zsh-autosuggestions
clone_or_update "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# syntax highlighting
clone_or_update "https://github.com/z-shell/F-Sy-H.git" "$ZSH_CUSTOM/plugins/F-Sy-H"

# fzf-tab
clone_or_update "https://github.com/Aloxaf/fzf-tab" "$ZSH_CUSTOM/plugins/fzf-tab"

# atuin
if command -v atuin &>/dev/null; then
    echo "  [skip] atuin (already installed)"
else
    echo "  [install] atuin"
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
fi
mkdir -p "$HOME/.config/atuin"
create_symlink "$DOTFILES_DIR/other/atuin/config.toml" "$HOME/.config/atuin/config.toml"

echo ''
echo 'Done! Restart your shell or run: exec zsh'
