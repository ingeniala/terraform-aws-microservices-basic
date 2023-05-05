
data "aws_availability_zones" "available" {}

locals {
  name    = var.db_name
  engine  = var.engine
  version = var.engine_version

  family                = join("",[var.engine,var.engine_version])  # DB parameter group
  major_engine_version  = var.engine_version                        # DB option group
  instance_class        = var.instance_type
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  port                  = var.db_port

  replication_enabled = var.replication_enabled

  vpc_name = var.vpc_name

  tags = {
    Module = "terraform-aws-microservices-basic"
    Tier   = "storage"
    Type   = var.engine
  }
}

################################################################################
# RDS Module
################################################################################

module "database_master" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.6.0"

  identifier = "${local.name}-master"

  engine               = local.engine
  engine_version       = local.version
  family               = local.family
  major_engine_version = local.major_engine_version
  instance_class       = local.instance_class

  allocated_storage     = local.allocated_storage
  max_allocated_storage = local.max_allocated_storage

  username               = var.db_user
  create_random_password = true
  port                   = local.port

  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [module.security_group.security_group_id]
  
  create_db_parameter_group   = true
  parameter_group_name        = "${local.name}-cluster-parameter-group"
  parameter_group_description = "${local.name} cluster parameter group"

  backup_window      = "00:00-03:00"
  maintenance_window = "Tue:03:00-Tue:06:00"
  apply_immediately  = true

  create_cloudwatch_log_group     = var.enable_cloudwatch_logging
  enabled_cloudwatch_logs_exports = var.cloudwatch_logging_exports

  # Backups are required in order to create a replica
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = true
  deletion_protection     = false
  storage_encrypted       = false

  tags = merge({Name = "${local.name}-master"},local.tags, var.tags_root)
}

################################################################################
# Replica DB
################################################################################

module "database_replica" {
  source  = "terraform-aws-modules/rds/aws"
  version = "5.6.0"

  identifier = "${local.name}-replica"
  
  create_db_instance = local.replication_enabled

  # Source database. For cross-region use db_instance_arn
  replicate_source_db    = module.database_master.db_instance_id
 
  engine               = local.engine
  engine_version       = local.version
  family               = local.family
  major_engine_version = local.major_engine_version
  instance_class       = local.instance_class

  allocated_storage     = local.allocated_storage
  max_allocated_storage = local.max_allocated_storage

  create_random_password = false
  port                   = local.port

  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [module.security_group.security_group_id]

  backup_window      = "00:00-03:00"
  maintenance_window = "Tue:03:00-Tue:06:00"
  apply_immediately  = true

  enabled_cloudwatch_logs_exports = var.cloudwatch_logging_exports
  create_cloudwatch_log_group     = var.enable_cloudwatch_logging

  # Backups are required in order to create a replica
  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = true
  deletion_protection     = false
  storage_encrypted       = false

  tags = merge({Name = "${local.name}-replica"},local.tags, var.tags_root)
}

################################################################################
# Supporting Resources
################################################################################

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "main"
  subnet_ids = var.database_subnet_ids

  tags = merge({
    Name = "${local.name} subnet group"
  }, local.tags, var.tags_root)
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.name}-security-group"
  description = "Database security group for VPC access"
  vpc_id      = var.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = local.port
      to_port     = local.port
      protocol    = "tcp"
      description = "Database access from within VPC"
      cidr_blocks = var.vpc_cidr_block
    }
  ]

  tags = merge({
    Name = "${local.name}-access-security-group"
  }, local.tags, var.tags_root)
}