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

resource "aws_s3_bucket" "KristupasThesisBucket" {
  bucket = "kristupas-thesis-bucket-2024"
  acl    = "private"

  tags = {
    Name        = "KristupasThesisBucket"
    Environment = "Dev"
  }
}
