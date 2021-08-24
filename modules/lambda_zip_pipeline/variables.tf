variable "name_prefix" {
  type = string
}

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
}

variable "src_org" {
  type    = string
  default = "hmrc"
}

variable "src_repo" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "target_region" {
  type        = string
  default     = "eu-west-2"
  description = "The region that lambdas will be deployed into"
}

variable "source_v1_oauth_token" {
  type = string
}

variable "accounts" {
  type = object({
    sandbox = object({
      id                  = number,
      deployment_role_arn = string,
    }),
    development = object({
      id                  = number,
      deployment_role_arn = string,
    }),
    production = object({
      id                  = number,
      deployment_role_arn = string,
    }),
  })
}
