# Global variables

variable "env" {
  description = "Environment name"
  type        = string
  default     = "dev" // dev, test, prod
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "POC-Ingenia"
}

variable "aws_profile" {
  description = "AWS Profile to use when interacting with resources during installation"
  type        = string
  default     = "default"
}

# Networking

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc_subnet_extra_mask_bits" {
  description = "Extra mask bits amount for performing subnetting within the VPC"
  type        = number
  default     = 8
}

variable "vpc_enable_vpn" {
  description = "Whether to enable a Virtual Private Network Gateway attached to the VPC"
  type        = bool
  default     = false
}

# Runtime

variable "eks_cluster_version" {
  description = "EKS Cluster version to be set"
  type        = string
  default     = "1.29"
}

variable "eks_cluster_max_size" {
  type        = number
  description = "EKS Cluster maximum amount of worker nodes"
  default     = 10
}

variable "eks_cluster_auth_map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(any)
  default = []
}

variable "eks_cluster_auth_map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(any)
  default = []
}

variable "eks_cluster_auth_map_accounts" {
  description = "Additional IAM accounts to add to the aws-auth configmap."
  type = list(any)
  default = []
}

variable "eks_cluster_node_group_instance_types" {
  type        = list(string)
  description = "EKS Cluster Main Node group instance types"
  default     = ["t3.medium", "t3.large", "m5.large", "m5.xlarge", "m5.2xlarge", "m5.4xlarge"]
}

variable "eks_cluster_node_group_ami" {
  type        = string
  description = "EKS Cluster Main Node group AMI machine"
  default     = "BOTTLEROCKET_x86_64"
}

variable "eks_cluster_node_group_platform" {
  type        = string
  description = "EKS Cluster Main Node group platform"
  default     = "bottlerocket"
}

variable "eks_cluster_node_group_capacity" {
  type        = string
  description = "EKS Cluster Main Node group capacity type"
  default     = "ON_DEMAND"
}

variable "eks_cluster_node_group_disk_size" {
  type        = number
  description = "EKS Cluster Main Node group disk size, described in Gigabytes"
  default     = 20
}

variable "eks_addon_aws_lb_version" {
  type        = string
  description = "AWS Load Balancer Controller Addon Version"
  default     = "v2.4.7"
}

variable "eks_addon_autoscaler_version" {
  type        = string
  description = "EKS Cluster Autoscaler Addon Version"
  default     = "v1.22.0"
}

variable "eks_addon_ack_apigw2_version" {
  description = "EKS ACK Addon for ApiGatewayv2 Version"
  type        = string
  default     = "v1.0.0"
}

variable "eks_ingress_controller_version" {
  description = "EKS Nginx Ingress Controller Version"
  type        = string
  default     = "v1.0.0"
}

variable "bastion_instance_class" {
  description = "Bastion server instance class"
  type        = string
  default     = "t3.micro"
}

variable "bastion_public_visible" {
  description = "Whether to associate a public EIP to Bastion server"
  type        = bool
  default     = true
}

# Registry

variable "registry_repositories" {
  description = "List of repositories to create in ECR"
  type        = list(string)
  default     = ["nginx", "redis", "mysql", "postgres", "php", "python", "java", "node", "go", "dotnet", "ruby", "phpfpm"]
}

variable "registry_protected_tags" {
  description = "List of ECR protected tags which won't never be expired on any repository."
  type        = list(string)
  default     = ["latest"]
}

variable "registry_full_access_users" {
  description = "List of users with full access privileges to ECR."
  type        = list(string)
  default     = ["ChangeMe", "ARN Example for user ARN full access: arn:aws:iam::123456789012:user/ChangeMe"]
}

# Storage

variable "database_port" {
  description = "Database Instance Port to be set"
  type        = number
  default     = 3306

}

variable "database_user" {
  description = "Database user to be set"
  type        = string
  default     = "admin"
}

variable "database_engine" {
    description = "Database engine to be set"
    type        = string
    default     = "mysql"
}

variable "database_engine_version" {
  description = "Database engine version to be set"
  type        = string
  default     = "5.7.30"
}

variable "database_replication_enabled" {
  description = "Whether to enable replication mode"
  type        = bool
  default     = false
}

variable "database_instance_type" {
  description = "Instace type to use for the database"
  type        = string
}

variable "database_allocated_storage" {
  description = "Instance allocated storage"
  type        = number
  default     = 20
}

variable "database_max_allocated_storage" {
  description = "Instance maximum allocated storage"
  type        = number
  default     = 100
}

variable "database_enable_cloudwatch_logging" {
  description = "Whether to enable cloudwatch log group creation"
  type        = bool
  default     = false
}

variable "database_cloudwatch_logging_exports" {
  description = "What to export to cloudwatch log group"
  type        = list(string)
  default     = []
}

variable "database_backup_retention_period" {
  description = "Database backup retention period"
  type        = number
  default     = 2
}

# Traffic Access

variable "traffic_main_domain_name" {
  description = "Main domain name managed by AWS of the solution"
  type        = string
  default     = "example.com"
}

variable "traffic_apigw_domain_name" {
  description = "Domain name managed by AWS and used for exposing services within the API Gateway"
  type        = string
  default     = "api.example.com"
}

variable "traffic_apigw_api_version" {
  description = "(Optional) API Version to set"
  type        = string
  default     = "stable"
}

variable "traffic_create_api_stage" {
  description = "Whether to create default stage to publish API"
  type        = bool
  default     = false
}

variable "traffic_create_api_routes" {
  description = "Whether to create routes and integrations"
  type        = bool
  default     = false
}

variable "traffic_create_api_lambda_authorizer" {
  description = "Whether to create lambda authorizers to enable API authentication"
  type        = bool
  default     = false
}

variable "traffic_api_authorizer_bucket_name" {
  description = "S3 bucket name where the package to create lambda authorizer is located"
  type        = string
  default     = null
}

variable "traffic_api_authorizer_bucket_key" {
  description = "S3 bucket key where the package to create lambda authorizer is located"
  type        = string
  default     = null
}

variable "traffic_api_authorizer_runtime" {
  description = "Lambda authorizer software runtime to be defined"
  type        = string
  default     = null
}

variable "traffic_api_authorizer_env_vars" {
  description = "Lambda authorizer environment variables to be defined"
  type        = map(string)
  default     = {}
}

variable "traffic_api_request_mappings" {
  description = "Mappings applied to request parameters that the API Gateway should perform"
  type        = map(string)
  default     = {}
}

variable "traffic_api_response_mappings" {
  description = "Mappings applied to response parameters that the API Gateway should perform"
  type        = map(string)
  default     = {}
}

variable "traffic_api_extra_routes" {
  description = "Map of API gateway extra routes with integrations"
  type        = map(any)
  default     = {}
}

variable "traffic_certificate_subjective_names" {
  description = "List of subjective names to include in the main ACM"
  type        = list(string)
  default     = ["example.com"]
}

variable "traffic_waf_name" {
  description = "Name to assign to Web Application Firewall ACL"
  type        = string
  default     = "traffic-waf"
}

variable "traffic_waf_enabled" {
  description = "Whether to configure Web Application Firewall ACL"
  type        = bool
  default     = false
}

variable "traffic_waf_allow_global" {
  description = "Whether to allow global traffic in Web Application Firewall ACL. If false, then only provided country-based traffic is allowed"
  type        = bool
  default     = true
}

variable "traffic_waf_allowed_countries" {
  description = "Provided country list from where traffic should be allowed in Web Application Firewall ACL"
  type        = list(string)
  default     = []
}

variable "frontend_subdomain" {
  description = "Frontend subdomain to configure in Route53 and CDN distribution"
  type        = string
  default     = ""
}