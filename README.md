# DevOps Full Stack Project

A comprehensive DevOps project demonstrating Infrastructure as Code, Configuration Management, Application Deployment, and Monitoring using industry-standard tools.

## 🎯 Project Overview

This project deploys a simple full-stack application (Node.js backend + React frontend) on AWS using DevOps best practices.

### **Application Stack**
- **Frontend**: React.js (Hello World app)
- **Backend**: Node.js/Express (API server)
- **Cloud**: AWS (Free Tier)

### **DevOps Tools**

| Tool | Purpose | Role in Project |
|------|---------|----------------|
| **Terraform** | Infrastructure as Code | Provisions AWS resources (EC2, VPC, Security Groups) |
| **Ansible** | Configuration Management | Deploys applications, installs dependencies |
| **Puppet** | State Management | Maintains server configurations continuously |
| **Nagios** | Monitoring | Monitors server health and application uptime |

## 🏗️ Architecture

```
                    ┌─────────────────┐
                    │   AWS Cloud     │
                    │   (Free Tier)   │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
        ┌─────▼─────┐  ┌─────▼─────┐  ┌────▼──────┐
        │ Frontend  │  │ Backend   │  │  Nagios   │
        │  EC2      │  │   EC2     │  │   EC2     │
        │ (t2.micro)│  │(t2.micro) │  │(t2.micro) │
        │           │  │           │  │           │
        │  React    │──│  Node.js  │  │ Monitoring│
        │ Port 3000 │  │  Port 5000│  │           │
        └───────────┘  └───────────┘  └───────────┘
```

## 📁 Project Structure

```
devops_prac/
├── README.md                          # This file
├── DEPLOYMENT_GUIDE.md                # Step-by-step deployment instructions
├── applications/                      # Application code
│   ├── backend/                       # Node.js backend
│   │   ├── package.json
│   │   ├── server.js
│   │   └── .env.example
│   └── frontend/                      # React frontend
│       ├── package.json
│       ├── public/
│       └── src/
├── terraform/                         # Infrastructure as Code
│   ├── main.tf                        # Main Terraform configuration
│   ├── variables.tf                   # Variable definitions
│   ├── outputs.tf                     # Output values
│   ├── terraform.tfvars.example       # Example variables file
│   └── modules/
│       ├── vpc/                       # VPC module
│       ├── security-groups/           # Security groups
│       └── ec2/                       # EC2 instances
├── ansible/                           # Configuration & Deployment
│   ├── inventory/                     # Server inventory
│   │   └── hosts.ini
│   ├── playbooks/                     # Ansible playbooks
│   │   ├── deploy-backend.yml
│   │   ├── deploy-frontend.yml
│   │   ├── setup-nagios.yml
│   │   └── setup-puppet-agent.yml
│   ├── roles/                         # Ansible roles
│   │   ├── common/
│   │   ├── backend/
│   │   ├── frontend/
│   │   └── nagios/
│   └── ansible.cfg
├── puppet/                            # Configuration Management
│   ├── manifests/
│   │   └── site.pp
│   └── modules/
│       ├── nodejs/
│       ├── nginx/
│       └── security/
├── nagios/                            # Monitoring Configuration
│   ├── nagios.cfg
│   └── objects/
│       ├── hosts.cfg
│       └── services.cfg
└── scripts/                           # Helper scripts
    ├── deploy.sh                      # Main deployment script
    ├── destroy.sh                     # Cleanup script
    └── setup-local.sh                 # Local environment setup
```

## 🚀 Prerequisites

### 1. **AWS Account**
- Sign up for AWS Free Tier: https://aws.amazon.com/free/
- Create IAM user with EC2, VPC permissions
- Download access key and secret key

### 2. **Local Tools Installation**

#### macOS (using Homebrew):
```bash
# Install Terraform
brew install terraform

# Install Ansible
brew install ansible

# Install Puppet Bolt (for running Puppet)
brew install puppet-bolt

# Install AWS CLI
brew install awscli

# Configure AWS CLI
aws configure
```

### 3. **SSH Key Pair**
```bash
# Generate SSH key for EC2 instances
ssh-keygen -t rsa -b 4096 -f ~/.ssh/devops_project_key -N ""
```

## 📋 Deployment Steps (High-Level)

### Phase 1: Infrastructure Setup (Terraform)
1. Configure AWS credentials
2. Run Terraform to provision infrastructure
3. Note down the EC2 instance IPs

### Phase 2: Configuration & Deployment (Ansible)
1. Update Ansible inventory with EC2 IPs
2. Deploy backend application
3. Deploy frontend application
4. Setup Puppet agents on servers

### Phase 3: State Management (Puppet)
1. Configure Puppet master (or use masterless)
2. Apply Puppet manifests to maintain desired state

### Phase 4: Monitoring Setup (Nagios)
1. Deploy Nagios on monitoring server
2. Configure host and service checks
3. Access Nagios web interface

---

## 🚀 Complete Step-by-Step Guide

For detailed instructions on every step from AWS account creation to deployment, see:

**→ [SETUP_STEPS.md](SETUP_STEPS.md)** - Complete 22-step deployment guide

## 🎓 Learning Objectives

By completing this project, you'll learn:
- ✅ Infrastructure provisioning with Terraform
- ✅ Application deployment automation with Ansible
- ✅ Configuration management with Puppet
- ✅ Server monitoring with Nagios
- ✅ AWS cloud fundamentals
- ✅ DevOps best practices and workflows

## 💰 AWS Free Tier Resources Used

- **EC2**: 3x t2.micro instances (750 hours/month free)
- **EBS**: 30 GB storage (free tier)
- **Data Transfer**: 15 GB outbound (free tier)

**Estimated Monthly Cost**: $0 (within free tier limits)

## 📚 Documentation Guide

Start here based on your needs:

1. **Complete Beginner?** → Read [SETUP_STEPS.md](SETUP_STEPS.md)
2. **Quick Overview?** → Read [QUICKSTART.md](QUICKSTART.md)
3. **Understand Tools?** → Read [TOOLS_EXPLAINED.md](TOOLS_EXPLAINED.md)
4. **Manual Deployment?** → Read [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
5. **Architecture Details?** → Read [ARCHITECTURE.md](ARCHITECTURE.md)

## 🔗 Useful Links

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Puppet Documentation](https://puppet.com/docs/)
- [Nagios Documentation](https://www.nagios.org/documentation/)
- [AWS Free Tier Details](https://aws.amazon.com/free/)

## 📝 Notes

- This is a learning project optimized for AWS Free Tier
- For production, use more robust security practices
- Remember to destroy resources when done to avoid charges
- Monitor your AWS billing dashboard regularly

## 🤝 Contributing

Feel free to fork this project and experiment with different configurations!

---

**Happy Learning! 🚀**
