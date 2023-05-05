variable "tags_root" {
  type        = map
  description = "Tags to apply to global resources"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
}

variable "vpc_name" {
  description = "VPC name where the cluster will be placed"
  type        = string
}

variable "subnet_extra_mask_bits" {
  description = "Extra mask bits amount for performing subnetting"
  type        = number
}

variable "enable_vpn" {
  description = "Whether to enable a Virtual Private Network Gateway attached to the VPC"
  type        = bool
}