variable "pipeline_name" {
  type    = string
  default = "central-audit-pipeline"
}

variable "src_org" {
  type    = string
  default = "hmrc"
}

variable "src_repo" {
  type = string
}

variable "branch" {
  type    = string
  default = "main"
}


variable "test_timeout_in_minutes" {
  default = 30
}

variable "step_assume_roles" {
  type = list(map(map(string)))
}

variable "ci_agent_to_internet_sg_id" {
  type = string
}

variable "ci_agent_to_endpoints_sg_id" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}

variable "vpc_config" {
  type = object({
    private_subnet_ids  = list(string),
    private_subnet_arns = list(string),
    vpc_id              = string,
  })
}

variable "access_log_bucket_id" {
  type = string
}

variable "admin_role" {
  description = "The role for bucket policy admin"
  type        = string
}

variable "github_token" {
  type = string
}
