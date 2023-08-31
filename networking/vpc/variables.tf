variable "enabled" { default = true }
variable "environment" {}

variable "tags" { type = map(string) }

variable "vpc_name" {}
variable "vpc_cidr" {}

variable "azs_private" {
  type        = list(string)
  description = "List of Availability Zones for PRIVATE Subnets. No more than 3 items."
}

variable "azs_database" {
  type        = list(string)
  description = "List of Availability Zones for DATABASE Subnets. No more than 3 items."
}

variable "azs_public" {
  type        = list(string)
  description = "List of Availability Zones for PUBLIC Subnets. No more than 3 items."
}

variable "private_subnets" {
  default = null
}

variable "public_subnets" {
  default = null
}

variable "database_subnets" {
  default = null
}