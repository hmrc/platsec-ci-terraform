variable "name_prefix" {
  type = string
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

variable "s3_bucket_name" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:s3", var.s3_bucket_arn))
    error_message = "Arn must be given and should start with 'arn:aws:s3'."
  }
}

variable "github_connection_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:", var.github_connection_arn))
    error_message = "Arn must be given and should start with 'arn:aws:'."
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

variable "kms_key_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:kms", var.kms_key_arn))
    error_message = "Arn must be given and should start with 'arn:aws:kms'."
  }
}