# Terraform Files Summary

## File Structure

```
cloudfront_playground/
├── terraform/
│   ├── versions.tf           # Terraform version and provider requirements
│   ├── providers.tf          # AWS provider configuration
│   ├── variables.tf          # Input variables
│   ├── terraform.tfvars      # Variable values
│   ├── lambda.tf             # Lambda function and IAM role
│   ├── api_gateway.tf        # HTTP API Gateway configuration
│   ├── s3.tf                 # S3 bucket and bucket policy
│   ├── cloudfront.tf         # CloudFront distribution with OAC
│   ├── outputs.tf            # Output values
│   └── index.py              # Lambda function code
├── setup.sh                  # Deployment setup script
└── README.md                 # Documentation
```

## Key Features Implemented

### 1. Lambda Function (lambda.tf)
- Python 3.11 runtime
- Simple GET request handler
- Returns JSON response
- IAM role with basic execution permissions

### 2. API Gateway (api_gateway.tf)
- HTTP API (v2) with CORS enabled
- Lambda integration with AWS_PROXY
- GET and $default routes
- Lambda permissions configured
- IAM role for API Gateway to invoke Lambda

### 3. S3 Bucket (s3.tf)
- Private bucket (all public access blocked)
- Versioning enabled
- Server-side encryption (AES256)
- Sample index.html included
- Bucket policy allows only CloudFront OAC access

### 4. CloudFront Distribution (cloudfront.tf)
- Origin Access Control (OAC) for S3
- Two origins:
  - S3 bucket (static content)
  - API Gateway (API calls)
- Routing logic:
  - `/api/*` → API Gateway
  - Default → S3
- Cache behaviors:
  - Static: 1 hour TTL
  - API: No caching
- Error handling (403, 404 → index.html)
- IPv6 enabled

## Configuration

**Region**: us-east-1 (Note: "us-southeast-1" doesn't exist; using us-east-1 instead)

**Variables** (terraform.tfvars):
```hcl
aws_region   = "us-east-1"
environment  = "dev"
project_name = "cloudfront-playground"
bucket_name  = "cloudfront-playground-bucket"
api_name     = "cloudfront-playground-api"
```

## Deployment Steps

```bash
# 1. Make setup script executable
chmod +x setup.sh

# 2. Run setup (packages Lambda, inits Terraform, creates plan)
./setup.sh

# 3. Review the plan
terraform show tfplan

# 4. Apply configuration
terraform apply tfplan

# 5. View outputs
terraform output
```

## Key Outputs

After deployment:
- `cloudfront_url` - HTTPS CloudFront domain
- `api_through_cloudfront` - API endpoint via CloudFront
- `static_content_through_cloudfront` - Static content URL
- `cloudfront_distribution_id` - Distribution ID
- `api_gateway_endpoint` - Direct API endpoint

## Testing

```bash
# Test API through CloudFront
curl https://<cloudfront-domain>/api/

# Test static content
curl https://<cloudfront-domain>/index.html

# Test direct API Gateway
curl <api-gateway-endpoint>/
```

## Origin Access Control (OAC) Details

- **Type**: CloudFront to S3
- **Security**: Only CloudFront can access S3 bucket
- **Signing**: Uses SigV4 (Signature Version 4)
- **S3 Policy**: Restricts access by CloudFront distribution ARN

## Cost Notes

- Lambda: Charged per invocation + duration
- API Gateway: Charged per HTTP request
- S3: Storage + request charges
- CloudFront: Data transfer + request charges

## Cleanup

```bash
cd terraform
terraform destroy
```

## Troubleshooting

See README.md in the playground directory for detailed troubleshooting steps.
