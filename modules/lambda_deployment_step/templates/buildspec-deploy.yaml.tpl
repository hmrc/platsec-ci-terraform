version: 0.2

phases:
  build:
    commands:
      - # https://aws.amazon.com/premiumsupport/knowledge-center/codebuild-temporary-credentials-docker/
      - TEMP_ROLE='aws sts assume-role --role-arn ${DEPLOYMENT_ROLE_ARN} --role-session-name test'
      - export TEMP_ROLE
      - export AWS_ACCESS_KEY_ID=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.AccessKeyId')
      - export AWS_SECRET_ACCESS_KEY=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SecretAccessKey')
      - export AWS_SESSION_TOKEN=$(echo "${TEMP_ROLE}" | jq -r '.Credentials.SessionToken')
      - >
        aws lambda update-function-code
        --function-name ${function_arn}
        --zip-file fileb://distributable_lambda.zip
        --publish
