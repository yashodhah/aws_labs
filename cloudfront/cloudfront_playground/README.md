# CloudFront Playground

A simple infrastructure setup demonstrating:
- HTTP API Gateway with Lambda integration
- S3 bucket for static content
- CloudFront distribution with Origin Access Control (OAC)

## Architecture

```
┌─────────────────────────────────────────────┐
│           CloudFront Distribution           │
│  (Domain: xxx.cloudfront.net)               │
└─────────┬─────────────────────────────┬─────┘
          │                             │
    /api/* path                  Default / path
          │                             │
          ↓                             ↓
    ┌─────────────┐            ┌──────────────┐
    │  API Gateway│            │  S3 Bucket   │
    │   + Lambda  │            │ (with OAC)   │
    └─────────────┘            └──────────────┘
```

## Features

- **API Gateway**: HTTP API with Lambda integration for dynamic content
- **Lambda**: Python function that responds to GET requests
- **S3 Bucket**: Private bucket with static HTML content
- **CloudFront**: Distribution with two origins:
  - API Gateway for `/api/*` paths
  - S3 bucket for static content
- **OAC (Origin Access Control)**: Secure S3 access from CloudFront only

## Prerequisites

- AWS CLI configured with credentials
- Terraform >= 1.0
- Python 3.11 (for Lambda runtime)
- Bash shell

## Deployment

### Quick Start

```bash
chmod +x setup.sh
./setup.sh
```

This will:
1. Package the Lambda function
2. Initialize Terraform
3. Create a deployment plan

### Manual Steps

1. **Package Lambda**:
   ```bash
   cd terraform
   zip -j lambda_function.zip index.py
   ```

2. **Initialize Terraform**:
   ```bash
   terraform init
   ```

3. **Plan**:
   ```bash
   terraform plan -out=tfplan
   ```

4. **Apply**:
   ```bash
   terraform apply tfplan
   ```

## Configuration

Edit `terraform/terraform.tfvars` or pass variables:

```hcl
aws_region   = "us-east-1"
environment  = "dev"
project_name = "cloudfront-playground"
bucket_name  = "my-unique-bucket-name"
api_name     = "my-api"
```

## Outputs

After deployment, view outputs with:
```bash
terraform output
```

Key outputs:
- `cloudfront_url`: Main CloudFront URL
- `api_through_cloudfront`: API endpoint via CloudFront
- `static_content_through_cloudfront`: Static content URL
- `cloudfront_distribution_id`: CloudFront distribution ID

## Testing

### Test API through CloudFront
```bash
curl https://<cloudfront-domain>/api/
```

### Test Static Content
```bash
curl https://<cloudfront-domain>/index.html
```

### Direct API Gateway
```bash
curl <api-gateway-endpoint>/
```

## Cleanup

```bash
cd terraform
terraform destroy
```

## Architecture Notes

### Origin Access Control (OAC)
- S3 bucket has a bucket policy that only allows CloudFront to access it
- CloudFront uses OAC (not Origin Access Identity) for secure S3 access
- Direct S3 URL access is blocked

### Cache Behavior
- **Static content** (`/`): Cached for 1 hour (3600s)
- **API calls** (`/api/*`): Not cached (0s TTL), all methods allowed
- Both redirected to HTTPS

### CloudFront Distribution
- IPv6 enabled
- Error responses (403, 404) redirect to index.html
- HTTPS default certificate used

## Cost Optimization

For production, consider:
- Using a custom domain with ACM certificate
- Enabling CloudFront caching for API responses (where applicable)
- Setting up WAF rules
- Configuring CloudWatch monitoring

## Troubleshooting

### S3 403 Forbidden
Check that OAC policy is correctly applied:
```bash
aws s3api get-bucket-policy --bucket <bucket-name>
```

### Lambda Timeout
Check CloudWatch logs:
```bash
aws logs tail /aws/lambda/<function-name> --follow
```

### CloudFront 504 Error
Ensure API Gateway is responding and Lambda has correct permissions.

## References

- [AWS CloudFront OAC](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-origin.html)
- [API Gateway HTTP API](https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api.html)
- [Lambda Deployment Packages](https://docs.aws.amazon.com/lambda/latest/dg/python-package.html)
