variable "tags_root" {
  type        = map
  description = "Tags to apply to global resources"
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

variable "enable_vpn" {
  description = "Whether to enable a Virtual Private Network Gateway attached to the VPC"
  type        = bool
  default     = false
}