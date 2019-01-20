provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "tf-redmine"
    key    = "base.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}

resource "aws_elastic_beanstalk_application" "beanstalkApp" {
  name        = "${var.app_name}"
  description = "Redmine application"
}
