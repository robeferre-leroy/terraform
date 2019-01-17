# -----------------------------------------------------
# default variables that are shared by all environments
# -----------------------------------------------------

variable "access_key" {
  type        = "string"
  description = "AWS access key loaded from env variable"
}

variable "secret_key" {
  type        = "string"
  description = "AWS secret key loaded from env variable"
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

variable "base_vpc" {
  type        = "string"
  default     = "vpc-81a109fa"
  description = "Base VPC to deploy infrastructure"
}

variable "app_name" {
  type        = "string"
  default     = "creativemanager"
  description = "Application Name"
}

variable "domain" {
  type    = "string"
  default = "negocios.tvglobo.com.br"
}
