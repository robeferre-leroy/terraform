output "subnet_public_id" {
  value = "${aws_subnet.eu-east-1a-public.id}"
}

output "subnet_private_a_id" {
  value = "${aws_subnet.eu-east-1a-private.id}"
}

output "subnet_private_b_id" {
  value = "${aws_subnet.eu-east-1b-private.id}"
}
