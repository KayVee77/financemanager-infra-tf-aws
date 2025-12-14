output "function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.openai.function_name
}

output "function_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.openai.arn
}

output "invoke_arn" {
  description = "Lambda invoke ARN for API Gateway"
  value       = aws_lambda_function.openai.invoke_arn
}
