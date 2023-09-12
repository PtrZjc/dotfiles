#!/bin/sh
DOTFILES_DIR=$( cd -- $( dirname -- ${BASH_SOURCE[0]} ) &> /dev/null && pwd )

# make link to brewfile required by `brew bundle``
export HOMEBREW_BUNDLE_FILE="${DOTFILES_DIR}/brew/Brewfile"

echo 'installing brew packages'
brew bundle

#####################
# FONT CONFIGURATION #
#####################

curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip --output /tmp/font.zip
curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip --output /tmp/font.zip
unzip /tmp/font.zip -d /tmp/font
cp tmp/font/MesloLGSNerdFont-*.ttf "${HOME}Library/Fonts"

######################
# NVIM CONFIGURATION #
######################

echo 'configuring nvim'

git clone https://github.com/NvChad/NvChad "${HOME}/.config/nvim" --depth 1
mkdir -p "${HOME}/.config/nvim/lua/custom/configs"

ln -sf "${DOTFILES_DIR}/nvim/chadrc.lua" "$HOME/.config/nvim/lua/custom/chadrc.lua"
ln -s "${DOTFILES_DIR}/nvim/plugins.lua" "$HOME/.config/nvim/lua/custom/plugins.lua"
ln -s "${DOTFILES_DIR}/nvim/init.lua" "$HOME/.config/nvim/lua/custom/init.lua"
ln -s "${DOTFILES_DIR}/nvim/configs/lspconfig.lua" "$HOME/.config/nvim/lua/custom/configs/lspconfig.lua"
ln -s "${DOTFILES_DIR}/nvim/configs/null-ls.lua" "$HOME/.config/nvim/lua/custom/configs/null-ls.lua"

#####################
# ZSH CONFIGURATION #
#####################

echo 'configuring zsh'

# symlinks to dotfiles
ln -sf "${DOTFILES_DIR}/zsh/.zshrc" ~/.zshrc
ln -s "${DOTFILES_DIR}/zsh/git.zsh" "$ZSH/custom/git.zsh"
ln -s "${DOTFILES_DIR}/zsh/custom.zsh" "$ZSH/custom/custom.zsh"
ln -s "${DOTFILES_DIR}/zsh/db-credentials.zsh" "$ZSH/custom/db-credentials.zsh"

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

echo "do not forget to deregister finder from opt+cmd+space! (show iterm2 hotkey)"
