variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "alb_dns_name" {
  description = "ALB DNS name"
  type        = string
}

variable "api_path_patterns" {
  description = "Path patterns for API (no caching)"
  type        = list(string)
  default     = ["/users/*", "/api/*"]
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
