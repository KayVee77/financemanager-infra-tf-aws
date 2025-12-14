output "transactions_table_name" {
  description = "Name of the transactions DynamoDB table"
  value       = aws_dynamodb_table.transactions.name
}

output "transactions_table_arn" {
  description = "ARN of the transactions DynamoDB table"
  value       = aws_dynamodb_table.transactions.arn
}

output "categories_table_name" {
  description = "Name of the categories DynamoDB table"
  value       = aws_dynamodb_table.categories.name
}

output "categories_table_arn" {
  description = "ARN of the categories DynamoDB table"
  value       = aws_dynamodb_table.categories.arn
}
