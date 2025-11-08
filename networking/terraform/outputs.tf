output "primary_api_id" {
  value       = module.http_api_ap_southeast_1.api_id
  description = "API ID for primary region"
}

output "primary_api_endpoint" {
  value       = module.http_api_ap_southeast_1.api_endpoint
  description = "Invoke URL for primary region"
}

output "secondary_api_id" {
  value       = module.http_api_us_east_1.api_id
  description = "API ID for secondary region"
}

output "secondary_api_endpoint" {
  value       = module.http_api_us_east_1.api_endpoint
  description = "Invoke URL for secondary region"
}
