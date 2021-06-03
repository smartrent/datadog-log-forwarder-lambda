# https://github.com/DataDog/datadog-serverless-functions/tree/master/aws/logs_monitoring

locals {
  lambda_function_name = "logs_to_datadog"
  tags = merge(var.tags, {
    service : "logs_to_datadog"
  })
}
provider "aws" {
  region  = var.region
}

data "aws_caller_identity" "current" {}

resource "aws_kms_key" "datadog" {
  description = "KMS key for datadog lambda"
  tags        = local.tags
}

resource "aws_kms_alias" "datadog" {
  target_key_id = aws_kms_key.datadog.key_id
  name          = "alias/datadog_lambda"
}

resource "aws_lambda_function" "logs_to_datadog" {
  filename                       = "${path.module}/lambda/aws-dd-forwarder-${var.datadog_forwarder_version}.zip"
  description                    = "Datadog serverless log forwarder - Pushes logs, metrics and traces from AWS to Datadog."
  function_name                  = local.lambda_function_name
  role                           = aws_iam_role.lambda_execution.arn
  handler                        = "lambda_function.lambda_handler"
  source_code_hash               = filebase64sha256("${path.module}/lambda/aws-dd-forwarder-${var.datadog_forwarder_version}.zip")
  runtime                        = var.runtime
  timeout                        = 120
  memory_size                    = 1024
  reserved_concurrent_executions = 100

  kms_key_arn = aws_kms_key.datadog.arn

  environment {
    variables = {
      DD_API_KEY_SECRET_ARN = aws_secretsmanager_secret.api-key.arn
      DD_SITE               = var.dd_site
      DD_ENHANCED_METRICS   = false
    }
  }
  lifecycle {
    ignore_changes = [
      last_modified,
    ]
  }

  tracing_config {
    mode = "Active"
  }

  tags = merge(
    local.tags,
    { dd_forwarder_version = var.datadog_forwarder_version }
  )
}

resource "aws_secretsmanager_secret" "api-key" {
  name       = "datadog-lambda-api-key"
  kms_key_id = aws_kms_key.datadog.key_id
  tags       = var.tags
}

data "aws_iam_policy_document" "lambda_runtime" {
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      aws_secretsmanager_secret.api-key.arn
    ]
  }

  statement {
    actions = ["kms:Decrypt"]

    resources = [
      aws_kms_key.datadog.arn
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${var.bucket}/*",
    ]
  }
  statement {
    sid = "AllowXRay"

    effect = "Allow"

    actions = [
      "xray:PutTraceSegments",
      "xray:PutTelemetryRecords",
      "xray:GetSamplingRules",
      "xray:GetSamplingTargets",
      "xray:GetSamplingStatisticSummaries",
    ]

    resources = ["*"]

  }
  statement {
    sid = "AllowEFS"

    effect = "Allow"

    actions = [
      "elasticfilesystem:DescribeAccessPoints",
    ]

    resources = ["arn:aws:elasticfilesystem:*::file-system/*"]

  }
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}


resource "aws_iam_role" "lambda_execution" {
  name               = "datadog-lambda-execution-${var.environment_name}-${var.aws_region}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "labmda_execution" {
  name        = "datadog-lambda-${var.environment_name}-${var.aws_region}"
  policy      = data.aws_iam_policy_document.lambda_runtime.json
  description = "Managed by Terraform"
  tags        = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_datadog_push" {
  policy_arn = aws_iam_policy.labmda_execution.arn
  role       = aws_iam_role.lambda_execution.name
}

# Manage Log Group
resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${aws_lambda_function.logs_to_datadog.function_name}"
  retention_in_days = var.retention
  tags              = local.tags
}