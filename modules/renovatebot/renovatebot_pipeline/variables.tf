variable "github_token" {
  description = "GitHub Personal Access Token for Renovate"
  type        = string
  sensitive   = true
}

variable "slack_webhook_url" {
  description = "Slack Webhook URL for notifications"
  type        = string
  sensitive   = true
}

variable "codeconnection_arn" {
  description = "CodeStar connection ARN for GitHub"
  type        = string
}

variable "src_org" {
  description = "GitHub organization name"
  type        = string
}

variable "src_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "branch" {
  description = "Branch to track for the source stage"
  type        = string
  default     = "main"
}

variable "tags" {
  type        = map(string)
  description = "A map of key, value pairs to be added to resources as tags"
  default     = {}
}
