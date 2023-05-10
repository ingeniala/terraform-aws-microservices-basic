provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", var.aws_profile]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      # This requires the awscli to be installed locally where Terraform is executed
      args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name, "--profile", var.aws_profile]
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  name            = var.cluster_name
  cluster_version = var.cluster_version
  vpc_name        = var.vpc_name

  cluster_max_size     = var.cluster_max_size

  lb_controller_name = "aws-lb-controller"
  autoscaler_name = "eks-cluster-autoscaler"

  lb_name = regex("^([a-z0-9-]+)-[a-z0-9]+", data.kubernetes_service_v1.nginx.status.0.load_balancer.0.ingress.0.hostname)[0]

  tags = {
    Module = "terraform-aws-microservices-basic"
    Tier   = "runtime"
  }
}

################################################################################
# EKS Module
################################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.1"

  cluster_name                   = local.name
  cluster_version                = local.cluster_version
  cluster_endpoint_public_access = true

  cluster_ip_family = "ipv4"

  cluster_addons = {
    coredns = {
      most_recent = true
      preserve    = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent    = true
      before_compute = true
    }
  }

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  manage_aws_auth_configmap = true
  
  aws_auth_roles    = var.cluster_auth_map_roles
  aws_auth_users    = var.cluster_auth_map_users
  aws_auth_accounts = var.cluster_auth_map_accounts

  eks_managed_node_group_defaults = {

    instance_types = var.cluster_node_group_instance_types

    # We are using the IRSA created below for permissions
    # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
    # and then turn this off after the cluster/node group is created. Without this initial policy,
    # the VPC CNI fails to assign IPs and nodes cannot join the cluster
    # See https://github.com/aws/containers-roadmap/issues/1666 for more context
    iam_role_attach_cni_policy = true
  }

  eks_managed_node_groups = {

    # Default node group
    main_ng = {

      use_custom_launch_template = false

      description = "EKS managed node group example launch template using BottleRocket AMI"

      ami_type = var.cluster_node_group_ami
      platform = var.cluster_node_group_platform

      capacity_type  = var.cluster_node_group_capacity
      disk_size      = var.cluster_node_group_disk_size

      min_size     = 1
      max_size     = local.cluster_max_size
      desired_size = 1

      remote_access = {
        ec2_ssh_key               = module.key_pair.key_pair_name
        source_security_group_ids = [aws_security_group.remote_ssh_access.id]
      }

      labels = {
        Module = "terraform-aws-microservices-basic"
        Type   = "bottlerocket"
      }

      update_config = {
        max_unavailable_percentage = 33
      }

      ebs_optimized           = true
      enable_monitoring       = true

      create_iam_role          = true
      iam_role_name            = "${local.name}-iam-role"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS bottlerock managed node group IAM role for ${local.name}"

      iam_role_additional_policies = {
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        
        additional                         = aws_iam_policy.node_additional.arn
      }
    }
  }

  tags = merge({Type = "EKS", Description = "Resources involved in ${local.name} creation"},
              local.tags, var.tags_root)
}

################################################################################
# Supporting Resources
################################################################################

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  key_name_prefix    = local.name
  create_private_key = true

  tags = merge({Type = "EKS SSH Key Pair", Name = "${local.name}-node-group-access-key"},
                local.tags, var.tags_root)
}

resource "aws_security_group" "remote_ssh_access" {
  name_prefix = "${local.name}-remote-ssh-access"
  description = "Allow remote SSH access"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.tags, { Name = "${local.name}-remote" }, var.tags_root)
}

resource "aws_iam_policy" "node_additional" {
  name        = "${local.name}-additional"
  description = "Example usage of node additional policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = merge({Type = "EKS IAM Policy", Name = "${local.name}-node-group-custom-iam-policy"},
                local.tags, var.tags_root)
}

################################################################################
# Deploy Cluster Autoscaler Addon
# Ref: https://github.com/lablabs/terraform-aws-eks-cluster-autoscaler
################################################################################

module "cluster_autoscaler_helm" {
  source  = "lablabs/eks-cluster-autoscaler/aws"
  version = "2.1.0"

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = false

  cluster_name                     = module.eks.cluster_name
  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn

  helm_release_name  = local.autoscaler_name
  namespace          = "kube-system"

  values = yamlencode({
    "replicaCount": 2,
    "image" : {
      "repository": "registry.k8s.io/autoscaling/cluster-autoscaler",
      "tag" : "v${var.addon_autoscaler_version}",
      "pullPolicy": "IfNotPresent"
    },
    "podLabels" : {
      "app" : local.autoscaler_name
    }
  })
}

################################################################################
# Deploy AWS LB Controller Addon
# Ref: https://github.com/lablabs/terraform-aws-eks-load-balancer-controller
################################################################################

module "aws_lb_controller" {
  source  = "lablabs/eks-load-balancer-controller/aws"
  version = "1.2.0"

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = false

  cluster_name                     = module.eks.cluster_name
  cluster_identity_oidc_issuer     = module.eks.cluster_oidc_issuer_url
  cluster_identity_oidc_issuer_arn = module.eks.oidc_provider_arn

  helm_chart_name    = "aws-load-balancer-controller"
  helm_chart_version = "1.5.2"
  helm_release_name  = local.lb_controller_name
  namespace          = "kube-system"

  # Values can be fetch from: https://github.com/aws/eks-charts/blob/master/stable/aws-load-balancer-controller/values.yaml
  values = yamlencode({
    "replicaCount": 2,
    "image": {
      "repository": "public.ecr.aws/eks/aws-load-balancer-controller",
      "tag": "v${var.addon_aws_lb_version}",
      "pullPolicy": "IfNotPresent"
    },
    "podLabels" : {
      "app" : local.lb_controller_name
    },
    "defaultTargetType": "instance"
  })

  helm_timeout = 240
  helm_wait    = true

}

################################################################################
# Deploy ACK Addons
################################################################################
data "aws_ecrpublic_authorization_token" "token" {}

module "eks_ack_addons" {
  source  = "aws-ia/eks-ack-addons/aws"
  version = "1.3.0"

  cluster_id          = module.eks.cluster_name
  ecrpublic_username  = data.aws_ecrpublic_authorization_token.token.user_name
  ecrpublic_token     = data.aws_ecrpublic_authorization_token.token.password

  # Wait for data plane to be ready
  data_plane_wait_arn = module.eks.eks_managed_node_groups.main_ng.node_group_arn

  enable_api_gatewayv2 = true

  api_gatewayv2_helm_config = {
      chart               = "apigatewayv2-chart"
      repository          = "oci://public.ecr.aws/aws-controllers-k8s"
      version             = "v${var.addon_ack_apigw2_version}"
      namespace           = "kube-system"
    }

  tags = merge({Type = "EKS Addon", Name = "Amazon Controller for ApiGateway v2"},
              local.tags, var.tags_root)

  # This module depends on the cluster creation
  depends_on = [module.eks]
}

################################################################################
# Deploy Nginx Ingress Controller
################################################################################

module "ingress_nginx" {
  source  = "lablabs/eks-ingress-nginx/aws"
  version = "1.2.0"

  enabled           = true
  argo_enabled      = false
  argo_helm_enabled = false

  helm_release_name = "ingress-nginx"
  namespace         = "ingress"

  # Values can be fetched from https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml
  values = yamlencode({
    "controller": {
      "image": {
        "tag": "v${var.ingress_controller_version}"
      },
      "replicaCount": 2,
      "proxySetHeaders": {
        "X-Using-Nginx-Controller": "true"
      }
    },
    "podLabels" : {
      "app" : "ingress-nginx"
    }
  })

  helm_timeout = 240
  helm_wait    = true

  depends_on = [  # <= In order to wait for EKS ALB controller helm release
    module.aws_lb_controller
  ]
}

# Wait for the ALB provisioned by Nginx

resource "time_sleep" "wait_nginx_deploy" {
 
  create_duration = "60s"

  triggers = {
    nginx_deploy = module.ingress_nginx.helm_release_metadata[0].name
  }
}

data "kubernetes_service_v1" "nginx" {

  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress"
  }

  depends_on = [
    time_sleep.wait_nginx_deploy
  ]
}

################################################################################
# Bastion Server to access internal resources by SSH
################################################################################

data "aws_ami" "amazon_linux_2" {
    most_recent = true

    filter {
      name   = "owner-alias"
      values = ["amazon"]
    }

    filter {
      name   = "name"
      values = ["amzn2-ami-hvm*"]
    }

    owners = ["amazon"]
}

module "bastion_key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  key_name_prefix    = var.bastion_name
  create_private_key = true

  tags = merge({Type = "Bastion SSH Key Pair", Name = "${var.bastion_name}-bastion-access-key"},
                local.tags, var.tags_root)
}

module "ec2_bastion" {
  source  = "cloudposse/ec2-bastion-server/aws"
  version = "0.30.1"

  name                        = var.bastion_name
  instance_type               = var.bastion_instance_type
  ami                         = data.aws_ami.amazon_linux_2.id  # Amazon Linux 2
  subnets                     = var.public_subnet_ids
  key_name                    = module.bastion_key_pair.key_pair_name
  user_data                   = var.bastion_user_data
  vpc_id                      = var.vpc_id
  associate_public_ip_address = var.bastion_associate_public_ip

  tags = merge({Type = "Bastion Server", Name = var.bastion_name},
                local.tags, var.tags_root)
}