variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket to create"
}

variable "admin_roles" {
  type        = list(string)
  description = "A list of roles to allow admin access to bucket"
  default     = []
}

variable "read_roles" {
  type        = list(string)
  description = "A list of ARNs to allow actions for reading files"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A map of key, value pairs to be added to resources as tags"
  default     = {}
}

variable "grant_current_provisioner_admin_access" {
  type        = bool
  description = "Whether to automatically grant the IAM role currently running Terraform admin access to the bucket, to avoid accidental self-lockout. Set to false if the role running plan (e.g. a read-only planner role) should never gain admin access."
  default     = false
}
