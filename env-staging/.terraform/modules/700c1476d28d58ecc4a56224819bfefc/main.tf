resource "aws_security_group" "ec2" {
  name        = "eb-${var.app_name}-${var.env}"
  description = "Terraform managed EB SG."
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_elastic_beanstalk_environment" "default" {
  application            = "${var.app_name}"
  name                   = "eb-${var.app_name}-${var.env}"
  solution_stack_name    = "${var.solution-stack}"
  wait_for_ready_timeout = "60m"                           // more than 20 mins to create this shit.

  //Setting CDAP default vpc
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = "vpc-1f74d566"
  }

  //Subnet with route to the Internal datacenter
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = "${var.subnet_id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBSubnets"
    value     = "${var.subnet_id}"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "public"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = "${var.key_name}"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "ImageId"
    value     = "${var.image_id}"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = "Health"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = "${aws_security_group.ec2.id}"
  }

  // RDS CONFIGURATION
  # setting {
  #   namespace = "aws:elasticbeanstalk:application:environment"
  #   name      = "RDS_USERNAME"
  #   value     = "${var.db_username}"
  # }


  # setting {
  #   namespace = "aws:elasticbeanstalk:application:environment"
  #   name      = "RDS_PASSWORD"
  #   value     = "${var.db_password}"
  # }


  # setting {
  #   namespace = "aws:elasticbeanstalk:application:environment"
  #   name      = "RDS_DATABASE"
  #   value     = "${var.db_name}"
  # }


  # setting {
  #   namespace = "aws:elasticbeanstalk:application:environment"
  #   name      = "RDS_HOSTNAME"
  #   value     = "${var.db_endpoint}"
  # }


  # setting {
  #   namespace = "aws:elasticbeanstalk:application:environment"
  #   name      = "SOA_ENDPOINT"
  #   value     = "${var.soa_endpoint}"
  # }

  tags {
    Role        = "backend"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_route53_record" "backend" {
  zone_id = "ZKVWZOLXYACT"
  name    = "${var.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_elastic_beanstalk_environment.default.cname}"]
}
