output "budget_id" {
  description = "The ID of the cost budget"
  value       = aws_budgets_budget.cost_budget.id
}

output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.bonus_instance.id
}

output "db_endpoint" {
  description = "The endpoint of the RDS database"
  value       = aws_db_instance.bonus_db.endpoint
}

output "lambda_function_name" {
  description = "The name of the Lambda function"
  value       = aws_lambda_function.bonus_lambda.function_name
}

output "api_gateway_url" {
  description = "The URL of the API Gateway"
  value       = aws_api_gateway_deployment.bonus_deployment.invoke_url
}
