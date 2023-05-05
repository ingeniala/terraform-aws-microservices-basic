# Static website bucket

output "s3_bucket_id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.root_website_bucket.id
}

output "s3_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = aws_s3_bucket.root_website_bucket.arn
}

output "s3_bucket_bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       = aws_s3_bucket.root_website_bucket.bucket_domain_name
}

output "s3_bucket_website_endpoint" {
  description = "The website endpoint, if the bucket is configured with a website. If not, this will be an empty string."
  value       = aws_s3_bucket_website_configuration.root_website_bucket_config.website_endpoint
}

output "s3_bucket_website_domain" {
  description = "The domain of the website endpoint, if the bucket is configured with a website. If not, this will be an empty string. This is used to create Route 53 alias records. "
  value       = aws_s3_bucket_website_configuration.root_website_bucket_config.website_domain
}

# CDN

output "cloudfront_distribution_id" {
  description = "The identifier for the distribution."
  value       = module.root_website_cdn.cloudfront_distribution_id
}

output "cloudfront_distribution_arn" {
  description = "The ARN (Amazon Resource Name) for the distribution."
  value       = module.root_website_cdn.cloudfront_distribution_arn
}

output "cloudfront_distribution_domain_name" {
  description = "The domain name corresponding to the distribution."
  value       = module.root_website_cdn.cloudfront_distribution_domain_name
}

# Records

output "root_record_name" {
  description = "Route53 record created for accessing website"
  value       = aws_route53_record.root_website_record.name
}