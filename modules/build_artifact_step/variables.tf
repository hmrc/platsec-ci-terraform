variable "name_prefix" {
  type = string
}

variable "docker_required" {
  type = bool
}

variable "s3_bucket_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:s3:", var.s3_bucket_arn))
    error_message = "Arn must be given and should start with 'arn:aws:s3:'."
  }
}

variable "build_core_policy_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:iam:", var.build_core_policy_arn))
    error_message = "Arn must be given and should start with 'arn:aws:iam:'."
  }
}