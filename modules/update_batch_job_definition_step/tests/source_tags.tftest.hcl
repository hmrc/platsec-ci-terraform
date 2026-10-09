mock_provider "aws" {
  mock_data "aws_default_tags" {
    defaults = { tags = { source = "https://github.com/hmrc/platsec-ci-terraform" } }
  }
  mock_data "aws_caller_identity" {
    defaults = { account_id = "123456789012" }
  }
  mock_data "aws_iam_policy_document" {
    defaults = { json = "{}" }
  }
}

variables {
  step_name                = "test-update-batch"
  ecr_url                  = "123456789012.dkr.ecr.eu-west-2.amazonaws.com/scanner"
  job_definition_name      = "scanner-jd"
  deployment_role_arn      = "arn:aws:iam::123456789012:role/deploy"
  build_core_policy_arn    = "arn:aws:iam::123456789012:policy/build"
  agent_security_group_ids = ["sg-0123456789abcdef0"]
  vpc_config = {
    vpc_id              = "vpc-0123456789abcdef0"
    private_subnet_ids  = ["subnet-0123456789abcdef0"]
    private_subnet_arns = ["arn:aws:ec2:eu-west-2:123456789012:subnet/subnet-0123456789abcdef0"]
  }
}

run "deployment_receives_exact_provider_source" {
  command = plan

  assert {
    condition = {
      for item in aws_codebuild_project.deploy.environment[0].environment_variable : item.name => item.value
    }["SOURCE_TAG"] == "https://github.com/hmrc/platsec-ci-terraform"
    error_message = "CodeBuild must receive the inherited provider source verbatim for new Batch definition revisions."
  }
}
