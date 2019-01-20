provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}


# ---------------------------------------------------------------------------------------------------------------------
# Setting up my remote state file stored in a S3 bucket to avoid local state files.
# Also, i'm using one state file per environment for security propose, and keep my prod state safe from
# the development workflow.
#
# A bucket should be created at your account and attributed to the bucket field.
# ---------------------------------------------------------------------------------------------------------------------
terraform {
  backend "s3" {
    bucket = "tf-redmine"
    key    = "staging.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}


# ---------------------------------------------------------------------------------------------------------------------
# NETWORKING => One VPC per env, NAT GW, IG GW, public and private subnets configured
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block       = "${var.vpc_cidr}"
  instance_tenancy = "default"
  enable_dns_support = "True"
  enable_dns_hostnames = "True"

  tags = {
    Name = "vpc-${var.app_name}-${var.env}"
    Role        = "vpc"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  timeouts {
    delete = "40m"
  }

  tags = {
    Name        = "ig-${var.app_name}-${var.env}"
    Role        = "InternetGateway"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_route_table" "us-east-1a-vpc" {

  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags {
    Name        = "rt-vpc-${var.app_name}-${var.env}"
    Role        = "Route table"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_main_route_table_association" "vpc" {
  vpc_id         = "${aws_vpc.main.id}"
  route_table_id = "${aws_route_table.us-east-1a-vpc.id}"
}

module "subnets" {
  source                = "../modules/subnets/"
  app_name              = "${var.app_name}"
  name                  = "${var.app_name}-${var.env}"
  env                   = "${var.env}"
  vpc_id                = "${aws_vpc.main.id}"
  public_subnet_cidr    = "${var.public_subnet_cidr}"
  private_a_subnet_cidr = "${var.private_a_subnet_cidr}"
  private_b_subnet_cidr = "${var.private_b_subnet_cidr}"
  gateway_id            = "${aws_internet_gateway.gw.id}"
  availability_zone     = "us-east-1a"
}

# ---------------------------------------------------------------------------------------------------------------------
# DB Provisioning
# ---------------------------------------------------------------------------------------------------------------------
module "mysql" {
  source   = "../modules/mysql/"
  subnet_a = "${module.subnets.subnet_private_a_id}"
  subnet_b = "${module.subnets.subnet_private_b_id}"
  app_name = "${var.app_name}"
  env      = "${var.env}"
  db_name  = "db${var.app_name}${var.env}"
  vpc_id   = "${aws_vpc.main.id}"
  multi_az = "false"
}

# ---------------------------------------------------------------------------------------------------------------------
# EC2 Provisioning
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

data "aws_ami" "centos" {
  owners      = ["057448758665"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS 7.4.1708 - HVM"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "redmine" {

  ami           = "${data.aws_ami.centos.id}"
  subnet_id     = "${module.subnets.subnet_public_id}"
  associate_public_ip_address = true
  instance_type = "t2.small"
  key_name = "terraform_key"
  security_groups = ["${aws_security_group.allow_all.id}"]
  depends_on = ["module.mysql"]

  tags = {
    Name        = "ec2-${var.app_name}-${var.env}"
    Role        = "Ec2"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_key_pair" "terraform_ec2_key" {
  key_name = "terraform_key"
  public_key = "${file("../base/scripts/keypair/terraform_key.pub")}"
}


# ---------------------------------------------------------------------------------------------------------------------
# LB Provisioning
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_lb" "redmine" {
  name               = "nlb-${var.app_name}-${var.env}"
  load_balancer_type = "network"
  internal           = false
  subnets            = ["${module.subnets.subnet_public_id}"]
  enable_deletion_protection = false

  tags = {
    Name        = "nlb-${var.app_name}-${var.env}"
    Role        = "NLB"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_lb_target_group" "redmine" {
  name     = "tg-${var.app_name}-${var.env}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "redmine" {
  target_group_arn = "${aws_lb_target_group.redmine.arn}"
  target_id        = "${aws_instance.redmine.id}"
  port             = 5777
}


# ---------------------------------------------------------------------------------------------------------------------
# Cloudfront distribution Provisioning
# ---------------------------------------------------------------------------------------------------------------------
module "cloudfront_static" {
  source   = "../modules/cloudfront/"
  app_name = "${var.app_name}"
  env      = "${var.env}"
  lb_arn = "${aws_lb.redmine.dns_name}"
}

# ---------------------------------------------------------------------------------------------------------------------
# Provision the server using remote-exec
# ---------------------------------------------------------------------------------------------------------------------
resource "null_resource" "redmine" {
  triggers {
    public_ip = "${aws_instance.redmine.public_ip}"
  }

  connection {
    type = "ssh"
    host = "${aws_instance.redmine.public_ip}"
    user = "ec2-user"
    port = "22"
    private_key="${file("../base/scripts/keypair/terraform_key")}"
    agent = true
  }

  provisioner "file" {
    source      = "../base/scripts/ansible/examples/playbook.yml"
    destination = "/tmp/playbook.yml"
  }

  provisioner "remote-exec" {

     inline = ["sudo yum update -y",
               "sudo yum install git ansible vim telnet -y",
               "git clone https://github.com/robeferre/ansible-role-redmine.git .",
               "sudo ansible-galaxy install bngsudheer.redmine",
               "sudo ansible-galaxy install bngsudheer.centos_base",
               "sudo ansible-playbook -e redmine_sql_database_name=${module.mysql.dbname} -e redmine_sql_database_host=${module.mysql.endpoint} -e redmine_sql_username=${module.mysql.username} -e redmine_sql_password=${module.mysql.password} -e redmine_configure_nginx='false' -e redmine_configure_selinux='false' -e redmine_configure_firewalld='false' /tmp/playbook.yml",
               "sudo systemctl start redmine"]
  }
}