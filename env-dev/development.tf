provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "tvg-negocios-terraform"
    key    = "creativemanager/development.tfstate"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "base" {
  backend = "s3"

  config {
    bucket = "tvg-negocios-terraform"
    key    = "creativemanager/base.tfstate"
    region = "us-east-1"
  }
}

module "subnets" {
  source                = "../../modules/subnets/"
  app_name              = "${var.app_name}"
  name                  = "${var.app_name}-${var.env}"
  env                   = "${var.env}"
  vpc_id                = "${var.base_vpc}"
  public_subnet_cidr    = "${var.public_subnet_cidr}"
  private_a_subnet_cidr = "${var.private_a_subnet_cidr}"
  private_b_subnet_cidr = "${var.private_b_subnet_cidr}"
  soa_network_address   = "${var.soa_network_address}"
  availability_zone     = "us-east-1a"
  gateway_id            = "igw-be4f9dc6"
  nat_instance_id       = "nat-0e40a0546b3efd66a"
}

module "mysql" {
  source   = "../../modules/mysql/"
  subnet_a = "${module.subnets.subnet_private_a_id}"
  subnet_b = "${module.subnets.subnet_private_b_id}"
  app_name = "${var.app_name}"
  env      = "${var.env}"
  db_name  = "db${var.app_name}${var.env}"
  domain   = "db.${var.app_name}.${var.env}.${var.domain}"
  vpc_id   = "${var.base_vpc}"
  multi_az = "false"
  dns_zone = "${var.route53_zone_id}"
}

module "beanstalk" {
  app_name       = "${data.terraform_remote_state.base.app_name}"
  source         = "../../modules/beanstalk_env/"
  db_username    = "${module.mysql.username}"
  db_password    = "${module.mysql.password}"
  db_name        = "${module.mysql.dbname}"
  db_endpoint    = "${module.mysql.endpoint}"
  subnet_id      = "${module.subnets.subnet_public_id}"
  env            = "${var.env}"
  solution-stack = "${var.eb_solution_stack_name}"
  key_name       = "${var.app_name}-${var.env}"
  vpc_id         = "${var.base_vpc}"
  soa_endpoint   = "${var.soa_endpoint}"
  image_id       = "${var.image_id}"
  dns_zone       = "${var.route53_zone_id}"
  domain         = "backend.${var.app_name}.${var.env}.${var.domain}"
}

module "mysql-logs" {
  source   = "../../modules/mysql/"
  app_name = "${var.app_name}"
  env      = "${var.env}"
  db_name  = "dblogs${var.app_name}${var.env}"
  domain   = "db.log.${var.app_name}.${var.env}.apps.tvglobo.com.br"
  subnet_a = "${module.subnets.subnet_private_a_id}"
  subnet_b = "${module.subnets.subnet_private_b_id}"
  multi_az = "false"
  vpc_id   = "${var.base_vpc}"
  dns_zone = "${var.route53_zone_id}"
}

module "cloudfront_static" {
  source   = "../../modules/cloudfront/"
  dns_zone = "${var.route53_zone_id}"
  app_name = "${var.app_name}"
  env      = "${var.env}"
  domain   = "${var.app_name}.${var.env}.${var.domain}"
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "tvg-${var.app_name}-datastore"
  acl           = "public-read"
  force_destroy = true

  tags {
    Role        = "bucket"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}
