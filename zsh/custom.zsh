
export REPO="${HOME}/workspace"
export CUSTOM="${REPO}/0_others/dotfiles/zsh/custom.zsh"
export ZSHRC="${REPO}/0_others/dotfiles/zsh/.zshrc"

alias rst="exec zsh"

alias co=tldr
alias cof='declare -f'

alias -g H='| head'
alias -g T='| tail'

alias ij="/Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea"

function wiremock(){
    cd ~/workspace/hub-mocks && sh launch-wiremock.sh
}

function preserve_custom(){
    echo "\n$1" >> "${CUSTOM}"
}

function goto(){
    DESTINATION=$(find . -type d | fzf)
    if [ "$DESTINATION" = "" ]; then
       echo "Empty destination"
    else
       cd "$DESTINATION" || exit
    fi
}

#from awesome-fzf
function feval(){ 
    echo | fzf -q "$*" --preview-window=up:99% --preview="eval {q}"
}

alias repo="cd $REPO"
