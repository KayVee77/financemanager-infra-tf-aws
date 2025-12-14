# =============================================================================
# Outputs
# =============================================================================
# Outputs that are useful for the application and debugging.
# These values can be used to configure the application or other systems.

# -----------------------------------------------------------------------------
# Networking (Dedicated VPC)
# -----------------------------------------------------------------------------

output "vpc_id" {
  description = "ID of the Terraform-managed VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the Terraform-managed VPC"
  value       = module.networking.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of private subnets"
  value       = module.networking.private_subnet_ids
}

# -----------------------------------------------------------------------------
# Application URL
# -----------------------------------------------------------------------------

output "app_url" {
  description = "The URL to access the application (CloudFront HTTPS or ALB HTTP)"
  value       = var.enable_cloudfront ? "https://${module.cloudfront[0].distribution_domain_name}" : "http://${module.alb.dns_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID (for cache invalidation)"
  value       = var.enable_cloudfront ? module.cloudfront[0].distribution_id : null
}

output "cloudfront_domain_name" {
  description = "CloudFront domain name"
  value       = var.enable_cloudfront ? module.cloudfront[0].distribution_domain_name : null
}

# -----------------------------------------------------------------------------
# Cognito
# -----------------------------------------------------------------------------

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.auth.user_pool_id
}

output "cognito_client_id" {
  description = "Cognito App Client ID"
  value       = module.auth.client_id
}

output "cognito_domain" {
  description = "Cognito hosted UI domain"
  value       = module.auth.cognito_domain
}

# -----------------------------------------------------------------------------
# Database
# -----------------------------------------------------------------------------

output "dynamodb_transactions_table" {
  description = "DynamoDB transactions table name"
  value       = module.database.transactions_table_name
}

output "dynamodb_categories_table" {
  description = "DynamoDB categories table name"
  value       = module.database.categories_table_name
}

# -----------------------------------------------------------------------------
# Container Registry
# -----------------------------------------------------------------------------

output "ecr_repository_url" {
  description = "ECR repository URL for Docker images"
  value       = module.ecr.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = module.ecr.repository_name
}

# -----------------------------------------------------------------------------
# ECS
# -----------------------------------------------------------------------------

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

# -----------------------------------------------------------------------------
# Load Balancer
# -----------------------------------------------------------------------------

output "alb_dns_name" {
  description = "ALB DNS name (HTTP only)"
  value       = module.alb.dns_name
}

output "alb_arn" {
  description = "ALB ARN"
  value       = module.alb.alb_arn
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = module.alb.target_group_arn
}

# -----------------------------------------------------------------------------
# AI API (Lambda + API Gateway)
# -----------------------------------------------------------------------------

output "ai_api_url" {
  description = "API Gateway URL for AI endpoints"
  value       = var.enable_lambda_ai ? module.api_gateway[0].api_url : null
}

output "lambda_function_name" {
  description = "Lambda function name for OpenAI integration"
  value       = var.enable_lambda_ai ? module.lambda[0].function_name : null
}

# -----------------------------------------------------------------------------
# Build Arguments for Docker
# -----------------------------------------------------------------------------

output "docker_build_args" {
  description = "Build arguments to use when building the Docker image"
  value = {
    VITE_DEV_ONLY_AUTH            = "false"
    VITE_RUNTIME                  = "aws"
    VITE_USE_DYNAMODB             = "true"
    VITE_AWS_COGNITO_USER_POOL_ID = module.auth.user_pool_id
    VITE_AWS_COGNITO_CLIENT_ID    = module.auth.client_id
    VITE_APP_URL                  = var.enable_cloudfront ? "https://${module.cloudfront[0].distribution_domain_name}" : "http://${module.alb.dns_name}"
    VITE_AI_API_URL               = var.enable_lambda_ai ? module.api_gateway[0].api_url : ""
  }
}

# -----------------------------------------------------------------------------
# Deployment Commands
# -----------------------------------------------------------------------------

output "deployment_commands" {
  description = "Helpful commands for deployment"
  value = {
    ecr_login     = "aws ecr get-login-password --region ${data.aws_region.current.name} | docker login --username AWS --password-stdin ${module.ecr.repository_url}"
    ecs_redeploy  = "aws ecs update-service --cluster ${module.ecs.cluster_name} --service ${module.ecs.service_name} --force-new-deployment --region ${data.aws_region.current.name}"
    cf_invalidate = var.enable_cloudfront ? "aws cloudfront create-invalidation --distribution-id ${module.cloudfront[0].distribution_id} --paths '/*'" : "N/A"
  }
}

# -----------------------------------------------------------------------------
# Resource Groups
# -----------------------------------------------------------------------------

output "resource_groups" {
  description = "ARNs of Resource Groups for easy resource management"
  value = {
    all_resources = aws_resourcegroups_group.financeflow_terraform.arn
    compute       = aws_resourcegroups_group.financeflow_compute.arn
    network       = aws_resourcegroups_group.financeflow_network.arn
    database      = aws_resourcegroups_group.financeflow_database.arn
    security      = aws_resourcegroups_group.financeflow_security.arn
    cdn_lb        = aws_resourcegroups_group.financeflow_cdn_lb.arn
    prod_env      = aws_resourcegroups_group.financeflow_prod.arn
  }
}

output "resource_group_console_urls" {
  description = "Direct URLs to Resource Groups in AWS Console"
  value = {
    all_resources = "https://console.aws.amazon.com/resource-groups/group/financeflow-terraform-resources"
    compute       = "https://console.aws.amazon.com/resource-groups/group/financeflow-terraform-compute"
    network       = "https://console.aws.amazon.com/resource-groups/group/financeflow-terraform-network"
    database      = "https://console.aws.amazon.com/resource-groups/group/financeflow-terraform-database"
    security      = "https://console.aws.amazon.com/resource-groups/group/financeflow-terraform-security"
    cdn_lb        = "https://console.aws.amazon.com/resource-groups/group/financeflow-terraform-cdn-lb"
    prod_env      = "https://console.aws.amazon.com/resource-groups/group/financeflow-terraform-prod"
  }
}
