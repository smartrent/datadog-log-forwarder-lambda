output "lambda_function_name" {
  value = local.lambda_function_name
}

output "lambda_function_arn" {
  value = aws_lambda_function.logs_to_datadog.arn
}

output "lambda_iam_role_arn" {
  value = aws_iam_role.lambda_execution.arn
}

output "kms_key_arn" {
  value = aws_kms_key.datadog.arn
}