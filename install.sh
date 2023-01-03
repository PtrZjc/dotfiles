#!/bin/sh
# run this script from repo directory, so pwd works correctly

# make link to brewfile
export HOMEBREW_BUNDLE_FILE=$(pwd)/brew/Brewfile
brew bundle

## oh-my-zsh

sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

### symlinks to dotfiles
ln -s $(pwd)/zsh/.zshrc ~/.zshrc
ln -s $(pwd)/zsh/git.zsh $ZSH/custom/git.zsh

# z plugin for oh-my-zsh
curl https://raw.githubusercontent.com/agkozak/zsh-z/master/zsh-z.plugin.zsh --output $ZSH/custom/plugins/zsh-z.plugin.zsh

#zsh theme
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# zsh plugin git-open
git clone https://github.com/paulirish/git-open.git $ZSH_CUSTOM/plugins/git-open

# zsh plugin k
git clone https://github.com/supercrabtree/k $ZSH_CUSTOM/plugins/k

# zsh/fzf History Search plugin https://github.com/joshskidmore/zsh-fzf-history-search
FZF_HISTORY_FOLDER=$ZSH/custom/plugins/zsh-fzf-history-search
mkdir $FZF_HISTORY_FOLDER
curl https://raw.githubusercontent.com/joshskidmore/zsh-fzf-history-search/master/zsh-fzf-history-search.zsh --output $FZF_HISTORY_FOLDER/zsh-fzf-history-search.zsh
curl https://raw.githubusercontent.com/joshskidmore/zsh-fzf-history-search/master/zsh-fzf-history-search.plugin.zsh --output $FZF_HISTORY_FOLDER/zsh-fzf-history-search.plugin.zsh
