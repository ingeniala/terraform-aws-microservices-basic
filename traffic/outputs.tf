# Api Gateway HTTP VPC Link

output "api_endpoint" {
  description = "The URI of the API"
  value       = module.microservices_api_gateway.apigatewayv2_api_api_endpoint
}

output "api_execution_arn" {
  description = "The ARN prefix to be used in an aws_lambda_permission's source_arn attribute or in an aws_iam_policy to authorize access to the @connections API."
  value       = module.microservices_api_gateway.apigatewayv2_api_execution_arn
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

# Api Gateway Security Group

output "apigw_security_group_id" {
  description = "The ID of the API Security Group created to handle traffic"
  value       = module.api_gateway_security_group.security_group_id
}

# Internal Load Balancer

output "alb_dns" {
  description = "The DNS of the Application Load Balancer behind the API Gateway"
  value       = data.aws_lb.eks_alb.dns_name 
}

output "alb_zone_id" {
  description = "The Zone ID of the Application Load Balancer behind the API Gateway"
  value       = data.aws_lb.eks_alb.zone_id  
}

# Web Application Firewall

output "waf_id" {
  description = "The ID of the WAF WebACL"
  value       = module.waf.id
}

output "waf_arn" {
  description = "The ARN of the WAF WebACL"
  value       = module.waf.arn
}