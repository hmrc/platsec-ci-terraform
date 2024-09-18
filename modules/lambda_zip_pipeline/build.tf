module "build_artifact_step" {
  source = "../build_artifact_step"

  docker_required = var.docker_build_required
  policy_arns     = [module.common.policy_build_core_arn, module.common.policy_get_artifactory_credentials_arn]
  step_name       = "${module.common.pipeline_name}-build"
  s3_bucket_arn   = module.common.bucket_arn

  vpc_config                       = var.vpc_config
  agent_security_group_ids         = values(var.agent_security_group_ids)
  artifactory_secret_manager_names = module.common.artifactory_secret_manager_names

  tags = var.tags
}

module "build_timestamp_step" {
  source      = "../build_timestamp_step"
  step_name   = "${module.common.pipeline_name}-timestamp"
  policy_arns = [module.common.policy_build_core_arn]

  tags = var.tags
}

module "zip_upload_artifactory_step" {
  source       = "../zip_upload_step"
  step_name    = "${module.common.pipeline_name}-artifactory"
  package_name = var.src_repo
  policy_arns  = [module.common.policy_build_core_arn, module.common.policy_get_artifactory_credentials_arn]

  artifactory_secret_manager_names = module.common.artifactory_secret_manager_names
  vpc_config                       = var.vpc_config
  agent_security_group_ids         = [var.agent_security_group_ids.service_endpoints]

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
