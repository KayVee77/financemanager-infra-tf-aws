# =============================================================================
# Production Environment Configuration
# =============================================================================
# These values are committed to the repo.
# Sensitive values (like openai_api_key) should be set in Terraform Cloud workspace.

environment     = "prod"
aws_region      = "eu-central-1"
project_name    = "financeflow"
owner           = "thesis-student"
resource_prefix = "tf"

# ECS Configuration
ecs_cpu           = 512  # 0.5 vCPU
ecs_memory        = 1024 # 1 GB
ecs_desired_count = 1

# Lambda Configuration
lambda_memory  = 256
lambda_timeout = 30

# Feature Flags
enable_cloudfront = true
enable_lambda_ai  = true

# Cognito URLs (localhost for dev testing)
cognito_callback_urls = [
  "http://localhost:5173/callback",
  "http://localhost:3000/callback"
]

cognito_logout_urls = [
  "http://localhost:5173",
  "http://localhost:3000"
]
