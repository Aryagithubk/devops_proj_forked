# 🚀 Complete Deployment Guide

This guide will walk you through deploying the entire DevOps project from scratch.

## Table of Contents
1. [Environment Setup](#1-environment-setup)
2. [AWS Account Configuration](#2-aws-account-configuration)
3. [Infrastructure Provisioning (Terraform)](#3-infrastructure-provisioning-terraform)
4. [Application Deployment (Ansible)](#4-application-deployment-ansible)
5. [Configuration Management (Puppet)](#5-configuration-management-puppet)
6. [Monitoring Setup (Nagios)](#6-monitoring-setup-nagios)
7. [Testing & Verification](#7-testing--verification)
8. [Cleanup](#8-cleanup)

---

## 1. Environment Setup

### Step 1.1: Install Required Tools

```bash
# Update Homebrew
brew update

# Install Terraform
brew install terraform
terraform --version

# Install Ansible
brew install ansible
ansible --version

# Install Puppet Bolt
brew install puppet-bolt
bolt --version

# Install AWS CLI
brew install awscli
aws --version

# Install Node.js and npm (for local testing)
brew install node
node --version
npm --version
```

### Step 1.2: Generate SSH Key

```bash
# Create SSH key for EC2 instances
ssh-keygen -t rsa -b 4096 -f ~/.ssh/devops_project_key -N ""

# Set correct permissions
chmod 400 ~/.ssh/devops_project_key

# Verify key was created
ls -la ~/.ssh/devops_project_key*
```

---

## 2. AWS Account Configuration

### Step 2.1: Create AWS Account
1. Go to https://aws.amazon.com/free/
2. Click "Create a Free Account"
3. Complete the registration process
4. Verify your email and phone number

### Step 2.2: Create IAM User

1. Log into AWS Console: https://console.aws.amazon.com/
2. Go to **IAM** service
3. Click **Users** → **Add User**
4. Username: `terraform-user`
5. Access type: ✅ **Programmatic access**
6. Permissions: Attach existing policies:
   - `AmazonEC2FullAccess`
   - `AmazonVPCFullAccess`
   - `IAMReadOnlyAccess`
7. Click through and **Download** the CSV file with credentials

### Step 2.3: Configure AWS CLI

```bash
# Configure AWS credentials
aws configure

# Enter when prompted:
# AWS Access Key ID: [from downloaded CSV]
# AWS Secret Access Key: [from downloaded CSV]
# Default region name: us-east-1
# Default output format: json

# Verify configuration
aws sts get-caller-identity
```

### Step 2.4: Create EC2 Key Pair in AWS

```bash
# Import your SSH public key to AWS
aws ec2 import-key-pair \
  --key-name devops-project-key \
  --public-key-material fileb://~/.ssh/devops_project_key.pub \
  --region us-east-1

# Verify
aws ec2 describe-key-pairs --region us-east-1
```

---

## 3. Infrastructure Provisioning (Terraform)

### Step 3.1: Configure Terraform Variables

```bash
# Navigate to terraform directory
cd /Users/printrip/Desktop/Code/devops_prac/terraform

# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your details
nano terraform.tfvars
```

### Step 3.2: Initialize Terraform

```bash
# Initialize Terraform (downloads providers)
terraform init

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```

### Step 3.3: Plan Infrastructure

```bash
# See what Terraform will create
terraform plan

# Review the output carefully
# Should show: 3 EC2 instances, 1 VPC, security groups, etc.
```

### Step 3.4: Apply Infrastructure

```bash
# Create the infrastructure
terraform apply

# Type 'yes' when prompted

# Wait 3-5 minutes for resources to be created

# Save the output (EC2 IPs)
terraform output > ../outputs.txt
```

### Step 3.5: Verify Infrastructure

```bash
# Check EC2 instances
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=devops-fullstack" \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
  --output table

# Test SSH connection
ssh -i ~/.ssh/devops_project_key ubuntu@<BACKEND_IP>
exit
```

---

## 4. Application Deployment (Ansible)

### Step 4.1: Update Ansible Inventory

```bash
# Navigate to ansible directory
cd /Users/printrip/Desktop/Code/devops_prac/ansible

# Edit inventory file
nano inventory/hosts.ini

# Update with actual IPs from Terraform output
# [backend]
# <BACKEND_IP>
#
# [frontend]
# <FRONTEND_IP>
#
# [monitoring]
# <NAGIOS_IP>
```

### Step 4.2: Test Ansible Connectivity

```bash
# Ping all hosts
ansible all -i inventory/hosts.ini -m ping

# Should see SUCCESS for all hosts
```

### Step 4.3: Deploy Backend Application

```bash
# Run backend deployment playbook
ansible-playbook -i inventory/hosts.ini playbooks/deploy-backend.yml

# This will:
# - Install Node.js
# - Copy backend code
# - Install npm dependencies
# - Start the backend service
```

### Step 4.4: Deploy Frontend Application

```bash
# Run frontend deployment playbook
ansible-playbook -i inventory/hosts.ini playbooks/deploy-frontend.yml

# This will:
# - Install Node.js and nginx
# - Copy frontend code
# - Build React app
# - Configure nginx
# - Start the frontend service
```

### Step 4.5: Verify Deployments

```bash
# Test backend
curl http://<BACKEND_IP>:5000/
# Expected: {"message":"Hello World from Backend!"}

# Test frontend (in browser)
# Open: http://<FRONTEND_IP>
# Expected: Hello World page with backend data
```

---

## 5. Configuration Management (Puppet)

### Step 5.1: Setup Puppet Agents

```bash
# Install Puppet on all servers
ansible-playbook -i inventory/hosts.ini playbooks/setup-puppet-agent.yml

# This installs Puppet in masterless mode
```

### Step 5.2: Apply Puppet Manifests

```bash
# Deploy Puppet configurations
ansible all -i inventory/hosts.ini -m copy -a "src=../puppet/manifests/site.pp dest=/tmp/site.pp"

# Apply Puppet manifest on each server
ansible all -i inventory/hosts.ini -m shell -a "puppet apply /tmp/site.pp"

# Puppet will ensure:
# - Firewall rules are set
# - Required packages are installed
# - Services are running
```

### Step 5.3: Verify Puppet is Managing State

```bash
# SSH into backend server
ssh -i ~/.ssh/devops_project_key ubuntu@<BACKEND_IP>

# Run Puppet again to verify idempotency
sudo puppet apply /tmp/site.pp

# Should show no changes (already in desired state)
exit
```

---

## 6. Monitoring Setup (Nagios)

### Step 6.1: Install Nagios

```bash
# Run Nagios installation playbook
ansible-playbook -i inventory/hosts.ini playbooks/setup-nagios.yml

# This takes 10-15 minutes (compiling Nagios)
```

### Step 6.2: Configure Nagios Monitoring

```bash
# The playbook automatically configures monitoring for:
# - Backend server (HTTP, SSH, PING)
# - Frontend server (HTTP, SSH, PING)
# - Nagios server itself

# Restart Nagios to apply configuration
ansible monitoring -i inventory/hosts.ini -m service -a "name=nagios state=restarted"
```

### Step 6.3: Access Nagios Web Interface

```bash
# Get Nagios URL
echo "http://<NAGIOS_IP>/nagios"

# Default credentials:
# Username: nagiosadmin
# Password: nagiosadmin (change this!)

# Open in browser and login
```

### Step 6.4: Verify Monitoring

1. Navigate to **Services** page
2. You should see all hosts (backend, frontend, nagios)
3. All services should be **OK** (green)
4. Check the **Status Map** for visual overview

---

## 7. Testing & Verification

### Complete System Test

```bash
# 1. Test Backend API
curl http://<BACKEND_IP>:5000/
curl http://<BACKEND_IP>:5000/health

# 2. Test Frontend (browser)
# Open: http://<FRONTEND_IP>

# 3. Test Frontend calling Backend
# The frontend page should display data from backend API

# 4. Check Nagios
# Open: http://<NAGIOS_IP>/nagios
# All services should be UP

# 5. Test Puppet state management
ssh -i ~/.ssh/devops_project_key ubuntu@<BACKEND_IP>
sudo systemctl stop backend
# Wait 30 seconds
sudo puppet apply /tmp/site.pp
# Backend should restart
exit
```

### Load Test (Optional)

```bash
# Install Apache Bench
brew install apache-bench

# Test backend performance
ab -n 1000 -c 10 http://<BACKEND_IP>:5000/
```

---

## 8. Cleanup

### When You're Done Learning

```bash
# Navigate to terraform directory
cd /Users/printrip/Desktop/Code/devops_prac/terraform

# Destroy all AWS resources
terraform destroy

# Type 'yes' when prompted

# Verify everything is deleted
aws ec2 describe-instances --region us-east-1 --filters "Name=tag:Project,Values=devops-fullstack"

# Should show no instances
```

### Remove AWS Key Pair

```bash
# Delete the key pair from AWS
aws ec2 delete-key-pair --key-name devops-project-key --region us-east-1
```

---

## 🎉 Congratulations!

You've successfully deployed a complete DevOps project with:
- ✅ Infrastructure as Code (Terraform)
- ✅ Application Deployment (Ansible)
- ✅ Configuration Management (Puppet)
- ✅ Monitoring (Nagios)
- ✅ Cloud Deployment (AWS)

---

## Troubleshooting

### Issue: Terraform fails with authentication error
**Solution**: Verify AWS credentials with `aws sts get-caller-identity`

### Issue: Ansible can't connect to hosts
**Solution**: 
- Check security groups allow SSH (port 22)
- Verify SSH key path in ansible.cfg
- Wait 2-3 minutes after Terraform apply

### Issue: Backend/Frontend not accessible
**Solution**:
- Check security groups allow traffic on ports 5000/80
- Verify services are running: `sudo systemctl status backend`
- Check logs: `journalctl -u backend -f`

### Issue: Nagios not showing services
**Solution**:
- Restart Nagios: `sudo systemctl restart nagios`
- Check config: `sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg`

---

## Next Steps

1. Customize the applications (add more features)
2. Add more monitoring checks in Nagios
3. Experiment with Puppet modules
4. Try blue-green deployment with Ansible
5. Add CI/CD pipeline (GitHub Actions)
6. Implement auto-scaling with Terraform

**Remember**: Always run `terraform destroy` when done to avoid AWS charges!
