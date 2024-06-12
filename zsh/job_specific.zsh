export CURL_CA_BUNDLE=$HOME/Zscaler_CA.pem

set_aws_profile() {
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
