data "aws_availability_zones" "available" {}

locals {
#  name                  = var.db_name
  aws_db_instance_name  = var.db_name
  aws_engine            = var.engine
#  engine                = var.engine
  aws_engine_version    = var.engine_version
#  version               = var.engine_version
  aws_db_family         = join("",[var.engine,var.engine_version])
#  family                = join("",[var.engine,var.engine_version])  # DB parameter group
  aws_db_major_engine_version = var.engine_version
#  major_engine_version  = var.engine_version                        # DB option group
  aws_db_instance_class = var.aws_db_instance_class
#  instance_class        = var.instance_type
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
  version = "6.4.0"
  create_aws_db_instance = true
#  create_db_instance = true
#  aws_db_instance = local.replication_enabled
  identifier = "${local.name}-master"
#  aws_db_instance_name = "${local.name}-master"
  aws_engine            = local.engine
#  engine               = local.engine
#  engine_version        = local.version
  aws_engine_version    = local.version
  aws_db_family         = local.family
#  family                = local.family
  aws_db_major_engine_version = local.major_engine_version
#  major_engine_version  = local.major_engine_version
  aws_db_instance_class = local.instance_class
#  instance_class       = local.instance_class
  allocated_storage     = local.allocated_storage
#  max_allocated_storage = local.max_allocated_storage
  aws_max_allocated_storage = local.max_allocated_storage
  username               = var.db_user
  create_random_password = true
  port                   = local.port
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [module.security_group.security_group_id]
  create_aws_db_parameter_group = true
#  create_db_parameter_group   = true
#  Agregados por Andres Kitaura
#  2024-02-09
  # create_aws_db_parameter_group.name = "${local.name}-cluster-parameter-group"
  # create_aws_db_parameter_group.family = local.family
  # create_aws_db_parameter_group.description = "${local.name} cluster parameter group"
  # create_aws_db_parameter_group.parameters = [
  #   {
  #     name  = "character_set_client"
  #     value = "utf8mb4"
  #   },
  #   {
  #     name  = "character_set_server"
  #     value = "utf8mb4"
  #   }
  # ]
#  Agregados por Andres Kitaura
#  2024-02-09

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
  source                  = "terraform-aws-modules/rds/aws"
  version                 = "6.4.0"
  identifier              = "${local.name}-replica"
#  aws_db_instance_name = "${local.name}-replica"
## Added the create_aws_db_instance to avoid the hashicorp/db	issue
  create_aws_db_instance  = local.replication_enabled
  aws_db_instance_class   = local.aws_db_instance_class
#  aws_db_instance_name    = "${local.name}-replica"
  aws_dbinstance_region   = data.aws_availability_zones.available.names[0]
  # Changed the db_instance for aws_db_instance because of the problem on hashicorp/db
  # create_db_instance      = local.replication_enabled
  # Added aws_db_instance to avoid the bug on hashicorp/db that's not existsing
  # Source database. For cross-region use db_instance_arn
  
  replicate_source_db             = module.database_master.db_instance_id
  aws_engine                      = local.engine
  aws_engine_version              = local.version
#  engine                  = local.engine
#  engine_version          = local.version
#  family                  = local.family
  aws_db_family                   = local.family
  aws_db_major_engine_version     = local.major_engine_version
#  major_engine_version           = local.major_engine_version
  allow_max_version_upgrade       = false
  allow_min_version_upgrade       = true
  allocated_storage               = local.allocated_storage
  max_allocated_storage           = local.max_allocated_storage
  aws_create_random_password      = false
  aws_port                        = local.port
#  port                           = local.port
  multi_az                        = false
  aws_db_subnet_group_name        = aws_db_subnet_group.db_subnet_group.name
#  db_subnet_group_name           = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids          = [module.security_group.security_group_id]
  backup_window                   = "00:00-03:00"
  maintenance_window              = "Tue:03:00-Tue:06:00"
  apply_immediately               = true
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
  description = "Database subnet group for ${local.name}"
  type        = "SubnetGroup"
  default     = true
  name        = var.db_subnet_group_name != "" ? var.db_subnet_group_name : "${local.name}-sg"
  subnet_ids  = var.database_subnet_ids

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