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

