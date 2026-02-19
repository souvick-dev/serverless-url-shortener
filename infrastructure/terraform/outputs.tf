output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.url_table.name
}

output "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.url_table.arn
}

output "api_gateway_url" {
  description = "API Gateway URL"
  value       = "https://${aws_api_gateway_rest_api.url_api.id}.execute-api.${var.aws_region}.amazonaws.com/dev"
}