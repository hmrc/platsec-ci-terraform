# platsec-ci-terraform

This repo holds OpenSource modules that are used for a CodePipeline release

In the [main.tf](main.tf) container images.

> If you are using Docker Hub as a source of your base image or using Docker Hub
> for build purpose, it may hit API limits. To avoid this please use our
> Artifactory proxy eg. instead of Docker image `python` you can use
> `dockerhub.tax.service.gov.uk/python` in your `FROM` directive in a Dockerfile.

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

This repository has the following terraform components:

* `bootstrap`: for bootstrapping terraform state management resources. It should be run locally only.
* `ci`: for CI/CD pipeline resources for applying changes to this repository
* `live`: for the main terraform config that this repository delivers

### Plan

```
make plan-${component}
```

### Apply

```
make apply-${component}
```

## CI/CD pipeline

### Where can I find a CI/CD pipeline for this code base?

* [PR build job](https://eu-west-2.console.aws.amazon.com/codesuite/codebuild/987972305662/projects/platsec-ci-terraform-pr-builder/history?region=eu-west-2)
* [Deployment pipeline](https://eu-west-2.console.aws.amazon.com/codesuite/codepipeline/pipelines/platsec-ci-terraform-pipeline/view?region=eu-west-2)

### How is the CI/CD pipeline configured?

* PR build job is an [AWS CodeBuild](https://eu-west-2.console.aws.amazon.com/codesuite/codebuild/987972305662/projects/platsec-ci-terraform-pr-builder/history?region=eu-west-2) project
* Deployment pipeline and PR build job are managed in code [here](https://github.com/hmrc/platsec-ci-terraform/tree/main/ci)

## License

This code is open source software licensed under the [Apache 2.0 License]("http://www.apache.org/licenses/LICENSE-2.0.html").
