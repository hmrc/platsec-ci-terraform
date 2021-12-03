variable "branch" {
  type    = string
  default = "main"
}

variable "docker_build_required" {
  type    = bool
  default = true
}

variable "pipeline_name" {
  type = string
}

variable "src_org" {
  type    = string
  default = "hmrc"
}

variable "src_repo" {
  type = string
}

variable "vpc_config" {
  type = object({
    private_subnet_ids  = list(string),
    private_subnet_arns = list(string),
    vpc_id              = string,
  })
}

variable "ci_agent_to_internet_sg_id" {
  type = string
}
variable "ci_agent_to_endpoints_sg_id" {
  type = string
}

variable "lambda_function_name" {
  type = string
}

variable "target_region" {
  type        = string
  default     = "eu-west-2"
  description = "The region that lambdas will be deployed into"
}

variable "github_token" {
  type = string
}

variable "accounts" {
  type = object({
    sandbox = object({
      id        = number,
      role_arns = map(string),
    }),
    development = object({
      id        = number,
      role_arns = map(string),
    }),
    production = object({
      id        = number,
      role_arns = map(string),
    }),
  })
}
