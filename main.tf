terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}

locals {
    env_fullname = "${var.env}-${var.project}"
    tags = {
        env = "${var.env}"
        project = "${var.project}"
    }
}

# Networking Layer (VPC, Subnets)

module "networking_layer" {
  source = "./networking"

  vpc_name               = "${local.env_fullname}-vpc"
  vpc_cidr_block         = var.vpc_cidr_block
  subnet_extra_mask_bits = var.vpc_subnet_extra_mask_bits
  enable_vpn             = var.vpc_enable_vpn
  tags_root              = local.tags
}

# Runtime Layer (EKS, EC2)

module "runtime_layer" {
  source = "./runtime"

  aws_profile = var.aws_profile # For Kubernetes CLI and helm interaction

  vpc_name       = "${local.env_fullname}-vpc"
  vpc_id         = module.networking_layer.vpc_id
  vpc_cidr_block = module.networking_layer.vpc_cidr_block

  private_subnet_ids = module.networking_layer.private_subnets
  public_subnet_ids  = module.networking_layer.public_subnets

  ## EKS Cluster
  cluster_name     = "${local.env_fullname}-eks-cluster"
  cluster_version  = var.eks_cluster_version
  cluster_max_size = var.eks_cluster_max_size

  cluster_auth_map_roles    = var.eks_cluster_auth_map_roles
  cluster_auth_map_users    = var.eks_cluster_auth_map_users
  cluster_auth_map_accounts = var.eks_cluster_auth_map_accounts

  cluster_node_group_instance_types = var.eks_cluster_node_group_instance_types
  cluster_node_group_ami            = var.eks_cluster_node_group_ami
  cluster_node_group_platform       = var.eks_cluster_node_group_capacity
  cluster_node_group_capacity       = var.eks_cluster_node_group_capacity
  cluster_node_group_disk_size      = var.eks_cluster_node_group_disk_size
  
  addon_aws_lb_version           = var.eks_addon_aws_lb_version
  addon_autoscaler_version       = var.eks_addon_autoscaler_version
  addon_ack_apigw2_version       = var.eks_addon_ack_apigw2_version
  ingress_controller_version     = var.eks_ingress_controller_version

  ## EC2 Public Bastion Server to jump to private resources
  bastion_name                = "${local.env_fullname}-bastion"
  bastion_instance_type       = var.bastion_instance_class
  bastion_associate_public_ip = var.bastion_public_visible
  bastion_user_data           = [
    "sudo yum -y update",
    # Postgresql Client
    "sudo amazon-linux-extras install postgresql14",
    # MySQL Client
    "sudo amazon-linux-extras install mariadb10.5",
    # Install Networking Tools
    "sudo yum install -y bind-utils",
    "sudo yum install -y net-tools",
    "sudo yum install -y telnet",
    "sudo yum install -y traceroute",
    "sudo yum install -y tcpdump",
    "sudo yum install -y nmap",
    "sudo yum install -y mtr"
  ]

  tags_root = local.tags
}

# Container Registry Layer (ECR)

module "registry_layer" {
  source = "./registry"

  registry_name     = "${local.env_fullname}-ecr"
  repository_names  = var.registry_repositories
  protected_tags    = var.registry_protected_tags
  full_access_users = var.registry_full_access_users

  tags_root = local.tags
}

# Storage (RDS)
module "storage_layer" {
  source = "./storage"

  vpc_name       = "${local.env_fullname}-vpc"
  vpc_id         = module.networking_layer.vpc_id
  vpc_cidr_block = module.networking_layer.vpc_cidr_block

  database_subnet_ids = module.networking_layer.database_subnets

  db_name  = "${local.env_fullname}-${var.database_engine}"
  db_port  = var.database_port
  db_user  = var.database_user
  
  engine         = var.database_engine
  engine_version = var.database_engine_version
  instance_type  = var.database_instance_type
  
  allocated_storage     = var.database_allocated_storage
  max_allocated_storage = var.database_max_allocated_storage
  replication_enabled   = var.database_replication_enabled

  backup_retention_period    = var.database_backup_retention_period
  enable_cloudwatch_logging  = var.database_enable_cloudwatch_logging
  cloudwatch_logging_exports = var.database_cloudwatch_logging_exports

  tags_root = local.tags
}

# Traffic Access (WAF, ApiGateway VPC Link)

module "traffic_access_layer" {
  source = "./traffic"

  vpc_id             = module.networking_layer.vpc_id
  private_subnet_ids = module.networking_layer.private_subnets

  apigw_name        = "${local.env_fullname}-apigw"
  apigw_api_version = var.traffic_apigw_api_version

  # API Related resources (Integrations, Stage, Routes, Authorizer)
  create_api_stage             = var.traffic_create_api_stage
  create_api_routes            = var.traffic_create_api_routes
  create_api_lambda_authorizer = var.traffic_create_api_lambda_authorizer
  api_authorizer_bucket_name   = var.traffic_api_authorizer_bucket_name
  api_authorizer_bucket_key    = var.traffic_api_authorizer_bucket_key
  api_authorizer_runtime       = var.traffic_api_authorizer_runtime
  api_authorizer_env_vars      = var.traffic_api_authorizer_env_vars
  api_request_mappings         = var.traffic_api_request_mappings
  api_response_mappings        = var.traffic_api_response_mappings

  # Route53 & ACM
  domain_name          = var.traffic_main_domain_name
  apigw_domain_name    = var.traffic_apigw_domain_name
  
  # Utils
  acm_subjective_names = concat(var.traffic_certificate_subjective_names,
    var.frontend_subdomain != "" ? [
      "${var.frontend_subdomain}.${var.traffic_main_domain_name}",
      "www.${var.frontend_subdomain}.${var.traffic_main_domain_name}"
    ] : [
      var.traffic_main_domain_name,
      "www.${var.traffic_main_domain_name}"
    ])
  
  eks_cluster_alb  = module.runtime_layer.cluster_addon_created_alb 

  # WAF
  waf_enabled      = var.traffic_waf_enabled
  waf_name         = var.traffic_waf_name
  waf_allow_global = var.traffic_waf_allow_global
  waf_allowed_countries = var.traffic_waf_allowed_countries

  tags_root = local.tags
}

# Frontend Access (CDN, Static S3 Website)

module "frontend_layer" {
  source = "./frontend"

  domain_name       = var.traffic_main_domain_name
  website_name      = "${local.env_fullname}-website"
  website_subdomain = var.frontend_subdomain
  
  # Utils
  acm_certificate_arn = module.traffic_access_layer.main_acm_certificate_arn

  # WAF (if enabled)
  waf_arn = var.traffic_waf_enabled ? module.traffic_access_layer.waf_arn : ""

  tags_root = local.tags
}