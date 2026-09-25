module "slack_v2_api_key_kms_policy" {
  source = "../modules/kms_key_policy"

  read_roles = concat(
    local.slack_v2_api_key_consumer_role_arns,
    [
      local.terraform_planner_role,
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleProwlerScanner",
    ]
  )

  describe_roles = local.slack_v2_api_key_consumer_planner_role_arns

  write_roles = [
    local.terraform_applier_role,
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer",
  ]

  admin_roles = [
    local.terraform_applier_role,
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleKmsAdministrator",
  ]
}

resource "aws_kms_key" "slack_v2_api_key" {
  description                        = "Encrypts the shared ${local.slack_v2_api_key_secret_name} secret"
  bypass_policy_lockout_safety_check = false
  deletion_window_in_days            = 30
  enable_key_rotation                = true
  rotation_period_in_days            = 90
  policy                             = module.slack_v2_api_key_kms_policy.policy_document_json
}

resource "aws_kms_alias" "slack_v2_api_key" {
  name          = "alias/service_accounts_slack_v2_api_key"
  target_key_id = aws_kms_key.slack_v2_api_key.id
}

module "external_github_token_kms_policy" {
  source = "../modules/kms_key_policy"

  read_roles = concat(
    local.external_github_token_consumer_role_arns,
    [
      local.terraform_planner_role,
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer",
    ]
  )

  describe_roles = local.external_github_token_consumer_terraform_role_arns

  write_roles = [
    local.terraform_applier_role,
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer",
  ]

  admin_roles = [
    local.terraform_applier_role,
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleKmsAdministrator",
  ]
}

resource "aws_kms_key" "external_github_token" {
  description                        = "Encrypts the shared ${local.external_github_token_secret_name} secret"
  bypass_policy_lockout_safety_check = false
  deletion_window_in_days            = 30
  enable_key_rotation                = true
  rotation_period_in_days            = 90
  policy                             = module.external_github_token_kms_policy.policy_document_json
}

resource "aws_kms_alias" "external_github_token" {
  name          = "alias/service_accounts_external_github_token"
  target_key_id = aws_kms_key.external_github_token.id
}

module "pagerduty_live_services_key_kms_policy" {
  source = "../modules/kms_key_policy"

  read_roles = concat(
    local.pagerduty_live_services_key_consumer_read_role_arns,
    [
      local.terraform_planner_role,
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer",
    ]
  )

  describe_roles = concat(
    local.pagerduty_live_services_key_consumer_terraform_role_arns,
    [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleProwlerScanner"
    ]
  )

  write_roles = [
    local.terraform_applier_role,
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer",
  ]

  admin_roles = [
    local.terraform_applier_role,
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleKmsAdministrator",
  ]
}

resource "aws_kms_key" "pagerduty_live_services_key" {
  description                        = "Encrypts the shared pagerduty_live_services_key secret"
  bypass_policy_lockout_safety_check = false
  deletion_window_in_days            = 30
  enable_key_rotation                = true
  rotation_period_in_days            = 90
  policy                             = module.pagerduty_live_services_key_kms_policy.policy_document_json
}

resource "aws_kms_alias" "pagerduty_live_services_key" {
  name          = "alias/service_accounts_pagerduty_live_services_key"
  target_key_id = aws_kms_key.pagerduty_live_services_key.id
}

module "pagerduty_lab_services_key_kms_policy" {
  source = "../modules/kms_key_policy"

  read_roles = concat(
    local.pagerduty_lab_services_key_consumer_read_role_arns,
    [
      local.terraform_planner_role,
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer",
    ]
  )

  describe_roles = concat(
    local.pagerduty_lab_services_key_consumer_terraform_role_arns,
    [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleProwlerScanner"
    ]
  )

  write_roles = [
    local.terraform_applier_role,
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleSecurityEngineer",
  ]

  admin_roles = [
    local.terraform_applier_role,
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleKmsAdministrator",
  ]
}

resource "aws_kms_key" "pagerduty_lab_services_key" {
  description                        = "Encrypts the shared pagerduty_lab_services_key secret"
  bypass_policy_lockout_safety_check = false
  deletion_window_in_days            = 30
  enable_key_rotation                = true
  rotation_period_in_days            = 90
  policy                             = module.pagerduty_lab_services_key_kms_policy.policy_document_json
}

resource "aws_kms_alias" "pagerduty_lab_services_key" {
  name          = "alias/service_accounts_pagerduty_lab_services_key"
  target_key_id = aws_kms_key.pagerduty_lab_services_key.id
}
