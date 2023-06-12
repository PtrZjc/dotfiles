export REPO="${HOME}/workspace"
export CUSTOM="${REPO}/0_others/dotfiles/zsh/custom.zsh"
export ZSHRC="${REPO}/0_others/dotfiles/zsh/.zshrc"
export GIT="${REPO}/0_others/dotfiles/zsh/git.zsh"
export VIMRC="${REPO}/0_others/dotfiles/vim/.vimrc"
export BREWFILE="${REPO}/0_others/dotfiles/brew/Brewfile"
export TEMP_FILE="${HOME}/temp_file"
alias rst="exec zsh"

alias ocustom='code $CUSTOM'
alias obrew='code $BREWFILE'
alias ogit='code $GIT'

alias co=tldr
alias a='alias'
alias cof='declare -f'
alias icat='imgcat'
alias ipaste='pngpaste'
alias todo='todo.sh'
alias t='tree -C -L'
alias cls='clear && printf "\e[3J"'
alias ch='cls && cht.sh'
alias vi='nvim'
alias vim='nvim'
alias argbash='${HOME}/.local/argbash-2.10.0/bin/argbash'
alias argbash-init='${HOME}/.local/argbash-2.10.0/bin/argbash-init'

alias -g H='| head'
alias -g L='| less'
alias -g JL='| jq -C | less'
alias -g T='| tail'
alias -g C='| cat'
alias -g O='| xargs -I _ open _'
alias -g TOX='> xx && mv xx x'
alias -g DF='-u | diff-so-fancy' # use as: diff file1 file2 DF
alias ls='ls -lahgG'
# alias l='ls -1G'
alias l='tree -C -L 1'

alias ij="/Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea ."

# alias ke-p='dbxcli put ~/Keepas_globalny.kdbx "Aplikacje/KeePass.kdbx"'
alias ke-l='cp ~/Keepas_globalny.kdbx ~/Keepas_globalny_backup.kdbx && dbxcli get "Aplikacje/KeePass 2.x" ~/Keepas_globalny.kdbx'

function ke-p(){
    DB_NAME="KeePass"
    LOCAL_FILE="${HOME}/keepass/$DB_NAME.kdbx"
    REMOTE_FILE="Aplikacje/KeePass/$DB_NAME.kdbx"
    BACKUP_DIR_REMOTE="${HOME}/keepass/backup/remote"
    BACKUP_DIR_LOCAL="${HOME}/keepass/backup/local"
    LOCAL_FILE_DATE=`stat -f "%Sm" -t "%Y%m%d_%H%M%S" "$LOCAL_FILE"`
    echo "Making backup of remote database before override"
    dbxcli get "$REMOTE_FILE" "$TEMP_FILE"
    REMOTE_FILE_DATE=`stat -f "%Sm" -t "%Y%m%d_%H%M%S" "$TEMP_FILE"`
    REMOTE_BACKUP="$BACKUP_DIR_REMOTE/$DB_NAME"_"$REMOTE_FILE_DATE.kdbx"
    mv "$TEMP_FILE" "$REMOTE_BACKUP"
    echo "Remote backup made to $REMOTE_BACKUP"
    echo "Uploading local database"
    dbxcli put "$LOCAL_FILE" $REMOTE_FILE
}

function wiremock() {
    cd $REPO/hub-mocks && sh launch-wiremock.sh
}

function line() {
    head -$1 | tail -1
}

function goto() {
    DESTINATION=$(fd -t d | fzf)
    if [ "$DESTINATION" = "" ]; then
        echo "Empty destination" && exit 1
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
	#dev test prod
        ["broker-billing"]="ed740590-4cca-11ea-ab6c-1d4dfe7c53f6 87b09c30-5e29-11ea-9237-61d11d053255 3a2c7190-5e2a-11ea-b1fd-796a50e2656e"
        ["hub-additional-delivery-expenses"]="62816680-1613-11ec-884b-a7e04c42ef33 067952f0-2764-11ec-ac64-974e835c3fc1 1bba1490-2766-11ec-a62f-cdc27736e017"
        ["hub-external-order-processor-service"]="2d923f50-1192-11ed-9149-9dd60d0ca628 30d27630-1192-11ed-9313-4ff773b2e478 2e1970b0-1192-11ed-8fe8-f74bfea0e165"
        ["hub-mail-hasher"]="d8de6640-f305-11e8-ba55-c1f39c5d083c c2ee08b0-e47f-11e9-9174-e11cdc4d82dd f67c2470-fc34-11e8-9387-c1fb28e452c4"
        ["hub-price-list-facade"]="f640fa20-55d2-11ed-b8f4-ff0689ed4fe2 28934bc0-568e-11ed-baab-991719185eb0 d8cea700-568e-11ed-bd10-99465b55dd95"
        ["hub-delivery-seller-price-source"]="f48bef60-4e38-11ed-94d2-95bfcf9fed37 e1e30ab0-4eba-11ed-ab09-03caaa840372 e23dd4e0-4eba-11ed-8c1c-7d0533e0c560"
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
        ["hub-additional-delivery-expenses"]="hades-local"
    )
    if [[ $(echo ${(k)db_names} | rg $repo_name) == "" ]]; then
        echo "Database of $repo_name is not supported" && return 2
    fi
    mongosh "mongodb://mongoadmin:secret@localhost:27017/${db_names[$repo_name]}?authSource=admin"  --eval 'db.getCollectionNames().forEach(c=>db[c].deleteMany({}))'
}

alias apc="open_bookmark apc"
alias kbn="kibana"
alias gfn="grafana"

## TEXT PROCESSING

alias extract-ids='pbpaste | rg id | sd ".*(\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w+{12}).*" "\$1," | pbcopy && pbpaste'
alias wrap-with-uuid='pbpaste | sd ".*?(\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}).*" "UUID(\"\$1\"), " | pbcopy && pbpaste'
