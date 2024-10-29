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

variable "access_log_bucket_id" {
  type = string
}

variable "admin_roles" {
  type        = list(string)
  description = "A list of roles to allow admin access to bucket"
  default     = []
}

variable "agent_security_group_ids" {
  description = "A map of CI agent security group ids"
  type = object({
    internet          = string
    service_endpoints = string
  })
}

variable "build_timeout_in_minutes" {
  type        = number
  description = "The timeout in minutes for the CodeBuild project"
  default     = 60
}

variable "codeconnection_arn" {
  type        = string
  description = "The codestar connection ARN."
}

variable "enable_break_points" {
  default     = false
  description = "Enable SSM codebuild-breakpoint capabilities for CodeBuild."
  type        = bool
}

variable "enable_debug" {
  default     = false
  description = "Run RenovateBot in debug mode."
  type        = bool
}

variable "enable_dry_run" {
  default     = false
  description = "Run RenovateBot in dry-run mode."
  type        = bool
}

variable "repositories" {
  description = "The list of repositories you would like to monitor with RenovateBot in {org}/{repository} format."
  type        = list(string)
  default     = []
}

variable "sns_topic_arn" {
  description = "SNS topic to send failure notifications to."
  type        = string
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "A map of key, value pairs to be added to resources as tags"
  default     = {}
}

variable "vpc_config" {
  type = object({
    private_subnet_ids  = list(string),
    private_subnet_arns = list(string),
    vpc_id              = string,
  })
}