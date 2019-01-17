# -----------------------------------------------------
# Empty variable declarations for the variables that
# will be populated in each env’s .tfvars
# -----------------------------------------------------

variable "env" {}

variable "public_subnet_cidr" {
  description = "CIDR for the Public Subnet"
}

variable "private_a_subnet_cidr" {
  description = "CIDR for the Private Subnet"
}

variable "private_b_subnet_cidr" {
  description = "CIDR for the Private Subnet"
}

// SOA STUFF
variable "soa_network_address" {}

variable "soa_endpoint" {}

variable "image_id" {
  description = "image_id to use, created by packer please"
}

//asdasdasdasd

