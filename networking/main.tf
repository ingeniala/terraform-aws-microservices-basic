data "aws_availability_zones" "available" {}

locals {
  name   = var.vpc_name

  vpc_cidr = var.vpc_cidr_block
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)
  
  azs_count = length(local.azs)
  
  subnet_cidr_extra_mask = var.subnet_extra_mask_bits

  tags = merge({
    Module = "terraform-aws-microservices-basic"
    Tier   = "networking"
  }, var.tags_root)
}

################################################################################
# VPC Module
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = local.name
  cidr = local.vpc_cidr

  azs               = local.azs
  private_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, local.subnet_cidr_extra_mask, k)]
  public_subnets    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, local.subnet_cidr_extra_mask, k+local.azs_count)]
  database_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, local.subnet_cidr_extra_mask, k+local.azs_count*2)]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  reuse_nat_ips          = true # <= Skip creation of EIPs for the NAT Gateways
  external_nat_ip_ids    = [aws_eip.nat_eip.id]
  
  enable_vpn_gateway     = var.enable_vpn

  enable_dns_hostnames = true
  enable_dns_support   = true

  create_database_subnet_group  = false

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "Type" = "public"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "Type" = "private"
  }

  database_subnet_tags = {
    "Type" = "database"
  }

  tags = local.tags
}

# Supporting resources
resource "aws_eip" "nat_eip" {
  vpc  = true
  tags = merge({Name="${local.name}-nat-eip"},local.tags)
}

resource "aws_security_group" "vpc_tls" {
  name_prefix = "${local.name}-allow-tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = merge({Name="${local.name}-allow-tls"},local.tags)
}

resource "aws_security_group" "vpc_http" {
  name_prefix = "${local.name}-allow-http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  tags = merge({Name="${local.name}-allow-http"}, local.tags)
}