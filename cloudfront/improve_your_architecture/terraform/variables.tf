variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project / stack name used for tagging and naming"
  type        = string
  default     = "cloudfront-workshop"
}

variable "assets_bucket_name" {
  description = "Existing S3 bucket that contains Lambda zips and static asset archives"
  type        = string
  default     = "ws-assets-prod-iad-r-iad-ed304a55c2ca1aee"
}

variable "assets_bucket_prefix" {
  description = "Prefix within assets bucket where artifacts live (with trailing slash)"
  type        = string
  default     = "4557215e-2a5c-4522-a69b-8d058aba088c/"
}
