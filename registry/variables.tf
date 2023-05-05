variable "tags_root" {
  type        = map
  description = "Tags to apply to global resources"
}

variable "registry_name" {
  description = "ECR name to be set"
  type        = string
}

variable "repository_names" {
  description = "List of names provided to ECR created repositories."
  type        = list(string)
}

variable "protected_tags" {
  description = "List of ECR protected tags which won't never be expired on any repository."
  type        = list(string)
}

variable "full_access_users" {
  description = "List of users with full access privileges to ECR."
  type        = list(string)
}