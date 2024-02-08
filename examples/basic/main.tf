terraform {
  backend "s3" {
    bucket = "my-infra-state"  # <= This should be created 
    key = "microservices-basic.tfstate"
    region = "us-east-1"
  }
}

locals {
    aws_region  = "us-east-1"
    aws_profile = "my-aws-profile"
    project     = "my-project"
    env         = "my-env"
    domain_name = "my-env.my-company.com"
    root_domain = trimprefix(local.domain_name, "${local.env}.")
    frontend_subdomain = "frontend"
}

provider "aws" {
  region  = "${local.aws_region}"
  profile = "${local.aws_profile}"
}

module "microservices_architecture_basic" {
    source = "../.."
#    source = "git@github.com:ingeniala/terraform-aws-microservices-basic.git"   <= To reference it remotely
    
    env     = "${local.env}"
    project = "${local.project}"

    aws_profile = local.aws_profile

    #Networking
    vpc_cidr_block             = "10.1.0.0/16"
    vpc_subnet_extra_mask_bits = 4

    #Runtime - EKS Control Plane
    eks_cluster_version  = "1.26"
    eks_cluster_max_size = 3

    eks_cluster_auth_map_users = [
      {
        userarn  = "arn:aws:iam::XXXXXXXXXXXX:user/john.doe"
        username = "john.doe"
        groups   = ["system:masters"]
      }
    ]

    #Runtime - EKS Main Node Group
    eks_cluster_node_group_instance_types = ["t3a.medium"]
    eks_cluster_node_group_disk_size      = 50
    
    #Runtime - EKS Addons
    eks_addon_aws_lb_version       = "2.5.1"
    eks_addon_autoscaler_version   = "1.26.2"
    eks_addon_ack_apigw2_version   = "1.0.3"
    eks_ingress_controller_version = "1.7.0"

    #Runtime - Bastion Server
    bastion_instance_class = "t3a.nano"

    #Container Registry
    registry_repositories = [
        "poc"
    ]
    registry_protected_tags = [
        "stable",
        "master",
        "prod"
    ]
    registry_full_access_users = [
        "arn:aws:iam::XXXXXXXXXXXX:user/john.doe"
    ]

    # Storage - Standalone RDS Instance
    database_port                  = 3306
    database_user                  = "master"
    database_engine                = "mysql"
    database_engine_version        = "8.0"
    database_instance_type         = "db.t4g.large"
    database_allocated_storage     = 20
    database_max_allocated_storage = 100

    database_backup_retention_period    = 1
    database_enable_cloudwatch_logging  = true
    database_cloudwatch_logging_exports = ["general"]

    # Traffic
    traffic_main_domain_name   = local.domain_name
    traffic_apigw_domain_name  = "api.${local.domain_name}"
    
    traffic_create_api_stage             = true
    traffic_create_api_routes            = true

    # Lambda authorizer
    traffic_create_api_lambda_authorizer = true
    traffic_api_authorizer_bucket_name   = "my-custom-authorizer"
    traffic_api_authorizer_bucket_key    = "source.zip"
    traffic_api_authorizer_runtime       = "nodejs18.x"
    traffic_api_authorizer_env_vars      = {
      FOO = "BAR"
    }

    traffic_certificate_subjective_names = [ 
      "*.dev.${local.root_domain}"
    ]

    frontend_subdomain = local.frontend_subdomain
}

# Ouputs

output "db_instance_endpoint" {
  description = "The connection endpoint of the master RDS instance"
  value       = module.microservices_architecture_basic.storage_master_db_instance_endpoint
}

output "db_instance_name" {
  description = "The database name of the master RDS instance"
  value       = module.microservices_architecture_basic.storage_master_db_instance_name
}

output "db_instance_username" {
  description = "The master username for the database of the master RDS instance"
  value       = module.microservices_architecture_basic.storage_master_db_instance_username
  sensitive   = true
}

output "db_instance_password" {
  description = "The database password of the master RDS instance (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = module.microservices_architecture_basic.storage_master_db_instance_password
  sensitive   = true
}

output "db_instance_port" {
  description = "The database port of the master RDS instance"
  value       = module.microservices_architecture_basic.storage_master_db_instance_port
}

output "eks_private_key_openssh" {
  description = "Private key data used in EKS Cluster Node Groups in OpenSSH PEM (RFC 4716) format"
  value       = module.microservices_architecture_basic.runtime_eks_managed_node_groups_private_key_openssh
  sensitive   = true
}

output "eks_public_key_openssh" {
  description = "The public key data used in EKS Cluster Node Groups in \"Authorized Keys\" format. This is populated only if the configured private key is supported: this includes all `RSA` and `ED25519` keys"
  value       = module.microservices_architecture_basic.runtime_eks_managed_node_groups_public_key_openssh
}

output "bastion_public_key_openssh" {
  description = "The public key data used in Bastion Server in \"Authorized Keys\" format. This is populated only if the configured private key is supported: this includes all `RSA` and `ED25519` keys"
  value       = module.microservices_architecture_basic.runtime_bastion_public_key_openssh
}

output "bastion_private_key_openssh" {
  description = "Private key data used in Bastion Server in OpenSSH PEM (RFC 4716) format"
  value       = module.microservices_architecture_basic.runtime_bastion_private_key_openssh
  sensitive   = true
}

output "bastion_public_ip" {
  value       = module.microservices_architecture_basic.runtime_bastion_public_ip
  description = "Bastion server Public IP of the instance (or EIP)"
}

output "traffic_main_certificate_arn" {
  description = "The ARN of the main certificate"
  value       = module.microservices_architecture_basic.traffic_main_certificate_arn
}

output "traffic_apigw_record_name" {
  description = "Route53 record created for accessing API Gateway"
  value       = module.microservices_architecture_basic.traffic_apigw_record_name
}

output "frontend_root_record_name" {
  description = "Route53 record created for accessing website"
  value       = module.microservices_architecture_basic.frontend_root_record_name
}
