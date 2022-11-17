# https://github.com/DataDog/datadog-serverless-functions/tree/master/aws/logs_monitoring

locals {
  lambda_function_name = "logs_to_datadog"
  layers = var.layers ? [
    "arn:aws:lambda:${var.aws_region}:464622532012:layer:Datadog-Python${replace(var.runtime, ".", "")}:${var.datadog_python_layer_version}",
    "arn:aws:lambda:${var.aws_region}:464622532012:layer:Datadog-Extension:${var.datadog_extension_layer_version}",
  ] : []
  tags = merge(var.tags, {
    service : "logs_to_datadog"
  })
}

resource "aws_kms_key" "datadog" {
  description = "KMS key for datadog lambda"
  tags        = local.tags
}

resource "aws_kms_alias" "datadog" {
  target_key_id = aws_kms_key.datadog.key_id
  name          = "alias/datadog_lambda"
}

#resource "aws_lambda_function" "logs_to_datadog" {
#  filename                       = "${path.module}/lambda/aws-dd-forwarder-${var.datadog_forwarder_version}.zip"
#  description                    = "Datadog serverless log forwarder - Pushes logs, metrics and traces from AWS to Datadog."
#  function_name                  = local.lambda_function_name
#  role                           = aws_iam_role.lambda_execution.arn
#  handler                        = "lambda_function.lambda_handler"
#  source_code_hash               = filebase64sha256("${path.module}/lambda/aws-dd-forwarder-${var.datadog_forwarder_version}.zip")
#  runtime                        = "python${var.runtime}"
#  timeout                        = var.timeout
#  memory_size                    = var.memory_size
#  reserved_concurrent_executions = var.reserved_concurrent_executions

#  kms_key_arn = aws_kms_key.datadog.arn

#  environment {
#    variables = {
#      DD_API_KEY_SECRET_ARN = aws_secretsmanager_secret.api-key.arn
#      DD_SITE               = var.dd_site
#      DD_ENHANCED_METRICS   = var.enhanced_metrics
#      ## Filter out lambda platform logs
#      EXCLUDE_AT_MATCH = "\"(START|END) RequestId:\\s"
#    }
#  }

#  layers = local.layers

#  lifecycle {
#    ignore_changes = [
#      last_modified,
#    ]
#  }

#  tracing_config {
#    mode = "Active"
#  }

#  tags = merge(
#    local.tags,
#    { dd_forwarder_version = var.datadog_forwarder_version }
#  )
#}

# Datadog Forwarder to ship logs from S3 and CloudWatch, as well as observability data from Lambda functions to Datadog.
# https://github.com/DataDog/datadog-serverless-functions/tree/master/aws/logs_monitoring
resource "aws_cloudformation_stack" "logs_to_datadog" {
  name                           = "logs_to_datadog"
  capabilities                   = ["aws_iam_role.lambda_execution.arn"]
  parameters                     = {
    DdApiKeySecretArn  = aws_secretsmanager_secret.api-key.arn,
    DdSite             = "{{< region-param key="var.dd_site" code="true" >}}",
    FunctionName       = "local.lambda_function_name"
  }
  description                    = "Datadog serverless log forwarder - Pushes logs, metrics and traces from AWS to Datadog."
  template_url                   = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/latest.yaml"
  timeout                        = var.timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions

  environment {
    variables = {
      DD_API_KEY_SECRET_ARN = aws_secretsmanager_secret.api-key.arn
      DD_SITE               = var.dd_site
      DD_ENHANCED_METRICS   = var.enhanced_metrics
      ## Filter out lambda platform logs
      EXCLUDE_AT_MATCH = "\"(START|END) RequestId:\\s"
    }
  }

  layers = local.layers

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

resource "aws_sns_topic_subscription" "sns_topic_arns" {
  count     = var.provision_trigger ? length(var.sns_topic_arns) : 0
  topic_arn = var.sns_topic_arns[count.index]
  protocol  = "lambda"
  endpoint  = aws_lambda_function.logs_to_datadog.arn
}

resource "aws_lambda_permission" "sns_topic_arns" {
  count         = var.provision_trigger ? length(var.sns_topic_arns) : 0
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.logs_to_datadog.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arns[count.index]
}
