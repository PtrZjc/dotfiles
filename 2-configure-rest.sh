#!/bin/sh
DOTFILES_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )

# install homebrew
echo "Installing Homebrew"
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

# make link to brewfile required by `brew bundle``
export HOMEBREW_BUNDLE_FILE="${DOTFILES_DIR}/brew/Brewfile"

echo 'installing brew packages'
brew bundle

######################
# FONT CONFIGURATION #
######################

curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip --output /tmp/font.zip
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip --output /tmp/font.zip
unzip /tmp/font.zip -d /tmp/font
mv /tmp/font/MesloLGSNerdFont-*.ttf "${HOME}/Library/Fonts"

######################
# NVIM CONFIGURATION #
######################

echo 'configuring nvim'

mkdir -p "${HOME}/.config/nvim"

ln -sf "${DOTFILES_DIR}/nvim/init.lua" "$HOME/.config/nvim/init.lua"

#####################
# ZSH CONFIGURATION #
#####################

echo 'configuring zsh'

## symlinks to dotfiles
ln -sf "${DOTFILES_DIR}/zsh/.zshrc" ~/.zshrc

find  "${DOTFILES_DIR}/zsh" \
    -name '*.zsh' \
    -exec sh -c 'ln -s $1 "$ZSH/custom/$(basename $1)"' _ {} \;

# git
ln -sf "${DOTFILES_DIR}/other/.gitconfig" "$HOME/.gitconfig"

# poverlevel10k theme 
ln -sf "${DOTFILES_DIR}/other/.p10k.zsh" "$HOME/.p10k.zsh"

# wezterm
mkdir -p "${HOME}/.config/wezterm"
ln -s "${DOTFILES_DIR}/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"

# github copilot
mkdir -p "$HOME/.config/github-copilot/intellij"
ln -sf "$DOTFILES_DIR/ai/copilot/mcp.json" "$HOME/.config/github-copilot/intellij/mcp.json"
ln -sf "$DOTFILES_DIR/ai/copilot/global-copilot-instructions.md" "$HOME/.config/github-copilot/intellij/global-copilot-instructions.md"

# claude desktop
mkdir -p "$HOME/Library/Application Support/Claude"
ln -sf "$DOTFILES_DIR/ai/claude_desktop_config.json" "$HOME/Library/Application Support/Claude/claude_desktop_config.json"

# theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

# synthax highlighting
git clone https://github.com/z-shell/F-Sy-H.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/F-Sy-H"

# fzf-tab
git clone https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"

# zsh-histdb
git clone https://github.com/larkery/zsh-histdb "${HOME}/.oh-my-zsh/custom/plugins/zsh-histdb"


# zsh/fzf History Search plugin https://github.com/joshskidmore/zsh-fzf-history-search
FZF_HISTORY_FOLDER="$ZSH/custom/plugins/zsh-fzf-history-search"
mkdir "$FZF_HISTORY_FOLDER"
curl https://raw.githubusercontent.com/joshskidmore/zsh-fzf-history-search/master/zsh-fzf-history-search.zsh --output "$FZF_HISTORY_FOLDER/zsh-fzf-history-search.zsh"
curl https://raw.githubusercontent.com/joshskidmore/zsh-fzf-history-search/master/zsh-fzf-history-search.plugin.zsh --output "$FZF_HISTORY_FOLDER/zsh-fzf-history-search.plugin.zsh"
