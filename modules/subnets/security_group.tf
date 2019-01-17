# resource "aws_security_group" "az" {
#   name        = "az-${data.aws_availability_zone.target.name}"
#   description = "Open access within the AZ ${data.aws_availability_zone.target.name}"
#   vpc_id      = "${var.vpc_id}"
#   ingress {
#     from_port   = 0
#     to_port     = 65535
#     protocol    = "tcp"
#     cidr_blocks = ["${aws_subnet.main.cidr_block}"]
#   }
#   tags {
#     Application = "${var.app_name}"
#     Environment = "${var.env}"
#     Terraform   = "True"
#   }
# }

