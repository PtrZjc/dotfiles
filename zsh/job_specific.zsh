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

function wiremock() {
    cd $REPO/hub-mocks && sh launch-wiremock.sh
}

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

# Custom certs - Sportradar
export CURL_CA_BUNDLE=$HOME/Zscaler_CA.pem

set_aws_profile() {
    local current_profile=$AWS_PROFILE
    local choice

    echo "Select the AWS profile:"
    echo "1) ld-igp-k8s"
    echo "2) ld-nonprod-k8s"
    echo "3) priv"
    read choice

    case $choice in
        1)
            [[ $current_profile == "ld-igp-k8s" ]] && return
            aws sso login --no-browser
            aws eks update-kubeconfig --region eu-central-1 --name nonprod-euc1-igp-srld-io
            export AWS_PROFILE="ld-igp-k8s"
            ;;
        2)
            [[ $current_profile == "ld-nonprod-k8s" ]] && return
            aws sso login --no-browser
            aws eks update-kubeconfig --region eu-central-1 --name nonprod-euc1-srlivedata-io
            export AWS_PROFILE="ld-nonprod-k8s"
            ;;
        3)
            [[ $current_profile == "priv" ]] && return
            export AWS_PROFILE="priv"
            ;;
        *)
            echo "Invalid selection."
            ;;
    esac
}

