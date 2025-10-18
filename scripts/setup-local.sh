#!/usr/bin/env bash

# Local Setup Script
# Prepares your local environment for the DevOps project

set -e

# Colors
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
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}  ${1}${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
}

print_header "Local Environment Setup"

# Check OS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is designed for macOS"
    exit 1
fi

# Check Homebrew
print_info "Checking Homebrew..."
if command -v brew &> /dev/null; then
    print_success "Homebrew is installed"
else
    print_warning "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Update Homebrew
print_info "Updating Homebrew..."
brew update

# Install Terraform
print_info "Installing Terraform..."
if command -v terraform &> /dev/null; then
    print_success "Terraform already installed: $(terraform version -json | grep -o '\"terraform_version\":\"[^\"]*' | cut -d'\"' -f4)"
else
    brew install terraform
    print_success "Terraform installed"
fi

# Install Ansible
print_info "Installing Ansible..."
if command -v ansible &> /dev/null; then
    print_success "Ansible already installed: $(ansible --version | head -n1 | awk '{print $2}')"
else
    brew install ansible
    print_success "Ansible installed"
fi

# Install AWS CLI
print_info "Installing AWS CLI..."
if command -v aws &> /dev/null; then
    print_success "AWS CLI already installed: $(aws --version | awk '{print $1}')"
else
    brew install awscli
    print_success "AWS CLI installed"
fi

# Install Node.js (for local testing)
print_info "Installing Node.js..."
if command -v node &> /dev/null; then
    print_success "Node.js already installed: $(node --version)"
else
    brew install node
    print_success "Node.js installed"
fi

# Generate SSH key
print_info "Setting up SSH key..."
if [ -f ~/.ssh/devops_project_key ]; then
    print_success "SSH key already exists"
else
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/devops_project_key -N ""
    chmod 400 ~/.ssh/devops_project_key
    print_success "SSH key generated"
fi

# Configure AWS
print_header "AWS Configuration"

print_info "Checking AWS credentials..."
if aws sts get-caller-identity &> /dev/null; then
    print_success "AWS credentials are configured"
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    print_info "AWS Account ID: $ACCOUNT_ID"
else
    print_warning "AWS credentials not configured"
    print_info "Please run: aws configure"
    print_info "You'll need:"
    echo "  • AWS Access Key ID"
    echo "  • AWS Secret Access Key"
    echo "  • Default region (e.g., us-east-1)"
    echo ""
    read -p "Press Enter to configure AWS now, or Ctrl+C to cancel..."
    aws configure
fi

# Import SSH key to AWS
print_info "Importing SSH key to AWS..."
if aws ec2 describe-key-pairs --key-names devops-project-key --region us-east-1 &> /dev/null; then
    print_success "SSH key already imported to AWS"
else
    aws ec2 import-key-pair \
        --key-name devops-project-key \
        --public-key-material fileb://~/.ssh/devops_project_key.pub \
        --region us-east-1
    print_success "SSH key imported to AWS"
fi

# Setup Terraform variables
print_info "Setting up Terraform variables..."
cd terraform
if [ -f "terraform.tfvars" ]; then
    print_success "terraform.tfvars already exists"
else
    cp terraform.tfvars.example terraform.tfvars
    print_success "Created terraform.tfvars from example"
fi
cd ..

# Install local dependencies (optional)
print_header "Local Application Setup (Optional)"

read -p "Do you want to install application dependencies for local testing? (yes/no): " install_deps

if [ "$install_deps" = "yes" ]; then
    print_info "Installing backend dependencies..."
    cd applications/backend
    npm install
    print_success "Backend dependencies installed"
    cd ../..

    print_info "Installing frontend dependencies..."
    cd applications/frontend
    npm install
    print_success "Frontend dependencies installed"
    cd ../..
fi

# Make scripts executable
print_info "Making scripts executable..."
chmod +x scripts/*.sh
print_success "Scripts are now executable"

print_header "✓ Setup Complete!"

echo ""
echo -e "${GREEN}Your local environment is ready!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Review and edit terraform/terraform.tfvars if needed"
echo "  2. Run the deployment script: ./scripts/deploy.sh"
echo "  3. Follow the on-screen instructions"
echo ""
echo -e "${YELLOW}Optional - Test locally:${NC}"
echo "  • Backend: cd applications/backend && npm start"
echo "  • Frontend: cd applications/frontend && npm start"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo "  • Deploy project: ./scripts/deploy.sh"
echo "  • Destroy resources: ./scripts/destroy.sh"
echo "  • Check AWS account: aws sts get-caller-identity"
echo ""
