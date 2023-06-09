locals {
  apigw_name = var.apigw_name

  root_domain_name = var.domain_name

  tags = {
    Module = "terraform-aws-microservices-basic"
    Tier   = "traffic"
  }
}

################################################################################
# Api Gateway HTTP VPC Link
################################################################################

module "microservices_api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "~> 2.2"

  name          = "${local.apigw_name}-apis"
  description   = "HTTP API Gateway with VPC links and exposed through a Custom Domain Name"
  protocol_type = "HTTP"
  api_version   = try(var.apigw_api_version, "stable")

  cors_configuration = {
    allow_headers  = ["*"]
    expose_headers = ["*"]
    allow_methods  = ["*"]
    allow_origins  = ["*"]
  }

  # Create a Custom Domain Name to access APIs publicly
  domain_name                 = var.apigw_domain_name
  domain_name_certificate_arn = module.main_acm.acm_certificate_arn
  domain_name_tags            = merge({Type = "API Gateway Custom Domain"}, local.tags, var.tags_root)

  # Create a VPC Link to access internal resources
  vpc_links = {
    alb-link = {
      name               = "${local.apigw_name}-api-gateway-alb-link"
      security_group_ids = [module.api_gateway_security_group.security_group_id]
      subnet_ids         = var.private_subnet_ids
    }
  }
  vpc_link_tags          = merge({Name = "${local.apigw_name}-api-gateway-alb-link", 
                                  Type = "API Gateway VPC Link"}, local.tags, var.tags_root)

  create_default_stage           = var.create_api_stage # <=Whether to create default stage to publish API
  create_routes_and_integrations = var.create_api_routes # <= Whether to create routes and integrations

  # Specify a REQUEST Lambda Authorizer
  authorizers = var.create_api_lambda_authorizer ? {
    "lambda-req" = {
      name                              = "${local.apigw_name}-api-gateway-authorizer"
      authorizer_type                   = "REQUEST"
      authorizer_uri                    = module.authorizer.lambda_function_invoke_arn
      authorizer_payload_format_version = "1.0"
      authorizer_result_ttl_in_seconds  = 0 #<= Caching TTL
      identity_sources                  = "$request.header.Authorization"
      enable_simple_responses           = false
    }
  } : {}

  # Specify a generic integration with the defined Authorizer
  integrations = var.create_api_lambda_authorizer ? merge({

    "$default" = {
      description            = "Default route integration with authentication"
      operation_name         = "Default authenticated operation"
      connection_type        = "VPC_LINK"
      vpc_link               = "alb-link"
      integration_type       = "HTTP_PROXY"
      integration_method     = "ANY"
      integration_uri        = data.aws_lb_listener.eks_alb_http.arn
      payload_format_version = "1.0"
      authorization_type     = "CUSTOM"
      authorizer_key         = "lambda-req"
      request_parameters     = jsonencode(var.api_request_mappings)
      response_parameters    = jsonencode([{status_code = 200, mappings = var.api_response_mappings}])
    }

    "OPTIONS /{proxy+}" = {
      description            = "Default unauthenticated route integration"
      operation_name         = "Default unauthenticated operation for preflight"
      connection_type        = "VPC_LINK"
      vpc_link               = "alb-link"
      integration_type       = "HTTP_PROXY"
      integration_method     = "OPTIONS"
      integration_uri        = data.aws_lb_listener.eks_alb_http.arn
      payload_format_version = "1.0"
      response_parameters    = jsonencode([
        {
          status_code = 500
          mappings = {
            "append:header.request" = "$context.requestId"
            "overwrite:statuscode"  = "403"
          }
        }
      ])
    }

  },var.api_extra_routes) : {  # <= No need to create authenticated integration when no authorizer is set
    "$default" = {
      description            = "Default unauthenticated route integration"
      operation_name         = "Default unauthenticated operation"
      connection_type        = "VPC_LINK"
      vpc_link               = "alb-link"
      integration_type       = "HTTP_PROXY"
      integration_method     = "ANY"
      integration_uri        = data.aws_lb_listener.eks_alb_http.arn
      payload_format_version = "1.0"
      response_parameters    = jsonencode([
        {
          status_code = 500
          mappings = {
            "append:header.request" = "$context.requestId"
            "overwrite:statuscode"  = "403"
          }
        }
      ])
    }
  }

  tags = merge({Name = "${local.apigw_name}-apis", Type = "API Gateway"}, local.tags, var.tags_root)
}

module "api_gateway_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${local.apigw_name}-api-gateway-sg"
  description = "Security group for allowing traffic from API Gateway through VPC Link"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]

  egress_rules = ["all-all"]
}

###################################################
# Lambda Authorizer using packaged function from S3
###################################################

module "authorizer" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 4.16"

  create = var.create_api_lambda_authorizer

  function_name = "${local.apigw_name}-jwt-lambda-authorizer"
  description   = "Lambda function which performs a validation to authenticate and authorize requests to ${local.apigw_name}"
  handler       = "index.handler"
  runtime       = var.api_authorizer_runtime

  vpc_subnet_ids         = var.private_subnet_ids
  vpc_security_group_ids = [module.api_gateway_security_group.security_group_id]
  attach_network_policy  = true

  publish        = true
  lambda_at_edge = false

  create_package      = false
  s3_existing_package = {
    bucket = var.api_authorizer_bucket_name
    key    = var.api_authorizer_bucket_key
  }

  environment_variables = var.api_authorizer_env_vars

  allowed_triggers = {
    AllowExecutionFromAPIGateway = {
      service    = "apigateway"
      source_arn = "${module.microservices_api_gateway.apigatewayv2_api_execution_arn}/*/*"
    }
  }

  tags = merge({Name = "${local.apigw_name}-lambda-authorizer", Type = "Lambda Function"}, 
                local.tags, var.tags_root)
}

###################################################
# Web Application Firewall
###################################################
module "waf" {
  source  = "cloudposse/waf/aws"
  version = "0.3.0"

  enabled = var.waf_enabled
  name    = var.waf_name

  scope = "CLOUDFRONT"

  default_action = "allow"
 
  geo_match_statement_rules = var.waf_allow_global ? [] : [
    {
      name     = "allow-geo"
      action   = "allow"
      priority = 10

      statement = {
        country_codes = var.waf_allowed_countries
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = false
        metric_name                = "allow-geo-metric"
      }
    }
  ]

  managed_rule_group_statement_rules = [
    {
      name      = "common"
      priority  = 20

      statement = {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = false
        metric_name                = "common-rules-metric"
      }
    }
  ]

  rate_based_statement_rules = [
    {
      name     = "block-ip"
      action   = "block"
      priority = 30

      statement = {
        limit              = 100
        aggregate_key_type = "IP"
      }

      visibility_config = {
        cloudwatch_metrics_enabled = true
        sampled_requests_enabled   = false
        metric_name                = "block-ip-metric"
      }
    }
  ]

  tags = merge({Name = "Frontend Shield", Type = "Amazon Web Application Firewall"}, 
            local.tags, var.tags_root)

}

################################################################################
# Supporting Resources
################################################################################
data "aws_route53_zone" "main" {
  name         = "${local.root_domain_name}."
  private_zone = false
}

module "main_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.3"

  domain_name = local.root_domain_name
  zone_id     = data.aws_route53_zone.main.zone_id

  subject_alternative_names = var.acm_subjective_names

  tags = merge({Name = local.root_domain_name, Type = "Amazon Issued Certificate"}, 
            local.tags, var.tags_root)
}

# Create Route53 record to map with associated custom domain name
resource "aws_route53_record" "apigw_record" {
  name    = var.apigw_domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.main.zone_id

  alias {
    name                   = module.microservices_api_gateway.apigatewayv2_domain_name_target_domain_name
    zone_id                = module.microservices_api_gateway.apigatewayv2_domain_name_hosted_zone_id
    evaluate_target_health = false
  }
}

# Get listener ARN from EKS Cluster ALB to be setup in VPC Link

data "aws_lb" "eks_alb" {
  name = var.eks_cluster_alb
}

data "aws_lb_listener" "eks_alb_http" {
  load_balancer_arn = data.aws_lb.eks_alb.arn
  port              = 80
}