module "access_logs" {
  source             = "../modules/access_logs_bucket"
  account_id         = data.aws_caller_identity.current.id
  bucket_name_prefix = var.boostrap_name
}

data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret_version" "s3_state_bucket_name" {
  secret_id = "/terraform/platsec-ci-state-bucket-name"
}

locals {
  tf_provisioner_role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformProvisioner"
}

module "state_bucket" {
  source        = "hmrc/s3-bucket-standard/aws"
  version       = "0.1.2"
  bucket_name   = nonsensitive(data.aws_secretsmanager_secret_version.s3_state_bucket_name.secret_string)
  force_destroy = false

  list_roles  = [local.tf_provisioner_role]
  read_roles  = [local.tf_provisioner_role]
  write_roles = [local.tf_provisioner_role]

  data_expiry      = "10-years"
  data_sensitivity = "high"

  log_bucket_id = module.access_logs.bucket_id
}
