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

variable "build_core_policy_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:", var.build_core_policy_arn))
    error_message = "Arn must be given and should start with 'arn:aws:'."
  }
}

variable "ecr_url" {
  type = string
}

variable "ecr_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:", var.ecr_arn))
    error_message = "Arn must be given and should start with 'arn:aws:'."
  }
}

variable "tags" {
  type        = map(string)
  description = "A map of key, value pairs to be added to resources as tags"
  default     = {}
}

variable "upload_image_timeout_in_minutes" {
  type    = string
  default = 5
}
