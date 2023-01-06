# platsec-ci-terraform

This repo holds OpenSource modules that are used for a CodePipeline release

In the [main.tf](main.tf) file there are examples for different methods of lambda
deployment as:

1. ZIP file
2. Docker image

>If you are using Docker Hub as a source of your base image or using Docker Hub
for build purpose, it may hit API limits. To avoid this please use our
Artifactory proxy eg. instead of Docker image `python` you can use
`dockerhub.tax.service.gov.uk/python` in your `FROM` directive in a Dockerfile.

## ZIP deploy pipeline

### CodeBuild Buildspec

To be able to use this pipeline you need to supply `buildspec.yml` in the root
of your repo which will be used by CI to build the artefact. The artefact needs
to be saved in the root of the repo as `lambda.zip`.

For example this buildspec will use `Makefile` to run all tests, then build
lambda package and finally save it as artifact `lambda.zip`.

```yaml
version: 0.2
phases:
  build:
    commands:
      - make test
      - make lambda-package
artifacts:
  files:
    - lambda.zip
```

### Terraform

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

### CodeBuild Buildspec

To be able to use this pipeline you need to supply `buildspec.yml` in the root
of your repo which will be used by CI to build the artefact. There are a few
requirements for Docker image:

1. tagged as `container-release:local`
2. saved as `docker.tar` in the root of the repo and reference it as an artifact

```yaml
version: 0.2
phases:
  build:
    commands:
      - make test
      - make container-release
      - docker save -o docker.tar container-release:local
artifacts:
  files:
    - docker.tar
```

This buildspec will use `Makefile` to run all tests, then build Docker image and
finally save it `docker.tar`.

### Terraform

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
- You can switch Terraform workspaces to test your changes in isolation with: `terraform workspace list` and `terraform workspace select foo`
- you are now free to make changes e.g. `terraform apply`
- done ✅

## CI/CD pipeline

### Where can I find a CI/CD pipeline for this code base?

* No PR build job yet
* No deployment pipeline job yet

### How is the CI/CD pipeline configured?
N/A

## License

This code is open source software licensed under the [Apache 2.0 License]("http://www.apache.org/licenses/LICENSE-2.0.html").
