terraform {
  backend "s3" {
    bucket  = "the-cloud-plumbing-co-terraform"
    key     = "aws_labs/netwroking/terraform.tfstate"
    region  = "ap-southeast-1"  # Change if the bucket is in another region
    encrypt = true
  }
}
