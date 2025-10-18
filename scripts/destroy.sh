#!/usr/bin/env bash

# Cleanup Script - Destroys all AWS resources
# This script safely removes all infrastructure created by Terraform

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

print_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

print_header() {
    echo ""
    echo -e "${RED}================================================${NC}"
    echo -e "${RED}  ${1}${NC}"
    echo -e "${RED}================================================${NC}"
    echo ""
}

# Check if running from correct directory
if [ ! -f "README.md" ] || [ ! -d "terraform" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

print_header "⚠️  DESTROY AWS INFRASTRUCTURE"

print_warning "This will permanently delete all AWS resources created by Terraform:"
echo ""
echo "  • All EC2 instances (backend, frontend, nagios)"
echo "  • VPC and networking components"
echo "  • Security groups"
echo "  • All associated data"
echo ""

read -p "Are you ABSOLUTELY sure you want to destroy everything? (type 'destroy' to confirm): " confirm

if [ "$confirm" != "destroy" ]; then
    print_info "Destruction cancelled"
    exit 0
fi

print_header "Destroying Infrastructure"

cd terraform

# Check if Terraform is initialized
if [ ! -d ".terraform" ]; then
    print_warning "Terraform not initialized. Initializing now..."
    terraform init
fi

print_info "Planning destruction..."
terraform plan -destroy

read -p "Proceed with destruction? (yes/no): " proceed
if [ "$proceed" != "yes" ]; then
    print_warning "Destruction cancelled"
    exit 0
fi

print_info "Destroying all resources..."
terraform destroy -auto-approve

print_success "All resources have been destroyed"

cd ..

# Clean up local files
print_info "Cleaning up local files..."

if [ -f "terraform/tfplan" ]; then
    rm terraform/tfplan
    print_success "Removed terraform plan file"
fi

if [ -f "outputs.txt" ]; then
    rm outputs.txt
    print_success "Removed outputs file"
fi

print_header "✓ Cleanup Complete"

print_success "All AWS resources have been destroyed"
print_info "Your AWS account should no longer be charged for these resources"
print_warning "Please verify in AWS Console that all resources are deleted"

echo ""
echo -e "${BLUE}To redeploy the project, run:${NC} ./scripts/deploy.sh"
echo ""
