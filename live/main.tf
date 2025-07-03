locals {
  environment          = "live"
  state_bucket         = "platsec-ci20210713082841419000000002"
  prefix               = "platsec-ci-"
  step_roles           = toset(["lambda-deploy", "ecs-task-update", "terraform-applier", "terraform-planner"])
  access_log_bucket_id = nonsensitive(data.aws_secretsmanager_secret_version.s3_access_logs_bucket_name.secret_string)

  accounts = {
    sandbox : {
      id : nonsensitive(tonumber(data.aws_secretsmanager_secret_version.sandbox_account_id.secret_string))
      role_arns : { for role, secret in data.aws_secretsmanager_secret_version.sandbox_role_arn : role => nonsensitive(secret.secret_string) }
    }
    development : {
      id : nonsensitive(tonumber(data.aws_secretsmanager_secret_version.development_account_id.secret_string))
      role_arns : { for role, secret in data.aws_secretsmanager_secret_version.development_role_arn : role => nonsensitive(secret.secret_string) }
    }

    production : {
      id : nonsensitive(tonumber(data.aws_secretsmanager_secret_version.production_account_id.secret_string))
      role_arns : { for role, secret in data.aws_secretsmanager_secret_version.production_role_arn : role => nonsensitive(secret.secret_string) }
    }

    central_audit_production : {
      id : nonsensitive(tonumber(data.aws_secretsmanager_secret_version.central_audit_production_account_id.secret_string))
      role_arns : { for role, secret in data.aws_secretsmanager_secret_version.central_audit_production_role_arn : role => nonsensitive(secret.secret_string) }
    }

    central_audit_development : {
      id : nonsensitive(tonumber(data.aws_secretsmanager_secret_version.central_audit_development_account_id.secret_string))
      role_arns : { for role, secret in data.aws_secretsmanager_secret_version.central_audit_development_role_arn : role => nonsensitive(secret.secret_string) }
    }
  }
  all_platsec_account_ids = [for account in values(local.accounts) : account.id]

  tf_admin_roles = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformApplier",
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/RoleTerraformPlanner",
  ]
  vpc_config               = data.terraform_remote_state.ci.outputs.vpc_config
  agent_security_group_ids = data.terraform_remote_state.ci.outputs.agent_security_group_ids
  ci_alerts_sns_topic_arn  = data.terraform_remote_state.ci.outputs.sns_topic_arn
}

module "label" {
  source = "github.com/hmrc/terraform-null-label?ref=0.25.0"

  namespace = "mdtp"
  stage     = local.environment
  name      = "platsec-ci"
}

