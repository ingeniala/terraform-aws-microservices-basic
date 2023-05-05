# Networking 

output "networking_vpc_id" {
  description = "The ID of the VPC"
  value       = module.networking_layer.vpc_id
}

output "networking_vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.networking_layer.vpc_cidr_block
}

output "networking_default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = module.networking_layer.default_security_group_id
}

output "networking_private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.networking_layer.private_subnets
}

output "networking_private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.networking_layer.private_subnets_cidr_blocks
}

output "networking_private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.networking_layer.private_route_table_ids
}

output "networking_public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.networking_layer.public_subnets
}

output "networking_public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = module.networking_layer.public_subnets_cidr_blocks
}

output "networking_public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = module.networking_layer.public_route_table_ids
}

output "networking_database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.networking_layer.database_subnets
}

output "networking_database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = module.networking_layer.database_subnets_cidr_blocks
}

output "networking_database_route_table_ids" {
  description = "List of IDs of database route tables"
  value       = module.networking_layer.database_route_table_ids
}

output "networking_nat_ids" {
  description = "List of allocation ID of Elastic IPs created for AWS NAT Gateway"
  value       = module.networking_layer.nat_ids
}

output "networking_nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.networking_layer.nat_public_ips
}

output "networking_natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.networking_layer.natgw_ids
}

output "networking_igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.networking_layer.igw_id
}

output "networking_vgw_id" {
  description = "The ID of the VPN Gateway"
  value       = module.networking_layer.vgw_id
}

# Runtime

output "runtime_eks_cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the EKS cluster"
  value       = module.runtime_layer.cluster_arn
}

output "runtime_eks_cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.runtime_layer.cluster_certificate_authority_data
}

output "runtime_eks_cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = module.runtime_layer.cluster_endpoint
}

output "runtime_eks_cluster_id" {
  description = "The ID of the EKS cluster. Note: currently a value is returned only for local EKS clusters created on Outposts"
  value       = module.runtime_layer.cluster_id
}

output "runtime_eks_cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.runtime_layer.cluster_name
}

output "runtime_eks_cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  value       = module.runtime_layer.cluster_oidc_issuer_url
}

output "runtime_eks_cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = module.runtime_layer.cluster_platform_version
}

output "runtime_eks_cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = module.runtime_layer.cluster_status
}

output "runtime_eks_cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = module.runtime_layer.cluster_primary_security_group_id
}

output "runtime_eks_cluster_addons" {
  description = "Map of attribute maps for all EKS cluster addons enabled"
  value       = module.runtime_layer.cluster_addons
}

output "runtime_eks_eks_managed_node_groups" {
  description = "Map of attribute maps for all EKS managed node groups created"
  value       = module.runtime_layer.eks_managed_node_groups
}

output "runtime_eks_eks_managed_node_groups_autoscaling_group_names" {
  description = "List of the autoscaling group names created by EKS managed node groups"
  value       = module.runtime_layer.eks_managed_node_groups_autoscaling_group_names
}

output "runtime_eks_aws_auth_configmap_yaml" {
  description = "Formatted yaml output for base aws-auth configmap containing roles used in cluster node groups/fargate profiles"
  value       = module.runtime_layer.aws_auth_configmap_yaml
}

output "runtime_eks_managed_node_groups_key_pair_id" {
  description = "The key pair ID used in EKS Cluster Node Groups"
  value       = module.runtime_layer.key_pair_id
}

output "runtime_eks_managed_node_groups_key_pair_name" {
  description = "The key pair name used in EKS Cluster Node Groups"
  value       = module.runtime_layer.key_pair_name
}

output "runtime_eks_managed_node_groups_private_key_id" {
  description = "Unique identifier for this resource: hexadecimal representation of the SHA1 checksum of the resource"
  value       = module.runtime_layer.private_key_id
}

output "runtime_eks_managed_node_groups_private_key_openssh" {
  description = "Private key data used in EKS Cluster Node Groups in OpenSSH PEM (RFC 4716) format"
  value       = module.runtime_layer.private_key_openssh
  sensitive   = true
}

output "runtime_eks_managed_node_groups_private_key_pem" {
  description = "Private key data used in EKS Cluster Node Groups in PEM (RFC 1421) format"
  value       = module.runtime_layer.private_key_pem
  sensitive   = true
}

output "runtime_eks_managed_node_groups_public_key_openssh" {
  description = "The public key data used in EKS Cluster Node Groups in \"Authorized Keys\" format. This is populated only if the configured private key is supported: this includes all `RSA` and `ED25519` keys"
  value       = module.runtime_layer.public_key_openssh
}

output "runtime_eks_managed_node_groups_public_key_pem" {
  description = "Public key data used in EKS Cluster Node Groups in PEM (RFC 1421) format"
  value       = module.runtime_layer.public_key_pem
}

output "runtime_bastion_public_ip" {
  value       = module.runtime_layer.public_ip
  description = "Bastion server Public IP of the instance (or EIP)"
}

output "runtime_bastion_name" {
  description = "Bastion server instance name"
  value       = module.runtime_layer.name
}

output "runtime_bastion_security_group_name" {
  value       = module.runtime_layer.security_group_name
  description = "Bastion host Security Group name"
}

output "runtime_bastion_key_name" {
  value       = module.runtime_layer.bastion_key_name
  description = "Bastion server Key Name"
}

output "runtime_bastion_public_key_openssh" {
  description = "The public key data used in Bastion Server in \"Authorized Keys\" format. This is populated only if the configured private key is supported: this includes all `RSA` and `ED25519` keys"
  value       = module.runtime_layer.bastion_public_key_openssh
}

output "runtime_bastion_public_key_pem" {
  description = "Public key data used in Bastion Server in PEM (RFC 1421) format"
  value       = module.runtime_layer.bastion_public_key_pem
}

output "runtime_bastion_private_key_openssh" {
  description = "Private key data used in Bastion Server in OpenSSH PEM (RFC 4716) format"
  value       = module.runtime_layer.bastion_private_key_openssh
  sensitive   = true
}

output "runtime_bastion_private_key_pem" {
  description = "Private key data used in Bastion Server in PEM (RFC 1421) format"
  value       = module.runtime_layer.bastion_private_key_pem
  sensitive   = true
}

# Container Registry

output "registry_repository_arn_map" {
  value       = module.registry_layer.repository_arn_map
  description = "Map of repository names to repository ARNs"
}

output "registry_repository_url_map" {
  value       = module.registry_layer.repository_url_map
  description = "Map of repository names to repository URLs"
}

# Storage

output "storage_master_db_instance_address" {
  description = "The address of the master RDS instance"
  value       = module.storage_layer.master_db_instance_address
}

output "storage_master_db_instance_arn" {
  description = "The ARN of the master RDS instance"
  value       = module.storage_layer.master_db_instance_arn
}

output "storage_master_db_instance_availability_zone" {
  description = "The availability zone of the master RDS instance"
  value       = module.storage_layer.master_db_instance_availability_zone
}

output "storage_master_db_instance_endpoint" {
  description = "The connection endpoint of the master RDS instance"
  value       = module.storage_layer.master_db_instance_endpoint
}

output "storage_master_db_instance_engine" {
  description = "The database engine of the master RDS instance"
  value       = module.storage_layer.master_db_instance_engine
}

output "storage_master_db_instance_engine_version_actual" {
  description = "The running version of the database of the master RDS instance"
  value       = module.storage_layer.master_db_instance_engine_version_actual
}

output "storage_master_db_instance_id" {
  description = "The RDS instance ID of the master RDS instance"
  value       = module.storage_layer.master_db_instance_id
}

output "storage_master_db_instance_status" {
  description = "The RDS instance status of the master RDS instance"
  value       = module.storage_layer.master_db_instance_status
}

output "storage_master_db_instance_name" {
  description = "The database name of the master RDS instance"
  value       = module.storage_layer.master_db_instance_name
}

output "storage_master_db_instance_username" {
  description = "The master username for the database of the master RDS instance"
  value       = module.storage_layer.master_db_instance_username
  sensitive   = true
}

output "storage_master_db_instance_password" {
  description = "The database password of the master RDS instance (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = module.storage_layer.master_db_instance_password
  sensitive   = true
}

output "storage_master_db_instance_port" {
  description = "The database port of the master RDS instance"
  value       = module.storage_layer.master_db_instance_port
}

output "storage_master_db_subnet_group_id" {
  description = "The db subnet group name of the master RDS instance"
  value       = module.storage_layer.master_db_subnet_group_id
}

output "storage_master_db_subnet_group_arn" {
  description = "The ARN of the db subnet group of the master RDS instance"
  value       = module.storage_layer.master_db_subnet_group_arn
}

output "storage_replica_db_instance_address" {
  description = "The address of the replica RDS instance"
  value       = module.storage_layer.replica_db_instance_address
}

output "storage_replica_db_instance_arn" {
  description = "The ARN of the replica RDS instance"
  value       = module.storage_layer.replica_db_instance_arn
}

output "storage_replica_db_instance_availability_zone" {
  description = "The availability zone of the replica RDS instance"
  value       = module.storage_layer.replica_db_instance_availability_zone
}

output "storage_replica_db_instance_endpoint" {
  description = "The connection endpoint of the replica RDS instance"
  value       = module.storage_layer.replica_db_instance_endpoint
}

output "storage_replica_db_instance_engine" {
  description = "The database engine of the replica RDS instance"
  value       = module.storage_layer.replica_db_instance_engine
}

output "storage_replica_db_instance_engine_version_actual" {
  description = "The running version of the database of the replica RDS instance"
  value       = module.storage_layer.replica_db_instance_engine_version_actual
}

output "storage_replica_db_instance_id" {
  description = "The RDS instance ID of the replica RDS instance"
  value       = module.storage_layer.replica_db_instance_id
}

output "storage_replica_db_instance_status" {
  description = "The RDS instance status of the replica RDS instance"
  value       = module.storage_layer.replica_db_instance_status
}

output "storage_replica_db_instance_name" {
  description = "The database name of the replica RDS instance"
  value       = module.storage_layer.replica_db_instance_name
}

output "storage_replica_db_instance_username" {
  description = "The replica username for the database of the replica RDS instance"
  value       = module.storage_layer.replica_db_instance_username
  sensitive   = true
}

output "replica_master_db_instance_password" {
  description = "The database password of the replica RDS instance (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = module.storage_layer.master_db_instance_password
  sensitive   = true
}

output "storage_replica_db_instance_port" {
  description = "The database port of the replica RDS instance"
  value       = module.storage_layer.replica_db_instance_port
}

# Traffic

output "traffic_api_endpoint" {
  description = "The URI of the API"
  value       = module.traffic_access_layer.api_endpoint
}

output "traffic_vpc_link_id" {
  description = "ID of the API Gateway VPC Link"
  value       = module.traffic_access_layer.vpc_link_id
}

output "traffic_vpc_link_arn" {
  description = "ARN of the API Gateway VPC Link"
  value       = module.traffic_access_layer.vpc_link_arn
}

output "traffic_main_certificate_arn" {
  description = "The ARN of the main certificate"
  value       = module.traffic_access_layer.main_acm_certificate_arn
}

output "traffic_apigw_record_name" {
  description = "Route53 record created for accessing API Gateway Custom Domain Name"
  value       = module.traffic_access_layer.apigw_route53_record_name
}

# Frontend

output "frontend_root_record_name" {
  description = "Route53 record created for accessing website"
  value       = module.frontend_layer.root_record_name
}

output "frontend_root_cdn_arn" {
  description = "The ARN (Amazon Resource Name) for the distribution."
  value       = module.frontend_layer.cloudfront_distribution_arn
}

output "frontend_root_cdn_domain_name" {
  description = "TThe domain name corresponding to the distribution."
  value       = module.frontend_layer.cloudfront_distribution_domain_name
}
