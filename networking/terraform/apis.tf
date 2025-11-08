module "http_api_ap_southeast_1" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  # version = "~> 5.0"  # Optionally pin

  providers = {
    aws = aws
  }

  name          = "${var.project_name}-ap-southeast-1"
  description   = "HTTP API (ap-southeast-1)"
  protocol_type = "HTTP"

  # Minimal route -> integration: send all traffic to demo upstream
  routes = {
    "$default" = {
      integration = {
        type = "HTTP_PROXY"
        uri  = var.http_integration_uri
      }
    }
  }

  tags = var.tags
}

module "http_api_us_east_1" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  # version = "~> 5.0"  # Optionally pin

  providers = {
    aws = aws.us_east_1
  }

  name          = "${var.project_name}-us-east-1"
  description   = "HTTP API (us-east-1)"
  protocol_type = "HTTP"

  routes = {
    "$default" = {
      integration = {
        type = "HTTP_PROXY"
        uri  = var.http_integration_uri
      }
    }
  }

  tags = var.tags
}
