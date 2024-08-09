variable "pipeline" {
  type = string
}

variable "src_org" {
  type    = string
  default = "hmrc"
}

variable "src_repo" {
  type = string
}

variable "github_token" {
  type = string
}

variable "vpc_config" {
  type = object({
    private_subnet_ids  = list(string),
    private_subnet_arns = list(string),
    vpc_id              = string,
  })
}

variable "sns_topic_arn" {
  type    = string
  default = null
}

variable "access_log_bucket_id" {
  description = "The name of the access log bucket"
  type        = string
}

variable "admin_roles" {
  type        = list(string)
  description = "A list of roles to allow admin access to bucket"
  default     = []
}
