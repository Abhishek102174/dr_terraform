#!/bin/bash

# Bootstrap script to create Terraform backend infrastructure
# Usage: ./setup.sh <environment>
# Example: ./setup.sh dr

set -e

ENVIRONMENT=${1:-dr}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Setting up Terraform backend for environment: $ENVIRONMENT"

# Check if tfvars file exists
if [ ! -f "$SCRIPT_DIR/terraform.tfvars.$ENVIRONMENT" ]; then
    echo "❌ Error: terraform.tfvars.$ENVIRONMENT not found"
    exit 1
fi

# Initialize and apply bootstrap
cd "$SCRIPT_DIR"
terraform init
terraform plan -var-file="terraform.tfvars.$ENVIRONMENT"
terraform apply -var-file="terraform.tfvars.$ENVIRONMENT" -auto-approve

# Get outputs
BUCKET_NAME=$(terraform output -raw s3_bucket_name)
DYNAMODB_TABLE=$(terraform output -raw dynamodb_table_name)

echo "✅ Backend infrastructure created successfully!"
echo ""
echo "📋 Backend Configuration:"
echo "  S3 Bucket: $BUCKET_NAME"
echo "  DynamoDB Table: $DYNAMODB_TABLE"
echo ""
echo "🔧 Next steps:"
echo "1. Update backend-configs/$ENVIRONMENT.hcl with the actual bucket name"
echo "2. Run 'terraform init -backend-config=backend-configs/$ENVIRONMENT.hcl' in the main directory"
echo "3. Commit and push the changes to trigger CI/CD"
