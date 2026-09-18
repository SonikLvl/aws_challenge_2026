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