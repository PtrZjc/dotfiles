#!/bin/sh
DOTFILES_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )

# make link to brewfile required by `brew bundle``
export HOMEBREW_BUNDLE_FILE="${DOTFILES_DIR}/brew/Brewfile"
brew bundle

#####################
# ZSH CONFIGURATION #
#####################

# symlinks to dotfiles
ln -s "${DOTFILES_DIR}/zsh/.zshrc" ~/.zshrc
ln -s "${DOTFILES_DIR}/zsh/git.zsh" "$ZSH/custom/git.zsh"
ln -s "${DOTFILES_DIR}/zsh/custom.zsh" "$ZSH/custom/custom.zsh"

# z plugin 
curl https://raw.githubusercontent.com/agkozak/zsh-z/master/zsh-z.plugin.zsh --output "$ZSH/custom/plugins/zsh-z.plugin.zsh"

# theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"

# fzf-tab
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

# zsh/fzf History Search plugin https://github.com/joshskidmore/zsh-fzf-history-search
FZF_HISTORY_FOLDER="$ZSH/custom/plugins/zsh-fzf-history-search"
mkdir "$FZF_HISTORY_FOLDER"
curl https://raw.githubusercontent.com/joshskidmore/zsh-fzf-history-search/master/zsh-fzf-history-search.zsh --output "$FZF_HISTORY_FOLDER/zsh-fzf-history-search.zsh"
curl https://raw.githubusercontent.com/joshskidmore/zsh-fzf-history-search/master/zsh-fzf-history-search.plugin.zsh --output "$FZF_HISTORY_FOLDER/zsh-fzf-history-search.plugin.zsh"
