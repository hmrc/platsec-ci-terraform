variable "branch" {
  type    = string
  default = "main"
}

variable "docker_build_required" {
  type    = bool
  default = true
}

variable "pipeline_name" {
  type = string
  validation {
    condition     = can(regex("^[0-9a-z-]+$", var.pipeline_name))
    error_message = "Due to resource name limitations only lowercase alphanumeric characters and hyphens are allowed in pipeline names."
  }
}

variable "src_org" {
  type    = string
  default = "hmrc"
}

variable "src_repo" {
  type = string
}

variable "vpc_config" {
  type = object({
    private_subnet_ids  = list(string),
    private_subnet_arns = list(string),
    vpc_id              = string,
  })
}

variable "agent_security_group_ids" {
  description = "A map of CI agent security group ids"
  type = object({
    internet          = string
    service_endpoints = string
  })
}

variable "lambda_function_name" {
  type = string
}

variable "target_region" {
  type        = string
  default     = "eu-west-2"
  description = "The region that lambdas will be deployed into"
}

variable "github_token" {
  type = string
}

variable "accounts" {
  type = object({
    sandbox = object({
      id        = number,
      role_arns = map(string),
    }),
    development = object({
      id        = number,
      role_arns = map(string),
    }),
    production = object({
      id        = number,
      role_arns = map(string),
    }),
  })
}

variable "sns_topic_arn" {
  type    = string
  default = null
}

variable "access_log_bucket_id" {
  type = string
}

variable "admin_roles" {
  type        = list(string)
  description = "A list of roles to allow admin access to bucket"
  default     = []
}

variable "lambda_deployment_package_name" {
  type    = string
  default = "lambda.zip"
}
