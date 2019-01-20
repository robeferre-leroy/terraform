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

resource "aws_eip" "nat" {
  vpc      = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.eu-east-1a-public.id}"

  tags = {
    Name        = "nat-gateway-${var.app_name}-${var.name}"
    Role        = "Nat Gateway"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
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
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
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
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
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
