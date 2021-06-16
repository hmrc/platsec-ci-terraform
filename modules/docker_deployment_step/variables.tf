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

variable "ecr_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:ecr:", var.ecr_arn))
    error_message = "Arn must be given and should start with 'arn:aws:ecr:'."
  }
}

variable "ecr_url" {
  type = string
}

variable "lambda_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:lambda:", var.lambda_arn))
    error_message = "Arn must be given and should start with 'arn:aws:lambda:'."
  }
}


