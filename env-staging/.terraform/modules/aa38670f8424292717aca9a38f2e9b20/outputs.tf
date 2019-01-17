output "username" {
  value = "${aws_db_instance.mysql.username}"
}

output "password" {
  value = "${aws_db_instance.mysql.password}"
}

output "dbname" {
  value = "${aws_db_instance.mysql.name}"
}

output "endpoint" {
  value = "${aws_route53_record.database.name}"
}
