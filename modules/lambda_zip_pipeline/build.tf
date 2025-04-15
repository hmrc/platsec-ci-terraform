module "build_timestamp_step" {
  source      = "../build_timestamp_step"
  step_name   = "${module.common.pipeline_name}-timestamp"
  policy_arns = [module.common.policy_build_core_arn]

  tags = var.tags
}

module "zip-deployment-step-development" {
  source = "../zip_deployment_step"

  lambda_arn                     = "arn:aws:lambda:${var.target_region}:${var.accounts.development.id}:function:${var.lambda_function_name}"
  lambda_deployment_package_name = var.lambda_deployment_package_name
  step_name                      = "${module.common.pipeline_name}-development"
  build_core_policy_arn          = module.common.policy_build_core_arn
  deployment_role_arn            = var.accounts.development.role_arns["lambda-deploy"]

  vpc_config               = var.vpc_config
  agent_security_group_ids = [var.agent_security_group_ids.service_endpoints]

  tags = var.tags
}

module "zip-deployment-step-production" {
  source = "../zip_deployment_step"

  lambda_arn                     = "arn:aws:lambda:${var.target_region}:${var.accounts.production.id}:function:${var.lambda_function_name}"
  step_name                      = "${module.common.pipeline_name}-production"
  lambda_deployment_package_name = var.lambda_deployment_package_name
  build_core_policy_arn          = module.common.policy_build_core_arn
  deployment_role_arn            = var.accounts.production.role_arns["lambda-deploy"]

  vpc_config               = var.vpc_config
  agent_security_group_ids = [var.agent_security_group_ids.service_endpoints]

  tags = var.tags
}
