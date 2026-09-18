variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "bucket_name" {
  type        = string
  description = "Globally unique S3 bucket name"
}

variable "github_token" {
  type        = string
  sensitive   = true
  description = "GitHub PAT used by Terraform to create repo and secrets"
}

variable "repository_name" {
  type    = string
  default = "s3-static-website"
}

variable "iam_role_cb" {
  type        = string
  description = "Name of the IAM role for CodeBuild"
}

variable "codebuild_project" {
  type        = string
  description = "CodeBuild project name"
}

variable "lambda_function_trigger" {
  type        = string
  description = "Name for the trigger Lambda function"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the target Lambda function being updated"
}

variable "iam_role_lambda_cf" {
  type        = string
  description = "Pre-created IAM role for the Lambda trigger function"
}

variable "event_notification_name" {
  type        = string
  description = "Name/ID of the S3 event notification"
}