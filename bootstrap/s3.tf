data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret_version" "s3_state_bucket_name" {
  secret_id = "/terraform/platsec-ci-state-bucket-name"
}

data "aws_secretsmanager_secret_version" "s3_logging_bucket_name" {
  secret_id = "/terraform/platsec-ci-logging-bucket-name"
}

locals {
  tf_provisioner_role    = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformProvisioner"
  security_eng_role      = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer"
  changeset_creator_role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleChangeSetCreator"
  iam_admin_role         = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleIAMAdministrator"

  tmp_all_roles = [local.tf_provisioner_role, local.security_eng_role, local.changeset_creator_role, local.iam_admin_role]
}

module "access_logs" {
  source             = "../modules/access_logs_bucket"
  account_id         = data.aws_caller_identity.current.id
  bucket_name        = nonsensitive(data.aws_secretsmanager_secret_version.s3_logging_bucket_name.secret_string)
}

module "state_bucket" {
  source        = "hmrc/s3-bucket-standard/aws"
  version       = "1.1.0"
  bucket_name   = nonsensitive(data.aws_secretsmanager_secret_version.s3_state_bucket_name.secret_string)
  force_destroy = false

  list_roles  = [local.tf_provisioner_role]
  read_roles  = [local.tf_provisioner_role]
  write_roles = [local.tf_provisioner_role]

  data_expiry      = "forever-config-only"
  data_sensitivity = "high"

  log_bucket_id = module.access_logs.bucket_id
}

module "cf_templates_bucket" {
  source        = "hmrc/s3-bucket-standard/aws"
  version       = "1.1.0"
  bucket_name   = "cf-templates-1a94pgui3v5ft-eu-west-2"
  force_destroy = false

  list_roles          = local.tmp_all_roles
  read_roles          = local.tmp_all_roles
  write_roles         = local.tmp_all_roles
  metadata_read_roles = local.tmp_all_roles

  data_expiry      = "90-days"
  data_sensitivity = "low"

  log_bucket_id = module.access_logs.bucket_id
}
