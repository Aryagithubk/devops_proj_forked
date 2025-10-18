# Main Puppet Manifest
# This file defines the desired state for all servers

node default {
  # Ensure system is up to date
  exec { 'apt-update':
    command => '/usr/bin/apt-get update',
    timeout => 300,
  }

  # Essential packages
  package { ['curl', 'wget', 'vim', 'htop', 'net-tools']:
    ensure  => installed,
    require => Exec['apt-update'],
  }

  # Configure timezone
  file { '/etc/timezone':
    ensure  => file,
    content => "UTC\n",
  }

  # Enable automatic security updates
  package { 'unattended-upgrades':
    ensure => installed,
  }

  # Configure firewall (UFW)
  package { 'ufw':
    ensure => installed,
  }

  # Ensure SSH is allowed
  exec { 'ufw-allow-ssh':
    command => '/usr/sbin/ufw allow 22/tcp',
    unless  => '/usr/sbin/ufw status | /bin/grep -q "22/tcp.*ALLOW"',
    require => Package['ufw'],
  }
}

# Backend server specific configuration
node /backend/ {
  include default

  # Ensure Node.js service is running
  service { 'backend':
    ensure  => running,
    enable  => true,
    require => Package['nodejs'],
  }

  # Allow backend port
  exec { 'ufw-allow-backend':
    command => '/usr/sbin/ufw allow 5000/tcp',
    unless  => '/usr/sbin/ufw status | /bin/grep -q "5000/tcp.*ALLOW"',
    require => Package['ufw'],
  }

  # Ensure backend directory exists
  file { '/opt/backend':
    ensure => directory,
    owner  => 'ubuntu',
    group  => 'ubuntu',
    mode   => '0755',
  }

  # Monitor backend process
  exec { 'check-backend-process':
    command => '/bin/systemctl is-active backend || /bin/systemctl restart backend',
    unless  => '/bin/systemctl is-active backend',
  }
}

# Frontend server specific configuration
node /frontend/ {
  include default

  # Ensure nginx is running
  service { 'nginx':
    ensure => running,
    enable => true,
  }

  # Allow HTTP port
  exec { 'ufw-allow-http':
    command => '/usr/sbin/ufw allow 80/tcp',
    unless  => '/usr/sbin/ufw status | /bin/grep -q "80/tcp.*ALLOW"',
    require => Package['ufw'],
  }

  # Ensure frontend directory exists
  file { '/opt/frontend':
    ensure => directory,
    owner  => 'ubuntu',
    group  => 'ubuntu',
    mode   => '0755',
  }

  # Monitor nginx process
  exec { 'check-nginx-process':
    command => '/bin/systemctl is-active nginx || /bin/systemctl restart nginx',
    unless  => '/bin/systemctl is-active nginx',
  }
}

# Nagios monitoring server configuration
node /nagios/ {
  include default

  # Ensure Apache is running
  service { 'apache2':
    ensure => running,
    enable => true,
  }

  # Ensure Nagios is running
  service { 'nagios':
    ensure => running,
    enable => true,
  }

  # Allow HTTP port
  exec { 'ufw-allow-http-nagios':
    command => '/usr/sbin/ufw allow 80/tcp',
    unless  => '/usr/sbin/ufw status | /bin/grep -q "80/tcp.*ALLOW"',
    require => Package['ufw'],
  }

  # Monitor Nagios process
  exec { 'check-nagios-process':
    command => '/bin/systemctl is-active nagios || /bin/systemctl restart nagios',
    unless  => '/bin/systemctl is-active nagios',
  }
}
