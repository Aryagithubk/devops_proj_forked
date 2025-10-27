#!/usr/bin/env bash

# Complete Deployment Script for DevOps Project
# This script orchestrates the entire deployment process

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}
# comment for pr diff test
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

# Check if running from correct directory
if [ ! -f "README.md" ] || [ ! -d "terraform" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

print_header "DevOps Project Deployment Script"

# Step 1: Pre-deployment checks
print_header "Step 1: Pre-deployment Checks"

print_info "Checking required tools..."

# Check Terraform
if command -v terraform &> /dev/null; then
    print_success "Terraform is installed: $(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)"
else
    print_error "Terraform is not installed. Run: brew install terraform"
    exit 1
fi

# Check Ansible
if command -v ansible &> /dev/null; then
    print_success "Ansible is installed: $(ansible --version | head -n1 | awk '{print $2}')"
else
    print_error "Ansible is not installed. Run: brew install ansible"
    exit 1
fi

# Check AWS CLI
if command -v aws &> /dev/null; then
    print_success "AWS CLI is installed: $(aws --version | awk '{print $1}')"
else
    print_error "AWS CLI is not installed. Run: brew install awscli"
    exit 1
fi

# Check AWS credentials
if aws sts get-caller-identity &> /dev/null; then
    print_success "AWS credentials are configured"
else
    print_error "AWS credentials not configured. Run: aws configure"
    exit 1
fi

# Check SSH key
if [ -f ~/.ssh/devops_project_key ]; then
    print_success "SSH key exists"
else
    print_error "SSH key not found. Generate it with: ssh-keygen -t rsa -b 4096 -f ~/.ssh/devops_project_key -N ''"
    exit 1
fi

# Step 2: Infrastructure Provisioning
print_header "Step 2: Infrastructure Provisioning (Terraform)"

cd terraform

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_warning "terraform.tfvars not found. Creating from example..."
    cp terraform.tfvars.example terraform.tfvars
    print_info "Please review and edit terraform.tfvars if needed"
fi

print_info "Initializing Terraform..."
terraform init

print_info "Validating Terraform configuration..."
terraform validate

print_info "Planning infrastructure..."
terraform plan -out=tfplan

read -p "Do you want to apply this plan? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    print_warning "Deployment cancelled"
    exit 0
fi

print_info "Applying infrastructure changes..."
terraform apply tfplan

print_success "Infrastructure provisioned successfully!"

# Get outputs
print_info "Retrieving server IPs..."
BACKEND_IP=$(terraform output -raw backend_public_ip)
FRONTEND_IP=$(terraform output -raw frontend_public_ip)
NAGIOS_IP=$(terraform output -raw nagios_public_ip)

print_success "Backend IP: $BACKEND_IP"
print_success "Frontend IP: $FRONTEND_IP"
print_success "Nagios IP: $NAGIOS_IP"

cd ..

# Step 3: Update Ansible Inventory
print_header "Step 3: Updating Ansible Inventory"

cat > ansible/inventory/hosts.ini <<EOF
[backend]
$BACKEND_IP

[frontend]
$FRONTEND_IP

[monitoring]
$NAGIOS_IP

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/devops_project_key
ansible_python_interpreter=/usr/bin/python3
EOF

print_success "Ansible inventory updated"

# Step 4: Wait for instances to be ready
print_header "Step 4: Waiting for EC2 Instances"

print_info "Waiting for instances to initialize (60 seconds)..."
sleep 60

# Step 5: Test Connectivity
print_header "Step 5: Testing SSH Connectivity"

cd ansible

print_info "Testing connectivity to all servers..."
if ansible all -i inventory/hosts.ini -m ping; then
    print_success "All servers are reachable"
else
    print_error "Cannot reach servers. Please check security groups and SSH keys"
    exit 1
fi

# Step 6: Deploy Applications
print_header "Step 6: Deploying Applications"

print_info "Deploying backend application..."
ansible-playbook -i inventory/hosts.ini playbooks/deploy-backend.yml
print_success "Backend deployed"

print_info "Deploying frontend application..."
ansible-playbook -i inventory/hosts.ini playbooks/deploy-frontend.yml
print_success "Frontend deployed"

# Step 7: Setup Monitoring
print_header "Step 7: Setting Up Monitoring"

print_info "Installing Nagios (this may take 10-15 minutes)..."
ansible-playbook -i inventory/hosts.ini playbooks/setup-nagios.yml
print_success "Nagios monitoring configured"

# Step 8: Setup Configuration Management
print_header "Step 8: Setting Up Configuration Management"

print_info "Installing Puppet agents..."
ansible-playbook -i inventory/hosts.ini playbooks/setup-puppet-agent.yml
print_success "Puppet agents installed"

print_info "Deploying Puppet manifests..."
ansible all -i inventory/hosts.ini -m copy -a "src=../puppet/manifests/site.pp dest=/tmp/site.pp"

print_info "Applying Puppet configuration..."
ansible all -i inventory/hosts.ini -m shell -a "/opt/puppetlabs/bin/puppet apply /tmp/site.pp"
print_success "Puppet configuration applied"

cd ..

# Step 9: Verification
print_header "Step 9: Verification"

print_info "Testing backend API..."
if curl -s "http://$BACKEND_IP:5000/health" | grep -q "UP"; then
    print_success "Backend is healthy"
else
    print_warning "Backend health check failed"
fi

print_info "Testing frontend..."
if curl -s -o /dev/null -w "%{http_code}" "http://$FRONTEND_IP" | grep -q "200"; then
    print_success "Frontend is accessible"
else
    print_warning "Frontend accessibility check failed"
fi

print_info "Testing Nagios..."
if curl -s -o /dev/null -w "%{http_code}" "http://$NAGIOS_IP/nagios" | grep -q "401\|200"; then
    print_success "Nagios is accessible"
else
    print_warning "Nagios accessibility check failed"
fi

# Final Summary
print_header "🎉 Deployment Complete!"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  Access Your Application${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${BLUE}Backend API:${NC}     http://$BACKEND_IP:5000"
echo -e "  ${BLUE}Frontend App:${NC}    http://$FRONTEND_IP"
echo -e "  ${BLUE}Nagios Monitor:${NC}  http://$NAGIOS_IP/nagios"
echo ""
echo -e "${YELLOW}  Nagios Credentials:${NC}"
echo -e "    Username: nagiosadmin"
echo -e "    Password: nagiosadmin"
echo -e "    ${RED}(Change this password immediately!)${NC}"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

print_info "To destroy all resources later, run: ./scripts/destroy.sh"
print_warning "Remember to destroy resources when done to avoid AWS charges!"

echo ""
