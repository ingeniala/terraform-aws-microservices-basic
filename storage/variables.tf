variable "tags_root" {
  type        = map
  description = "Tags to apply to global resources"
}

variable "db_name" {
  description = "Database Instance Name to be set"
  type        = string
}

variable "db_port" {
  description = "Database Instance Port to be set"
  type        = number
}

variable "db_user" {
  description = "Database user to be set"
  type        = string
}

variable "engine" {
    description = "Database engine to be set"
    type        = string
}

variable "engine_version" {
  description = "Database engine version to be set"
  type        = string
}

variable "vpc_name" {
  description = "VPC name where the cluster will be placed"
  type        = string
}

variable "replication_enabled" {
  description = "Whether to enable replication mode"
  type        = bool
}

variable "instance_type" {
  description = "Instace type to use for the database"
  type        = string
}

variable "allocated_storage" {
  description = "Instance allocated storage"
  type        = number
}

variable "max_allocated_storage" {
  description = "Instance maximum allocated storage"
  type        = number
}

variable "vpc_id" {
  type        = string
  description = "VPC Identifier where the storage layer will be placed"
}

variable "vpc_cidr_block" {
  type        = string
  description = "VPC block IP range where the storage layer will be placed"
}

variable "database_subnet_ids" {
  type        = list(string)
  description = "VPC Database subnets Identifiers where the storage layer will be placed"
}

variable "enable_cloudwatch_logging" {
  type        = bool
  description = "Whether to enable cloudwatch log group creation"
}

variable "cloudwatch_logging_exports" {
  type        = list(string)
  description = "What to export to cloudwatch log group"
}

variable "backup_retention_period" {
  type        = number
  description = "Database backup retention period"
}
