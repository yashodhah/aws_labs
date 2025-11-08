locals {
  common_tags = {
    Project = var.project_name
  }
}

# S3 buckets
module "origin_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1"

  bucket        = "${var.project_name}-origin-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  force_destroy = true

  # Website hosting like CFN
  website = {
    index_document = "index.html"
  }

  # Allow public read for website (to mimic CFN policy)
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  tags = local.common_tags
}

resource "aws_s3_bucket_policy" "origin_public_read" {
  bucket = module.origin_bucket.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${module.origin_bucket.s3_bucket_arn}/*"]
      }
    ]
  })
}

module "video_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1"

  bucket        = "${var.project_name}-video-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  force_destroy = true
  tags          = local.common_tags
}

module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1"

  bucket        = "${var.project_name}-logs-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  force_destroy = true
  tags          = local.common_tags
}

module "failover_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.1"

  bucket        = "${var.project_name}-failover-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  force_destroy = true
  tags          = local.common_tags
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# IAM roles for MediaPackage
resource "aws_iam_role" "mediapackage_role" {
  name               = "${var.project_name}-mediapackage-role"
  assume_role_policy = data.aws_iam_policy_document.mediapackage_assume.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "mediapackage_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["mediapackage.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "mediapackage_s3_access" {
  name   = "s3-access"
  role   = aws_iam_role.mediapackage_role.id
  policy = data.aws_iam_policy_document.mediapackage_s3_access.json
}

data "aws_iam_policy_document" "mediapackage_s3_access" {
  statement {
    sid     = "0"
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::*/*",
    ]
  }
  statement {
    sid     = "1"
    actions = [
      "s3:GetBucketRequestPayment",
      "s3:ListBucket",
      "s3:GetBucketLocation",
    ]
    resources = [
      "arn:aws:s3:::*",
    ]
  }
}

resource "aws_iam_role" "mediapackage_secret_read_role" {
  name               = "${var.project_name}-mediapackage-secret-read"
  assume_role_policy = data.aws_iam_policy_document.mediapackage_assume.json
  tags               = local.common_tags
}

resource "aws_iam_role_policy" "mediapackage_secretmanager_access" {
  name   = "secretmanager-access"
  role   = aws_iam_role.mediapackage_secret_read_role.id
  policy = data.aws_iam_policy_document.mediapackage_secrets_access.json
}

data "aws_iam_policy_document" "mediapackage_secrets_access" {
  statement {
    sid     = "0"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecrets",
      "secretsmanager:ListSecretVersionIds",
    ]
    resources = ["*"]
  }
  statement {
    sid     = "1"
    actions = ["iam:GetRole", "iam:PassRole"]
    resources = ["*"]
  }
}

# MediaPackage VOD resources are not supported in the AWS provider as of this version.
# Leaving IAM roles and the getplayurl Lambda permissions in place so you can integrate
# MediaPackage VOD manually or via alternate providers if needed.

# Lambda functions (using standard module)
module "lambda_echo" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.5"

  function_name = "${var.project_name}-echo"
  description   = "returns incoming request object"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  create_role               = true
  attach_policy_statements  = true
  policy_statements = {
    logs = {
      effect    = "Allow"
      actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      resources = ["*"]
    }
  }

  s3_existing_package = {
    bucket = var.assets_bucket_name
    key    = "${var.assets_bucket_prefix}function/echo.zip"
  }

  tags = local.common_tags
}

module "lambda_login" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.5"

  function_name = "${var.project_name}-login"
  description   = "emulates login function"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  create_role              = true
  attach_policy_statements = true
  policy_statements = {
    logs = {
      effect    = "Allow"
      actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      resources = ["*"]
    }
  }

  environment_variables = {
    cookieName = "cloudfront-workshopSessionId"
    userName   = "admin"
    password   = "testadmin"
  }

  s3_existing_package = {
    bucket = var.assets_bucket_name
    key    = "${var.assets_bucket_prefix}function/login.zip"
  }

  tags = local.common_tags
}

module "lambda_logout" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.5"

  function_name = "${var.project_name}-logout"
  description   = "emulates logout (remove cookie)"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  create_role              = true
  attach_policy_statements = true
  policy_statements = {
    logs = {
      effect    = "Allow"
      actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      resources = ["*"]
    }
  }

  s3_existing_package = {
    bucket = var.assets_bucket_name
    key    = "${var.assets_bucket_prefix}function/logout.zip"
  }

  tags = local.common_tags
}

module "lambda_sessionvalue" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.5"

  function_name = "${var.project_name}-sessionvalue"
  description   = "return session ID or anonymous session"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  create_role              = true
  attach_policy_statements = true
  policy_statements = {
    logs = {
      effect    = "Allow"
      actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      resources = ["*"]
    }
  }

  environment_variables = {
    cookieName = "cloudfront-workshopSessionId"
  }

  s3_existing_package = {
    bucket = var.assets_bucket_name
    key    = "${var.assets_bucket_prefix}function/sessionvalue.zip"
  }

  tags = local.common_tags
}

module "lambda_getplayurl" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.5"

  function_name = "${var.project_name}-getplayurl"
  description   = "read the play url of mediapackage VOD"
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  timeout       = 60

  create_role              = true
  attach_policy_statements = true

  policy_statements = {
    logs = {
      effect    = "Allow"
      actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      resources = ["*"]
    }
    mediapackage = {
      effect = "Allow"
      actions = [
        "mediapackage-vod:List*",
        "mediapackage-vod:Describe*",
      ]
      resources = [
        "arn:aws:mediapackage-vod:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
        "arn:aws:mediapackage-vod:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:assets/*",
        "arn:aws:mediapackage-vod:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:packaging-configurations/*",
        "arn:aws:mediapackage-vod:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:packaging-groups/*",
      ]
    }
  }

  s3_existing_package = {
    bucket = var.assets_bucket_name
    key    = "${var.assets_bucket_prefix}function/getplayurl.zip"
  }

  tags = local.common_tags
}

module "lambda_getsignedcookie" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.5"

  function_name = "${var.project_name}-getsignedcookie"
  description   = "sets cookie for CloudFront private content"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  create_role              = true
  attach_policy_statements = true
  policy_statements = {
    logs = {
      effect    = "Allow"
      actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      resources = ["*"]
    }
  }

  environment_variables = {
    cloudFrontKeypairId = "<put your keypair id>"
    cloudFrontPrivateKey = "<put your private key text>"
    sessionDuration      = "86400"
    websiteDomain        = "<put your CloudFront domain name>"
  }

  s3_existing_package = {
    bucket = var.assets_bucket_name
    key    = "${var.assets_bucket_prefix}function/getsignedcookie.zip"
  }

  tags = local.common_tags
}

module "lambda_fle" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.5"

  function_name = "${var.project_name}-fle"
  description   = "shows incoming POST body as it is"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  create_role              = true
  attach_policy_statements = true
  policy_statements = {
    logs = {
      effect    = "Allow"
      actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      resources = ["*"]
    }
  }

  s3_existing_package = {
    bucket = var.assets_bucket_name
    key    = "${var.assets_bucket_prefix}function/fle.zip"
  }

  tags = local.common_tags
}

module "lambda_teststaleobject" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "~> 7.5"

  function_name = "${var.project_name}-teststaleobject"
  description   = "returns 200 OK or 5xx error based on env variable"
  handler       = "index.handler"
  runtime       = "nodejs20.x"

  create_role              = true
  attach_policy_statements = true
  policy_statements = {
    logs = {
      effect    = "Allow"
      actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      resources = ["*"]
    }
  }

  s3_existing_package = {
    bucket = var.assets_bucket_name
    key    = "${var.assets_bucket_prefix}function/teststaleobject.zip"
  }

  environment_variables = {
    statusCode = "200"
  }

  tags = local.common_tags
}

# API Gateway (REST)
resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.project_name}-OriginAPI"
  description = "API endpoint for function calls"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeploy = sha1(join(",", [
      aws_api_gateway_method.echo_get.id,
      aws_api_gateway_method.login_post.id,
      aws_api_gateway_method.logout_get.id,
      aws_api_gateway_method.sessionvalue_get.id,
      aws_api_gateway_method.getplayurl_get.id,
      aws_api_gateway_method.getsignedcookie_get.id,
      aws_api_gateway_method.fle_post.id,
      aws_api_gateway_method.teststaleobject_get.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "api" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = "api"
}

# Helper to create resources/methods/integrations
locals {
  api_paths = {
    "/echo"            = { method = "GET",  lambda_arn = module.lambda_echo.lambda_function_arn }
    "/login"           = { method = "POST", lambda_arn = module.lambda_login.lambda_function_arn }
    "/logout"          = { method = "GET",  lambda_arn = module.lambda_logout.lambda_function_arn }
    "/sessionvalue"    = { method = "GET",  lambda_arn = module.lambda_sessionvalue.lambda_function_arn }
    "/getplayurl"      = { method = "GET",  lambda_arn = module.lambda_getplayurl.lambda_function_arn }
    "/getsignedcookie" = { method = "GET",  lambda_arn = module.lambda_getsignedcookie.lambda_function_arn }
    "/fle"             = { method = "POST", lambda_arn = module.lambda_fle.lambda_function_arn }
    "/teststaleobject" = { method = "GET",  lambda_arn = module.lambda_teststaleobject.lambda_function_arn }
  }
}

resource "aws_api_gateway_resource" "resources" {
  for_each    = local.api_paths
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = trim(each.key, "/")
}

resource "aws_api_gateway_method" "echo_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.resources["/echo"].id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "echo_get" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.resources["/echo"].id
  http_method             = aws_api_gateway_method.echo_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_echo.lambda_function_invoke_arn
}

resource "aws_api_gateway_method" "login_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.resources["/login"].id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "login_post" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.resources["/login"].id
  http_method             = aws_api_gateway_method.login_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_login.lambda_function_invoke_arn
}

resource "aws_api_gateway_method" "logout_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.resources["/logout"].id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "logout_get" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.resources["/logout"].id
  http_method             = aws_api_gateway_method.logout_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_logout.lambda_function_invoke_arn
}

resource "aws_api_gateway_method" "sessionvalue_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.resources["/sessionvalue"].id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "sessionvalue_get" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.resources["/sessionvalue"].id
  http_method             = aws_api_gateway_method.sessionvalue_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_sessionvalue.lambda_function_invoke_arn
}

resource "aws_api_gateway_method" "getplayurl_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.resources["/getplayurl"].id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "getplayurl_get" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.resources["/getplayurl"].id
  http_method             = aws_api_gateway_method.getplayurl_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_getplayurl.lambda_function_invoke_arn
}

resource "aws_api_gateway_method" "getsignedcookie_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.resources["/getsignedcookie"].id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "getsignedcookie_get" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.resources["/getsignedcookie"].id
  http_method             = aws_api_gateway_method.getsignedcookie_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_getsignedcookie.lambda_function_invoke_arn
}

resource "aws_api_gateway_method" "fle_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.resources["/fle"].id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "fle_post" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.resources["/fle"].id
  http_method             = aws_api_gateway_method.fle_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_fle.lambda_function_invoke_arn
}

resource "aws_api_gateway_method" "teststaleobject_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.resources["/teststaleobject"].id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "teststaleobject_get" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.resources["/teststaleobject"].id
  http_method             = aws_api_gateway_method.teststaleobject_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.lambda_teststaleobject.lambda_function_invoke_arn
}

# Lambda permissions for API Gateway invoke
resource "aws_lambda_permission" "invoke" {
  for_each = local.api_paths

  statement_id  = "AllowAPIGatewayInvoke-${replace(each.key, "/", "-")}-${each.value.method}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.this.id}/*/${each.value.method}${each.key}"
}
