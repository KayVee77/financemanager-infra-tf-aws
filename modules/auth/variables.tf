variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "callback_urls" {
  description = "Allowed OAuth2 callback URLs"
  type        = list(string)
}

variable "logout_urls" {
  description = "Allowed logout URLs"
  type        = list(string)
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
