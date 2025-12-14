# =============================================================================
# FinanceFlow Infrastructure - Main Configuration
# =============================================================================
# This is the root module that orchestrates all infrastructure components.
# All resources are prefixed with "tf_" to distinguish from manually created resources.
#
# IMPORTANT: This infrastructure runs in a dedicated Terraform-managed VPC,
# completely separate from the default VPC used by the existing manual POC.
#
# Architecture Overview:
# - Dedicated VPC with public and private subnets (10.10.0.0/16)
# - Cognito User Pool for authentication
# - DynamoDB for transactions and categories storage
# - ECR for Docker image storage
# - ECS Fargate for running the unified container (React + Express)
# - ALB for load balancing
# - CloudFront for HTTPS termination (Cognito requires HTTPS)
# - Lambda + API Gateway for OpenAI integration (optional)

# -----------------------------------------------------------------------------
# Data Sources
# -----------------------------------------------------------------------------

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

# -----------------------------------------------------------------------------
# Local Values
# -----------------------------------------------------------------------------

locals {
  # Name prefix for all Terraform-managed resources
  name_prefix = "tf_${var.project_name}-${var.environment}"

  # Name prefix for resources that don't allow underscores (ALB, etc.)
  name_prefix_alb = "tf-${var.project_name}-${var.environment}"

  # Get account and region from data sources
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # ECR image URI
  ecr_image_uri = "${module.ecr.repository_url}:${var.container_image_tag}"

  # Cognito callback URLs (add CloudFront URL dynamically)
  cognito_callback_urls = var.enable_cloudfront ? concat(
    var.cognito_callback_urls,
    ["https://${module.cloudfront[0].distribution_domain_name}/callback"]
  ) : var.cognito_callback_urls

  cognito_logout_urls = var.enable_cloudfront ? concat(
    var.cognito_logout_urls,
    ["https://${module.cloudfront[0].distribution_domain_name}"]
  ) : var.cognito_logout_urls

  # Common tags for all resources
  common_tags = {
    ManagedBy       = "terraform"
    TerraformPrefix = "tf_"
    Environment     = var.environment
    Project         = var.project_name
    Owner           = var.owner
  }
}

# -----------------------------------------------------------------------------
# Networking Module (Dedicated VPC)
# -----------------------------------------------------------------------------

module "networking" {
  source = "./modules/networking"

  name_prefix          = "tf"
  app_name             = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  enable_nat_gateway   = var.enable_nat_gateway
  container_port       = var.container_port
  common_tags          = local.common_tags
}

# -----------------------------------------------------------------------------
# IAM Module
# -----------------------------------------------------------------------------

module "iam" {
  source = "./modules/iam"

  name_prefix = local.name_prefix
  region      = local.region
  account_id  = local.account_id
  common_tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Cognito Module (Authentication)
# -----------------------------------------------------------------------------

module "auth" {
  source = "./modules/auth"

  name_prefix   = local.name_prefix
  callback_urls = local.cognito_callback_urls
  logout_urls   = local.cognito_logout_urls
  common_tags   = local.common_tags
}

# -----------------------------------------------------------------------------
# DynamoDB Module (Database)
# -----------------------------------------------------------------------------

module "database" {
  source = "./modules/database"

  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

# -----------------------------------------------------------------------------
# ECR Module (Container Registry)
# -----------------------------------------------------------------------------

module "ecr" {
  source = "./modules/ecr"

  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Lambda Module (OpenAI Integration)
# -----------------------------------------------------------------------------

module "lambda" {
  source = "./modules/lambda"
  count  = var.enable_lambda_ai ? 1 : 0

  name_prefix    = local.name_prefix
  openai_api_key = var.openai_api_key
  memory_size    = var.lambda_memory
  timeout        = var.lambda_timeout
  common_tags    = local.common_tags
}

# -----------------------------------------------------------------------------
# API Gateway Module (Lambda HTTP Endpoint)
# -----------------------------------------------------------------------------

module "api_gateway" {
  source = "./modules/api-gateway"
  count  = var.enable_lambda_ai ? 1 : 0

  name_prefix         = local.name_prefix
  lambda_function_arn = module.lambda[0].function_arn
  lambda_invoke_arn   = module.lambda[0].invoke_arn
  common_tags         = local.common_tags
}

# -----------------------------------------------------------------------------
# ALB Module (Application Load Balancer)
# -----------------------------------------------------------------------------

module "alb" {
  source = "./modules/alb"

  name_prefix       = local.name_prefix_alb
  vpc_id            = module.networking.vpc_id
  subnet_ids        = module.networking.public_subnet_ids
  security_group_id = module.networking.alb_security_group_id
  container_port    = var.container_port
  common_tags       = local.common_tags

  depends_on = [module.networking]
}

# -----------------------------------------------------------------------------
# ECS Module (Fargate Container Service)
# -----------------------------------------------------------------------------

module "ecs" {
  source = "./modules/ecs"

  name_prefix = local.name_prefix
  vpc_id      = module.networking.vpc_id

  # Use private subnets if NAT is enabled, otherwise public subnets
  subnet_ids = var.enable_nat_gateway ? module.networking.private_subnet_ids : module.networking.public_subnet_ids

  # Container configuration
  container_image = local.ecr_image_uri
  container_port  = var.container_port
  cpu             = var.ecs_cpu
  memory          = var.ecs_memory
  desired_count   = var.ecs_desired_count

  # IAM roles
  task_execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn           = module.iam.ecs_task_role_arn

  # Load balancer
  target_group_arn  = module.alb.target_group_arn
  security_group_id = module.networking.ecs_security_group_id

  # Assign public IP only if not using NAT Gateway
  assign_public_ip = !var.enable_nat_gateway

  # Environment variables for container
  environment_variables = {
    AWS_REGION        = local.region
    DYNAMODB_ENDPOINT = "https://dynamodb.${local.region}.amazonaws.com"
    NODE_ENV          = var.environment == "prod" ? "production" : "development"
  }

  # Secrets (optional)
  secrets = var.openai_api_key != "" ? {
    OPENAI_API_KEY = var.openai_api_key
  } : {}

  common_tags = local.common_tags

  depends_on = [module.alb, module.networking]
}

# -----------------------------------------------------------------------------
# CloudFront Module (HTTPS Distribution)
# -----------------------------------------------------------------------------

module "cloudfront" {
  source = "./modules/cloudfront"
  count  = var.enable_cloudfront ? 1 : 0

  providers = {
    aws = aws.us_east_1
  }

  name_prefix  = local.name_prefix
  alb_dns_name = module.alb.dns_name

  # API paths that should not be cached
  api_path_patterns = ["/users/*", "/api/*"]

  common_tags = local.common_tags

  depends_on = [module.alb]
}

# -----------------------------------------------------------------------------
# Resource Groups for Resource Management
# -----------------------------------------------------------------------------

# Main resource group for all FinanceFlow Terraform resources
resource "aws_resourcegroups_group" "financeflow_terraform" {
  name        = "financeflow-terraform-resources"
  description = "All resources managed by Terraform for FinanceFlow application"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        {
          Key    = "ManagedBy"
          Values = ["terraform"]
        },
        {
          Key    = "Project"
          Values = ["financeflow"]
        }
      ]
    })
  }

  tags = merge(local.common_tags, {
    Name = "FinanceFlow Terraform Resources"
  })
}

# Compute resources group (ECS, Lambda)
resource "aws_resourcegroups_group" "financeflow_compute" {
  name        = "financeflow-terraform-compute"
  description = "Compute resources - ECS and Lambda for FinanceFlow"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = [
        "AWS::ECS::Cluster",
        "AWS::ECS::Service",
        "AWS::ECS::TaskDefinition",
        "AWS::Lambda::Function"
      ]
      TagFilters = [
        {
          Key    = "ManagedBy"
          Values = ["terraform"]
        },
        {
          Key    = "Project"
          Values = ["financeflow"]
        }
      ]
    })
  }

  tags = merge(local.common_tags, {
    Name         = "FinanceFlow Compute Resources"
    ResourceType = "Compute"
  })
}

# Network resources group (VPC, Subnets, Security Groups)
resource "aws_resourcegroups_group" "financeflow_network" {
  name        = "financeflow-terraform-network"
  description = "Network resources - VPC Subnets and Security Groups for FinanceFlow"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = [
        "AWS::EC2::VPC",
        "AWS::EC2::Subnet",
        "AWS::EC2::SecurityGroup",
        "AWS::EC2::InternetGateway",
        "AWS::EC2::NatGateway",
        "AWS::EC2::RouteTable"
      ]
      TagFilters = [
        {
          Key    = "ManagedBy"
          Values = ["terraform"]
        },
        {
          Key    = "Project"
          Values = ["financeflow"]
        }
      ]
    })
  }

  tags = merge(local.common_tags, {
    Name         = "FinanceFlow Network Resources"
    ResourceType = "Network"
  })
}

# Database resources group (DynamoDB)
resource "aws_resourcegroups_group" "financeflow_database" {
  name        = "financeflow-terraform-database"
  description = "Database resources - DynamoDB tables for FinanceFlow"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = [
        "AWS::DynamoDB::Table"
      ]
      TagFilters = [
        {
          Key    = "ManagedBy"
          Values = ["terraform"]
        },
        {
          Key    = "Project"
          Values = ["financeflow"]
        }
      ]
    })
  }

  tags = merge(local.common_tags, {
    Name         = "FinanceFlow Database Resources"
    ResourceType = "Database"
  })
}

# Security resources group (Cognito, IAM)
resource "aws_resourcegroups_group" "financeflow_security" {
  name        = "financeflow-terraform-security"
  description = "Security resources - Cognito for FinanceFlow"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = [
        "AWS::Cognito::UserPool"
      ]
      TagFilters = [
        {
          Key    = "ManagedBy"
          Values = ["terraform"]
        },
        {
          Key    = "Project"
          Values = ["financeflow"]
        }
      ]
    })
  }

  tags = merge(local.common_tags, {
    Name         = "FinanceFlow Security Resources"
    ResourceType = "Security"
  })
}

# CDN and Load Balancing resources group
resource "aws_resourcegroups_group" "financeflow_cdn_lb" {
  name        = "financeflow-terraform-cdn-lb"
  description = "CDN and Load Balancing resources - CloudFront and ALB for FinanceFlow"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = [
        "AWS::CloudFront::Distribution",
        "AWS::ElasticLoadBalancingV2::LoadBalancer",
        "AWS::ElasticLoadBalancingV2::TargetGroup"
      ]
      TagFilters = [
        {
          Key    = "ManagedBy"
          Values = ["terraform"]
        },
        {
          Key    = "Project"
          Values = ["financeflow"]
        }
      ]
    })
  }

  tags = merge(local.common_tags, {
    Name         = "FinanceFlow CDN and Load Balancing"
    ResourceType = "CDN_LB"
  })
}

# Environment-specific resource group (Production)
resource "aws_resourcegroups_group" "financeflow_prod" {
  name        = "financeflow-terraform-prod"
  description = "Production environment resources for FinanceFlow"

  resource_query {
    query = jsonencode({
      ResourceTypeFilters = ["AWS::AllSupported"]
      TagFilters = [
        {
          Key    = "ManagedBy"
          Values = ["terraform"]
        },
        {
          Key    = "Project"
          Values = ["financeflow"]
        },
        {
          Key    = "Environment"
          Values = ["prod"]
        }
      ]
    })
  }

  tags = merge(local.common_tags, {
    Name        = "FinanceFlow Production Environment"
    Environment = "prod"
  })
}
