resource "aws_db_subnet_group" "mysql" {
  name       = "db-${var.db_name}-${var.app_name}-${var.env}"
  subnet_ids = ["${var.subnet_a}", "${var.subnet_b}"]

  tags {
    Name        = "db-${var.db_name}-${var.app_name}-${var.env}"
    Role        = "Subnet group"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_security_group" "mysql" {
  name = "db-sg--${var.db_name}-${var.app_name}-${var.env}"

  description = "RDS mysql servers (terraform-managed)"
  vpc_id      = "${var.vpc_id}"

  # Only mysql in
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "sg-db-${var.db_name}-${var.app_name}-${var.env}"
    Role        = "Security group"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 10
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.6.35"
  instance_class         = "db.t2.small"
  identifier             = "db-${var.db_name}-${var.app_name}-${var.env}"
  name                   = "${var.db_name}"
  username               = "cdap"
  password               = "globo123"
  parameter_group_name   = "default.mysql5.6"
  skip_final_snapshot    = "true"
  publicly_accessible    = "false"
  multi_az               = "${var.multi_az}"
  db_subnet_group_name   = "${aws_db_subnet_group.mysql.id}"
  vpc_security_group_ids = ["${aws_security_group.mysql.id}"]

  tags {
    Name        = "db-${var.app_name}-${var.env}"
    Role        = "Database"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_route53_record" "database" {
  zone_id = "ZKVWZOLXYACT"
  name    = "${var.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_db_instance.mysql.address}"]
}
