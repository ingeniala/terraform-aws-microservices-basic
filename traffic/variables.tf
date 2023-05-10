variable "tags_root" {
  type        = map
  description = "Tags to apply to global resources"
}

variable "apigw_name" {
  description = "API Gateway Name to be set"
  type        = string
}

variable "vpc_id" {
  type        = string
  description = "VPC Identifier where the runtime layer will be placed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "VPC Private subnets Identifiers where the runtime layer will be placed"
}

variable "domain_name" {
  description = "Main domain name managed by AWS of the solution"
  type        = string
}

variable "apigw_domain_name" {
  description = "Domain name managed by AWS and used for exposing services within the API Gateway"
  type        = string
}

variable "apigw_api_version" {
  type        = string
  description = "(Optional) API Version to set"
}

variable "create_api_stage" {
  type        = bool
  description = "Whether to create default stage to publish API"
}

variable "create_api_routes" {
  type        = bool
  description = "Whether to create routes and integrations"
}

variable "create_api_lambda_authorizer" {
  type        = bool
  description = "Whether to create lambda authorizers to enable API authentication"
}

variable "api_authorizer_bucket_name" {
  type        = string
  description = "S3 bucket name where the package to create lambda authorizer is located"
}

variable "api_authorizer_bucket_key" {
  type        = string
  description = "S3 bucket key where the package to create lambda authorizer is located"
}

variable "api_authorizer_runtime" {
  type        = string
  description = "Lambda authorizer software runtime to be defined"
}

variable "api_authorizer_env_vars" {
  type        = map(string)
  description = "Lambda authorizer environment variables to be defined"
}

variable "api_request_mappings" {
  type        = map(string)
  description = "Mappings applied to request parameters that the API Gateway should perform"
}

variable "api_response_mappings" {
  type        = map(string)
  description = "Mappings applied to response parameters that the API Gateway should perform"
}

variable "acm_subjective_names" {
  description = "List of subjective names to include in the main ACM"
  type        = list(string)
}

variable "eks_cluster_alb" {
  type        = string
  description = "ALB Hostname populated by Nginx Ingress Controller addon, in order to allow APIGateway creation"
}