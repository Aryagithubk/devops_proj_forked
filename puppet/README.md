# Puppet Configuration

This directory contains Puppet manifests for configuration management.

## Structure

```
puppet/
├── manifests/
│   └── site.pp          # Main manifest file
└── modules/             # Custom Puppet modules (optional)
```

## What Puppet Does

Puppet ensures servers maintain their desired state:

- **Common Configuration** (all servers):
  - System packages up to date
  - Essential tools installed
  - Firewall (UFW) configured
  - Timezone set
  - Automatic security updates enabled

- **Backend Server**:
  - Backend service running
  - Port 5000 open
  - Application directory exists
  - Auto-restart on failure

- **Frontend Server**:
  - Nginx running
  - Port 80 open
  - Application directory exists
  - Auto-restart on failure

- **Nagios Server**:
  - Apache running
  - Nagios service running
  - Port 80 open
  - Auto-restart on failure

## Usage

### Apply Manifest (Masterless Mode)

```bash
# On any server
sudo /opt/puppetlabs/bin/puppet apply /etc/puppetlabs/code/environments/production/manifests/site.pp

# Or if manifest is in /tmp
sudo /opt/puppetlabs/bin/puppet apply /tmp/site.pp
```

### Test Without Making Changes

```bash
sudo /opt/puppetlabs/bin/puppet apply --noop /tmp/site.pp
```

### Apply with Ansible

```bash
# Copy manifest to all servers
ansible all -i inventory/hosts.ini -m copy -a "src=../puppet/manifests/site.pp dest=/tmp/site.pp"

# Apply on all servers
ansible all -i inventory/hosts.ini -m shell -a "/opt/puppetlabs/bin/puppet apply /tmp/site.pp"
```

## Idempotency

Puppet is idempotent - running it multiple times produces the same result. It only makes changes when the system drifts from the desired state.

## Validation

```bash
# Check syntax
sudo /opt/puppetlabs/bin/puppet parser validate /tmp/site.pp

# Dry run
sudo /opt/puppetlabs/bin/puppet apply --noop /tmp/site.pp
```

## Node Matching

The manifest uses node patterns to match servers:
- `node default` - Applies to all servers
- `node /backend/` - Matches hostnames containing "backend"
- `node /frontend/` - Matches hostnames containing "frontend"
- `node /nagios/` - Matches hostnames containing "nagios"

## Monitoring

Puppet can be run periodically via cron to ensure continuous compliance:

```bash
# Add to crontab
*/30 * * * * /opt/puppetlabs/bin/puppet apply /tmp/site.pp > /var/log/puppet-apply.log 2>&1
```
