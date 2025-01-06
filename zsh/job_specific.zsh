export CURL_CA_BUNDLE="$HOME/Zscaler_CA.pem"


function set_aws_profile() {
    local current_profile=$AWS_PROFILE
    local choice

    local function check_token_expiration() {
        local profile=$1
        local cache_file="$HOME/.aws/cli/cache/*.json"
        
        # Check if cache file exists
        if [[ ! -f $cache_file ]]; then
            return 1
        fi

        local expiration=$(cat $cache_file | jq -r '.Credentials.Expiration')
        local now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

        if [[ "$now" > "$expiration" ]]; then
            return 1  # expired
        else
            return 0  # valid
        fi
    }

    # Function to handle SSO login and kubeconfig update
    local function handle_profile_switch() {
        local profile=$1
        local cluster=$2
        local region=${3:-eu-central-1}

        if [[ $current_profile == "$profile" ]]; then
            if ! check_token_expiration "$profile"; then
                echo "Token expired, refreshing login..."

                    return 1
                aws sso login --no-browser --profile "$profile"
            else
                echo "Already logged in with valid token for $profile"
                return
            fi
        else
            aws sso login --no-browser --profile "$profile"
        fi

        export AWS_PROFILE="$profile"
        
        # Update kubeconfig only if cluster name is provided
        if [[ -n "$cluster" ]]; then
            aws eks update-kubeconfig --region "$region" --name "$cluster"
        fi
    }
 
    echo "Select the AWS profile:"
    echo "1) LIVEDATA_IGP_NONPROD"
    echo "2) LIVEDATA_IGP_PROD"
    echo "3) NO_TRD_LIVEDATA_K8S_NONPROD"
    echo "4) priv"
    read choice

    case $choice in
        (1) handle_profile_switch "LIVEDATA_IGP_NONPROD" "nonprod-euc1-igp-srld-io" ;;
        (2) handle_profile_switch "LIVEDATA_IGP_PROD" "prod-euc1-igp-srld-io" ;;
        (3) handle_profile_switch "NO_TRD_LIVEDATA_K8S_NONPROD" "nonprod-euc1-srlivedata-io" ;;
        (4) export AWS_PROFILE="priv" ;;
        (*) echo "Invalid selection." ;;
    esac
}

function aset_aws_profile () {
    local current_profile=$AWS_PROFILE
    local choice

    echo "Select the AWS profile:"
    echo "1) LIVEDATA_IGP_NONPROD"
    echo "2) LIVEDATA_IGP_PROD"
    echo "3) NO_TRD_LIVEDATA_K8S_NONPROD"
    echo "4) priv"
    read choice
    case $choice in
        1)
            [[ $current_profile == "LIVEDATA_IGP_NONPROD" ]] && return
            aws sso login --no-browser --profile LIVEDATA_IGP_NONPROD
            export AWS_PROFILE="LIVEDATA_IGP_NONPROD"
            aws eks update-kubeconfig --region eu-central-1 --name nonprod-euc1-igp-srld-io
            ;;
        2)
            [[ $current_profile == "LIVEDATA_IGP_PROD" ]] && return
            aws sso login --no-browser --profile LIVEDATA_IGP_PROD
            export AWS_PROFILE="LIVEDATA_IGP_PROD"
            aws eks update-kubeconfig --region eu-central-1 --name prod-euc1-igp-srld-io
            ;;
        3)
            [[ $current_profile == "NO_TRD_LIVEDATA_K8S_NONPROD" ]] && return
            aws sso login --no-browser --profile NO_TRD_LIVEDATA_K8S_NONPROD
            export AWS_PROFILE="NO_TRD_LIVEDATA_K8S_NONPROD"
            aws eks update-kubeconfig --region eu-central-1 --name nonprod-euc1-srlivedata-io
            ;;
        4)
            [[ $current_profile == "priv" ]] && return
            export AWS_PROFILE="priv"
            echo "using k8s context docker-desktop"
            kubectl config use-context docker-desktop
            ;;
        *)
            echo "Invalid selection."
            ;;
    esac
}

function at_report() {
    url="https://ldt.pages.sportradar.ag/-/igp/tests/acceptance/-/jobs/$1/artifacts/build/reports/jgiven/test/html/index.html"
    open -n -a "Google Chrome" --args $url
}

function test(){
    local function nested(){
        echo 123
    }
    nested
}
