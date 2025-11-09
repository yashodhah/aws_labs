output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.main.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.main.id
}

output "api_gateway_endpoint" {
  description = "API Gateway HTTP endpoint"
  value       = aws_apigatewayv2_api.http_api.api_endpoint
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.static_content.id
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.hello_world.function_name
}

output "cloudfront_url" {
  description = "Full CloudFront URL"
  value       = "https://${aws_cloudfront_distribution.main.domain_name}"
}

output "api_through_cloudfront" {
  description = "API endpoint through CloudFront"
  value       = "https://${aws_cloudfront_distribution.main.domain_name}/api"
}

output "static_content_through_cloudfront" {
  description = "Static content through CloudFront"
  value       = "https://${aws_cloudfront_distribution.main.domain_name}/index.html"
}
