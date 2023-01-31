data "terraform_remote_state" "networking_ci" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    region = "eu-west-2"
    key    = "components/networking_ci.tfstate"
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_role" "terraform_provisioner" {
  name = "RoleTerraformProvisioner"
}

module "pull_request_builder" {

  source = "../../../modules/ci/pull_request_builder"

  docker_required = true
  project_name    = "terraform-pr-builder"

  project_assume_roles = {
    "SANDBOX_TERRAFORM_PROVISIONER_ROLE_ARN"     = "arn:aws:iam::${var.account_ids["platsec-sandbox"]}:role/RoleTerraformProvisioner"
    "DEVELOPMENT_TERRAFORM_PROVISIONER_ROLE_ARN" = "arn:aws:iam::${var.account_ids["platsec-development"]}:role/RoleTerraformProvisioner"
    "PRODUCTION_TERRAFORM_PROVISIONER_ROLE_ARN"  = "arn:aws:iam::${var.account_ids["platsec-production"]}:role/RoleTerraformProvisioner"
  }

  vpc_config = data.terraform_remote_state.networking_ci.outputs.vpc_config
  agent_security_group_ids = [
    data.terraform_remote_state.networking_ci.outputs.ci_agent_to_endpoints_sg_id,
    data.terraform_remote_state.networking_ci.outputs.ci_agent_to_internet_sg_id
  ]
}
