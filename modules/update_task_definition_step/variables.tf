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

variable "task_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "deployment_role_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws:", var.deployment_role_arn))
    error_message = "Must be role arn."
  }
}

variable "tags" {
  type        = map(string)
  description = "A map of key, value pairs to be added to resources as tags"
  default     = {}
}