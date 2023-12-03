export REPO="${HOME}/workspace"
export DOTFILES="${REPO}/priv/dotfiles"
export CUSTOM="${DOTFILES}/zsh/custom.zsh"
export ZSHRC="${DOTFILES}/zsh/.zshrc"
export GIT="${DOTFILES}/zsh/git.zsh"
export VIMRC="${DOTFILES}/vim/.vimrc"
export BREWFILE="${DOTFILES}/brew/Brewfile"
export TEMP_FILE="/tmp/temp_file"
export PYTHON_SRC="${REPO}/priv/python-scripts"

alias rst="exec zsh"
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
alias code='code .'
alias wat='which '
alias python='python3'
alias argbash='${HOME}/.local/argbash-2.10.0/bin/argbash'
alias argbash-init='${HOME}/.local/argbash-2.10.0/bin/argbash-init'
alias pip='pip3'

alias -g H='| head'
alias -g L='| less'
alias -g JL='| jq -C | less'
alias -g T='| tail'
alias -g C='| cat'
alias -g O='| xargs -I _ open _'
alias -g DF='-u | diff-so-fancy' # use as: diff file1 file2 DF
alias ls='ls -lahgG'
alias l='tree -C -L 1'

alias ij="nohup /Applications/IntelliJ\ IDEA.app/Contents/MacOS/idea . > /dev/null 2>&1 &"

function ke-l(){
    DB_NAME="KeePass"
    DIR="${HOME}/keepass"
    LOCAL_FILE="${HOME}/keepass/$DB_NAME.kdbx"
    REMOTE_FILE="Aplikacje/KeePass/$DB_NAME.kdbx"
    mkdir -p $BACKUP_DIR_REMOTE $BACKUP_DIR_LOCAL
    LOCAL_FILE_DATE=`stat -f "%Sm" -t "%Y%m%d_%H%M%S" "$LOCAL_FILE"`

    LOCAL_BACKUP="$DIR/$DB_NAME"_local_"$LOCAL_FILE_DATE.kdbx"
    cp "$LOCAL_FILE" "$LOCAL_BACKUP"

    echo "Downloading and overriding local database"
    dbxcli get "$REMOTE_FILE" "$LOCAL_FILE"

    if cmp -s "$LOCAL_FILE" "$LOCAL_BACKUP"; then
        rm "$LOCAL_BACKUP"
    else
        echo "Difference with remote - Local backup kept in $LOCAL_BACKUP"
    fi
}

function ke-p(){
    DB_NAME="KeePass"
    DIR="${HOME}/keepass"
    LOCAL_FILE="${HOME}/keepass/$DB_NAME.kdbx"
    REMOTE_FILE="Aplikacje/KeePass/$DB_NAME.kdbx"

    # Step 1: Make backup of remote database before override
    echo "Making backup of remote database before override"
    dbxcli get "$REMOTE_FILE" "$TEMP_FILE"
    REMOTE_FILE_DATE=`stat -f "%Sm" -t "%Y%m%d_%H%M%S" "$TEMP_FILE"`
    REMOTE_BACKUP="$DIR/$DB_NAME"_remote_"$REMOTE_FILE_DATE.kdbx"
    mv "$TEMP_FILE" "$REMOTE_BACKUP"

    if cmp -s "$LOCAL_FILE" "$REMOTE_BACKUP"; then
        rm "$REMOTE_BACKUP"
    else
        echo "Difference with remote - Remote backup kept in $REMOTE_BACKUP"
    fi
    echo "Uploading local database"
    # Step 2: Upload the local file, overriding the remote database
    dbxcli put "$LOCAL_FILE" $REMOTE_FILE
}

function obs-p() {
    if [[ -z $(pwd | rg 'obsidian/goddy') ]]; then
        echo "Not in obsidian folder" && return 2
    fi
    DROPBOX_DEST=$(pwd | sd '.*(/obsidian.*)' '$1')
    python "${PYTHON_SRC}/dropbox/upload_folder.py" "$DROPBOX_DEST" $(pwd) -y
}

function obs-l() {
    if [[ -z $(pwd | rg 'obsidian/goddy') ]]; then
        echo "Not in obsidian folder" && return 2
    fi
    DROPBOX_SOURCE=$(pwd | sd '.*(/obsidian.*)' '$1')
    echo "downloading from $DROPBOX_SOURCE"
    python "${PYTHON_SRC}/dropbox/download_folder.py" "$DROPBOX_SOURCE"
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
    tesseract -l pol ~/ocr_temp.jpg stdout | pbcopy
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
	lsof -i tcp:"$1" | gawk 'NR>1 {print $2}' | xargs kill -9
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
        ["cbs-api"]="ed0d5ba0-c296-11ea-a243-15c0bb563f4e TBD TBD"
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

function localmongo_uri(){
    repo_name=$(pwd | rev | cut -d / -f1 | rev)
    declare -A db_names=(
        ["broker-billing"]="bb_local"
        ["hub-additional-delivery-expenses"]="hades-local"
        ["hub-delivery-seller-price-source"]="hdsps-local"
        ["hub-external-order-processor-service"]="heops-local"
        ["hub-price-list-facade"]="hub-price-list-facade"
        ["hub-additional-delivery-expenses"]="hades-local"
    )
    if [[ $(echo ${(k)db_names} | rg $repo_name) == "" ]]; then
        echo "Database of $repo_name is not supported" && return 2
    fi
    echo "mongodb://mongoadmin:secret@localhost:27017/${db_names[$repo_name]}?authSource=admin"
}

function clearmongo() {
    mongosh "$(localmongo_uri)"  --eval 'db.getCollectionNames().forEach(c=>db[c].deleteMany({}))'
}

function db4u_uri(){
    service=${(U)1}
    env=${(U)2}
    password_var_env="DB4U_PASSWORD_${service}_${env}"
    
    if [[ -z $service || -z $env ]]; then
    echo "Either service ($service) or environment ($env) params not given"
    return 1
    elif [[ -z ${(P)password_var_env} ]]; then
    echo "Environment variable '$password_var_env' is not set. Exiting."
    return 1
    fi  
    password=${(P)password_var_env}
    
    db=${(L)service}'_'${(L)env:0:1}
    serv_e=${(L)service}'-'${(L)env:0:1}

    hosts=$serv_e-mongod-rs0-service.${(L)env}.distributed.alledc.net
    replica_set=$serv_e-rs0
    
    echo "mongodb+srv://$DB4U_USERNAME:$password@$hosts/?replicaSet=$replica_set&ssl=false&retryWrites=true&readPreference=primary&srvServiceName=mongodb&connectTimeoutMS=10000&authSource=admin&authMechanism=SCRAM-SHA-1"
}

function db4u_refresh_pricelists() {
    target=${(L)1}
    if [[ $target == "prod" ]]; then
        echo "prod is not supported as target environment. Exiting." && return 1
    elif [[ $target == "test" ]]; then
        source="prod"
    elif [[ $target == "dev" ]]; then
        source="test"
    else
        echo "Invalid target environment. Exiting." && return 1
    fi

    service="hplf"
    collections=("price-lists" "pricing-entries")
    for collection in "${collections[@]}"; do
        echo "Dumping $collection from $service $source database"
        mongodump --uri=$(db4u_uri $service ${(U)source}) --collection=$collection --db=${service}_${source:0:1} --out=/tmp/dump

        echo "Restoring $collection to $service $target database"
        mongorestore --uri=$(db4u_uri $service ${(U)target}) --drop --collection=$collection --db=${service}_${target:0:1} "/tmp/dump/${service}_${source:0:1}/$collection.bson"
    done
}

function db4u_backup(){
    service=${(U)1}
    env=${(U)2}
    collections=("price-lists" "pricing-entries")

    env_letter=${(L)env:0:1}
    db=${(L)service}'_'$env_letter

    for collection in "${collections[@]}"; do
        mongodump --uri=$(db4u_uri $service $env) --collection=$collection --db=$db --out=/tmp/dump && \
        mongorestore --uri=$(db4u_uri $service $env) --drop --collection=$collection"_backup" --db=$db "/tmp/dump/"${(L)service}"_"$env_letter"/"$collection".bson" && \
        echo "Successfully backed up collection $collection from $service $env database as "$collection"_backup"
    done
}

alias apc="open_bookmark apc"
alias kbn="kibana"
alias gfn="grafana"

## TEXT PROCESSING

# below functions are meant to be used with stdin input 
function ucase() {
  while read -r line; do
    print -r -- ${(U)line}
  done
}


# Function used to divide stdin into multiple files 
function split() {
  # Read stdin into a variable
  input_string=$(cat)

  # Calculate the length of the string
  length=${#input_string}

  # Number of files to split into
  num_files=$1

  # Calculate the length of each segment
  segment_length=$((length / num_files))

  # Initialize variables
  start=0
  end=$segment_length

  # Loop to create files
  for (( i=1; i<=num_files; i++ )); do
    # Extract the substring
    segment=${input_string:start:end}

    # Write to a file
    echo -n "$segment" > "split_$i.txt"

    # Update start and end for the next iteration
    start=$((start + segment_length))
    end=$((end + segment_length))
  done
}


alias extract-ids='pbpaste | rg id | sd ".*(\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w+{12}).*" "\$1," | pbcopy && pbpaste'
alias wrap-with-uuid='pbpaste | sd ".*?(\\w{8}-\\w{4}-\\w{4}-\\w{4}-\\w{12}).*" "UUID(\"\$1\"), " | pbcopy && pbpaste'

export TSTRUCT_TOKEN="tstruct_eyJ2ZXJzaW9uIjoxLCJkYXRhIjp7InVzZXJJRCI6NzQxMjk2MTksInVzZXJFbWFpbCI6Im5vcG9nNzY3MThAYWx2aXNhbmkuY29tIiwidGVhbUlEIjoyMjYzNzM5NjAsInRlYW1OYW1lIjoibm9wb2c3NjcxOEBhbHZpc2FuaS5jb20ncyB0ZWFtIiwicmVuZXdhbERhdGUiOiIyMDIzLTEwLTAzVDE2OjM2OjA3LjAwOTY2NTgzNFoiLCJjcmVhdGVkQXQiOiIyMDIzLTA5LTI2VDE2OjM2OjA3LjAwOTY2ODQ3NFoifSwic2lnbmF0dXJlIjoieVhJRnJoN1hId3NlUjhTL2VMM05SWDkxL2I1L0xpdjFQL1NsS2V1dVBEVWhvTEwwWE9Ud2pWZWVIYTR6TElaQlkzMmhrNlZLbnZqVWZab0poajNLRFE9PSJ9"
