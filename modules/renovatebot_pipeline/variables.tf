variable "repositories" {
  # just a long string for now
  type = list(string)
}

variable "target_region" {
  type        = string
  default     = "eu-west-2"
  description = "The region that lambdas will be deployed into"
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

variable "codeconnection_arn" {
  type        = string
  description = "The codestar connection ARN."
}

variable "tags" {
  type        = map(string)
  description = "A map of key, value pairs to be added to resources as tags"
  default     = {}
}

variable "build_timeout_in_minutes" {
  type        = number
  description = "The timeout in minutes for the CodeBuild project"
  default     = 60
}

