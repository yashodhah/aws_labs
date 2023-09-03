module "ec2_bastion" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.3.1"

  name = "ec2_bastion"

  instance_type               = "t2.micro"
  subnet_id                   = element(module.vpc_1.private_subnets, 0)
  vpc_security_group_ids      = [module.ec2_bastion_sec_group.security_group_id]
  associate_public_ip_address = true

  maintenance_options = {
    auto_recovery = "default"
  }

  tags = local.tags
}

module "ec2_db" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.3.1"

  name = "ec2_db"

  instance_type               = "t2.micro"
  subnet_id                   = element(module.vpc_1.database_subnets, 0)
  vpc_security_group_ids      = [module.ec2_db_sec_group.security_group_id]
  associate_public_ip_address = true

  maintenance_options = {
    auto_recovery = "default"
  }

  tags = local.tags
}

module "ec2_bastion_sec_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "ec2_bastion_sec_group"
  description = "ec2 bastion group"
  vpc_id      = module.vpc_1.vpc_id

  egress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      rule        = "all-all"
      cidr_blocks = "10.0.0.0/16"
    },

  ]

  tags = local.tags
}

module "ec2_db_sec_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "ec2_db_sec_group"
  description = "Allow internal traffic only - mock DB"
  vpc_id      = module.vpc_1.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/16"]
  ingress_rules       = ["all-all"]

  tags = local.tags
}
