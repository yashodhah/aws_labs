# Default region: ap-southeast-1 (Singapore)
provider "aws" {
  region = var.primary_region
}

# Secondary region: us-east-1 (N. Virginia)
provider "aws" {
  alias  = "us_east_1"
  region = var.secondary_region
}
