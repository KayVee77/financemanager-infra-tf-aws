# =============================================================================
# AWS Provider Configuration
# =============================================================================
# Provider configuration with default tags applied to all resources.

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = var.owner
      CostCenter  = "thesis-project"
    }
  }
}

# Provider for CloudFront (must be us-east-1 for some resources)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Owner       = var.owner
      CostCenter  = "thesis-project"
    }
  }
}
