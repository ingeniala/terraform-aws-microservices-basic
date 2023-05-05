# Api Gateway HTTP VPC Link

output "api_endpoint" {
  description = "The URI of the API"
  value       = module.microservices_api_gateway.apigatewayv2_api_api_endpoint
}

output "vpc_link_arn" {
  description = "The ARN of the API Gateway VPC Link"
  value       = module.microservices_api_gateway.apigatewayv2_vpc_link_arn
}

output "vpc_link_id" {
  description = "The identifier of the API Gateway VPC Link"
  value       = module.microservices_api_gateway.apigatewayv2_vpc_link_id
}

# Api Gateway Custom Domain Name

output "main_acm_certificate_arn" {
  description = "The ARN of the main certificate"
  value       = module.main_acm.acm_certificate_arn
}

output "apigw_route53_record_name" {
  description = "Route53 record created for accessing API Gateway Custom Domain Name"
  value       = aws_route53_record.apigw_record.name
}