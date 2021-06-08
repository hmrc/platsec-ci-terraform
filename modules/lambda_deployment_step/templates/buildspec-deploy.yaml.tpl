version: 0.2

phases:
  build:
    commands:
      - >
        aws lambda update-function-code
        --function-name ${function_arn}
        --zip-file fileb://distributable_lambda.zip
        --publish
