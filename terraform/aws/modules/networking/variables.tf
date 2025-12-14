# =============================================================================
# Networking Module - Variables
# =============================================================================

variable "name_prefix" {
  description = "Prefix for resource names (e.g., 'tf')"
  type        = string
  default     = "tf"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "financeflow"
}

variable "environment" {
  description = "Environment name (e.g., 'poc', 'prod')"
  type        = string
  default     = "poc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.10.64.0/20", "10.10.80.0/20", "10.10.96.0/20"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "container_port" {
  description = "Container port for ECS security group rules"
  type        = number
  default     = 8080
}

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    ManagedBy       = "terraform"
    TerraformPrefix = "tf_"
  }
}
