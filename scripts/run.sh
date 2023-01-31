#!/usr/bin/env bash
#
# Note: The following environment variables are set by PR build job
#   - CODEBUILD_INITIATOR
#   - CODEBUILD_BUILD_NUMBER
#   - *_TERRAFORM_PROVISIONER_ROLE_ARN

set -euo pipefail
IFS=$'\n\t'

TERRAFORM_WORKSPACE="live"
ASSUME_ROLE_ARN=""
CMD=$1

set_aws_credentials() {
    STS=$(
        aws sts assume-role \
        --role-arn "${ASSUME_ROLE_ARN}" \
        --role-session-name "${CODEBUILD_INITIATOR#*/}-${CODEBUILD_BUILD_NUMBER}" \
        --query "Credentials"
    )

    AWS_ACCESS_KEY_ID="$(jq -r '.AccessKeyId' <<<"${STS}")"
    AWS_SECRET_ACCESS_KEY="$(jq -r '.SecretAccessKey' <<<"${STS}")"
    AWS_SESSION_TOKEN="$(jq -r '.SessionToken' <<<"${STS}")"

    export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY AWS_SESSION_TOKEN
}

main() {
    # set_aws_credentials
    
    case ${CMD} in
        validate)
            terraform init
            terraform validate
            ;;
        plan)
            terraform init
            terraform workspace select "${TERRAFORM_WORKSPACE}"
            terraform validate
            terraform plan
            ;;
        apply)
            terraform init
            terraform workspace select "${TERRAFORM_WORKSPACE}"
            terraform apply -no-color -auto-approve
            ;;
    esac
}

main "$@"
