variable "tags_root" {
  type        = map
  description = "Tags to apply to global resources"
}

variable "aws_profile" {
  description = "AWS Profile to use when interacting with resources during installation"
  type        = string
}

variable "cluster_name" {
  description = "EKS Cluster Name to be set"
  type        = string
}

variable "cluster_version" {
  description = "EKS Cluster version to be set"
  type        = string
}

variable "cluster_max_size" {
  type        = string
  description = "EKS Cluster maximum amount of worker nodes"
}

variable "cluster_auth_map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
}

variable "cluster_auth_map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
}

variable "cluster_auth_map_accounts" {
  description = "Additional IAM accounts to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
}

variable "cluster_node_group_instance_types" {
  type        = list(string)
  description = "EKS Cluster Main Node group instance types"
}

variable "cluster_node_group_ami" {
  type        = string
  description = "EKS Cluster Main Node group AMI machine"
}

variable "cluster_node_group_platform" {
  type        = string
  description = "EKS Cluster Main Node group platform"
}

variable "cluster_node_group_capacity" {
  type        = string
  description = "EKS Cluster Main Node group capacity type"
}

variable "cluster_node_group_disk_size" {
  type        = number
  description = "EKS Cluster Main Node group disk size, described in Gigabytes"
}

variable "addon_aws_lb_version" {
  type        = string
  description = "AWS Load Balancer Controller Addon Version"
}

variable "addon_autoscaler_version" {
  type        = string
  description = "AWS EKS Cluster Autoscaler Addon Version"
}

variable "addon_ack_apigw2_version" {
  type        = string
  description = "AWS EKS Cluster Controller for ApiGatewayv2 Version"
}

variable "ingress_controller_version" {
  type        = string
  description = "AWS EKS Nginx Ingress Controller Version"
}

variable "vpc_name" {
  description = "VPC name where the cluster will be placed"
  type        = string
}

variable "bastion_name" {
  type        = string
  description = "Bastion server chosen name"
}

variable "bastion_instance_type" {
  type        = string
  description = "Bastion server instance type"
}

variable "bastion_user_data" {
  type        = list(string)
  description = "Bastion server user data content"
}

variable "bastion_associate_public_ip" {
  type        = bool
  description = "Whether to associate a public EIP to Bastion server"
}

variable "vpc_id" {
  type        = string
  description = "VPC Identifier where the runtime layer will be placed"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC block IP range where the runtime layer will be placed"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "VPC Private subnets Identifiers where the runtime layer will be placed"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "VPC Public subnets Identifiers where the runtime layer will be placed"
}