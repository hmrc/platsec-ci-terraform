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

module "upload_to_artifactory_step" {
  source           = "../upload_to_artifactory_step"
  step_name        = "${module.common.pipeline_name}-artifactory"
  docker_repo_name = var.src_repo
  policy_arns      = [module.common.policy_build_core_arn, module.common.policy_get_artifactory_credentials_arn]

  artifactory_secret_manager_names = module.common.artifactory_secret_manager_names
  vpc_config                       = var.vpc_config
  agent_security_group_ids         = [var.ci_agent_to_endpoints_sg_id]
}

module "upload_to_ecr_development" {
  source = "../upload_to_ecr_step"

  step_name             = "${module.common.pipeline_name}-ecr-development"
  build_core_policy_arn = module.common.policy_build_core_arn
  ecr_url               = "${var.accounts.development.id}.dkr.ecr.${var.target_region}.amazonaws.com/${var.ecr_name}"
  deployment_role_arn   = var.accounts.development.role_arns["ecr-upload"]

  vpc_config               = var.vpc_config
  agent_security_group_ids = [var.ci_agent_to_endpoints_sg_id]
}

module "docker_deployment_development" {
  source = "../update_task_definition_step"

  step_name             = "${module.common.pipeline_name}-deploy-development"
  build_core_policy_arn = module.common.policy_build_core_arn
  deployment_role_arn   = var.accounts.development.role_arns["ecs-task-update"]
  ecr_url               = "${var.accounts.development.id}.dkr.ecr.${var.target_region}.amazonaws.com/${var.ecr_name}"
  task_name             = var.task_name
  service_name          = var.service_name
  cluster_name          = var.cluster_name

  vpc_config               = var.vpc_config
  agent_security_group_ids = [var.ci_agent_to_endpoints_sg_id]
}

module "upload_to_ecr_production" {
  source = "../upload_to_ecr_step"

  step_name             = "${module.common.pipeline_name}-ecr-production"
  build_core_policy_arn = module.common.policy_build_core_arn
  ecr_url               = "${var.accounts.production.id}.dkr.ecr.${var.target_region}.amazonaws.com/${var.ecr_name}"
  deployment_role_arn   = var.accounts.production.role_arns["ecr-upload"]

  vpc_config               = var.vpc_config
  agent_security_group_ids = [var.ci_agent_to_endpoints_sg_id]
}

module "docker_deployment_production" {
  source = "../update_task_definition_step"

  step_name             = "${module.common.pipeline_name}-deploy-production"
  build_core_policy_arn = module.common.policy_build_core_arn
  deployment_role_arn   = var.accounts.production.role_arns["ecs-task-update"]
  ecr_url               = "${var.accounts.production.id}.dkr.ecr.${var.target_region}.amazonaws.com/${var.ecr_name}"
  task_name             = var.task_name
  service_name          = var.service_name
  cluster_name          = var.cluster_name

  vpc_config               = var.vpc_config
  agent_security_group_ids = [var.ci_agent_to_endpoints_sg_id]
}
