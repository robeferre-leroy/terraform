// AWS Credentials
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

// Setting the backend
terraform {
  backend "s3" {
    bucket = "tvg-terraform"
    key    = "moduloagencias/staging.tfstate"
    region = "us-east-1"
  }
}

// Datasource to query base state file
data "terraform_remote_state" "base" {
  backend = "s3"

  config {
    bucket = "tvg-terraform"
    key    = "moduloagencias/base.tfstate"
    region = "us-east-1"
  }
}

// Public Subnet
module "subnets" {
  source                = "../../../modules/subnets/"
  app_name              = "${var.app_name}"
  name                  = "${var.app_name}-${var.env}"
  env                   = "${var.env}"
  vpc_id                = "${var.vpc_cdap}"
  availability_zone     = "us-east-1a"
  public_subnet_cidr    = "${var.public_subnet_cidr}"
  private_a_subnet_cidr = "${var.private_a_subnet_cidr}"
  private_b_subnet_cidr = "${var.private_b_subnet_cidr}"
  gateway_id            = "igw-4479e622"
  nat_instance_id       = "nat-039d820d4dac6c851"
  soa_network_address   = "${var.soa_network_address}"
}

// DB instance
module "mysql" {
  source   = "../../../modules/mysql/"
  app_name = "${var.app_name}"
  env      = "${var.env}"
  db_name  = "db${var.app_name}${var.env}"
  domain   = "db.${var.app_name}.${var.env}.apps.tvglobo.com.br"
  subnet_a = "${module.subnets.subnet_private_a_id}"
  subnet_b = "${module.subnets.subnet_private_b_id}"
  vpc_id   = "${var.vpc_cdap}"
  multi_az = "false"
}

// DB instance
module "mysql-logs" {
  source   = "../../../modules/mysql/"
  app_name = "${var.app_name}"
  env      = "${var.env}"
  db_name  = "dblogs${var.app_name}${var.env}"
  domain   = "db.log.${var.app_name}.${var.env}.apps.tvglobo.com.br"
  subnet_a = "${module.subnets.subnet_private_a_id}"
  subnet_b = "${module.subnets.subnet_private_b_id}"
  vpc_id   = "${var.vpc_cdap}"
  multi_az = "false"
}

// Elastic Beastalk
module "beanstalk" {
  source         = "../../../modules/beanstalk_env/"
  env            = "${var.env}"
  app_name       = "${data.terraform_remote_state.base.app_name}"
  subnet_id      = "${module.subnets.subnet_public_id}"                     //"subnet-28c66904"
  solution-stack = "${var.eb_solution_stack_name}"
  key_name       = "${var.app_name}-${var.env}"
  vpc_id         = "${var.vpc_cdap}"
  db_username    = "${module.mysql.username}"
  db_password    = "${module.mysql.password}"
  db_name        = "${module.mysql.dbname}"
  db_endpoint    = "${module.mysql.endpoint}"
  domain         = "backend.${var.app_name}.${var.env}.apps.tvglobo.com.br"
  soa_endpoint   = "${var.soa_endpoint}"
}

//Cloudfront Distributions
module "cloudfront_static" {
  source   = "../../../modules/cloudfront/"
  app_name = "${var.app_name}"
  env      = "${var.env}"
  domain   = "${var.app_name}.${var.env}.apps.tvglobo.com.br"
}

// Create an AWS s3 Bucket
resource "aws_s3_bucket" "bucket" {
  bucket        = "tvg-${var.app_name}-${var.env}-criativo"
  acl           = "public-read"
  force_destroy = true

  #   policy = <<EOF
  # {
  #       "Version":"2008-10-17",
  #       "Statement":[{
  #         "Sid":"AllowPublicRead",
  #         "Effect":"Allow",
  #         "Principal": {"AWS": "*"},
  #         "Action":["s3:GetObject"],
  #         "Resource":["arn:aws:s3:::tvg-moduloagencias-criativo/*"]
  #       }]
  # }
  # EOF

  website {
    index_document = "index.html"
  }
  tags {
    Role        = "bucket"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}
