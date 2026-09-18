# Dedicated IAM user for CI/CD deployments
resource "aws_iam_user" "deployer" {
  name = "${var.bucket_name}-deployer"
}

resource "aws_iam_access_key" "deployer_key" {
  user = aws_iam_user.deployer.name
}

# Scoped policy granting sync permissions only to this bucket
resource "aws_iam_user_policy" "s3_deploy" {
  name = "S3DeployPolicy"
  user = aws_iam_user.deployer.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = aws_s3_bucket.website.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.website.arn}/*"
      }
    ]
  })
}