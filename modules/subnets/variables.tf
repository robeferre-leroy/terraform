variable "vpc_id" {}

variable "availability_zone" {}

variable "env" {}

variable "app_name" {}

variable "name" {}

variable "gateway_id" {}

# variable "nat_instance_id" {}

variable "public_subnet_cidr" {}

variable "private_a_subnet_cidr" {}

variable "private_b_subnet_cidr" {}

data "aws_availability_zone" "target" {
  name = "${var.availability_zone}"
}

data "aws_vpc" "target" {
  id = "${var.vpc_id}"
}
