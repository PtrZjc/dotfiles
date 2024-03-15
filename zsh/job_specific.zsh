export CURL_CA_BUNDLE=$HOME/Zscaler_CA.pem

set_aws_profile() {
    local current_profile=$AWS_PROFILE
    local choice

    echo "Select the AWS profile:"
    echo "1) ld-igp-k8s"
    echo "2) livedata-igp-prod"
    echo "3) livedata-igp-nonprod"
    echo "4) priv"
    read choice
    case $choice in
        1)
            [[ $current_profile == "ld-igp-k8s" ]] && return
            aws sso login --no-browser --profile ld-igp-k8s
            export AWS_PROFILE="ld-igp-k8s"
            aws eks update-kubeconfig --region eu-central-1 --name nonprod-euc1-igp-srld-io
            ;;
        2)
            [[ $current_profile == "livedata-igp-prod" ]] && return
            aws sso login --no-browser --profile livedata-igp-prod
            export AWS_PROFILE="livedata-igp-prod"
            aws eks update-kubeconfig --region eu-central-1 --name prod-euc1-srlivedata-io
            ;;
        3)
            [[ $current_profile == "livedata-igp-nonprod" ]] && return
            aws sso login --no-browser --profile livedata-igp-nonprod
            export AWS_PROFILE="livedata-igp-nonprod"
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
