output "website_endpoint" {
  description = "Domain URL for the S3 static website"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

output "aws_access_key_id" {
  description = "Access key ID for the deployer IAM user"
  value       = aws_iam_access_key.deployer_key.id
}

output "aws_secret_access_key" {
  description = "Secret access key for the deployer IAM user"
  value       = aws_iam_access_key.deployer_key.secret
  sensitive   = true
}