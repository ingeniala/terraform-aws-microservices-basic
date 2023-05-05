output "repository_arn_map" {
  value       = module.ecr.repository_arn_map
  description = "Map of repository names to repository ARNs"
}

output "repository_url_map" {
  value       = module.ecr.repository_url_map
  description = "Map of repository names to repository URLs"
}