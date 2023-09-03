#module "ec2_public" {
#  source  = "terraform-aws-modules/ec2-instance/aws"
#  version = "5.3.1"
#
#  name = "ec2_public"
#
#  instance_type               = "t2.micro"
#  subnet_id                   = element(module.vpc_1.public_subnets, 0)
#  vpc_security_group_ids      = [module.ec2_public_sec_group.security_group_id]
#  associate_public_ip_address = true
#
#  key_name = var.ec2_key_name
#
#  maintenance_options = {
#    auto_recovery = "default"
#  }
#
#  tags = local.tags
#}
#
#module "ec2_private" {
#  source  = "terraform-aws-modules/ec2-instance/aws"
#  version = "5.3.1"
#
#  name = "ec2_private"
#
#  instance_type               = "t2.micro"
#  subnet_id                   = element(module.vpc_1.private_subnets, 0)
#  vpc_security_group_ids      = [module.ec2_private_sec_group.security_group_id]
#  associate_public_ip_address = true
#
#  key_name = var.ec2_key_name
#
#  maintenance_options = {
#    auto_recovery = "default"
#  }
#
#  tags = local.tags
#}
#
#module "ec2_public_sec_group" {
#  source  = "terraform-aws-modules/security-group/aws"
#  version = "~> 4.0"
#
#  name        = "ec2_public_sec_group"
#  description = "Allow ssh from anywhere :D"
#  vpc_id      = module.vpc_1.vpc_id
#
#  ingress_cidr_blocks = ["0.0.0.0/0"]
#  ingress_rules       = ["all-ssh"]
#
#  tags = local.tags
#}
#
#module "ec2_private_sec_group" {
#  source  = "terraform-aws-modules/security-group/aws"
#  version = "~> 4.0"
#
#  name        = "ec2_private_sec_group"
#  description = "Allow internal traffic only"
#  vpc_id      = module.vpc_1.vpc_id
#
#  ingress_cidr_blocks = ["10.0.0.0/16"]
#  ingress_rules       = ["all"]
#
#  tags = local.tags
#}
