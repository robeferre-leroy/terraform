# -----------------------------------------------------
# default variables that are shared by all environments
# -----------------------------------------------------

# AWS Credentials
variable "access_key" {
  type        = "string"
  description = "AWS access key load from env variable"
}

variable "secret_key" {
  type        = "string"
  description = "AWS secret key load from env variable"
}

variable "eb_solution_stack_name" {
  type        = "string"
  default     = "64bit Windows Server 2016 v1.2.0 running IIS 10.0"
  description = "Elastic beanstalk solution stack"
}

variable "region" {
  type        = "string"
  default     = "us-east-1"
  description = "AWS main region"
}

# Default Vpc CDAP
variable "vpc_cdap" {
  type        = "string"
  default     = "vpc-1f74d566"
  description = "CDAP's main VPC ID"
}

variable "base_cidr_block" {
  type        = "string"
  default     = "10.185.0.0/16"
  description = "CDAP's main VPC cidr block"
}

# App Name
variable "app_name" {
  type        = "string"
  default     = "creativemanager"
  description = "Application Name"
}
