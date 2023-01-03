
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
alias cls='clear && printf "\e[3J"'
alias ocr='tesseract'
alias ch='cls && cht.sh'

alias -g H='| head'
alias -g L='| less'
alias -g JL='| jq -C | less'
alias -g T='| tail'
alias -g C='| cat'
alias -g DF='-u | diff-so-fancy'
alias ls='ls -lahgG'
# alias l='ls -1G'
alias l='tree -C -L 1'

alias ij="/Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea ."

alias ke-p='dbxcli put ~/Keepas_globalny.kdbx "Aplikacje/KeePass 2.x"'
alias ke-l='dbxcli get "Aplikacje/KeePass 2.x" ~/Keepas_globalny.kdbx'

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


alias alf="cd $REPO/adjuster-of-logistics-fee"
alias bb="cd $REPO/broker-billing"
alias alffe="cd $REPO/cbs-billing-fee-adjustment"
alias hades="cd $REPO/hub-additional-delivery-expenses"
alias hdsps="cd $REPO/hub-delivery-seller-price-source"
alias heops="cd $REPO/hub-external-order-processor-service"
alias hipcio="cd $REPO/hub-invoice-pricing-configurator"
alias hip="cd $REPO/hub-invoice-processor"
alias hmh="cd $REPO/hub-mail-hasher"
alias hplf="cd $REPO/hub-price-list-facade"
alias hspc="cd $REPO/hub-seller-pricing-configurator"

#!/bin/bash

function op() {
    command=$1
    repo_name=$(pwd | rev | cut -d / -f1 | rev)
    allowed_repos=$(\ls -1 $REPO | rg --invert-match "(_|\.)")

    if [[ $(echo $allowed_repos | rg "\b$repo_name\b") == "" ]]; then
        echo "wrong folder"
        exit 2
    fi

    if [[ $command == "apc" ]]; then
        open "https://console.appengine.allegrogroup.com/info/pl.allegro.logistics.delivery.$repo_name"
    else
        echo "command not found"
    fi
}
