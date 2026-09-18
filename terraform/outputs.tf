output "eb_cname" {
  description = "Elastic Beanstalk Public URL entrypoint"
  value       = aws_elastic_beanstalk_environment.env.cname
}