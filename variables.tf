variable "environment_name" {
  type        = string
  description = "Environment name: dev, qa, prod"
}

variable "bucket" {
  type        = string
  description = "The s3 bucket ARN"
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
  default     = "3.29.0"
}

variable "runtime" {
  type        = string
  description = "The version of the runtime to use"
  default     = "python3.7"
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
