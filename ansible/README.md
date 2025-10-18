# Ansible Configuration

This directory contains Ansible playbooks and inventory for deploying and configuring the application.

## Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── inventory/
│   └── hosts.ini           # Server inventory
└── playbooks/
    ├── deploy-backend.yml      # Deploy backend application
    ├── deploy-frontend.yml     # Deploy frontend application
    ├── setup-nagios.yml        # Setup Nagios monitoring
    └── setup-puppet-agent.yml  # Install Puppet on servers
```

## Quick Start

### 1. Update Inventory

After running Terraform, update `inventory/hosts.ini` with the actual server IPs:

```bash
# Get IPs from Terraform
cd ../terraform
terraform output

# Edit inventory
cd ../ansible
nano inventory/hosts.ini
```

### 2. Test Connectivity

```bash
# Ping all hosts
ansible all -i inventory/hosts.ini -m ping

# Should see SUCCESS for all hosts
```

### 3. Deploy Applications

```bash
# Deploy backend
ansible-playbook -i inventory/hosts.ini playbooks/deploy-backend.yml

# Deploy frontend
ansible-playbook -i inventory/hosts.ini playbooks/deploy-frontend.yml

# Setup Nagios monitoring
ansible-playbook -i inventory/hosts.ini playbooks/setup-nagios.yml

# Setup Puppet agents
ansible-playbook -i inventory/hosts.ini playbooks/setup-puppet-agent.yml
```

## Playbooks

### deploy-backend.yml
- Installs Node.js 18.x
- Copies backend application files
- Installs npm dependencies
- Creates systemd service
- Starts backend on port 5000

### deploy-frontend.yml
- Installs Node.js and Nginx
- Copies frontend application files
- Builds React application
- Configures Nginx as web server
- Serves frontend on port 80

### setup-nagios.yml
- Installs Nagios Core
- Installs Nagios Plugins
- Configures monitoring for backend and frontend
- Sets up Apache for Nagios web interface
- Creates default admin user

### setup-puppet-agent.yml
- Installs Puppet Agent
- Configures for masterless mode
- Creates directory structure

## Common Commands

```bash
# Run a single task on all servers
ansible all -i inventory/hosts.ini -m shell -a "uptime"

# Check disk space
ansible all -i inventory/hosts.ini -m shell -a "df -h"

# Restart services
ansible backend -i inventory/hosts.ini -m systemd -a "name=backend state=restarted" --become

# Copy files
ansible all -i inventory/hosts.ini -m copy -a "src=file.txt dest=/tmp/file.txt"

# Run playbook with verbose output
ansible-playbook -i inventory/hosts.ini playbooks/deploy-backend.yml -vv

# Dry run (check mode)
ansible-playbook -i inventory/hosts.ini playbooks/deploy-backend.yml --check
```

## Troubleshooting

### SSH Connection Issues

```bash
# Test SSH manually
ssh -i ~/.ssh/devops_project_key ubuntu@<SERVER_IP>

# Check security groups in AWS
aws ec2 describe-security-groups --group-ids <SG_ID>
```

### Permission Denied

```bash
# Ensure SSH key has correct permissions
chmod 400 ~/.ssh/devops_project_key

# Verify key in ansible.cfg
cat ansible.cfg | grep private_key_file
```

### Service Not Starting

```bash
# Check service logs
ansible backend -i inventory/hosts.ini -m shell -a "journalctl -u backend -n 50" --become

# Check service status
ansible backend -i inventory/hosts.ini -m systemd -a "name=backend" --become
```

## Variables

You can override variables using:

```bash
# Command line
ansible-playbook -i inventory/hosts.ini playbooks/deploy-backend.yml -e "app_port=5001"

# Variables file
ansible-playbook -i inventory/hosts.ini playbooks/deploy-backend.yml -e @vars.yml
```

## Tips

- Always test connectivity with `ansible all -m ping` first
- Use `-vv` or `-vvv` for verbose output when debugging
- Run playbooks with `--check` for dry-run before actual execution
- Keep your inventory file updated
- Use `--limit` to target specific hosts: `ansible-playbook ... --limit backend`
