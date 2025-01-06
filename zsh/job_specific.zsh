export CURL_CA_BUNDLE="$HOME/Zscaler_CA.pem"

function set_aws_profile() {
    local current_profile=$AWS_PROFILE
    local choice

    # Function to handle SSO login and kubeconfig update
    local function handle_profile_switch() {
        local profile=$1
        local cluster=$2
        local region=${3:-eu-central-1}
        local cache_file
        local valid_token_exists=false

        cache_file=$(fd -e json . "$HOME/.aws/cli/cache/" --changed-within 3h)        

        if [[ -n "$cache_file" ]]; then
            valid_token_exists=true
        fi

        if [[ $current_profile == "$profile" ]]; then
            if ! $valid_token_exists; then
                echo "Token expired, refreshing login..."
                aws sso login --no-browser --profile "$profile"
            else
                echo "Already logged in with valid token for $profile"
                return
            fi
        else
            echo "Switching from profile $profile"
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

function at_report() {
    url="https://ldt.pages.sportradar.ag/-/igp/tests/acceptance/-/jobs/$1/artifacts/build/reports/jgiven/test/html/index.html"
    open -n -a "Google Chrome" --args $url
}
