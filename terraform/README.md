# Terraform Infrastructure

This directory contains Terraform configuration for provisioning AWS infrastructure.

## Resources Created

- **VPC** with Internet Gateway
- **Public Subnet** 
- **Security Groups** for Backend, Frontend, and Nagios
- **3 EC2 Instances** (t2.micro - Free Tier)
  - Backend server
  - Frontend server
  - Nagios monitoring server

## Prerequisites

1. AWS Account with Free Tier
2. AWS CLI configured (`aws configure`)
3. Terraform installed (`brew install terraform`)
4. SSH key pair created

## Quick Start

```bash
# 1. Copy variables file
cp terraform.tfvars.example terraform.tfvars

# 2. Edit variables (if needed)
nano terraform.tfvars

# 3. Initialize Terraform
terraform init

# 4. Validate configuration
terraform validate

# 5. Plan infrastructure
terraform plan

# 6. Apply infrastructure
terraform apply
# Type 'yes' when prompted

# 7. View outputs
terraform output
```

## Important Notes

### AMI IDs by Region

The default AMI is for Ubuntu 22.04 LTS in `us-east-1`. If you use a different region, update the `ami_id` variable:

- **us-east-1**: `ami-0e86e20dae9224db8`
- **us-west-2**: `ami-0efcece6bed30fd98`
- **eu-west-1**: `ami-0905a3c97561e0b69`

Find more: https://cloud-images.ubuntu.com/locator/ec2/

### Free Tier Limits

- **EC2**: 750 hours/month of t2.micro (we use 3 instances = 250 hours each)
- **EBS**: 30 GB (we use 20 GB per instance = 60 GB total - **exceeds free tier**)
- **Data Transfer**: 15 GB out per month

**Note**: With 3 instances, you may incur small charges (~$5-10/month). Monitor your AWS billing!

## Outputs

After `terraform apply`, you'll get:

- **Public IPs** for all servers
- **SSH commands** to connect
- **URLs** for accessing services

## Cleanup

```bash
# Destroy all resources
terraform destroy
# Type 'yes' when prompted

# This will delete everything and stop charges
```

## Troubleshooting

### Issue: Key pair not found
**Solution**: Run `aws ec2 import-key-pair` command from DEPLOYMENT_GUIDE.md

### Issue: AMI not found
**Solution**: Check your region and update `ami_id` in terraform.tfvars

### Issue: Insufficient permissions
**Solution**: Ensure your IAM user has EC2 and VPC permissions
