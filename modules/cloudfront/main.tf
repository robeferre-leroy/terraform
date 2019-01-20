resource "aws_s3_bucket" "cf_log_bucket" {
  bucket        = "cf-log-${var.app_name}-${var.env}"
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
        "Resource":["arn:aws:s3:::cf-log-${var.app_name}-${var.env}/*"]
      }]
}
EOF

  # website {
  #   index_document = "index.html"
  # }

  tags {
    Role        = "bucket"
    Application = "${var.app_name}"
    Environment = "${var.env}"
    Terraform   = "True"
  }
}

# Create Cloudfront Distibution
resource "aws_cloudfront_distribution" "redmine" {
  origin {
        domain_name = "${var.lb_arn}"
    origin_id   = "myLBOrigin"

    custom_origin_config {
      http_port = "80"
      https_port = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["SSLv3"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = false
  comment             = "${var.app_name}-${var.env}"
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = "${aws_s3_bucket.cf_log_bucket.bucket_domain_name}"
    prefix          = "myprefix"
  }

  # aliases = ["${var.domain}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "myLBOrigin"

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
