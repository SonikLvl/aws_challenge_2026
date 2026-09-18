# CodeBuild IAM Role
resource "aws_iam_role" "codebuild_role" {
  name = var.iam_role_cb

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name = "CodeBuildS3LambdaPolicy"
  role = aws_iam_role.codebuild_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "CloudWatchLogs"
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Sid      = "S3ReadArtifact"
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "arn:aws:s3:::${var.bucket_name}/*"
      },
      {
        Sid      = "LambdaUpdateCode"
        Effect   = "Allow"
        Action   = [
          "lambda:UpdateFunctionCode"
        ]
        Resource = "arn:aws:lambda:${var.aws_region}:*:function:${var.lambda_function_name}"
      }
    ]
  })
}

# CodeBuild Project
resource "aws_codebuild_project" "pipeline_build" {
  name         = var.codebuild_project
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = false
  }

  source {
    type      = "S3"
    location  = "${var.bucket_name}/build.zip"
    buildspec = "buildspec.yaml"
  }
}

# Lambda Trigger Package
data "archive_file" "lambda_trigger_zip" {
  type        = "zip"
  output_path = "${path.module}/trigger_handler.zip"

  source {
    content  = <<-EOF
import boto3
import os

def lambda_handler(event, context):
    client = boto3.client('codebuild')
    response = client.start_build(projectName=os.environ['CODEBUILD_PROJECT_NAME'])
    return {'message': 'Build started'}
    EOF
    filename = "index.py"
  }
}

# Use the pre-created Lambda execution role from CloudFormation
data "aws_iam_role" "lambda_cf_role" {
  name = var.iam_role_lambda_cf
}

# Lambda Trigger Function
resource "aws_lambda_function" "trigger" {
  function_name    = var.lambda_function_trigger
  role             = data.aws_iam_role.lambda_cf_role.arn
  handler          = "index.lambda_handler"
  runtime          = "python3.11"
  timeout          = 10
  filename         = data.archive_file.lambda_trigger_zip.output_path
  source_code_hash = data.archive_file.lambda_trigger_zip.output_base64sha256

  environment {
    variables = {
      CODEBUILD_PROJECT_NAME = aws_codebuild_project.pipeline_build.name
    }
  }
}

# Permission for S3 to invoke the trigger Lambda
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.trigger.arn
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.bucket_name}"
}

# S3 Event Notification on the existing bucket
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = var.bucket_name

  lambda_function {
    id                  = var.event_notification_name
    lambda_function_arn = aws_lambda_function.trigger.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = "build.zip"
  }

  depends_on = [aws_lambda_permission.allow_s3]
}