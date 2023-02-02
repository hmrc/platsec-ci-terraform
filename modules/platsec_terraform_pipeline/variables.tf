variable "pipeline_name" {
  type    = string
  default = "terraform-pipeline"
}

variable "src_org" {
  type    = string
  default = "hmrc"
}

variable "src_repo" {
  type    = string
  default = "platsec-terraform"
}

variable "branch" {
  type    = string
  default = "main"
}

variable "sns_topic_arn" {
  type    = string
  default = null
}


variable "test_timeout_in_minutes" {
  default = 15
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

variable "vpc_config" {
  type = object({
    private_subnet_ids  = list(string),
    private_subnet_arns = list(string),
    vpc_id              = string,
  })
}

variable "admin_role" {
  description = "The role for bucket policy admin"
  type        = string
}

variable "access_log_bucket_id" {
  type = string
}

variable "github_token" {
  type = string
}

