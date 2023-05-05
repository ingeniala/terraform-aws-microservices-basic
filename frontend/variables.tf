variable "tags_root" {
  type        = map
  description = "Tags to apply to global resources"
}

variable "domain_name" {
  description = "Main domain name managed by AWS of the solution"
  type        = string
}

variable "website_name" {
  description = "Name applied to the created website in S3"
  type        = string
}

variable "website_subdomain" {
  description = "Frontend subdomain to configure in Route53 and CDN distribution"
  type        = string
}

variable "acm_certificate_arn" {
  description = "ACM Certificate to plug into CDN distributions for the static website"
  type        = string
}

