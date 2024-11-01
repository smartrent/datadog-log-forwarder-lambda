variable "environment_name" {
  type        = string
  description = "Environment name: dev, qa, prod"
}

variable "bucket_arns" {
  type        = list(string)
  description = "A list of s3 bucket ARNs"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "dd_site" {
  type        = string
  description = "The Datadog Site Address"
}

variable "datadog_forwarder_version" {
  type        = string
  description = "The Datadog Forwarder version to use"
  default     = "3.121.0"
}

variable "runtime" {
  type        = string
  description = "The version of the runtime to use"
  default     = "3.11"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to resources created by this module"
}

variable "retention" {
  type        = number
  description = "The log group retention in days"
  default     = 30
}

variable "provision_trigger" {
  type        = bool
  description = "Whether or not to create a lambda trigger from an SNS topic"
  default     = "false"
}

variable "sns_topic_arns" {
  type        = list(string)
  description = "SNS Topic ARNs"
  default     = ["undefined"]
}

variable "timeout" {
  type        = number
  description = "The length of time in seconds before function times out"
  default     = 120
}

variable "memory_size" {
  type        = number
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  default     = 1024
}

variable "reserved_concurrent_executions" {
  type        = number
  description = "Amount of reserved concurrent executions for this lambda function"
  default     = 100
}

variable "enhanced_metrics" {
  type        = bool
  description = "Whether Datadog enhanced metrics is enabled"
  default     = false
}

variable "layers" {
  type        = bool
  description = "Whether or not to use layers"
  default     = false
}

variable "datadog_python_layer_version" {
  type        = number
  description = "The version of the Datadog Python Layer"
  default     = 98
}

variable "datadog_extension_layer_version" {
  type        = number
  description = "The version of the Datadog Extension Layer"
  default     = 64
}

variable "rds_logs" {
  type        = bool
  description = "Whether to create lambda resource policy for sending all /aws/rds/* cloudwatch logs to the datadog log forwarder"
  default     = true
}

variable "store_failed_events" {
  type        = bool
  description = "Whether to store failed events in the log forwarder"
  default     = true
}

variable "exclude_logs_regex" {
  type        = string
  description = "Regex pattern to exclude logs from forwarding to Datadog"
  default     = "\"(START|END) RequestId:\\s"
}

variable "log_group_names" {
  type        = map(any)
  description = "A map of log group names to create lambda subscriptions for"
  default     = {}
}