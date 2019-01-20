output "address" {
  value = "${aws_cloudfront_distribution.redmine.domain_name}"
}
