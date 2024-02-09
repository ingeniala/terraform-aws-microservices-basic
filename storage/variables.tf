variable "tags_root" {
  type        = map
  description = "Tags to apply to global resources"
}

variable "db_name" {
  description = "Database Instance Name to be set"
  type        = string
  default     = "mydb"
}

variable "db_port" {
  description = "Database Instance Port to be set"
  type        = number
  default     = 3306
}

variable "db_user" {
  description = "Database user to be set"
  type        = string
  default     = "admin"
}

variable "engine" {
    description = "Database engine to be set"
    type        = string
    default     = "mysql"
}

variable "engine_version" {
  description = "Database engine version to be set"
  type        = string
  default     = "8.0.35"
}

variable "vpc_name" {
  description = "VPC name where the cluster will be placed"
  type        = string
  default     = "Application VPC"
}

variable "replication_enabled" {
  description = "Whether to enable replication mode"
  type        = bool
  default     = false
}

variable "instance_type" {
  description = "Instace type to use for the database"
  type        = string
  default     = "db.t3.micro"
}

variable "allocated_storage" {
  description = "Instance allocated storage"
  type        = number
  default     = 5
}

variable "max_allocated_storage" {
  description = "Instance maximum allocated storage"
  type        = number
  default     = 10
}

variable "vpc_id" {
  description = "VPC Identifier where the storage layer will be placed"
  type        = string
  default     = ""  
}

variable "vpc_cidr_block" {
  description = "VPC block IP range where the storage layer will be placed"
  type        = string
  default     = "10.0.0.0/16"
}

variable "database_subnet_ids" {
  description = "VPC Database subnets Identifiers where the storage layer will be placed"
  type        = list(string)
  default     = []
}

variable "enable_cloudwatch_logging" {
  description = "Whether to enable cloudwatch log group creation"
  type        = bool
  default     = false
}

variable "cloudwatch_logging_exports" {
  description = "What to export to cloudwatch log group"
  type        = list(string)
  default     = []
}

variable "backup_retention_period" {
  description = "Database backup retention period"
  type        = number
  default     = 7
}
