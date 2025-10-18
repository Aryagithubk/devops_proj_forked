# 🚀 Quick Start Guide

Get your DevOps project up and running in minutes!

## Prerequisites

- **macOS** (this guide is for macOS)
- **AWS Account** (Free Tier)
- **30-60 minutes** of your time

## Step-by-Step Instructions

### 1️⃣ Setup Local Environment

Run the automated setup script:

```bash
cd /Users/printrip/Desktop/Code/devops_prac
chmod +x scripts/*.sh
./scripts/setup-local.sh
```

This will:
- ✅ Install Terraform, Ansible, AWS CLI
- ✅ Generate SSH keys
- ✅ Configure AWS credentials
- ✅ Prepare your environment

### 2️⃣ Deploy Everything

Run the deployment script:

```bash
./scripts/deploy.sh
```

This automated script will:
1. Validate prerequisites
2. Create AWS infrastructure (Terraform)
3. Deploy backend application (Ansible)
4. Deploy frontend application (Ansible)
5. Setup Nagios monitoring
6. Configure Puppet for state management
7. Test everything

**Time**: ~15-20 minutes

### 3️⃣ Access Your Application

After deployment completes, you'll see:

```
Backend API:     http://<BACKEND_IP>:5000
Frontend App:    http://<FRONTEND_IP>
Nagios Monitor:  http://<NAGIOS_IP>/nagios
```

### 4️⃣ Test It Out

**Backend API:**
```bash
curl http://<BACKEND_IP>:5000/
curl http://<BACKEND_IP>:5000/health
```

**Frontend:**
- Open `http://<FRONTEND_IP>` in your browser
- You should see a beautiful React app
- It will display data from the backend

**Nagios:**
- Open `http://<NAGIOS_IP>/nagios` in your browser
- Login: `nagiosadmin` / `nagiosadmin`
- View all monitored services

### 5️⃣ Cleanup (When Done)

**IMPORTANT:** Destroy resources to avoid charges!

```bash
./scripts/destroy.sh
```

Type `destroy` to confirm, then type `yes`.

---

## Manual Deployment (Alternative)

If you prefer to run commands manually:

### Phase 1: Infrastructure

```bash
cd terraform
terraform init
terraform plan
terraform apply
terraform output > ../outputs.txt
cd ..
```

### Phase 2: Update Inventory

Edit `ansible/inventory/hosts.ini` with the IPs from Terraform output.

### Phase 3: Deploy

```bash
cd ansible

# Test connectivity
ansible all -i inventory/hosts.ini -m ping

# Deploy backend
ansible-playbook -i inventory/hosts.ini playbooks/deploy-backend.yml

# Deploy frontend
ansible-playbook -i inventory/hosts.ini playbooks/deploy-frontend.yml

# Setup Nagios
ansible-playbook -i inventory/hosts.ini playbooks/setup-nagios.yml

# Setup Puppet
ansible-playbook -i inventory/hosts.ini playbooks/setup-puppet-agent.yml

cd ..
```

### Phase 4: Apply Puppet

```bash
cd ansible
ansible all -i inventory/hosts.ini -m copy -a "src=../puppet/manifests/site.pp dest=/tmp/site.pp"
ansible all -i inventory/hosts.ini -m shell -a "/opt/puppetlabs/bin/puppet apply /tmp/site.pp"
cd ..
```

---

## Troubleshooting

### Issue: AWS credentials not configured
```bash
aws configure
# Enter your Access Key ID and Secret Access Key
```

### Issue: SSH connection failed
```bash
# Check security groups allow port 22
# Wait 2-3 minutes after Terraform apply
# Verify SSH key: ls -la ~/.ssh/devops_project_key
```

### Issue: Service not starting
```bash
# Check logs
ssh -i ~/.ssh/devops_project_key ubuntu@<IP>
sudo journalctl -u backend -f
```

### Issue: Terraform fails
```bash
# Check AWS permissions
aws sts get-caller-identity

# Verify key pair exists
aws ec2 describe-key-pairs --region us-east-1
```

---

## Cost Information

**AWS Free Tier:**
- 750 hours/month of t2.micro (we use 3 instances)
- Each instance gets 250 hours/month
- **Should be free** if you stay within limits
- **Monitor your AWS billing dashboard!**

**Note:** We use 60 GB of storage (3 x 20 GB), which slightly exceeds the 30 GB free tier limit. Expected cost: **~$5-10/month** if you keep it running.

**To avoid charges:** Run `./scripts/destroy.sh` when done!

---

## Learning Path

1. **Day 1:** Run setup and deployment scripts
2. **Day 2:** Explore each component individually
3. **Day 3:** Make changes and redeploy
4. **Day 4:** Break something and fix it (best way to learn!)
5. **Day 5:** Add new features

---

## Next Steps

- ✅ Read the full [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
- ✅ Explore individual tool READMEs in each directory
- ✅ Customize the applications
- ✅ Add more monitoring checks
- ✅ Experiment with Puppet modules
- ✅ Try blue-green deployment

---

## Support

- Check individual README files in each directory
- Review DEPLOYMENT_GUIDE.md for detailed steps
- Common issues are documented in troubleshooting sections

---

**Happy Learning! 🎉**

Remember: The goal is to understand how these tools work together, not just to deploy the application!
