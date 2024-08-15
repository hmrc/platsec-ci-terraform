variable "name" {
  type        = string
  description = "(Required) The name of the connection to be created. The name must be unique in the calling AWS account. Changing name will create a new resource."
}

variable "tags" {
  type        = map(string)
  description = "(Optional) Map of key-value resource tags to associate with the resource. If configured with a provider default_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level."
  default     = {}
}