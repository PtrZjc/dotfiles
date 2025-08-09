export CURL_CA_BUNDLE="$HOME/Zscaler_CA.pem"

function set_aws_profile() {
    # takes 1 argument -s or --set-only when only AWS_PROFILE should be changed

    local set_only=false
    local choice

    # Check for -s or --set-only flag
    if [[ "$1" == "-s" ]] || [[ "$1" == "--set-only" ]]; then
        set_only=true
    fi

    # Function to handle profile switch
    local function handle_profile_switch() {
        local profile=$1
        local cluster=$2
        local region=${3:-eu-central-1}

        if $set_only; then
            export AWS_PROFILE="$profile"
            echo "AWS_PROFILE set to $profile"
            return
        fi

        # Original SSO login logic
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

        unset AWS_ACCESS_KEY_ID
        unset AWS_SECRET_ACCESS_KEY
        unset AWS_DEFAULT_REGION

        if [[ -n "$cluster" ]]; then
            aws eks update-kubeconfig --region "$region" --name "$cluster"
        fi
    }

    # Function to handle profile switch to priv
    local function handle_priv_switch() {

        # export envs for other apps that may need these
        export AWS_ACCESS_KEY_ID=$(cat "$HOME/.aws/config" | rg priv -A 5 | rg aws_access_key_id | sd ".* = (.*)" '$1')
        export AWS_SECRET_ACCESS_KEY=$(cat "$HOME/.aws/config" | rg priv -A 5 | rg aws_secret_access_key | sd ".* = (.*)" '$1')
        export AWS_DEFAULT_REGION=$(cat "$HOME/.aws/config" | rg priv -A 5 | rg region | sd ".* = (.*)" '$1')
        export AWS_PROFILE="priv"
    }

    echo "Select the AWS profile:"
    echo "1) LIVEDATA_IGP_NONPROD"
    echo "2) LIVEDATA_IGP_PROD_OBSERVER"
    echo "3) LIVEDATA_IGP_PROD_DEVELOPER"
    echo "4) NO_TRD_LIVEDATA_K8S_NONPROD"
    echo "5) priv"
    read choice

    case $choice in
        (1) handle_profile_switch "LIVEDATA_IGP_NONPROD" "nonprod-euc1-igp-srld-io" ;;
        (2) handle_profile_switch "LIVEDATA_IGP_PROD_OBSERVER" "prod-euc1-igp-srld-io" ;;
        (3) handle_profile_switch "LIVEDATA_IGP_PROD_DEVELOPER" "prod-euc1-igp-srld-io" ;;
        (4) handle_profile_switch "NO_TRD_LIVEDATA_K8S_NONPROD" "nonprod-euc1-srlivedata-io" ;;
        (5) handle_priv_switch ;;
        (*) echo "Invalid selection." ;;
    esac

    echo $AWS_PROFILE > "$HOME/.aws/aws_profile"
}

function k-set-ns() {
   local project=$1
   local env=$2
   local namespace=""

   if [[ -z "$project" || -z "$env" ]]; then
       echo "Error: Please provide both project and environment"
       echo "Usage: k_set_ns <project> <env>"
       echo "Projects: igp, ldla"
       echo "Environments: dev, qa, perf, prod"
       return 1
   fi

   case $project in
       igp)
           case $env in
               dev) namespace="igp-dev-igp" ;;
               qa) namespace="igp-qa-igp" ;;
               perf) namespace="igp-perf-igp" ;;
               prod) namespace="igp-prod-igp" ;;
               *)
                   echo "Error: Invalid environment for igp. Use: dev, qa, perf, or prod"
                   return 1
                   ;;
           esac
           ;;
       ldla)
           case $env in
               dev) namespace="ld-dev-legacy-api" ;;
               qa) namespace="ld-qa-legacy-api" ;;
               perf) namespace="ld-perf-legacy-api" ;;
               prod) namespace="ld-prod-legacy-api" ;;
               *)
                   echo "Error: Invalid environment for ldla. Use: dev, qa, perf, or prod"
                   return 1
                   ;;
           esac
           ;;
       *)
           echo "Error: Invalid project. Use: igp or ldla"
           return 1
           ;;
   esac

   kubectl config set-context --current --namespace="$namespace"
}

function at_report() {
    url="https://ldt.pages.sportradar.ag/-/igp/tests/acceptance/-/jobs/$1/artifacts/build/reports/jgiven/test/html/index.html"
    open -n -a "Google Chrome" --args $url
}
