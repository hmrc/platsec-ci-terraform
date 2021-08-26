variable "name_prefix" {
  type = string
}

variable "branch" {
  type    = string
  default = "main"
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

variable "vpc_config" {
  type = object({
    private_subnet_ids   = list(string),
    private_subnet_arns  = list(string),
    ci_security_group_id = string,
    vpc_id               = string
  })
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
