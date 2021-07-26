variable "name_prefix" {
  type = string
}

variable "build_core_policy_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:", var.build_core_policy_arn))
    error_message = "Arn must be given and should start with 'arn:aws:'."
  }
}

variable "deployment_role_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:", var.deployment_role_arn))
    error_message = "Must be role arn."
  }
}

variable "lambda_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:lambda:", var.lambda_arn))
    error_message = "Arn must be given and should start with 'arn:aws:lambda:'."
  }
}


