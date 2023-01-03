
export REPO="${HOME}/workspace"
export CUSTOM="${REPO}/0_others/dotfiles/zsh/custom.zsh"
export ZSHRC="${REPO}/0_others/dotfiles/zsh/.zshrc"
export BREWFILE="${REPO}/0_others/dotfiles/brew/Brewfile"

alias rst="exec zsh"

alias ocustom='vim $CUSTOM'
alias obrew='vim $BREWFILE'

alias co=tldr
alias a='alias'
alias cof='declare -f'
alias icat='imgcat'
alias ipaste='pngpaste'
alias t='tree -C -L'
alias reset='clear && printf "\e[3J"'
alias ocr='tesseract'

alias -g H='| head'
alias -g T='| tail'
alias -g C='| cat'
alias ls='ls -lahgG'
# alias l='ls -1G'
alias l='tree -C -L 1'

alias ij="/Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea"

alias ke-p='dbxcli put ~/Keepas_globalny.kdbx "Aplikacje/KeePass 2.x"'
alias ke-l='dbxcli get "Aplikacje/KeePass 2.x" Keepas_globalny.kdbx'

function wiremock(){
    cd ~/workspace/hub-mocks && sh launch-wiremock.sh
}

function preserve_custom(){
    echo "\n$1" >> "${CUSTOM}"
}

function goto(){
    DESTINATION=$(fd -t d | fzf)
    if [ "$DESTINATION" = "" ]; then
       echo "Empty destination" || exit 2
    else
       cd "./$DESTINATION"
    fi
}

#from awesome-fzf
function feval(){ 
    echo | fzf -q "$*" --preview-window=up:99% --preview="eval {q}"
}

alias repo="cd $REPO"
