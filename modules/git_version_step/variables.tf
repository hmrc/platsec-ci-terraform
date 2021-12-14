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

variable "repository_url" {
  type        = string
  description = "full url to public repository"
}

variable "branch" {
  type = string
}
