locals {
  website_domain   = var.website_subdomain != "" ? "${var.website_subdomain}.${var.domain_name}" : var.domain_name

  tags = merge({
    Module = "terraform-aws-microservices-basic"
    Tier   = "frontend"
  }, var.tags_root)
}

###################################################
# MAIN ROOT FRONTEND (S3 BUCKET & CLOUDFRONT)
###################################################

# Root Bucket

resource "aws_s3_bucket" "root_website_bucket" {
  bucket = local.website_domain
  tags   = merge({Type = "S3 Root Website Bucket"}, local.tags, var.tags_root)
}

resource "aws_s3_bucket_policy" "root_website_bucket_policy" {
  bucket = aws_s3_bucket.root_website_bucket.id
  policy = data.aws_iam_policy_document.root_website_bucket_policy_document.json
}

data "aws_iam_policy_document" "root_website_bucket_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.root_website_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "root_website_bucket_cors" {
  bucket = aws_s3_bucket.root_website_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://www.${local.website_domain}"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_bucket_website_configuration" "root_website_bucket_config" {
  bucket = aws_s3_bucket.root_website_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

resource "aws_s3_bucket_ownership_controls" "root_website_bucket_ownership" {
  bucket = aws_s3_bucket.root_website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "root_website_bucket_access" {
  bucket = aws_s3_bucket.root_website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "root_website_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.root_website_bucket_ownership,
    aws_s3_bucket_public_access_block.root_website_bucket_access,
  ]

  bucket = aws_s3_bucket.root_website_bucket.id
  acl    = "public-read"
}

# Root CDN

module "root_website_cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 3.2"

  comment             = "Content Delivery Network Distribution for root frontend"
  aliases             = [local.website_domain]
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false
  default_root_object = "index.html"

  create_origin_access_identity = false

  origin = {
    s3_website = {
      domain_name = aws_s3_bucket_website_configuration.root_website_bucket_config.website_endpoint
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  viewer_certificate = {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  default_cache_behavior = {
    target_origin_id       = "s3_website"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    min_ttl         = 31536000
    default_ttl     = 31536000
    max_ttl         = 31536000
    compress        = true
    query_string    = true
  }

  tags = merge({Name = "${var.website_name}-root-cdn", Type = "CloudFront Distribution"}, local.tags, var.tags_root)
}

resource "aws_route53_record" "root_website_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = local.website_domain
  type    = "A"

  alias {
    name                   = module.root_website_cdn.cloudfront_distribution_domain_name
    zone_id                = module.root_website_cdn.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }

}

##############################################################################
# REDIRECT FRONTEND (S3 BUCKET & CLOUDFRONT) --> for redirecting www to root
###############################################################################

# Subdomain bucket

resource "aws_s3_bucket" "www_website_bucket" {
  bucket = "www.${local.website_domain}"
  tags   = merge({Type = "S3 Redirect Website Bucket"}, local.tags, var.tags_root)
}

resource "aws_s3_bucket_policy" "www_website_bucket_policy" {
  bucket = aws_s3_bucket.www_website_bucket.id
  policy = data.aws_iam_policy_document.www_website_bucket_policy_document.json
}

data "aws_iam_policy_document" "www_website_bucket_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.www_website_bucket.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_website_configuration" "www_website_bucket_config" {
  bucket = aws_s3_bucket.www_website_bucket.id

  redirect_all_requests_to {
    host_name = local.website_domain
    protocol  = "https"
  }

}

resource "aws_s3_bucket_ownership_controls" "www_website_bucket_ownership" {
  bucket = aws_s3_bucket.www_website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "www_website_bucket_access" {
  bucket = aws_s3_bucket.www_website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "www_website_bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.www_website_bucket_ownership,
    aws_s3_bucket_public_access_block.www_website_bucket_access
  ]

  bucket = aws_s3_bucket.www_website_bucket.id
  acl    = "public-read"
}

# Subdomain CDN

module "www_website_cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "~> 3.2"

  comment             = "Content Delivery Network Distribution for frontend redirection"
  aliases             = ["www.${local.website_domain}"]
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = false

  origin = {
    s3_website = {
      domain_name = aws_s3_bucket_website_configuration.www_website_bucket_config.website_endpoint
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  viewer_certificate = {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }

  default_cache_behavior = {
    target_origin_id       = "s3_website"
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    min_ttl         = 0
    default_ttl     = 86400
    max_ttl         = 31536000
    compress        = true
    query_string    = true
  }

  tags = merge({Name = "${var.website_name}-cdn", Type = "CloudFront Distribution"}, local.tags, var.tags_root)
}

# Create Route53 records to access Website
data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "www_website_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "www.${local.website_domain}"
  type    = "A"

  alias {
    name                   = module.www_website_cdn.cloudfront_distribution_domain_name
    zone_id                = module.www_website_cdn.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }

}