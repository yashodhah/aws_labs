variable "environment" {}
variable "aws_region_main" {}

variable "core_project_name" { default = "ssh-lab" }

variable "main_vpc_az_count_private" { default = 2 }
variable "main_vpc_az_count_database" { default = 2 }
variable "main_vpc_az_count_public" { default = 2 }

variable "ec2_key_name" { default = "" }

#variable "tags" { type = map(string) }
