module "ec2_vpc_1" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.3.1"

  name = "ec2_vpc_1"

  instance_type               = "t2.micro"
  subnet_id                   = element(module.vpc_1.public_subnets, 0)
  vpc_security_group_ids      = [module.vpc_1_ec2_sec_group.security_group_id]
  associate_public_ip_address = true

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonS3FullAccess           = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  maintenance_options = {
    auto_recovery = "default"
  }

  tags = local.tags
}

module "ec2_vpc_2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.3.1"

  name = "ec2_vpc_2"

  instance_type               = "t2.micro"
  subnet_id                   = element(module.vpc_2.public_subnets, 0)
  vpc_security_group_ids      = [module.vpc_2_ec2_sec_group.security_group_id]
  associate_public_ip_address = true

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonS3FullAccess           = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  maintenance_options = {
    auto_recovery = "default"
  }

  tags = local.tags
}

module "ec2_vpc_3" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.3.1"

  name = "ec2_vpc_3"

  instance_type               = "t2.micro"
  subnet_id                   = element(module.vpc_3.public_subnets, 0)
  vpc_security_group_ids      = [module.vpc_3_ec2_sec_group.security_group_id]
  associate_public_ip_address = true

  create_iam_instance_profile = true
  iam_role_description        = "IAM role for EC2 instance"
  iam_role_policies = {
    AmazonS3FullAccess           = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  maintenance_options = {
    auto_recovery = "default"
  }

  tags = local.tags
}

module "vpc_1_ec2_sec_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "vpc_1_ec2_sec_group"
  description = "Allow internal ICMP traffic only"
  vpc_id      = module.vpc_1.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/8"]
  ingress_rules       = ["all-icmp"]

  egress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0" # consider restricting egress traffic to specific destinations for sessions manager
    },
    {
      rule        = "all-icmp"
      cidr_blocks = "10.0.0.0/8"
    }
  ]

  tags = local.tags
}

module "vpc_2_ec2_sec_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "vpc_2_ec2_sec_group"
  description = "Allow internal ICMP traffic only"
  vpc_id      = module.vpc_2.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/8"]
  ingress_rules       = ["all-icmp"]

  egress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0" # consider restricting egress traffic to specific destinations for sessions manager
    },
    {
      rule        = "all-icmp"
      cidr_blocks = "10.0.0.0/8"
    }
  ]

  tags = local.tags
}

module "vpc_3_ec2_sec_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "vpc_3_ec2_sec_group"
  description = "Allow internal ICMP traffic only"
  vpc_id      = module.vpc_3.vpc_id

  ingress_cidr_blocks = ["10.0.0.0/8"]
  ingress_rules       = ["all-icmp"]

  egress_with_cidr_blocks = [
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0" # consider restricting egress traffic to specific destinations for sessions manager
    },
    {
      rule        = "all-icmp"
      cidr_blocks = "10.0.0.0/8"
    }
  ]

  tags = local.tags
}