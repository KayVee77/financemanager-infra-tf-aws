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

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

# AWS Budgets - Cost Budget
resource "aws_budgets_budget" "cost_budget" {
  name         = "monthly-cost-budget"
  budget_type  = "COST"
  limit_amount = "100"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
}

# EC2 Instance
resource "aws_instance" "bonus_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
}

# RDS Database
resource "aws_db_instance" "bonus_db" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "bonusdb"
  username             = "admin"
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true
}

# Lambda Function for Web App
resource "aws_lambda_function" "bonus_lambda" {
  function_name = "bonus-web-app"
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  filename      = data.archive_file.lambda_zip.output_path
  role          = aws_iam_role.lambda_role.arn
}

# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "bonus-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for Lambda
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Data source for Lambda zip (assuming a simple lambda_function.py exists)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

# API Gateway for Web App
resource "aws_api_gateway_rest_api" "bonus_api" {
  name        = "bonus-api"
  description = "API for bonus web app"
}

resource "aws_api_gateway_resource" "bonus_resource" {
  rest_api_id = aws_api_gateway_rest_api.bonus_api.id
  parent_id   = aws_api_gateway_rest_api.bonus_api.root_resource_id
  path_part   = "bonus"
}

resource "aws_api_gateway_method" "bonus_method" {
  rest_api_id   = aws_api_gateway_rest_api.bonus_api.id
  resource_id   = aws_api_gateway_resource.bonus_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "bonus_integration" {
  rest_api_id             = aws_api_gateway_rest_api.bonus_api.id
  resource_id             = aws_api_gateway_resource.bonus_resource.id
  http_method             = aws_api_gateway_method.bonus_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.bonus_lambda.invoke_arn
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.bonus_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.bonus_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "bonus_deployment" {
  depends_on  = [aws_api_gateway_integration.bonus_integration]
  rest_api_id = aws_api_gateway_rest_api.bonus_api.id
  stage_name  = "prod"
}
