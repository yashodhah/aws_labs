#!/bin/bash
# Quick deployment guide for CloudFront Playground

cd "$(dirname "$0")/terraform"

echo "🚀 CloudFront Playground - Quick Start"
echo "======================================"
echo ""
echo "Step 1: Package Lambda function"
zip -j lambda_function.zip index.py
echo "✓ Lambda packaged"
echo ""

echo "Step 2: Initialize Terraform"
terraform init
echo "✓ Terraform initialized"
echo ""

echo "Step 3: Validate configuration"
terraform validate
echo "✓ Configuration validated"
echo ""

echo "Step 4: Plan deployment"
terraform plan -out=tfplan
echo "✓ Plan created"
echo ""

echo "Step 5: Review outputs that will be created:"
terraform output
echo ""

echo "Ready to deploy! Run:"
echo "  terraform apply tfplan"
echo ""
echo "Or to auto-approve:"
echo "  terraform apply tfplan -auto-approve"
