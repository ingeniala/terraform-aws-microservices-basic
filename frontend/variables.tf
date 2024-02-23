variable "tags_root" {
  description = "Tags to apply to global resources"
  type        = map
  default     = {}
}

variable "domain_name" {
  description = "Main domain name managed by AWS of the solution"
  type        = string
  default     = "example.com"
}

variable "website_name" {
  description = "Name applied to the created website in S3"
  type        = string
  default     = "example.com"
}

variable "website_subdomain" {
  description = "Frontend subdomain to configure in Route53 and CDN distribution"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "ACM Certificate to plug into CDN distributions for the static website"
  type        = string
  default     = ""
}

variable "waf_arn" {
  description = "The ARN of the WAF WebACL"
  type        = string
  default     = ""
}

