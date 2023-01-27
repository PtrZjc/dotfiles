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
function open_bookmark() {
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

function kibana() {
    repo_name=$(pwd | rev | cut -d / -f1 | rev)

    #dev_id test_id prod_id
    declare -A kibana_ids=(
        ["broker-billing"]="ed740590-4cca-11ea-ab6c-1d4dfe7c53f6 87b09c30-5e29-11ea-9237-61d11d053255 3a2c7190-5e2a-11ea-b1fd-796a50e2656e"
        ["hub-additional-delivery-expenses"]="62816680-1613-11ec-884b-a7e04c42ef33 067952f0-2764-11ec-ac64-974e835c3fc1 1bba1490-2766-11ec-a62f-cdc27736e017"
        ["hub-external-order-processor-service"]="2d923f50-1192-11ed-9149-9dd60d0ca628 30d27630-1192-11ed-9313-4ff773b2e478 2e1970b0-1192-11ed-8fe8-f74bfea0e165"
        ["hub-mail-hasher"]=["d8de6640-f305-11e8-ba55-c1f39c5d083c c2ee08b0-e47f-11e9-9174-e11cdc4d82dd f67c2470-fc34-11e8-9387-c1fb28e452c4"]
        ["hub-price-list-facade"]=["f640fa20-55d2-11ed-b8f4-ff0689ed4fe2 28934bc0-568e-11ed-baab-991719185eb0 d8cea700-568e-11ed-bd10-99465b55dd95"]
    )
    
    if [[ $(echo ${(k)kibana_ids} | rg $repo_name) == "" ]]; then
        echo "Kibana ids of $repo_name not yet defined" && return 2
    fi

    if [[ "$1" == "dev" ]];    then; suffix="-dev";  id_idx=1
    elif [[ "$1" == "test" ]]; then; suffix="-test"; id_idx=2
    else;                            suffix="";      id_idx=3
    fi

    id=$(echo $kibana_ids[$repo_name] | cut -d " " -f $id_idx)
    open "https://web.logger$suffix.qxlint/app/kibana#/discover/$id"
}

function grafana() {
    repo_name=$(pwd | rev | cut -d / -f1 | rev)

    declare -A grafana_url=(
        ["broker-billing"]="BOQPNb8Wk/broker-billing-kotlin-v4-1-0-single-module-template-kotlin"
        ["hub-additional-delivery-expenses"]="6orAGyInk/hub-additional-delivery-expenses-v4-3-0-github-app-templates-single-module-kotlin-junit5"
        ["hub-external-order-processor-service"]="cD_EjkzVk/hub-external-order-processor-service-github-kotlin-v4-1-0-github-app-templates-single-module-kotlin-junit5"
        ["hub-mail-hasher"]="jzYtJdYmk/hub-mail-hasher-kotlin-v4-1-0-single-module-template-kotlin"
    )
    
    if [[ $(echo ${(k)grafana_url} | rg $repo_name) == "" ]]; then
        echo "Kibana ids of $repo_name not yet defined" && return 2
    fi

    open "https://metrics.allegrogroup.com/d/$grafana_url[$repo_name]"
}

function clearmongo() {
    repo_name=$(pwd | rev | cut -d / -f1 | rev)
    declare -A db_names=(
        ["broker-billing"]="broker_billing_local"
        ["hub-additional-delivery-expenses"]="hades-local"
        ["hub-delivery-seller-price-source"]="hdsps-local"
        ["hub-external-order-processor-service"]="heops-local"
        ["hub-price-list-facade"]="hub-price-list-facade"
    )
    if [[ $(echo ${(k)db_names} | rg $repo_name) == "" ]]; then
        echo "Database of $repo_name is not supported" && return 2
    fi
    mongosh "mongodb://mongoadmin:secret@localhost:27017/${db_names[$repo_name]}?authSource=admin"  --eval 'db.getCollectionNames().forEach(c=>db[c].deleteMany({}))'
}

alias apc="open_bookmark apc"
alias kbn="kibana"
alias gfn="grafana"

