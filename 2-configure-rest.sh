#!/bin/sh
DOTFILES_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )

######################
# FONT CONFIGURATION #
######################

mkdir -p ~/.local/share/fonts

# Download JetBrains Mono font
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip --output /tmp/JetBrainsMono.zip
unzip /tmp/JetBrainsMono.zip -d /tmp/font
mv /tmp/font/*JetBrainsMono*.ttf ~/.local/share/fonts/

# Download Meslo font
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip --output /tmp/Meslo.zip
unzip /tmp/Meslo.zip -d /tmp/font
mv /tmp/font/*Meslo*.ttf ~/.local/share/fonts/

# Refresh the font cache
fc-cache -fv

#####################
# ZSH CONFIGURATION #
#####################

echo 'configuring zsh'

# symlinks to dotfiles
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

# z plugin 
curl https://raw.githubusercontent.com/agkozak/zsh-z/master/zsh-z.plugin.zsh --output "$ZSH/custom/plugins/zsh-z.plugin.zsh"

# theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

# fzf-tab
git clone https://github.com/Aloxaf/fzf-tab "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fzf-tab"

# zsh/fzf History Search plugin https://github.com/joshskidmore/zsh-fzf-history-search
FZF_HISTORY_FOLDER="$ZSH/custom/plugins/zsh-fzf-history-search"
mkdir "$FZF_HISTORY_FOLDER"
curl https://raw.githubusercontent.com/joshskidmore/zsh-fzf-history-search/master/zsh-fzf-history-search.zsh --output "$FZF_HISTORY_FOLDER/zsh-fzf-history-search.zsh"
curl https://raw.githubusercontent.com/joshskidmore/zsh-fzf-history-search/master/zsh-fzf-history-search.plugin.zsh --output "$FZF_HISTORY_FOLDER/zsh-fzf-history-search.plugin.zsh"
