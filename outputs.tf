output "lambda_function_name" {
  value = local.lambda_function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.logs_to_datadog.arn
}