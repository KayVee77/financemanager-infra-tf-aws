# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Configure Terraform Cloud backend
  cloud {
    organization = "UniversityThesis"
    workspaces {
      name = "financemanager-infra-tf-aws"
    }
  }
}
