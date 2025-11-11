#!/bin/bash

# This script automates the setup of the MRTG service.

echo "Starting MRTG setup..."

# 1. System Update and Upgrade
echo "Updating and upgrading the system..."
sudo apt update
sudo apt upgrade -y

# 2. Install Required Packages
echo "Installing net-tools, snmpd, and snmp..."
sudo apt install -y net-tools
sudo apt install -y snmpd snmp

# 3. Configure SNMP
echo "Configuring SNMP..."

# 3.1. Backup the original configuration file
echo "Backing up snmpd.conf..."
sudo cp /etc/snmp/snmpd.conf /etc/snmp/snmpd.conf.orig

# 3.2. Edit the configuration file
echo "Editing snmpd.conf..."
sudo sed -i 's/rocommunity\s\+public\s\+default\s\+-V\s\+systemonly/#rocommunity public default -V systemonly/' /etc/snmp/snmpd.conf
sudo sed -i 's/rocommunity6\s\+public\s\+default\s\+-V\s\+systemonly/#rocommunity6 public default -V systemonly/' /etc/snmp/snmpd.conf
echo "rocommunity public default" | sudo tee -a /etc/snmp/snmpd.conf
sudo sed -i 's/#includeAllDisks 10%/includeAllDisks 10%/' /etc/snmp/snmpd.conf
echo "disk /" | sudo tee -a /etc/snmp/snmpd.conf

# 3.3. Start the SNMP service
echo "Starting snmpd service..."
sudo systemctl restart snmpd
sudo systemctl status snmpd

# 3.4. Test SNMP
echo "Testing SNMP..."
snmpwalk -v2c -c public localhost .1.3.6.1.2.1.1.1.0

# 4. Install and Configure MRTG
echo "Installing and configuring MRTG..."

# 4.1. Install Apache and MRTG
echo "Installing Apache and MRTG..."
sudo apt install -y apache2
sudo apt install -y mrtg

# 4.2. Create the MRTG configuration file
echo "Creating MRTG configuration file..."
sudo cfgmaker public@localhost | sudo tee /etc/mrtg/mrtg.cfg > /dev/null
sudo sed -i '1iWorkDir: /var/www/html/mrtg' /etc/mrtg/mrtg.cfg

# 4.3. Add custom monitoring targets
echo "Adding custom monitoring targets to mrtg.cfg..."
sudo tee -a /etc/mrtg/mrtg.cfg > /dev/null <<EOT

Target[cpu]: .1.3.6.1.4.1.2021.11.50.0&.1.3.6.1.4.1.2021.11.52.0:public@localhost
Title[cpu]: CPU Usage (%)
PageTop[cpu]: <h1>CPU Usage</h1>
MaxBytes[cpu]: 100
YLegend[cpu]: CPU Usage (%)
ShortLegend[cpu]: %
Legend1[cpu]: User CPU
Legend2[cpu]: System CPU
Options[cpu]: gauge, nopercent

Target[ram]: .1.3.6.1.4.1.2021.4.6.0&.1.3.6.1.4.1.2021.4.15.0:public@localhost
Title[ram]: Memory Usage (KB)
PageTop[ram]: <h1>Memory Usage</h1>
MaxBytes[ram]: 1000000000
YLegend[ram]: Memory (KB)
ShortLegend[ram]: KB
Legend1[ram]: Available RAM
Legend2[ram]: Cached RAM
Options[ram]: gauge, nopercent

Target[disk]: .1.3.6.1.4.1.2021.9.1.9.1&.1.3.6.1.4.1.2021.9.1.9.1:public@localhost
Title[disk]: Disk Usage (Root Partition - /)
PageTop[disk]: <h1>Disk Usage (Root Partition - /)</h1>
MaxBytes[disk]: 100
YLegend[disk]: Disk Usage (%)
ShortLegend[disk]: %
Legend1[disk]: Disk Usage
Legend2[disk]: Disk Usage (same)
LegendI[disk]: Used
LegendO[disk]:
Options[disk]: gauge, nopercent, noo
EOT

# 4.4. Run MRTG
echo "Running MRTG to generate initial graphs..."
sudo env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
sudo env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
sudo env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg

# 4.5. Create the index page
echo "Creating MRTG index page..."
sudo mkdir -p /var/www/html/mrtg
sudo indexmaker --output=/var/www/html/mrtg/index.html /etc/mrtg/mrtg.cfg

# 5. Automate MRTG Data Collection
echo "Setting up cron job for MRTG..."
echo "*/5 * * * * root env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg" | sudo tee /etc/cron.d/mrtg

echo "MRTG setup is complete."
echo "You can view the graphs at http://<your_server_ip>/mrtg/"
