#!/bin/bash
DOTFILES_DIR=$(cd -- $(dirname -- ${BASH_SOURCE[0]}) &>/dev/null && pwd)

# OS detection
IS_MACOS=$([[ "$OSTYPE" == "darwin"* ]] && echo true || echo false)
IS_LINUX=$([[ "$OSTYPE" == "linux"* ]] && echo true || echo false)

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

echo "Installing fonts to $FONT_DIR..."
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip --output /tmp/font-jb.zip
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip --output /tmp/font-meslo.zip
unzip -o /tmp/font-jb.zip -d /tmp/font-jb
unzip -o /tmp/font-meslo.zip -d /tmp/font-meslo
mv /tmp/font-jb/*.ttf "$FONT_DIR/" 2>/dev/null || true
mv /tmp/font-meslo/MesloLGSNerdFont-*.ttf "$FONT_DIR/" 2>/dev/null || true

# Rebuild font cache on Linux
if $IS_LINUX; then
    fc-cache -fv
fi

######################
# NVIM CONFIGURATION #
######################

echo 'Configuring nvim...'
mkdir -p "${HOME}/.config/nvim"
ln -sf "${DOTFILES_DIR}/nvim/init.lua" "$HOME/.config/nvim/init.lua"

#####################
# ZSH CONFIGURATION #
#####################

echo 'Configuring zsh...'

## symlinks to dotfiles
ln -sf "${DOTFILES_DIR}/zsh/.zshrc" ~/.zshrc

find "${DOTFILES_DIR}/zsh" \
    -name '*.zsh' \
    -exec sh -c 'ln -sf "$1" "$ZSH/custom/$(basename $1)"' _ {} \;

# git
ln -sf "${DOTFILES_DIR}/other/.gitconfig" "$HOME/.gitconfig"

# powerlevel10k theme
ln -sf "${DOTFILES_DIR}/other/.p10k.zsh" "$HOME/.p10k.zsh"

# wezterm
mkdir -p "${HOME}/.config/wezterm"
ln -sf "${DOTFILES_DIR}/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

# github copilot
mkdir -p "$HOME/.config/github-copilot/intellij"
ln -sf "$DOTFILES_DIR/ai/copilot/mcp.json" "$HOME/.config/github-copilot/intellij/mcp.json"
ln -sf "$DOTFILES_DIR/ai/copilot/global-copilot-instructions.md" "$HOME/.config/github-copilot/intellij/global-copilot-instructions.md"

######################
# ZSH PLUGINS        #
######################

echo 'Installing zsh plugins...'

# theme
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
fi

# zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
fi

# syntax highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/F-Sy-H" ]; then
    git clone https://github.com/z-shell/F-Sy-H.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/F-Sy-H"
fi

# fzf-tab
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab" ]; then
    git clone https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"
fi

# zsh-histdb
if [ ! -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-histdb" ]; then
    git clone https://github.com/larkery/zsh-histdb "${HOME}/.oh-my-zsh/custom/plugins/zsh-histdb"
fi

# zsh/fzf History Search plugin
FZF_HISTORY_FOLDER="$ZSH/custom/plugins/zsh-fzf-history-search"
if [ ! -d "$FZF_HISTORY_FOLDER" ]; then
    mkdir -p "$FZF_HISTORY_FOLDER"
    curl https://raw.githubusercontent.com/joshskidmore/zsh-fzf-history-search/master/zsh-fzf-history-search.zsh --output "$FZF_HISTORY_FOLDER/zsh-fzf-history-search.zsh"
    curl https://raw.githubusercontent.com/joshskidmore/zsh-fzf-history-search/master/zsh-fzf-history-search.plugin.zsh --output "$FZF_HISTORY_FOLDER/zsh-fzf-history-search.plugin.zsh"
fi

echo 'Done! Restart your shell or run: exec zsh'
