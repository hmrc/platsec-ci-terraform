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

variable "deployment_role_arn_development" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:iam::.*:role", var.deployment_role_arn_development))
    error_message = "Must be a role ARN."
  }
}

variable "deployment_role_arn_production" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:iam::.*:role", var.deployment_role_arn_production))
    error_message = "Must be a role ARN."
  }
}

variable "deploy_production_lambda_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:lambda:", var.deploy_production_lambda_arn))
    error_message = "Arn must be given and should start with 'arn:aws:lambda:'."
  }
}

variable "deploy_development_lambda_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:lambda:", var.deploy_development_lambda_arn))
    error_message = "Arn must be given and should start with 'arn:aws:lambda:'."
  }
}

