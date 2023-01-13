export REPO="${HOME}/workspace"
export CUSTOM="${REPO}/0_others/dotfiles/zsh/custom.zsh"
export ZSHRC="${REPO}/0_others/dotfiles/zsh/.zshrc"
export GIT="${REPO}/0_others/dotfiles/zsh/git.zsh"
export BREWFILE="${REPO}/0_others/dotfiles/brew/Brewfile"

alias rst="exec zsh"

alias ocustom='code $CUSTOM'
alias obrew='code $BREWFILE'
alias ogit='code $GIT'

alias co=tldr
alias a='alias'
alias cof='declare -f'
alias icat='imgcat'
alias ipaste='pngpaste'
alias t='tree -C -L'
alias cls='clear && printf "\e[3J"'
# alias ocr='tesseract'
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

function wiremock() {
    cd $REPO/hub-mocks && sh launch-wiremock.sh
}

function line() {
    head -$1 | tail -1
}

function goto() {
    DESTINATION=$(fd -t d | fzf)
    if [ "$DESTINATION" = "" ]; then
        echo "Empty destination" || exit 2
    else
        cd "./$DESTINATION"
    fi
}

function ocr() {
    ipaste - > ~/ocr_temp.jpg
    tesseract ~/ocr_temp.jpg stdout | pbcopy
    rm ~/ocr_temp.jpg
    pbpaste
}

#from awesome-fzf
function feval() {
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

function jira() {
    issue=$1
    if [[ $issue == "" ]]; then
        issue=$(git branch --show-current | sd ".*?(\d+).*" "\$1")
        [[ $issue == "" ]] && echo "wrong folder" && return 2
    elif [[ ! ($issue =~ [1-9]+) ]]; then
        echo "arg should be a number only" && return 2
    fi
    open "https://jira.allegrogroup.com/browse/HUBZ-$issue"
}

# serves as quick bookmarks
function op() {
    command=$1
    repo_name=$(pwd | rev | cut -d / -f1 | rev)
    allowed_repos=$(\ls -1 $REPO | rg --invert-match "(_|\.)")

    if [[ $(echo $allowed_repos | rg "\b$repo_name\b") == "" ]]; then
        echo "wrong folder"
        return 2
    fi

    if [[ $command == "apc" ]]; then
        open "https://console.appengine.allegrogroup.com/info/pl.allegro.logistics.delivery.$repo_name"
    else
        echo "command not found"
    fi
}

alias apc="op apc"
