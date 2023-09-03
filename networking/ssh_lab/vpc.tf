module "vpc_1" {
  source  = "../../vpc"
  enabled = true

  environment = var.environment

  vpc_name = "vpc_1"
  vpc_cidr = "10.0.0.0/16"

  azs_private  = local.azs.main.private
  azs_database = local.azs.main.database
  azs_public   = local.azs.main.public

  tags = local.tags
}

module "vpc_2" {
  source  = "../../vpc"
  enabled = true

  environment = var.environment

  vpc_name = "vpc_2"
  vpc_cidr = "10.1.0.0/16"

  public_subnets   = var.main_vpc_public_subnets
  private_subnets  = var.main_vpc_private_subnets
  database_subnets = var.main_vpc_database_subnets

  azs_private  = local.azs.main.private
  azs_database = local.azs.main.database
  azs_public   = local.azs.main.public

  tags = local.tags
}

module "vpc_3" {
  source  = "../../vpc"
  enabled = true

  environment = var.environment

  vpc_name = "vpc_3"
  vpc_cidr = "10.2.0.0/16"

  public_subnets   = var.main_vpc_public_subnets
  private_subnets  = var.main_vpc_private_subnets
  database_subnets = var.main_vpc_database_subnets

  azs_private  = local.azs.main.private
  azs_database = local.azs.main.database
  azs_public   = local.azs.main.public

  tags = local.tags
}