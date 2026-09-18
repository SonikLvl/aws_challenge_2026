variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "vpc_name" {
  type = string
}

variable "app_name" {
  type = string
}

variable "env_name" {
  type = string
}

variable "eb_service_role_name" {
  type = string
}

variable "eb_instance_profile_name" {
  type = string
}