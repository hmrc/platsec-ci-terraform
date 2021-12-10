module "build_artifact_step" {
  source = "../build_artifact_step"

  docker_required = true
  step_name       = "${module.common.pipeline_name}-build"

  s3_bucket_arn                    = module.common.bucket_arn
  vpc_config                       = var.vpc_config
  agent_security_group_ids         = [var.ci_agent_to_endpoints_sg_id, var.ci_agent_to_internet_sg_id]
  policy_arns                      = [module.common.policy_build_core_arn, module.common.policy_get_artifactory_credentials_arn]
  artifactory_secret_manager_names = module.common.artifactory_secret_manager_names
}

module "build_timestamp_step" {
  source      = "../build_timestamp_step"
  step_name   = "${module.common.pipeline_name}-timestamp"
  policy_arns = [module.common.policy_build_core_arn]

  vpc_config               = var.vpc_config
  agent_security_group_ids = [var.ci_agent_to_endpoints_sg_id]
}

module "upload_to_ecr_sandbox" {
  source = "../upload_to_ecr_step"

  step_name             = "${module.common.pipeline_name}-ecr-sandbox"
  build_core_policy_arn = module.common.policy_build_core_arn
  ecr_url               = "${var.accounts.sandbox.id}.dkr.ecr.${var.target_region}.amazonaws.com/${var.ecr_name}"
  deployment_role_arn   = var.accounts.sandbox.role_arns["ecr-upload"]

  vpc_config               = var.vpc_config
  agent_security_group_ids = [var.ci_agent_to_endpoints_sg_id]
}

module "docker_deployment_sandbox" {
  source = "../docker_deployment_step"

  step_name             = "${module.common.pipeline_name}-deploy-sandbox"
  build_core_policy_arn = module.common.policy_build_core_arn
  lambda_arn            = "arn:aws:lambda:${var.target_region}:${var.accounts.sandbox.id}:function:${var.lambda_function_name}"
  ecr_url               = "${var.accounts.sandbox.id}.dkr.ecr.${var.target_region}.amazonaws.com/${var.ecr_name}"
  deployment_role_arn   = var.accounts.sandbox.role_arns["lambda-deploy"]

  vpc_config               = var.vpc_config
  agent_security_group_ids = [var.ci_agent_to_endpoints_sg_id]
}
