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

variable "artifactory_secret_manager_names" {
  type = object({
    token    = string
    username = string,
  })
}

variable "agent_security_group_ids" {
  type = list(string)
}

variable "docker_repo_name" {
  type = string
}

variable "policy_arns" {
  type = list(string)
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
