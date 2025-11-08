Aim of this project is to create a multi‑region active/active architecture starting with two regional HTTP API Gateway endpoints, then layering CloudFront and Route 53 for global entry.

What exists now
- Terraform in `networking/terraform` that deploys two HTTP APIs using the standard `terraform-aws-modules/apigateway-v2/aws` module:
  - ap-southeast-1 (Singapore)
  - us-east-1 (N. Virginia)
- Each API proxies to a demo upstream (httpbin) via HTTP proxy integration, so you can test immediately.

How to deploy
1. Change directory:
	- `cd networking/terraform`
2. (Optional) Adjust variables in `variables.tf` or via `-var` flags:
	- `project_name` (default: `multi-region-http`)
	- `primary_region` (default: `ap-southeast-1`)
	- `secondary_region` (default: `us-east-1`)
	- `http_integration_uri` (default: `https://httpbin.org/anything`)
3. Initialize and validate:
	- `terraform init`
	- `terraform validate`
4. Plan and apply:
	- `terraform plan`
	- `terraform apply`

Outputs
- `primary_api_endpoint` – Invoke URL for ap-southeast-1
- `secondary_api_endpoint` – Invoke URL for us-east-1

Next steps
- Add CloudFront with origin failover across both regional APIs
- Add Route 53 latency-based routing to regional CloudFront distributions
- Replace the demo HTTP proxy integration with real backends (Lambda, ALB, etc.)

References

https://aws.amazon.com/blogs/networking-and-content-delivery/latency-based-routing-leveraging-amazon-cloudfront-for-a-multi-region-active-active-architecture/