# =============================================================================
# Terraform and Provider Versions
# =============================================================================
# This file defines version constraints for Terraform and required providers.
# Terraform Cloud/Enterprise workspace should use these constraints.

terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}
