output "origin_bucket_name" {
  value       = module.origin_bucket.s3_bucket_id
  description = "S3 bucket which contains static website origin"
}

output "log_bucket_name" {
  value       = module.log_bucket.s3_bucket_id
  description = "S3 bucket for storing logs"
}

output "failover_bucket_name" {
  value       = module.failover_bucket.s3_bucket_id
  description = "Failover contents bucket"
}

output "video_origin_domain" {
  value       = "(MediaPackage VOD not provisioned via Terraform - create manually)"
  description = "Placeholder since MediaPackage VOD resources not currently supported"
}

output "api_origin_endpoint" {
  value       = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${aws_api_gateway_stage.api.stage_name}/"
  description = "API endpoint"
}

output "s3_website_domain" {
  value       = module.origin_bucket.s3_bucket_website_endpoint
  description = "Static website URL served from S3"
}

output "media_package_secret_access_role_arn" {
  value       = aws_iam_role.mediapackage_secret_read_role.arn
  description = "Role ARN for Media Package to read secret from Secrets Manager"
}
