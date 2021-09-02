# platsec-ci-terraform

This repo holds OpenSource modules that are used for a CodePipeline release

In the [main.tf](main.tf) file there are examples for different methods of lambda
deployment as:

1. ZIP file
2. Docker image

## ZIP deploy pipeline

In your Terraform you will need to ignore changes in Lambda ZIP that the
pipeline makes. Otherwise your deployments will be reverted next time your
Terraform is run. This can be achieved by using dummy file which will never
change from Terraform point of view.

```hcl
data "archive_file" "empty_lambda" {
  type = "zip"

  output_file_mode = "0666"
  output_path      = "${path.module}/assets/empty_lambda.zip"
  source {
    content  = "import emptiness"
    filename = "handler.py"
  }
}

resource "aws_lambda_function" "lambda_function" {
  function_name    = "${module.label.id}-example-zip-lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  filename         = data.archive_file.empty_lambda.output_path
}
```

## Docker deploy pipeline

In your Terraform you will need to ignore changes of `image_uri` which is now
managed by this pipeline. Otherwise your deployments will be reverted next time
your Terraform is run.

```hcl
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

## Running locally

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
