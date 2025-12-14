# =============================================================================
# Terraform Cloud/Enterprise Backend Configuration
# =============================================================================
# Configure remote state storage in Terraform Cloud/Enterprise.
# 
# WORKSPACE SETUP:
# - Create workspace in Terraform Cloud named: financeflow-<env> (e.g., financeflow-prod)
# - Set execution mode to "Remote" or "Local" as preferred
# - Configure workspace variables (see variables.tf for required vars)

# Terraform Cloud Backend Configuration
# State stored in: https://app.terraform.io/app/UniversityThesis/workspaces/financemanager-infra-tf-aws

terraform {
  cloud {
    organization = "UniversityThesis"

    workspaces {
      name = "financemanager-infra-tf-aws"
    }
  }
}

# Alternative: Standard remote backend (uncomment if not using Terraform Cloud)
# terraform {
#   backend "s3" {
#     bucket         = "tf-financeflow-terraform-state"
#     key            = "financeflow/terraform.tfstate"
#     region         = "eu-central-1"
#     encrypt        = true
#     dynamodb_table = "tf-financeflow-terraform-locks"
#   }
# }
