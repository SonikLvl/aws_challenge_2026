output "codebuild_project_name" {
  value = aws_codebuild_project.pipeline_build.name
}

output "lambda_trigger_name" {
  value = aws_lambda_function.trigger.function_name
}