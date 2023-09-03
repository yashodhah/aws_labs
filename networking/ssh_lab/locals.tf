locals {
  environment = "${var.environment}-${terraform.workspace}"

  azs = {
    main = {
      private  = slice(data.aws_availability_zones.main.names, 0, min(length(data.aws_availability_zones.main.names), var.main_vpc_az_count_private))
      database = slice(data.aws_availability_zones.main.names, 0, min(length(data.aws_availability_zones.main.names), var.main_vpc_az_count_database))
      public   = slice(data.aws_availability_zones.main.names, 0, min(length(data.aws_availability_zones.main.names), var.main_vpc_az_count_public))
    }
  }

  tags = {
    terraform   = "true"
    environment = local.environment
    workspace   = terraform.workspace
    project     = var.core_project_name
  }
}