# datadog-log-forwarder-lambda

Basic module for the Datadog log forwarder lambda function and related resources.

This module was created to tighten permissions since at time of writing the CloudFormation templates provides more access to KMS and S3 buckets than we would like.

Zip file is from <https://github.com/DataDog/datadog-serverless-functions/releases/tag/aws-dd-forwarder-3.60.0>

Version numbers for datadog_python_layer_version can be found here: <https://github.com/DataDog/datadog-lambda-python/releases>

Version numbers for datadog_extension_layer_version can be found here: <https://github.com/DataDog/datadog-lambda-extension/releases>

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.26 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.26 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.labmda_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.lambda_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_basic_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_datadog_push](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_lambda_function.logs_to_datadog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.rds_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_lambda_permission.sns_topic_arns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_secretsmanager_secret.api-key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_sns_topic_subscription.sns_topic_arns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.lambda_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.lambda_runtime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_bucket_arns"></a> [bucket\_arns](#input\_bucket\_arns) | A list of s3 bucket ARNs | `list(string)` | n/a | yes |
| <a name="input_datadog_extension_layer_version"></a> [datadog\_extension\_layer\_version](#input\_datadog\_extension\_layer\_version) | The version of the Datadog Extension Layer | `number` | `63` | no |
| <a name="input_datadog_forwarder_version"></a> [datadog\_forwarder\_version](#input\_datadog\_forwarder\_version) | The Datadog Forwarder version to use | `string` | `"3.121.0"` | no |
| <a name="input_datadog_python_layer_version"></a> [datadog\_python\_layer\_version](#input\_datadog\_python\_layer\_version) | The version of the Datadog Python Layer | `number` | `98` | no |
| <a name="input_dd_site"></a> [dd\_site](#input\_dd\_site) | The Datadog Site Address | `string` | n/a | yes |
| <a name="input_enhanced_metrics"></a> [enhanced\_metrics](#input\_enhanced\_metrics) | Whether Datadog enhanced metrics is enabled | `bool` | `false` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Environment name: dev, qa, prod | `string` | n/a | yes |
| <a name="input_layers"></a> [layers](#input\_layers) | Whether or not to use layers | `bool` | `false` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MB your Lambda Function can use at runtime | `number` | `1024` | no |
| <a name="input_provision_trigger"></a> [provision\_trigger](#input\_provision\_trigger) | Whether or not to create a lambda trigger from an SNS topic | `bool` | `"false"` | no |
| <a name="input_rds_logs"></a> [rds\_logs](#input\_rds\_logs) | Whether to create lambda resource policy for sending all /aws/rds/* cloudwatch logs to the datadog log forwarder | `bool` | `true` | no |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | Amount of reserved concurrent executions for this lambda function | `number` | `100` | no |
| <a name="input_retention"></a> [retention](#input\_retention) | The log group retention in days | `number` | `30` | no |
| <a name="input_runtime"></a> [runtime](#input\_runtime) | The version of the runtime to use | `string` | `"3.11"` | no |
| <a name="input_sns_topic_arns"></a> [sns\_topic\_arns](#input\_sns\_topic\_arns) | SNS Topic ARNs | `list(string)` | <pre>[<br>  "undefined"<br>]</pre> | no |
| <a name="input_store_failed_events"></a> [store\_failed\_events](#input\_store\_failed\_events) | Whether to store failed events in the log forwarder | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to assign to resources created by this module | `map(string)` | n/a | yes |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | The length of time in seconds before function times out | `number` | `120` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | n/a |
| <a name="output_lambda_api_key_secret"></a> [lambda\_api\_key\_secret](#output\_lambda\_api\_key\_secret) | n/a |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | n/a |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | n/a |
| <a name="output_lambda_iam_policy_arn"></a> [lambda\_iam\_policy\_arn](#output\_lambda\_iam\_policy\_arn) | n/a |
| <a name="output_lambda_iam_role_arn"></a> [lambda\_iam\_role\_arn](#output\_lambda\_iam\_role\_arn) | n/a |
<!-- END_TF_DOCS -->
