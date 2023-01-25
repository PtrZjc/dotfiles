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
alias -g O='| xargs -I _ open _'
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
    ipaste - >~/ocr_temp.jpg
    tesseract ~/ocr_temp.jpg stdout | pbcopy
    rm ~/ocr_temp.jpg
    pbpaste
}

function unescape() {
    pbpaste | sd '\\n' '' | sd '\\"' '"' | jq
}

function killport() {
    if [[ ! ("$1" =~ ^[0-9]+$) ]]; then
        echo "impoproper port" && return 2
    fi
    lsof -i tcp:"$1" | sd '^\w+\s+(\d+).*' '$1' | rg '\d+' | xargs kill
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
    elif [[ ! ($issue =~ [0-9]+) ]]; then
        echo "arg should be a number only" && return 2
    fi
    open "https://jira.allegrogroup.com/browse/HUBZ-$issue"
}

# serves as quick bookmarks
function op() {
    command=$1
    repo_name="$(pwd | rev | cut -d / -f1 | rev)"
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

# use hash tables instead: https://stackoverflow.com/questions/1494178/how-to-define-hash-tables-in-bash
function kibana() {

    env=$1
    repo_name=$(pwd | rev | cut -d / -f1 | rev)

    if [[ " dev test prod " != *" $env "* ]]; then
        echo "incompatible / missing env param (dev/test/prod)" && return 2
    fi

    included_repo_links=" broker-billing hub-additional-delivery-expenses "

    if [[ $included_repo_links != *" $repo_name "* ]]; then
        echo "kibana links not yet added for $repo_name! " && return 2
    fi

    if [[ "$repo_name" == "broker-billing" ]]; then

        if [[ "$env" == "dev" ]]; then
            id="ed740590-4cca-11ea-ab6c-1d4dfe7c53f6"
            env="-"$env
        elif [[ "$env" == "test" ]]; then
            id="87b09c30-5e29-11ea-9237-61d11d053255"
            env="-"$env
        elif [[ "$env" == "prod" ]]; then
            id="3a2c7190-5e2a-11ea-b1fd-796a50e2656e"
            env=""
        fi
    fi

    if [[ "$repo_name" == "hub-additional-delivery-expenses" ]]; then

        if [[ "$env" == "dev" ]]; then
            id="62816680-1613-11ec-884b-a7e04c42ef33"
            env="-"$env
        elif [[ "$env" == "test" ]]; then
            id="067952f0-2764-11ec-ac64-974e835c3fc1"
            env="-"$env
        elif [[ "$env" == "prod" ]]; then
            id="1bba1490-2766-11ec-a62f-cdc27736e017"
            env=""
        fi
    fi

    open "https://web.logger$env.qxlint/app/kibana#/discover/$id"
}

function clearmongo() {

}

alias apc="op apc"
alias kbn="kibana"
