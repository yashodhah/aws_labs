#locals {
#  assume_role_arn = "arn:aws:iam::${var.target_account_id}:role/${var.iam_assume_role}"
#}

// TODO: Add assume role
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region_main
}

#terraform {
#  backend "s3" {
#    encrypt = true
#    bucket  = "dev.yashodha.space.tf.state"
#    key     = "dev/ssh-lab.tfstate"
#    region  = "ap-south-1"
#    #    dynamodb_table = "st-terraform-state-lock-dev"
#  }
#}
