# Complete AWS Setup & Deployment Steps

This guide walks you through every step needed to deploy your DevOps project to AWS.

---

## 📋 Prerequisites Checklist

- [ ] AWS Account created (Free Tier)
- [ ] AWS Access Keys generated
- [ ] AWS CLI installed
- [ ] Terraform installed
- [ ] Ansible installed
- [ ] SSH key pair created

---

## Step 1: Create AWS Account

1. Go to https://aws.amazon.com/free/
2. Click **"Create a Free Account"**
3. Fill in your details:
   - Email address
   - Password
   - AWS account name
4. Verify your email address
5. Provide contact information
6. Add payment method (credit/debit card)
   - ⚠️ **Note**: You won't be charged if you stay within Free Tier limits
7. Verify your phone number (SMS or voice call)
8. Choose **"Basic Support - Free"** plan
9. Complete sign-up

**Time required**: ~10 minutes

---

## Step 2: Generate AWS Access Keys

### A. Login to AWS Console

1. Go to https://console.aws.amazon.com/
2. Enter your email and password
3. You'll see the AWS Management Console

### B. Navigate to IAM (Identity and Access Management)

1. In the search bar at the top, type **"IAM"**
2. Click on **"IAM"** service
3. Or use direct link: https://console.aws.amazon.com/iam/

### C. Create Access Key

1. Click your **username** in the top-right corner
2. Select **"Security credentials"** from dropdown
3. Scroll down to **"Access keys"** section
4. Click **"Create access key"**
5. Select use case: **"Command Line Interface (CLI)"**
6. Check the acknowledgment box: ☑️ "I understand the above recommendation..."
7. Click **"Next"**
8. (Optional) Add a description tag
9. Click **"Create access key"**

### D. Save Your Credentials

⚠️ **CRITICAL**: The Secret Access Key is shown only once!

You'll see:
```
Access Key ID: AKIAIOSFODNN7EXAMPLE
Secret Access Key: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

**Do one of these:**
- Click **"Download .csv file"** and save it securely
- Or copy both keys to a secure password manager

**Time required**: ~5 minutes

---

## Step 3: Install AWS CLI

### macOS (Homebrew):

```bash
# Install AWS CLI
brew install awscli

# Verify installation
aws --version
```

Expected output:
```
aws-cli/2.x.x Python/3.x.x Darwin/xx.x.x
```

### Linux:

```bash
# Download installer
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

# Unzip
unzip awscliv2.zip

# Install
sudo ./aws/install

# Verify
aws --version
```

### Windows:

Download from: https://awscli.amazonaws.com/AWSCLIV2.msi

**Time required**: ~2 minutes

---

## Step 4: Configure AWS Credentials

Run the configuration command:

```bash
aws configure
```

You'll be prompted to enter 4 values:

```
AWS Access Key ID [None]: AKIAIOSFODNN7EXAMPLE
AWS Secret Access Key [None]: wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
Default region name [None]: us-east-1
Default output format [None]: json
```

**Enter**:
1. Your Access Key ID (from Step 2)
2. Your Secret Access Key (from Step 2)
3. `us-east-1` (or your preferred region)
4. `json` (recommended output format)

### What This Does:

Creates two files:
- `~/.aws/credentials` - Contains your access keys (private!)
- `~/.aws/config` - Contains region and output settings

### Verify Configuration:

```bash
aws sts get-caller-identity
```

Should return something like:
```json
{
    "UserId": "AIDAI23HXW2EXAMPLE",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/yourusername"
}
```

✅ If you see your account details, credentials are configured correctly!

**Time required**: ~2 minutes

---

## Step 5: Create SSH Key Pair

You need an SSH key to connect to EC2 instances.

### Option A: Using AWS CLI (Recommended)

```bash
# Create key pair and save it
aws ec2 create-key-pair \
  --key-name devops-project-key \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/devops-project-key.pem

# Set correct permissions (very important!)
chmod 400 ~/.ssh/devops-project-key.pem

# Verify the key was created
ls -la ~/.ssh/devops-project-key.pem
```

### Option B: Using AWS Console

1. Go to EC2 Dashboard: https://console.aws.amazon.com/ec2/
2. In left sidebar, click **"Key Pairs"** (under Network & Security)
3. Click **"Create key pair"**
4. Enter:
   - Name: `devops-project-key`
   - Key pair type: **RSA**
   - Private key file format: **.pem**
5. Click **"Create key pair"**
6. Browser will download `devops-project-key.pem`
7. Move it to SSH directory:
   ```bash
   mv ~/Downloads/devops-project-key.pem ~/.ssh/
   chmod 400 ~/.ssh/devops-project-key.pem
   ```

### Verify Key Pair:

```bash
aws ec2 describe-key-pairs --key-names devops-project-key
```

Should show your key pair details.

**Time required**: ~3 minutes

---

### Troubleshooting SSH Key Creation:

**Issue: "InvalidKeyPair.Duplicate" error**

The key already exists in AWS.

**Solution Option 1 - Delete and recreate:**
```bash
# Delete from AWS
aws ec2 delete-key-pair --key-name devops-project-key --region ap-south-1

# Delete local file if exists
rm ~/.ssh/devops-project-key.pem

# Create new key
aws ec2 create-key-pair \
  --key-name devops-project-key \
  --region ap-south-1 \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/devops-project-key.pem

# Set permissions
chmod 400 ~/.ssh/devops-project-key.pem
```

**Issue: "not a public key file" or empty file**

The key file is empty or corrupted.

**Solution:**
```bash
# Check file size
ls -lh ~/.ssh/devops-project-key.pem

# If it's 0 bytes, delete and recreate
rm ~/.ssh/devops-project-key.pem
aws ec2 delete-key-pair --key-name devops-project-key --region ap-south-1

# Create new key
aws ec2 create-key-pair \
  --key-name devops-project-key \
  --region ap-south-1 \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/devops-project-key.pem

chmod 400 ~/.ssh/devops-project-key.pem
```

**Issue: Wrong region**

Make sure you specify `--region ap-south-1` in all commands if that's your region.

---

## Step 6: Install Terraform (If Not Installed)

### macOS:

```bash
# Install Terraform
brew install terraform

# Verify installation
terraform --version
```

### Linux:

```bash
# Download Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip

# Unzip
unzip terraform_1.6.0_linux_amd64.zip

# Move to bin
sudo mv terraform /usr/local/bin/

# Verify
terraform --version
```

**Time required**: ~2 minutes

---

## Step 7: Install Ansible (If Not Installed)

### macOS:

```bash
# Install Ansible
brew install ansible

# Verify installation
ansible --version
```

### Linux (Ubuntu/Debian):

```bash
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install -y ansible

# Verify
ansible --version
```

**Time required**: ~3 minutes

---

## Step 8: Review & Update Terraform Variables (Optional)

Navigate to the terraform directory:

```bash
cd /Users/printrip/Desktop/Code/devops_prac/terraform
```

Check the default variables in `variables.tf`:
- Region: `us-east-1`
- Instance type: `t2.micro` (Free Tier)
- Key name: `devops-project-key`

**If you want to change anything**, create a `terraform.tfvars` file:

```bash
# Copy example file
cp terraform.tfvars.example terraform.tfvars

# Edit it
nano terraform.tfvars
```

Example customizations:
```hcl
aws_region    = "us-west-2"        # Different region
key_name      = "my-custom-key"    # Different key name
project_name  = "my-devops-demo"   # Custom project name
```

**Most users can skip this step** - defaults are fine!

**Time required**: ~2 minutes (optional)

---

## Step 9: Initialize Terraform

Navigate to terraform directory and initialize:

```bash
cd /Users/printrip/Desktop/Code/devops_prac/terraform

# Initialize Terraform
terraform init
```

### What This Does:

- Downloads AWS provider plugin
- Initializes backend
- Prepares working directory
- Creates `.terraform` directory

**Expected output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...

Terraform has been successfully initialized!
```

✅ Look for "successfully initialized" message

**Time required**: ~1 minute

---

## Step 10: Plan Infrastructure

See what Terraform will create:

```bash
terraform plan
```

### What You'll See:

Terraform will show all resources to be created:
- ✅ VPC (Virtual Private Cloud)
- ✅ Internet Gateway
- ✅ Public Subnet
- ✅ Route Table
- ✅ 3 Security Groups (firewall rules)
- ✅ 3 EC2 Instances (backend, frontend, nagios)

**Look for this at the end:**
```
Plan: 12 to add, 0 to change, 0 to destroy.
```

### Review Carefully:

- Check instance types are `t2.micro` (Free Tier)
- Verify region is correct
- Ensure key name matches your key

**Time required**: ~1 minute

---

## Step 11: Apply Infrastructure (Deploy to AWS!)

Deploy the infrastructure:

```bash
terraform apply
```

You'll see the plan again, then:
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: 
```

**Type**: `yes` (exactly, not 'y' or 'Yes')

### What Happens:

Terraform will:
1. Create VPC and networking (30 seconds)
2. Create security groups (30 seconds)
3. Launch 3 EC2 instances (2-3 minutes)

**Total time**: ~3-5 minutes

### Expected Output:

```
Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:

backend_public_ip = "54.123.45.67"
frontend_public_ip = "54.123.45.68"
nagios_public_ip = "54.123.45.69"
backend_url = "http://54.123.45.67:5000"
frontend_url = "http://54.123.45.68"
nagios_url = "http://54.123.45.69/nagios"
```

**⚠️ IMPORTANT**: Save these IP addresses! You'll need them next.

### Save Output to File:

```bash
terraform output > ../infrastructure-ips.txt
```

**Time required**: ~3-5 minutes

---

## Step 12: Wait for Instances to Initialize

EC2 instances need time to boot up.

```bash
# Wait 90 seconds
echo "Waiting for instances to boot..."
sleep 90
```

Or just wait 1-2 minutes before proceeding.

**Time required**: ~2 minutes

---

## Step 13: Update Ansible Inventory

Update the inventory file with actual IP addresses from Terraform.

```bash
cd /Users/printrip/Desktop/Code/devops_prac/ansible

# Edit the inventory file
nano inventory/hosts.ini
```

**Replace the placeholder comments** with actual IPs:

**Before:**
```ini
[backend]
# Replace with actual IP from Terraform output
# Example: 54.123.45.67

[frontend]
# Replace with actual IP from Terraform output
# Example: 54.123.45.68

[monitoring]
# Replace with actual IP from Terraform output
# Example: 54.123.45.69
```

**After:**
```ini
[backend]
54.123.45.67

[frontend]
54.123.45.68

[monitoring]
54.123.45.69

[all:vars]
ansible_user=ubuntu
ansible_ssh_private_key_file=~/.ssh/devops-project-key.pem
ansible_python_interpreter=/usr/bin/python3
```

**Save and exit**: `Ctrl+O`, `Enter`, `Ctrl+X`

**Time required**: ~2 minutes

---

## Step 14: Test SSH Connectivity

Before running Ansible, verify you can connect to servers.

### Test SSH Manually:

```bash
# Test backend server
ssh -i ~/.ssh/devops-project-key.pem ubuntu@54.123.45.67

# If successful, you'll see Ubuntu welcome message
# Type 'exit' to disconnect
exit
```

### Test with Ansible:

```bash
cd /Users/printrip/Desktop/Code/devops_prac/ansible

# Ping all hosts
ansible all -i inventory/hosts.ini -m ping
```

**Expected output:**
```
backend | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
frontend | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
monitoring | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

✅ All three should show "SUCCESS" and "pong"

### If Connection Fails:

```bash
# Wait another minute and try again
sleep 60
ansible all -i inventory/hosts.ini -m ping
```

**Common issues:**
- Instances still booting (wait 1-2 more minutes)
- Wrong key path (check `ansible.cfg`)
- Security group issue (should auto-allow SSH)

**Time required**: ~2 minutes

---

## Step 15: Deploy Backend Application

Deploy the Node.js backend:

```bash
cd /Users/printrip/Desktop/Code/devops_prac/ansible

ansible-playbook -i inventory/hosts.ini playbooks/deploy-backend.yml
```

### What This Does:

1. Updates apt cache
2. Installs Node.js 18.x
3. Copies backend application files
4. Installs npm dependencies
5. Creates systemd service
6. Starts backend on port 5000
7. Tests health endpoint

**Expected output:** You'll see each task execute with "ok" or "changed" status.

**Final task should show:**
```
TASK [Display backend status]
ok: [54.123.45.67] => {
    "msg": "Backend is running successfully at http://54.123.45.67:5000"
}
```

### Test Backend:

```bash
curl http://54.123.45.67:5000
```

Should return:
```json
{
  "message": "Hello World from Backend!",
  "timestamp": "2025-10-18T...",
  "server": "Node.js Express",
  "version": "1.0.0"
}
```

✅ If you see this JSON, backend is working!

**Time required**: ~3-5 minutes

---

## Step 16: Deploy Frontend Application

Deploy the React frontend:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/deploy-frontend.yml
```

### What This Does:

1. Installs Node.js and Nginx
2. Copies frontend application files
3. Creates .env file with backend URL
4. Installs npm dependencies
5. Builds React production bundle
6. Configures Nginx to serve the app
7. Starts Nginx on port 80

**Expected output:** Similar task execution messages.

**Final task should show:**
```
TASK [Display frontend status]
ok: [54.123.45.68] => {
    "msg": "Frontend is running successfully at http://54.123.45.68"
}
```

### Test Frontend:

**Option 1 - Command line:**
```bash
curl http://54.123.45.68
```

Should return HTML content.

**Option 2 - Browser (Recommended):**

Open in your browser:
```
http://54.123.45.68
```

You should see:
- 🚀 Beautiful React app with gradient background
- ✅ "React app is running successfully!"
- ✅ Backend connection status
- 🏗️ DevOps tools displayed (Terraform, Ansible, Puppet, Nagios)

✅ If you see the React app, frontend is working!

**Time required**: ~5-7 minutes

---

## Step 17: Setup Nagios Monitoring

Install and configure Nagios:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/setup-nagios.yml
```

### What This Does:

1. Installs Apache and PHP
2. Downloads and compiles Nagios Core
3. Downloads and compiles Nagios Plugins
4. Configures monitoring for backend and frontend
5. Creates web interface
6. Sets up admin user

**⚠️ This takes longest** - Nagios compiles from source

**Expected output:** Many compilation messages.

**Final output:**
```
TASK [Display Nagios access information]
ok: [54.123.45.69] => {
    "msg": [
        "Nagios is now running!",
        "Access URL: http://54.123.45.69/nagios",
        "Username: nagiosadmin",
        "Password: nagiosadmin",
        "Please change the password after first login!"
    ]
}
```

### Access Nagios:

**Open in browser:**
```
http://54.123.45.69/nagios
```

**Login with:**
- Username: `nagiosadmin`
- Password: `nagiosadmin`

You'll see the Nagios dashboard!

**Navigate to:**
- **Services** - See all monitored services
- **Hosts** - See all monitored servers
- **Map** - Visual topology

✅ All services should be "OK" (green) after a few minutes

**Time required**: ~10-15 minutes

---

## Step 18: Setup Puppet (Optional)

Install Puppet for configuration management:

```bash
ansible-playbook -i inventory/hosts.ini playbooks/setup-puppet-agent.yml
```

### What This Does:

1. Adds Puppet repository
2. Installs Puppet Agent
3. Creates directory structure

**Time required**: ~3 minutes

### Apply Puppet Configuration:

```bash
# Copy Puppet manifest to all servers
ansible all -i inventory/hosts.ini -m copy \
  -a "src=../puppet/manifests/site.pp dest=/tmp/site.pp"

# Apply Puppet configuration
ansible all -i inventory/hosts.ini -m shell \
  -a "/opt/puppetlabs/bin/puppet apply /tmp/site.pp" --become
```

**What Puppet Does:**
- Ensures services are running
- Manages firewall rules
- Installs essential packages
- Auto-heals if services crash

**Time required**: ~5 minutes

---

## Step 19: Verify Complete Deployment

Test everything is working:

### 1. Backend API Test:

```bash
# Get backend IP from terraform output
BACKEND_IP=$(cd ../terraform && terraform output -raw backend_public_ip)

# Test main endpoint
curl http://$BACKEND_IP:5000

# Test health endpoint
curl http://$BACKEND_IP:5000/health
```

Expected:
```json
{"status":"UP","uptime":123.456,"timestamp":"..."}
```

### 2. Frontend Test:

```bash
# Get frontend IP
FRONTEND_IP=$(cd ../terraform && terraform output -raw frontend_public_ip)

# Test HTTP response
curl -I http://$FRONTEND_IP
```

Expected: `HTTP/1.1 200 OK`

**In browser:** `http://<FRONTEND_IP>`
- Should display React app
- Should show data from backend API

### 3. Nagios Test:

```bash
# Get nagios IP
NAGIOS_IP=$(cd ../terraform && terraform output -raw nagios_public_ip)

# Test Nagios web interface
curl -I http://$NAGIOS_IP/nagios
```

Expected: `HTTP/1.1 401 Unauthorized` (auth required - this is correct!)

**In browser:** `http://<NAGIOS_IP>/nagios`
- Login with: `nagiosadmin` / `nagiosadmin`
- Check all services are OK

### 4. SSH Test:

```bash
# Test SSH to backend
ssh -i ~/.ssh/devops-project-key.pem ubuntu@$BACKEND_IP \
  "sudo systemctl status backend"
```

Should show: `Active: active (running)`

### 5. Full System Test:

```bash
cd ansible

# Check all servers are reachable
ansible all -i inventory/hosts.ini -m ping

# Check uptime
ansible all -i inventory/hosts.ini -m shell -a "uptime"

# Check disk usage
ansible all -i inventory/hosts.ini -m shell -a "df -h"

# Check running services
ansible backend -i inventory/hosts.ini -m shell -a "systemctl status backend" --become
ansible frontend -i inventory/hosts.ini -m shell -a "systemctl status nginx" --become
ansible monitoring -i inventory/hosts.ini -m shell -a "systemctl status nagios" --become
```

✅ **All tests passing means deployment is successful!

**Time required**: ~5 minutes

---

## Step 20: Access Your Applications

### 🎉 Congratulations! Your DevOps project is live!

**Get all URLs:**

```bash
cd /Users/printrip/Desktop/Code/devops_prac/terraform

echo "==================================="
echo "  Your Application URLs"
echo "==================================="
echo ""
echo "Backend API:"
terraform output -raw backend_url
echo ""
echo ""
echo "Frontend App:"
terraform output -raw frontend_url
echo ""
echo ""
echo "Nagios Monitor:"
terraform output -raw nagios_url
echo ""
echo "  Username: nagiosadmin"
echo "  Password: nagiosadmin"
echo ""
echo "==================================="
```

### What to Explore:

1. **Backend** - API endpoints:
   - `http://<IP>:5000/` - Welcome message
   - `http://<IP>:5000/health` - Health check
   - `http://<IP>:5000/api/message` - Sample API

2. **Frontend** - React app:
   - `http://<IP>` - Main page
   - Shows backend connection status
   - Displays all DevOps tools used

3. **Nagios** - Monitoring:
   - `http://<IP>/nagios` - Dashboard
   - Services → See all monitored endpoints
   - Hosts → See all servers
   - Map → Visual topology

---

## Step 21: Monitor and Maintain

### Check Logs:

```bash
# Backend logs
ssh -i ~/.ssh/devops-project-key.pem ubuntu@<BACKEND_IP>
sudo journalctl -u backend -f

# Frontend logs (Nginx)
ssh -i ~/.ssh/devops-project-key.pem ubuntu@<FRONTEND_IP>
sudo journalctl -u nginx -f

# Nagios logs
ssh -i ~/.ssh/devops-project-key.pem ubuntu@<NAGIOS_IP>
sudo tail -f /usr/local/nagios/var/nagios.log
```

### Restart Services if Needed:

```bash
# From your computer (using Ansible)
cd ansible

# Restart backend
ansible backend -i inventory/hosts.ini -m systemd \
  -a "name=backend state=restarted" --become

# Restart frontend (nginx)
ansible frontend -i inventory/hosts.ini -m systemd \
  -a "name=nginx state=restarted" --become

# Restart Nagios
ansible monitoring -i inventory/hosts.ini -m systemd \
  -a "name=nagios state=restarted" --become
```

---

## Step 22: Cleanup (When Done Learning)

⚠️ **IMPORTANT**: Destroy resources to avoid AWS charges!

### Stop Instances (Temporary):

```bash
# Stop all instances (keeps data, stops charges for compute)
aws ec2 stop-instances --instance-ids \
  $(aws ec2 describe-instances \
    --filters "Name=tag:Project,Values=devops-fullstack" \
    --query "Reservations[].Instances[].InstanceId" \
    --output text)
```

### Destroy Everything (Permanent):

```bash
cd /Users/printrip/Desktop/Code/devops_prac/terraform

# Destroy all infrastructure
terraform destroy
```

You'll see what will be deleted, then:
```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: 
```

**Type**: `yes`

**This will delete:**
- ✅ All EC2 instances
- ✅ Security groups
- ✅ VPC and networking
- ✅ Everything created by Terraform

**Time required**: ~3-5 minutes

### Verify Deletion:

```bash
aws ec2 describe-instances \
  --filters "Name=tag:Project,Values=devops-fullstack" \
  --query "Reservations[].Instances[].State.Name"
```

Should return empty or "terminated"

---

## 📊 Cost Monitoring

### Check AWS Billing:

1. Go to: https://console.aws.amazon.com/billing/
2. Click **"Bills"** in left sidebar
3. Check current month charges
4. Click **"Free Tier"** to see usage

### Expected Costs:

**With Free Tier (first 12 months):**
- 3 t2.micro instances: **$0** (within 750 hours/month)
- 60 GB storage: **~$6/month** (exceeds 30 GB free tier)
- Data transfer: **$0** (within 15 GB free)

**Total**: $0-10/month

**After Free Tier expires:**
- 3 t2.micro instances: ~$10-15/month
- Storage: ~$6/month
- **Total**: ~$15-20/month

### Set Up Billing Alerts:

1. Go to: https://console.aws.amazon.com/billing/home#/preferences
2. Enable: ✅ "Receive Billing Alerts"
3. Go to CloudWatch: https://console.aws.amazon.com/cloudwatch/
4. Create alarm for billing > $10

---

## 🔧 Troubleshooting

### Issue: "Error: InvalidKeyPair.NotFound"

**Cause**: Key pair name doesn't match

**Solution**:
```bash
# List your key pairs
aws ec2 describe-key-pairs

# Update terraform/variables.tf with correct key name
```

### Issue: "Connection timeout" when SSH

**Cause**: Instance still booting or security group issue

**Solution**:
```bash
# Wait 2 more minutes
sleep 120

# Try again
ssh -i ~/.ssh/devops-project-key.pem ubuntu@<IP>

# Check security groups allow SSH
aws ec2 describe-security-groups --filters "Name=tag:Project,Values=devops-fullstack"
```

### Issue: "Permission denied (publickey)"

**Cause**: Wrong key or permissions

**Solution**:
```bash
# Check key permissions
chmod 400 ~/.ssh/devops-project-key.pem

# Verify key path
ls -la ~/.ssh/devops-project-key.pem

# Use correct key in SSH command
ssh -i ~/.ssh/devops-project-key.pem ubuntu@<IP>
```

### Issue: Ansible can't connect

**Cause**: Inventory has wrong IPs or key path

**Solution**:
```bash
# Update inventory with correct IPs
nano ansible/inventory/hosts.ini

# Test connectivity
ansible all -i ansible/inventory/hosts.ini -m ping -vvv
```

### Issue: Backend/Frontend not accessible

**Cause**: Service not running or security group blocks port

**Solution**:
```bash
# SSH into server
ssh -i ~/.ssh/devops-project-key.pem ubuntu@<IP>

# Check service status
sudo systemctl status backend  # or nginx

# Check logs
sudo journalctl -u backend -n 50

# Restart service
sudo systemctl restart backend
```

### Issue: Terraform apply fails

**Cause**: AWS permissions or quota issues

**Solution**:
```bash
# Check AWS credentials
aws sts get-caller-identity

# Check EC2 limits
aws service-quotas get-service-quota \
  --service-code ec2 \
  --quota-code L-1216C47A

# Try different region
# Edit terraform/terraform.tfvars: aws_region = "us-west-2"
```

---

## 📚 Next Steps

### Learning Exercises:

1. **Modify the backend** - Add new API endpoints
2. **Customize frontend** - Change colors, add features
3. **Add monitoring** - Create new Nagios checks
4. **Experiment with Puppet** - Add new configuration rules
5. **Break things!** - Stop services and see what happens
6. **Scale up** - Add more EC2 instances
7. **Add database** - Deploy PostgreSQL or MySQL
8. **Implement CI/CD** - Use GitHub Actions

### Advanced Topics:

- Load balancing with ALB
- Auto-scaling groups
- RDS for databases
- S3 for static files
- CloudWatch for detailed monitoring
- Lambda functions
- Container orchestration with ECS/EKS

---

## 📝 Quick Reference Commands

```bash
# Terraform
terraform init              # Initialize
terraform plan              # Preview changes
terraform apply             # Deploy infrastructure
terraform destroy           # Delete everything
terraform output            # Show output values

# Ansible
ansible all -m ping         # Test connectivity
ansible-playbook <file>     # Run playbook
ansible all -m shell -a "command"  # Run command

# AWS CLI
aws ec2 describe-instances  # List instances
aws ec2 stop-instances --instance-ids <id>  # Stop instance
aws sts get-caller-identity # Check credentials

# SSH
ssh -i ~/.ssh/devops-project-key.pem ubuntu@<IP>  # Connect to server

# Systemctl (on server)
sudo systemctl status backend   # Check service
sudo systemctl restart backend  # Restart service
sudo journalctl -u backend -f   # View logs
```

---

## ✅ Completion Checklist

- [ ] AWS account created
- [ ] AWS credentials configured
- [ ] SSH key pair created
- [ ] Terraform initialized
- [ ] Infrastructure deployed
- [ ] Backend deployed and tested
- [ ] Frontend deployed and tested
- [ ] Nagios monitoring setup
- [ ] Puppet configured (optional)
- [ ] All services verified working
- [ ] URLs saved
- [ ] Billing alerts set up

---

## 🎉 Congratulations!

You've successfully deployed a complete DevOps project using:
- ✅ Terraform (Infrastructure as Code)
- ✅ Ansible (Configuration Management)
- ✅ Puppet (State Management)
- ✅ Nagios (Monitoring)
- ✅ AWS (Cloud Platform)

**You now have:**
- Production-ready infrastructure
- Automated deployment pipeline
- Monitoring and alerting
- Self-healing configurations
- Real-world DevOps experience

**Remember to destroy resources when done:**
```bash
cd terraform && terraform destroy
```

---

**Happy Learning! 🚀**
