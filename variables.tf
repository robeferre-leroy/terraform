# ---------------------------------------------------------------------
# default variables that are shared to all environments using sym links
# ---------------------------------------------------------------------

variable "access_key" {
  type        = "string"
  description = "AWS access key loaded from env variable"
}

variable "app_name" {
  type        = "string"
  default     = "redmine"
  description = "Application Name"
}

variable "secret_key" {
  type        = "string"
  description = "AWS secret key loaded from env variable"
}

variable "region" {
  type        = "string"
  default     = "us-east-1"
  description = "AWS region"
}

variable "base_vpc" {
  type        = "string"
  default     = "vpc-81a109fa"
  description = "Base VPC to deploy the infrastructure"
}