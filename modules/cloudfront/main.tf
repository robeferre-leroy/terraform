# Create an AWS s3 Bucket
resource "aws_s3_bucket" "cf_bucket" {
  bucket        = "${var.domain}"
  acl           = "public-read"
  force_destroy = true

  policy = <<EOF
{
      "Version":"2008-10-17",
      "Statement":[{
        "Sid":"AllowPublicRead",
        "Effect":"Allow",
        "Principal": {"AWS": "*"},
        "Action":["s3:GetObject"],
        "Resource":["arn:aws:s3:::${var.domain}/*"]
      }]
}
EOF

  website {
    index_document = "index.html"
  }

  tags {
    Role        = "bucket"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_s3_bucket" "cf_log_bucket" {
  bucket        = "log-${var.domain}"
  acl           = "public-read"
  force_destroy = true

  policy = <<EOF
{
      "Version":"2008-10-17",
      "Statement":[{
        "Sid":"AllowPublicRead",
        "Effect":"Allow",
        "Principal": {"AWS": "*"},
        "Action":["s3:GetObject"],
        "Resource":["arn:aws:s3:::log-${var.domain}/*"]
      }]
}
EOF

  website {
    index_document = "index.html"
  }

  tags {
    Role        = "bucket"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

resource "aws_route53_record" "root_domain" {
  zone_id = "${var.dns_zone}"
  name    = "${var.domain}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.s3_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.s3_distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

# Create Cloudfront Distibution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.cf_bucket.bucket_domain_name}"
    origin_id   = "myS3Origin"

    # s3_origin_config {
    #   origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
    # }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.app_name}-${var.env}"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.cf_log_bucket.bucket_domain_name}"
    prefix          = "myprefix"
  }

  aliases = ["${var.domain}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "myS3Origin"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 86400
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE", "BR"]
    }
  }

  tags {
    Role        = "cdn"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
