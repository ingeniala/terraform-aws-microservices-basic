variable "tags_root" {
  description = "Tags to apply to global resources"
  type        = map
  default     = {}
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "vpc_name" {
  description = "VPC name where the cluster will be placed"
  type        = string
  default     = "POC-Ingenia-VPC"
}

variable "subnet_extra_mask_bits" {
  description = "Extra mask bits amount for performing subnetting"
  type        = number
  default     = 8
}

variable db_subnet_groups {
  description = "List of DB subnet groups to be created"
  type = list
  default = ["POC-Ingenia-DB-Subnet-Group-1", "POC-Ingenia-DB-Subnet-Group-2"]
}

variable "enable_vpn" {
  description = "Whether to enable a Virtual Private Network Gateway attached to the VPC"
  type        = bool
  default     = false
}