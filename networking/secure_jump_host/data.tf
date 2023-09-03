data "aws_region" "main" { provider = aws }

data "aws_caller_identity" "main" {}

data "aws_availability_zones" "main" {
  state = "available"
}

