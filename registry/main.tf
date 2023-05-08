
locals {
  tags = {
    Module = "terraform-aws-microservices-basic"
    Tier   = "registry"
  }
}

################################################################################
# ECR Module. 
# Ref: https://github.com/cloudposse/terraform-aws-ecr
################################################################################

module "ecr" {
  source       = "cloudposse/ecr/aws"
  version      = "~> 0.35"

  name                    = var.registry_name
  use_fullname            = false
  image_tag_mutability    = "MUTABLE"
  image_names             = var.repository_names
  max_image_count         = 800
  protected_tags          = var.protected_tags
  principals_full_access  = var.full_access_users

  tags = merge(local.tags, var.tags_root)

}