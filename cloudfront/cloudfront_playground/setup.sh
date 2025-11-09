#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TERRAFORM_DIR="${SCRIPT_DIR}/terraform"

echo -e "${YELLOW}CloudFront Playground Setup${NC}"
echo "======================================"

# Step 1: Package Lambda function
echo -e "\n${YELLOW}[1/3] Packaging Lambda function...${NC}"
cd "${TERRAFORM_DIR}"
if [ -f "lambda_function.zip" ]; then
    rm lambda_function.zip
fi
zip -j lambda_function.zip index.py
echo -e "${GREEN}✓ Lambda packaged${NC}"

# Step 2: Initialize Terraform
echo -e "\n${YELLOW}[2/3] Initializing Terraform...${NC}"
terraform init
echo -e "${GREEN}✓ Terraform initialized${NC}"

# Step 3: Plan deployment
echo -e "\n${YELLOW}[3/3] Planning Terraform deployment...${NC}"
terraform plan -out=tfplan
echo -e "${GREEN}✓ Plan created (tfplan)${NC}"

echo -e "\n${YELLOW}======================================"
echo "Next steps:"
echo "  1. Review the plan: terraform show tfplan"
echo "  2. Apply: terraform apply tfplan"
echo "  3. View outputs: terraform output${NC}"
