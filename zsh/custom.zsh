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
