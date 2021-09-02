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

variable "policy_arns" {
  type = list(string)
}

variable "package_name" {
  type        = string
  description = "Name of package used for ZIP, usually name of the repository."
}
