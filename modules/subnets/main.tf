/*
  Public Subnet
*/
resource "aws_subnet" "eu-east-1a-public" {
  vpc_id = "${var.vpc_id}"

  cidr_block        = "${var.public_subnet_cidr}"
  availability_zone = "us-east-1a"

  tags {
    Name        = "tf-subnet-public-${var.name}"
    Role        = "Subnet"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_route_table" "eu-east-1a-public" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.gateway_id}"
  }

  # route {
  #   cidr_block = "10.32.255.0/24"
  #   gateway_id = "pcx-2bb2c642"
  # }

  route {
    cidr_block = "${var.soa_network_address}"
    gateway_id = "vgw-c83bcca1"
  }
  tags {
    Name        = "rt-public-${var.name}"
    Role        = "Route table"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_route_table_association" "eu-east-1a-public" {
  subnet_id      = "${aws_subnet.eu-east-1a-public.id}"
  route_table_id = "${aws_route_table.eu-east-1a-public.id}"
}

/*
  Private Subnet A
*/
resource "aws_subnet" "eu-east-1a-private" {
  vpc_id = "${var.vpc_id}"

  cidr_block        = "${var.private_a_subnet_cidr}"
  availability_zone = "us-east-1a"

  tags {
    Name        = "tf-subnet-private-${var.name}"
    Role        = "Subnet"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_route_table" "eu-east-1a-private" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${var.nat_instance_id}"
  }

  tags {
    Name        = "rt-private-${var.name}"
    Role        = "Route table"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_route_table_association" "eu-east-1a-private" {
  subnet_id      = "${aws_subnet.eu-east-1a-private.id}"
  route_table_id = "${aws_route_table.eu-east-1a-private.id}"
}

/*
  Private Subnet B
*/
resource "aws_subnet" "eu-east-1b-private" {
  vpc_id = "${var.vpc_id}"

  cidr_block        = "${var.private_b_subnet_cidr}"
  availability_zone = "us-east-1b"

  tags {
    Name        = "tf-subnet-private-${var.name}"
    Role        = "Subnet"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_route_table" "eu-east-1b-private" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${var.nat_instance_id}"
  }

  tags {
    Name        = "rt-private-${var.name}"
    Role        = "Route table"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_route_table_association" "eu-east-1b-private" {
  subnet_id      = "${aws_subnet.eu-east-1b-private.id}"
  route_table_id = "${aws_route_table.eu-east-1a-private.id}"
}
