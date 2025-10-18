# Architecture & Workflow Diagrams

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                           AWS Cloud (Free Tier)                      │
│                                                                      │
│  ┌──────────────────────┐  ┌──────────────────────┐                │
│  │   VPC: 10.0.0.0/16   │  │  Internet Gateway    │                │
│  │                      │──│                      │────── Internet  │
│  └──────────────────────┘  └──────────────────────┘                │
│                │                                                     │
│                │                                                     │
│  ┌─────────────▼────────────────────────────────────────────────┐  │
│  │              Public Subnet: 10.0.1.0/24                       │  │
│  │                                                                │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │  │
│  │  │   Backend    │  │   Frontend   │  │    Nagios    │       │  │
│  │  │     EC2      │  │     EC2      │  │     EC2      │       │  │
│  │  │  t2.micro    │  │  t2.micro    │  │  t2.micro    │       │  │
│  │  │              │  │              │  │              │       │  │
│  │  │  Node.js     │◄─│   React      │  │  Monitoring  │       │  │
│  │  │  Express     │  │   + Nginx    │  │  Dashboard   │       │  │
│  │  │  Port 5000   │  │   Port 80    │  │  Port 80     │       │  │
│  │  │              │  │              │  │              │       │  │
│  │  │ 🔵 Puppet    │  │ 🔵 Puppet    │  │ 🔵 Puppet    │       │  │
│  │  │ 📊 Monitored │  │ 📊 Monitored │  │ 📊 Monitored │       │  │
│  │  └──────────────┘  └──────────────┘  └──────────────┘       │  │
│  │                                                                │  │
│  └────────────────────────────────────────────────────────────────┘  │
│                                                                      │
│  Security Groups (Firewalls):                                       │
│  • Backend: 22 (SSH), 5000 (API), 5666 (NRPE)                      │
│  • Frontend: 22 (SSH), 80 (HTTP), 3000 (React Dev)                 │
│  • Nagios: 22 (SSH), 80 (HTTP)                                     │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Deployment Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│                         YOUR COMPUTER                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  1. Run: ./scripts/deploy.sh                                        │
│                                                                      │
│         │                                                            │
│         ▼                                                            │
│  ┌─────────────────┐                                                │
│  │   Terraform     │  Creates:                                      │
│  │   (IaC)         │  • VPC, Subnets, Internet Gateway              │
│  │                 │  • Security Groups                              │
│  └────────┬────────┘  • 3 EC2 Instances                             │
│           │                                                          │
│           ▼                                                          │
│  ┌─────────────────┐                                                │
│  │   Ansible       │  Deploys:                                      │
│  │ (Deployment)    │  • Backend application                         │
│  │                 │  • Frontend application                         │
│  └────────┬────────┘  • Nagios monitoring                           │
│           │           • Puppet agents                                │
│           ▼                                                          │
│  ┌─────────────────┐                                                │
│  │   Puppet        │  Configures:                                   │
│  │ (State Mgmt)    │  • System packages                             │
│  │                 │  • Service states                               │
│  └────────┬────────┘  • Firewall rules                              │
│           │           • Auto-healing                                 │
│           ▼                                                          │
│  ┌─────────────────┐                                                │
│  │   Nagios        │  Monitors:                                     │
│  │ (Monitoring)    │  • Server health                               │
│  │                 │  • Service availability                         │
│  └─────────────────┘  • Resource usage                              │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Data Flow

```
┌─────────────┐
│   Browser   │
│   (User)    │
└──────┬──────┘
       │
       │ HTTP Request
       ▼
┌─────────────────────────┐
│   Frontend EC2          │
│   React App (Nginx)     │
│   http://<IP>           │
└──────┬──────────────────┘
       │
       │ API Call
       ▼
┌─────────────────────────┐
│   Backend EC2           │
│   Node.js/Express       │
│   http://<IP>:5000      │
└──────┬──────────────────┘
       │
       │ Returns JSON
       ▼
┌─────────────────────────┐
│   Browser               │
│   Displays Data         │
└─────────────────────────┘

Meanwhile...

┌─────────────────────────┐
│   Nagios EC2            │
│   Monitoring Server     │
└──────┬──────────────────┘
       │
       │ Every 5 minutes
       ├──► Checks Backend (HTTP, SSH, Ping)
       ├──► Checks Frontend (HTTP, SSH, Ping)
       └──► Updates Dashboard
```

---

## Tool Interaction

```
┌──────────────────────────────────────────────────────────────┐
│                        Tool Relationships                     │
└──────────────────────────────────────────────────────────────┘

TERRAFORM
    │
    ├─► Creates Infrastructure
    │
    ▼
  EC2 Instances (Empty)
    │
    ├─► ANSIBLE connects via SSH
    │
    ▼
  Configured Servers (Apps Running)
    │
    ├─► PUPPET maintains state
    │   (Runs every 30 minutes or on-demand)
    │
    ▼
  Healthy Servers (Self-healing)
    │
    └─► NAGIOS monitors continuously
        (Checks every 5 minutes)
```

---

## File Dependencies

```
┌─────────────────────────────────────────────────────────────┐
│                    Configuration Flow                        │
└─────────────────────────────────────────────────────────────┘

terraform/terraform.tfvars
    │
    ├─► Used by terraform/main.tf
    │
    ▼
EC2 Instance IPs (outputs)
    │
    ├─► Written to ansible/inventory/hosts.ini
    │
    ▼
ansible/playbooks/*.yml
    │
    ├─► Reads hosts.ini
    ├─► Deploys from applications/
    ├─► Copies puppet/manifests/site.pp
    │
    ▼
Running System
```

---

## Continuous Operations

```
┌────────────────────────────────────────────────────────────┐
│              After Deployment (24/7)                        │
└────────────────────────────────────────────────────────────┘

Every 5 minutes:
    Nagios checks ────► Backend API
                  ────► Frontend HTTP
                  ────► Server SSH
                  └───► Ping tests

Every 30 minutes (optional):
    Puppet runs ──────► Checks service state
                  ────► Restarts if needed
                  ────► Applies config changes
                  └───► Reports changes

On-demand:
    Terraform ────────► Infrastructure changes
    Ansible ──────────► Application updates
    Puppet ───────────► Configuration updates
```

---

## Security Flow

```
┌────────────────────────────────────────────────────────────┐
│                   Security Architecture                     │
└────────────────────────────────────────────────────────────┘

Internet
    │
    ├─► Passes through AWS Internet Gateway
    │
    ▼
Security Groups (Firewall)
    │
    ├─► Backend: Only 22, 5000, 5666
    ├─► Frontend: Only 22, 80, 3000
    └─► Nagios: Only 22, 80
    │
    ▼
EC2 Instances
    │
    ├─► SSH: Key-based auth only
    ├─► Services: Non-root user
    └─► Firewall: UFW configured by Puppet
```

---

## Monitoring Architecture

```
┌────────────────────────────────────────────────────────────┐
│                  Nagios Monitoring Setup                    │
└────────────────────────────────────────────────────────────┘

┌─────────────────┐
│  Nagios Server  │
└────────┬────────┘
         │
         ├────► check_ping ────────► Backend
         │                           Frontend
         │
         ├────► check_ssh ─────────► Port 22
         │
         ├────► check_http ────────► Frontend :80
         │                           Nagios :80
         │
         └────► check_http ────────► Backend :5000/health

Results ──► Nagios Dashboard
         ──► Status: OK / WARNING / CRITICAL
         ──► Historical data
         ──► Alert notifications (configurable)
```

---

## Development vs Production

```
┌─────────────────────────────────────────────────────────────┐
│               Local Development (Optional)                   │
└─────────────────────────────────────────────────────────────┘

Your Computer:
    applications/backend  ──► npm install && npm start
                         ──► Runs on localhost:5000

    applications/frontend ──► npm install && npm start
                         ──► Runs on localhost:3000

    Test locally before deploying!

┌─────────────────────────────────────────────────────────────┐
│                  Production (AWS)                            │
└─────────────────────────────────────────────────────────────┘

AWS Cloud:
    Backend  ──► Runs as systemd service
             ──► Managed by Puppet
             ──► Monitored by Nagios

    Frontend ──► Built and served by Nginx
             ──► Managed by Puppet
             ──► Monitored by Nagios
```

---

## Disaster Recovery

```
┌─────────────────────────────────────────────────────────────┐
│              What Happens When...                            │
└─────────────────────────────────────────────────────────────┘

Backend crashes:
    1. Nagios detects (5 min)
    2. Puppet restarts (30 min or manual)
    3. Alert sent (if configured)

Frontend down:
    1. Nagios detects
    2. Puppet restarts Nginx
    3. Service restored

Configuration drift:
    1. Puppet detects difference
    2. Puppet reapplies manifest
    3. System returns to desired state

Infrastructure destroyed:
    1. Run: terraform apply
    2. Run: ansible-playbook deploy-*.yml
    3. System rebuilt from code!
```

---

## Cost Breakdown

```
┌─────────────────────────────────────────────────────────────┐
│                     AWS Cost Analysis                        │
└─────────────────────────────────────────────────────────────┘

Free Tier (12 months):
✅ EC2: 750 hours/month t2.micro
✅ EBS: 30 GB storage
✅ Data: 15 GB outbound

This Project:
• 3 t2.micro instances = 720 hours/month  ✅ FREE
• 60 GB storage (3 x 20 GB)               ⚠️  ~$6/month
• Minimal data transfer                    ✅ FREE

Estimated: $0-10/month (mostly storage overage)

To minimize costs:
1. Destroy when not using
2. Use 10 GB per instance instead
3. Turn off instances at night
```

---

## Quick Reference Commands

```bash
# Deploy everything
./scripts/deploy.sh

# Check status
ansible all -i ansible/inventory/hosts.ini -m ping

# View backend logs
ssh -i ~/.ssh/devops_project_key ubuntu@<BACKEND_IP>
sudo journalctl -u backend -f

# Apply Puppet manually
ansible all -i ansible/inventory/hosts.ini \
  -m shell -a "/opt/puppetlabs/bin/puppet apply /tmp/site.pp"

# Destroy everything
./scripts/destroy.sh
```

This visual guide helps you understand how all the pieces fit together!
