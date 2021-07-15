
# platsec-ci-terraform

This repo holds opensource modules that are used for a codepipline release

In the main.tf file there are examples for different methods of lambda
deployment

1. Zipfile deployments
2. Container image deployments (for more complex lambdas)

## Docker deploy pipeline

For lambdas that use zip deploys you can skip this section.

If you are making deployments via container image, you will need to ignore
changes that the pipeline makes. Else your deployments will be reverted next
time your terraform is run

```hcl
# container example
resource "aws_lambda_function" "docker" {
    package_type  = "Image"
    image_uri     = "${aws_ecr_repository.example.repository_url}:placeholder"
    function_name = "${module.label.id}-example-docker-lambda"
    role          = aws_iam_role.iam_for_lambda.arn

    lifecycle {
      ignore_changes = [image_uri]
    }
}
```

# Running locally

You will need to get the backend config file to run plans and applies locally

- run:

    ```bash
    AWS_PAGER="" aws secretsmanager get-secret-value \
      --secret-id "backend.hcl" \
      --query="SecretString" \
      --output=text \
      > "$(git rev-parse --show-toplevel)/backend.hcl"
    ```

- then run: `terraform init -backend-config="$(git rev-parse --show-toplevel)/backend.hcl"`
- you are now free to make changes e.g. `terraform apply`
- done ✅

## License

This code is open source software licensed under the [Apache 2.0 License]("http://www.apache.org/licenses/LICENSE-2.0.html").
