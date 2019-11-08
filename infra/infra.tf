variable "website_bucket_name" {
  description = "The name to give this website."
  default = "talks"
}

variable "enable_cloudfront_cdn" {
  description = "Optionally enable CloudFront to make the website accessible over HTTPS."
  default = 0
}

variable "route53_domain_name" {
  description = "The domain name for the talk."
}

provider "aws" {
  alias = "acm"
  region = "us-east-1"
}

locals {
  website_fqdn = "${var.website_bucket_name}.${var.route53_domain_name}"
  s3_bucket_origin_id = "${var.website_bucket_name}"
}

data "aws_route53_zone" "zone" {
  name = "${var.route53_domain_name}."
  private_zone = false
}

  
data "aws_iam_policy_document" "website_bucket" {
  statement {
    sid = "PublicReadGetObject"
    effect = "Allow"
    actions = [ "s3:GetObject" ]
    principals {
      type = "*"
      identifiers = [ "*" ]
    }
    resources = [ "arn:aws:s3:::${local.website_fqdn}/*" ]
  }
}

resource "aws_s3_bucket" "website" {
  bucket = "${local.website_fqdn}"
  acl = "public-read"
  policy = "${data.aws_iam_policy_document.website_bucket.json}"
  website {
    index_document = "slides.html"
    error_document = "404.html"
  }
}

resource "aws_acm_certificate" "aws_managed_https_certificate" {
  count   = "${var.enable_cloudfront_cdn}"
  provider = "aws.acm"
  domain_name = "${local.website_fqdn}"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "aws_managed_https_certificate_validation_record" {
  count   = "${var.enable_cloudfront_cdn}"
  name    = "${aws_acm_certificate.aws_managed_https_certificate[0].domain_validation_options[0].resource_record_name}"
  type    = "${aws_acm_certificate.aws_managed_https_certificate[0].domain_validation_options[0].resource_record_type}"
  zone_id = "${data.aws_route53_zone.zone.id}"
  records = ["${aws_acm_certificate.aws_managed_https_certificate[0].domain_validation_options[0].resource_record_value}"]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "aws_managed_https_certificate" {
  count   = "${var.enable_cloudfront_cdn}"
  provider = "aws.acm"
  certificate_arn         = "${aws_acm_certificate.aws_managed_https_certificate[0].arn}"
  validation_record_fqdns = ["${aws_route53_record.aws_managed_https_certificate_validation_record[0].fqdn}"]
  timeouts {
    create = "5m"
  }
}


resource "aws_cloudfront_origin_access_identity" "website" {
  count = "${var.enable_cloudfront_cdn}"
  comment = "HTTPS fronting for ${local.website_fqdn}"
}

resource "aws_cloudfront_distribution" "website" {
  count = "${var.enable_cloudfront_cdn}"
  provider = "aws.acm"
  aliases = [ "${local.website_fqdn}" ]
  origin {
    domain_name = "${aws_s3_bucket.website.website_endpoint}"
    origin_id = "${local.s3_bucket_origin_id}"
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = [ "SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2" ]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  enabled = true
  default_root_object = "slides.html"
  default_cache_behavior {
    allowed_methods = [ "GET","POST","PUT","DELETE","PATCH","OPTIONS","HEAD"]
    cached_methods = [ "GET","HEAD" ]
    target_origin_id = "${local.s3_bucket_origin_id}"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }
  price_class = "PriceClass_100"
  viewer_certificate {
    acm_certificate_arn = "${aws_acm_certificate_validation.aws_managed_https_certificate[count.index].certificate_arn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}

resource "aws_route53_record" "website" {
  zone_id = "${data.aws_route53_zone.zone.zone_id}"
  name = "${local.website_fqdn}"
  type = "A"
  alias {
    name = "${var.enable_cloudfront_cdn ? element(concat(aws_cloudfront_distribution.website.*.domain_name, list("")), 0) : aws_s3_bucket.website.website_domain}"
    zone_id = "${var.enable_cloudfront_cdn ? element(concat(aws_cloudfront_distribution.website.*.hosted_zone_id, list("")), 0) : aws_s3_bucket.website.hosted_zone_id}"
    evaluate_target_health = "${var.enable_cloudfront_cdn ? true : false }"
  }
}

output "website_bucket_url" {
  value = "${aws_s3_bucket.website.website_endpoint}"
}

output "cdn_url" {
  value = "${element(concat(aws_cloudfront_distribution.website.*.domain_name, list("none")), 0)}"
}
