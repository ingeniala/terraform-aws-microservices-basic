# Global variables

variable "env" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "aws_profile" {
  description = "AWS Profile to use when interacting with resources during installation"
  type        = string
}

# Networking

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "vpc_subnet_extra_mask_bits" {
  description = "Extra mask bits amount for performing subnetting within the VPC"
  type        = number
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
}

variable "eks_cluster_max_size" {
  type        = number
  description = "EKS Cluster maximum amount of worker nodes"
}

variable "eks_cluster_auth_map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = [{}]
}

variable "eks_cluster_auth_map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = [{}]
}

variable "eks_cluster_auth_map_accounts" {
  description = "Additional IAM accounts to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = [{}]
}

variable "eks_cluster_node_group_instance_types" {
  type        = list(string)
  description = "EKS Cluster Main Node group instance types"
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
}

variable "eks_addon_aws_lb_version" {
  type        = string
  description = "AWS Load Balancer Controller Addon Version"
}

variable "eks_addon_autoscaler_version" {
  type        = string
  description = "EKS Cluster Autoscaler Addon Version"
}

variable "eks_addon_ack_apigw2_version" {
  type        = string
  description = "EKS ACK Addon for ApiGatewayv2 Version"
}

variable "eks_ingress_controller_version" {
  type        = string
  description = "EKS Nginx Ingress Controller Version"
}

variable "bastion_instance_class" {
  type        = string
  description = "Bastion server instance class"
}

variable "bastion_public_visible" {
  type        = bool
  description = "Whether to associate a public EIP to Bastion server"
  default     = true
}

# Registry

variable "registry_repositories" {
  description = "List of repositories to create in ECR"
  type        = list(string)
}

variable "registry_protected_tags" {
  description = "List of ECR protected tags which won't never be expired on any repository."
  type        = list(string)
  default     = []
}

variable "registry_full_access_users" {
  description = "List of users with full access privileges to ECR."
  type        = list(string)
  default     = []
}

# Storage

variable "database_port" {
  description = "Database Instance Port to be set"
  type        = number
}

variable "database_user" {
  description = "Database user to be set"
  type        = string
}

variable "database_engine" {
    description = "Database engine to be set"
    type        = string
}

variable "database_engine_version" {
  description = "Database engine version to be set"
  type        = string
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
}

variable "database_max_allocated_storage" {
  description = "Instance maximum allocated storage"
  type        = number
}

variable "database_enable_cloudwatch_logging" {
  type        = bool
  description = "Whether to enable cloudwatch log group creation"
  default     = false
}

variable "database_cloudwatch_logging_exports" {
  type        = list(string)
  description = "What to export to cloudwatch log group"
  default     = []
}

variable "database_backup_retention_period" {
  type        = number
  description = "Database backup retention period"
  default     = 1
}

# Traffic Access

variable "traffic_main_domain_name" {
  description = "Main domain name managed by AWS of the solution"
  type        = string
}

variable "traffic_apigw_domain_name" {
  description = "Domain name managed by AWS and used for exposing services within the API Gateway"
  type        = string
}

variable "traffic_apigw_api_version" {
  type        = string
  default     = "stable"
  description = "(Optional) API Version to set"
}

variable "traffic_create_api_stage" {
  type        = bool
  description = "Whether to create default stage to publish API"
  default     = false
}

variable "traffic_create_api_routes" {
  type        = bool
  description = "Whether to create routes and integrations"
  default     = false
}

variable "traffic_create_api_lambda_authorizer" {
  type        = bool
  description = "Whether to create lambda authorizers to enable API authentication"
  default     = false
}

variable "traffic_api_authorizer_bucket_name" {
  type        = string
  description = "S3 bucket name where the package to create lambda authorizer is located"
  default     = null
}

variable "traffic_api_authorizer_bucket_key" {
  type        = string
  description = "S3 bucket key where the package to create lambda authorizer is located"
  default     = null
}

variable "traffic_api_authorizer_runtime" {
  type        = string
  description = "Lambda authorizer software runtime to be defined"
  default     = null
}

variable "traffic_api_authorizer_env_vars" {
  type        = map(string)
  description = "Lambda authorizer environment variables to be defined"
  default     = {}
}

variable "traffic_api_request_mappings" {
  type        = map(string)
  description = "Mappings applied to request parameters that the API Gateway should perform"
  default     = {}
}

variable "traffic_api_response_mappings" {
  type        = map(string)
  description = "Mappings applied to response parameters that the API Gateway should perform"
  default     = {}
}

variable "traffic_certificate_subjective_names" {
  description = "List of subjective names to include in the main ACM"
  type        = list(string)
}

variable "frontend_subdomain" {
  description = "Frontend subdomain to configure in Route53 and CDN distribution"
  type        = string
}