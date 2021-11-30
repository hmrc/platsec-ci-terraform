variable "step_name" {
  type = string
}

variable "vpc_config" {
  type = object({
    private_subnet_ids  = list(string),
    private_subnet_arns = list(string),
    vpc_id              = string,
  })
}

variable "agent_security_group_ids" {
  type = list(string)
}

variable "artifactory_secret_manager_names" {
  type = object({
    token    = string,
    username = string,
  })
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

variable "policy_arns" {
  type = list(string)
}
