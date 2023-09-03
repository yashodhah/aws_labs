variable "environment" {}
variable "aws_region_main" {}

variable "core_project_name" { default = "lab-1" }

variable "main_vpc_az_count_private" { default = 2 }
variable "main_vpc_az_count_database" { default = 2 }
variable "main_vpc_az_count_public" { default = 2 }

variable "main_vpc_public_subnets" { default = null }
variable "main_vpc_private_subnets" { default = null }
variable "main_vpc_database_subnets" { default = null }

#variable "tags" { type = map(string) }
