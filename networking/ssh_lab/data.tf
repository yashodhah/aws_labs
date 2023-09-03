data "aws_region" "main" { provider = aws }
#data "aws_region" "backup" { provider = aws.backup }

data "aws_caller_identity" "main" {}
#data "aws_caller_identity" "backup" { provider = aws.backup }

data "aws_availability_zones" "main" {
  state = "available"
}

