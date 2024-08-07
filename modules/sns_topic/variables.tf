variable "topic_name" {
  description = "SNS Topic Name"
  type        = string
}

variable "override_policy_json" {
  description = "Override policy document for SNS topic"
  type        = string
  default     = null
}

variable "subscriber_account_numbers" {
  description = "AWS account number of subscribers"
  type        = list(string)
}