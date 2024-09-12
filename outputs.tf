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

output "lambda_api_key_secret" {
  value = aws_secretsmanager_secret.api-key.arn
}

output "lambda_iam_policy_arn" {
  value = aws_iam_policy.labmda_execution.arn
}

output "bucket_name" {
  value = module.datadog_serverless_s3.bucket_name
}

output "bucket_arns" {
  value = module.datadog_serverless_s3.bucket_arn
}
