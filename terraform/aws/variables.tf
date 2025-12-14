# =============================================================================
# Input Variables
# =============================================================================
# Variables for configuring the FinanceFlow infrastructure.
# 
# WORKSPACE VARIABLE CONFIGURATION:
# Set these in Terraform Cloud/Enterprise workspace variables:
#
# REQUIRED (sensitive - set as "Sensitive"):
#   - openai_api_key: OpenAI API key for budget suggestions
#
# REQUIRED (standard):
#   - environment: "prod", "dev", or "staging"
#   - aws_region: AWS region (default: eu-central-1)
#
# OPTIONAL:
#   - container_image_tag: Docker image tag (default: "latest")
#   - ecs_desired_count: Number of ECS tasks (default: 1)

# -----------------------------------------------------------------------------
# General Configuration
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Name of the project, used in resource naming"
  type        = string
  default     = "financeflow"
}

variable "environment" {
  description = "Environment name (prod, dev, staging)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["prod", "dev", "staging"], var.environment)
    error_message = "Environment must be one of: prod, dev, staging."
  }
}

variable "owner" {
  description = "Owner of the resources (for tagging)"
  type        = string
  default     = "thesis-student"
}

# -----------------------------------------------------------------------------
# AWS Configuration
# -----------------------------------------------------------------------------

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}

variable "aws_account_id" {
  description = "AWS Account ID (auto-detected if not provided)"
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Networking (uses default VPC if not specified)
# -----------------------------------------------------------------------------

variable "vpc_cidr" {
  description = "CIDR block for the dedicated Terraform VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets (one per AZ)"
  type        = list(string)
  default     = ["10.10.0.0/20", "10.10.16.0/20", "10.10.32.0/20"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets (one per AZ)"
  type        = list(string)
  default     = ["10.10.64.0/20", "10.10.80.0/20", "10.10.96.0/20"]
}

variable "availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets (allows ECS in private subnets to access internet)"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Cognito Configuration
# -----------------------------------------------------------------------------

variable "cognito_callback_urls" {
  description = "Allowed callback URLs for Cognito OAuth2"
  type        = list(string)
  default = [
    "http://localhost:5173/callback",
    "http://localhost:3000/callback"
  ]
}

variable "cognito_logout_urls" {
  description = "Allowed logout URLs for Cognito"
  type        = list(string)
  default = [
    "http://localhost:5173",
    "http://localhost:3000"
  ]
}

# -----------------------------------------------------------------------------
# ECS Configuration
# -----------------------------------------------------------------------------

variable "ecs_cpu" {
  description = "CPU units for ECS task (256 = 0.25 vCPU)"
  type        = number
  default     = 512 # 0.5 vCPU
}

variable "ecs_memory" {
  description = "Memory (MB) for ECS task"
  type        = number
  default     = 1024 # 1 GB
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 1
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
  default     = 8080
}

variable "container_image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}

# -----------------------------------------------------------------------------
# Lambda Configuration
# -----------------------------------------------------------------------------

variable "lambda_memory" {
  description = "Memory (MB) for Lambda function"
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Timeout (seconds) for Lambda function"
  type        = number
  default     = 30
}

# -----------------------------------------------------------------------------
# Secrets (set as sensitive in Terraform Cloud workspace)
# -----------------------------------------------------------------------------

variable "openai_api_key" {
  description = "OpenAI API key for budget suggestions (set as sensitive in workspace)"
  type        = string
  sensitive   = true
  default     = ""
}

# -----------------------------------------------------------------------------
# Feature Flags
# -----------------------------------------------------------------------------

variable "enable_cloudfront" {
  description = "Enable CloudFront distribution for HTTPS"
  type        = bool
  default     = true
}

variable "enable_lambda_ai" {
  description = "Enable Lambda function for OpenAI integration"
  type        = bool
  default     = true
}

# -----------------------------------------------------------------------------
# Naming Prefix
# -----------------------------------------------------------------------------

variable "resource_prefix" {
  description = "Prefix for all Terraform-managed resources (avoids conflicts with manual resources)"
  type        = string
  default     = "tf"
}
