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

variable "policy_arns" {
  type = list(string)
}

variable "repository_name" {
  type = string
}

variable "use_release_version_explicitly" {
  default = true
}

variable "tags" {
  type        = map(string)
  description = "A map of key, value pairs to be added to resources as tags"
  default     = {}
}