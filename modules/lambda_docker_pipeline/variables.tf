variable "name_prefix" {
  type = string
}

variable "branch" {
  type    = string
  default = "main"
}

variable "docker_build_required" {
  type    = bool
  default = false
}

variable "pipeline_name" {
  type = string
}

variable "src_org" {
  type = string
}

variable "src_repo" {
  type = string
}

variable "github_connection_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:", var.github_connection_arn))
    error_message = "Arn must be given and should start with 'arn:aws:'."
  }
}

variable "lambda_function_name" {
  type = string
}

variable "ecr_name" {
  type = string
}

variable "target_region" {
  type        = string
  default     = "eu-west-2"
  description = "The region that lambdas will be deployed into"
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
