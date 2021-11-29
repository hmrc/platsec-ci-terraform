variable "name_prefix" {
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
