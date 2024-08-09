#!/usr/bin/env bash
#
# Note: The following environment variables are set by PR build job
#   - CODEBUILD_INITIATOR
#   - CODEBUILD_BUILD_NUMBER
#   - TERRAFORM_{APPLIER|PLANNER}_ROLE_ARN

set -euo pipefail
IFS=$'\n\t'

ASSUME_ROLE_ARN=""
CMD=$1
TARGET=$2

set_assume_role_arn() {
    if [[ "${CMD}" == "apply" ]]; then
        ASSUME_ROLE_ARN="${TERRAFORM_APPLIER_ROLE_ARN}"
    else
        ASSUME_ROLE_ARN="${TERRAFORM_PLANNER_ROLE_ARN}"
    fi
}

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
    set_assume_role_arn
    set_aws_credentials
    make "$CMD-${TARGET}"
}

main "$@"
