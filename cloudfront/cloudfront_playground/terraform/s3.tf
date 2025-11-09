# S3 bucket for static content
resource "aws_s3_bucket" "static_content" {
  bucket = "${var.bucket_name}-${data.aws_caller_identity.current.account_id}"
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "static_content" {
  bucket = aws_s3_bucket.static_content.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket versioning
resource "aws_s3_bucket_versioning" "static_content" {
  bucket = aws_s3_bucket.static_content.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "static_content" {
  bucket = aws_s3_bucket.static_content.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Bucket policy for CloudFront OAC access
resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = aws_s3_bucket.static_content.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAC"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.static_content.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main.arn
          }
        }
      }
    ]
  })
}

# Sample content
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.static_content.id
  key          = "index.html"
  content_type = "text/html"
  content      = <<-EOF
<!DOCTYPE html>
<html>
<head>
  <title>CloudFront Playground</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 40px; }
    h1 { color: #FF9900; }
  </style>
</head>
<body>
  <h1>CloudFront Playground</h1>
  <p>Static content served from S3 through CloudFront with OAC</p>
  <div id="result">Loading API response...</div>
  <script>
    // Uncomment to call the API through CloudFront
    // fetch('/api/').then(r => r.json()).then(d => document.getElementById('result').innerText = JSON.stringify(d));
  </script>
</body>
</html>
EOF
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}
