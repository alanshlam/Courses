#!/bin/bash

# This script automates the setup of the ntopng service.

if [ -z "$1" ]; then
    echo "Usage: $0 <network-interface>"
    echo "Please provide the network interface to monitor (e.g., eth0, ens33)."
    exit 1
fi

INTERFACE=$1
# You can change the local networks here if needed
LOCAL_NETWORKS="192.168.0.0/16,172.17.0.0/16"

echo "Starting ntopng setup..."

# 1. System Update and Preparation
echo "Updating system..."
sudo apt update && sudo apt upgrade -y

# 2. Add ntop repository and install ntopng
echo "Adding ntop repository and installing ntopng..."
wget https://packages.ntop.org/apt/24.04/all/apt-ntop.deb
sudo dpkg -i apt-ntop.deb
sudo apt update
sudo apt install -y ntopng

# 3. Configure ntopng
echo "Configuring ntopng..."

# 3.1. Backup the configuration file
echo "Backing up ntopng.conf..."
sudo cp /etc/ntopng/ntopng.conf /etc/ntopng/ntopng.conf.orig

# 3.2. Edit the configuration file
echo "Adding interface and local network configuration to ntopng.conf..."
echo "-i=$INTERFACE" | sudo tee -a /etc/ntopng/ntopng.conf
echo "-m=$LOCAL_NETWORKS" | sudo tee -a /etc/ntopng/ntopng.conf

# 4. Start and Enable ntopng Service
echo "Starting and enabling ntopng service..."
sudo systemctl start ntopng
sudo systemctl status ntopng
sudo systemctl enable ntopng

echo "ntopng setup is complete."
echo "You can access the web interface at http://<your_server_ip>:3000"
echo "Default login: admin / admin"

# Make the script executable
chmod +x setup_ntopng.sh
