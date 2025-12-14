variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "enable_pitr" {
  description = "Enable Point-in-Time Recovery for DynamoDB tables"
  type        = bool
  default     = false # Disabled for thesis to save costs
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
