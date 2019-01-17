# -----------------------------------------------------
# Empty variable declarations for the variables that
# will be populated in each env’s .tfvars
# -----------------------------------------------------

variable "env" {
  description = "CIDR for the Private Subnet"
}

variable "public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
}

variable "private_a_subnet_cidr" {
  description = "CIDR for the Private Subnet"
}

variable "private_b_subnet_cidr" {
  description = "CIDR for the Private Subnet"
}

variable "soa_network_address" {
  description = ""
}

variable "soa_endpoint" {
  description = ""
}

variable "image_id" {
  description = "image_id to use, create it using packer please"
}

variable "route53_zone_id" {
  description = "image_id to use, create it using packer please"
}
