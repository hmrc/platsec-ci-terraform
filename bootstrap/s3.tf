data "aws_caller_identity" "current" {}

locals {
  tf_read_roles          = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleProwlerScanner", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformApplier", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformPlanner", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer"]
  tf_list_roles          = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleProwlerScanner", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformApplier", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformPlanner", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer"]
  tf_metadata_read_roles = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleProwlerScanner", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformApplier", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformPlanner", "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer"]
  tf_write_roles         = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformApplier"]
  tf_admin_roles         = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformApplier"]

  cf_templates_all_roles = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformApplier",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformPlanner",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleChangeSetCreator",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleIAMAdministrator",
  ]

  tf_state_bucket_name    = "platsec-ci20210713082841419000000002"
  access_logs_bucket_name = "platsec-ci-access-logs20220222104748703700000001"
}

module "access_logs" {
  source      = "../modules/access_logs_bucket"
  bucket_name = local.access_logs_bucket_name
  admin_roles = local.tf_admin_roles
  read_roles  = local.tf_read_roles
}

module "state_bucket" {
  source        = "hmrc/s3-bucket-standard/aws"
  version       = "1.7.0"
  bucket_name   = local.tf_state_bucket_name
  force_destroy = false

  list_roles          = local.tf_list_roles
  read_roles          = local.tf_read_roles
  metadata_read_roles = local.tf_metadata_read_roles
  write_roles         = local.tf_write_roles
  admin_roles         = local.tf_admin_roles

  data_expiry      = "forever-config-only"
  data_sensitivity = "high"

  log_bucket_id = module.access_logs.bucket_id
}

module "cf_templates_bucket" {
  source        = "hmrc/s3-bucket-standard/aws"
  version       = "1.7.0"
  bucket_name   = "cf-templates-1a94pgui3v5ft-eu-west-2"
  force_destroy = false

  list_roles          = local.cf_templates_all_roles
  read_roles          = local.cf_templates_all_roles
  write_roles         = local.cf_templates_all_roles
  metadata_read_roles = local.cf_templates_all_roles
  admin_roles         = local.tf_admin_roles

  data_expiry      = "90-days"
  data_sensitivity = "low"

  log_bucket_id = module.access_logs.bucket_id
}
