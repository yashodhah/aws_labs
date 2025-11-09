variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "cloudfront-playground"
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "cloudfront-playground-bucket"
}

variable "api_name" {
  description = "API Gateway name"
  type        = string
  default     = "cloudfront-playground-api"
}
