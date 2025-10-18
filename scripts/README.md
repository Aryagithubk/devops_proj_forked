# Scripts Directory

Helper scripts for deploying and managing the DevOps project.

## Scripts

### setup-local.sh
**Purpose:** Prepares your local macOS environment

**What it does:**
- Installs Terraform, Ansible, AWS CLI, Node.js
- Generates SSH keys
- Configures AWS credentials
- Imports SSH key to AWS
- Creates Terraform variables file
- Optionally installs app dependencies for local testing

**Usage:**
```bash
chmod +x scripts/setup-local.sh
./scripts/setup-local.sh
```

**When to use:** Run this FIRST, before anything else

---

### deploy.sh
**Purpose:** Complete automated deployment of the entire project

**What it does:**
1. Validates prerequisites (tools, AWS credentials, SSH keys)
2. Provisions AWS infrastructure with Terraform
3. Updates Ansible inventory with server IPs
4. Tests SSH connectivity
5. Deploys backend application
6. Deploys frontend application
7. Sets up Nagios monitoring
8. Installs and configures Puppet
9. Verifies all services
10. Displays access URLs

**Usage:**
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

**Time required:** ~15-20 minutes

**When to use:** After running setup-local.sh

---

### destroy.sh
**Purpose:** Safely destroys all AWS resources

**What it does:**
- Confirms destruction (requires typing 'destroy')
- Runs Terraform destroy
- Removes local temporary files
- Cleans up plan files

**Usage:**
```bash
chmod +x scripts/destroy.sh
./scripts/destroy.sh
```

**When to use:** When you're done learning or want to start fresh

**IMPORTANT:** Always run this when done to avoid AWS charges!

---

## Making Scripts Executable

```bash
chmod +x scripts/*.sh
```

## Script Output

All scripts use colored output:
- 🔵 Blue (ℹ): Informational messages
- 🟢 Green (✓): Success messages
- 🟡 Yellow (⚠): Warnings
- 🔴 Red (✗): Errors

## Error Handling

All scripts use `set -e` which means they will exit immediately if any command fails. This prevents cascading failures.

## Customization

You can modify these scripts to:
- Add additional deployment steps
- Change deployment order
- Add custom validation checks
- Integrate with CI/CD pipelines

## Running Individual Steps

While the scripts are automated, you can also run individual commands manually. See DEPLOYMENT_GUIDE.md for detailed manual steps.

## Tips

1. **Always run setup-local.sh first**
2. **Review Terraform plan before applying**
3. **Keep terminal output for debugging**
4. **Run destroy.sh when done to save money**
5. **Check AWS billing dashboard regularly**

## Troubleshooting

### Script won't run
```bash
# Make it executable
chmod +x scripts/deploy.sh

# Run with bash explicitly
bash scripts/deploy.sh
```

### Script fails mid-way
- Check the error message (in red)
- Most issues are AWS credentials or SSH connectivity
- You can re-run the script - Terraform is idempotent
- For Ansible, use `--start-at-task` to resume

### Permission denied
```bash
# Check SSH key permissions
chmod 400 ~/.ssh/devops_project_key

# Check script permissions
chmod +x scripts/*.sh
```

## Advanced Usage

### Deploy with custom variables
```bash
# Edit variables first
nano terraform/terraform.tfvars

# Then deploy
./scripts/deploy.sh
```

### Deploy specific components
```bash
# Just infrastructure
cd terraform && terraform apply && cd ..

# Just backend
cd ansible && ansible-playbook -i inventory/hosts.ini playbooks/deploy-backend.yml && cd ..
```

### Dry run
```bash
# Terraform plan without apply
cd terraform
terraform plan

# Ansible check mode
cd ansible
ansible-playbook -i inventory/hosts.ini playbooks/deploy-backend.yml --check
```
