provider "aws" {
  alias  = "aws_cloudfront"
  version = "~> 3.0"
  region = "us-east-1"
  profile = "default"
}

resource "aws_cloudfront_distribution" "cloudfront-bucket-20210823" {
  enabled = true
  http_version = "http2"
  is_ipv6_enabled = false
  price_class = "PriceClass_All"
  retain_on_delete = false
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    cached_methods = [
      "GET",
      "HEAD",
    ]

    lambda_function_association {
      event_type   = "origin-request"
      lambda_arn   = aws_lambda_function.parse_client_ip.qualified_arn
      include_body = false
    }

    compress = true
    default_ttl = 0
    max_ttl = 0
    min_ttl = 0
    smooth_streaming = false
    target_origin_id = "cloudfront-bucket-20210823.s3.ap-east-1.amazonaws.com"
    trusted_key_groups = []
    trusted_signers = []
    viewer_protocol_policy = "allow-all"
  }

  origin {
    domain_name = "cloudfront-bucket-20210823.s3.ap-east-1.amazonaws.com"
    origin_id = "cloudfront-bucket-20210823.s3.ap-east-1.amazonaws.com"
  }

  restrictions {
    geo_restriction {
      locations = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version = "TLSv1"
  }
}