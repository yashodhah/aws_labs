module "vpc_1" {
  source  = "../vpc"
  enabled = true

  environment = var.environment

  vpc_name = "vpc_1"
  vpc_cidr = "10.0.0.0/16"

  azs_private  = local.azs.main.private
  azs_database = local.azs.main.database
  azs_public   = local.azs.main.public

  tags = local.tags
}