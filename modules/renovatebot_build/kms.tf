locals {
  readers = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformPlanner",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleProwlerScanner",
  ]
  writers = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformApplier",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer",
  ]
  admins = concat(var.admin_roles, ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleKmsAdministrator"])
}

module "kms_key_policy_document" {
  source = "../kms_key_policy"

  read_roles  = local.readers
  write_roles = local.writers
  admin_roles = local.admins
}

resource "aws_kms_key" "this" {
  bypass_policy_lockout_safety_check = false
  deletion_window_in_days            = 7
  enable_key_rotation                = true
  rotation_period_in_days            = 90
  policy                             = module.kms_key_policy_document.policy_document_json
  tags                               = var.tags
}

resource "aws_kms_alias" "this" {
  name_prefix   = "alias/${local.name}"
  target_key_id = aws_kms_key.this.id
}
