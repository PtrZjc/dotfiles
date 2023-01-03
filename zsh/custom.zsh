export REPO="${HOME}/workspace"

alias rst="source $HOME/.zshrc"

alias co=tldr $1
alias cof='declare -f $1'

alias -g H='| head'
alias -g T='| tail'

function wiremock(){
    cd ~/workspace/hub-mocks && sh launch-wiremock.sh
}

function add_to_zsh(){
    echo "$1" >> ~/workspace/0_other/dotfiles/zsh/custom.zsh
}

function goto(){
    DESTINATION=$(find . -type d | fzf)
    if [ "$DESTINATION" = "" ]; then
       echo "Empty destination"
    else
       cd "$DESTINATION"
    fi
}

#from awesome-fzf
function feval(){ 
    echo | fzf -q "$*" --preview-window=up:99% --preview="eval {q}"
}
