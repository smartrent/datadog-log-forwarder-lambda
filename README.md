# datadog-log-forwarder-lambda
Basic module for the Datadog log forwarder lambda function and related resources.

This module was created to tighten permissions since at time of writing the CloudFormation templates provides more access to KMS and S3 buckets than we would like. 

Zip file is from https://github.com/DataDog/datadog-serverless-functions/releases/tag/aws-dd-forwarder-3.60.0

Version numbers for datadog_python_layer_version can be found here: https://github.com/DataDog/datadog-lambda-python/releases

Version numbers for datadog_extension_layer_version can be found here: https://github.com/DataDog/datadog-lambda-extension/releases
