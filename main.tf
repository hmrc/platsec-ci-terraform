terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    region = "Please run 'make init' first"
    key    = "Please run 'make init' first"
    bucket = "Please run 'make init' first"
  }
}

provider "aws" {
  region = "eu-west-2"
  default_tags {
    tags = module.label.tags
  }
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.24.1"

  namespace = "mdtp"
  stage     = terraform.workspace
  name      = "platsec-ci"
}

module "ci-common" {
  source      = "./modules/ci_common"
  name_prefix = module.label.id
}

module "test_ci" {
  source                = "./modules/lambda_zip_pipeline"
  name_prefix           = module.label.id
  github_connection_arn = module.ci-common.github_connection_arn

  pipeline_name = "${module.label.stage}-test-pipeline"
  src_org       = "cob16"
  src_repo      = "test-python-repo"

  deploy_production_lambda_arn  = aws_lambda_function.example.arn
  deploy_development_lambda_arn = aws_lambda_function.example.arn
}


#todo remove placeholder resources
resource "aws_iam_role" "iam_for_lambda" {
  name = "${module.label.id}-example-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "example" {
  filename      = "dummy_lambda_payload.zip"
  function_name = "${module.label.id}-example-lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "python3.8"
  handler       = "run.lambda_handler"
}

resource "aws_ecr_repository" "example" {
  name = module.label.id
}