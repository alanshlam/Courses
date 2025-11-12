#!/bin/bash

# Nagios Installation Script

# Exit on any error
set -e

# 1. Update System and Install Dependencies
echo "Updating system and installing dependencies..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php libgd-dev libssl-dev openssl

# 2. Create User and Group
echo "Creating Nagios user and group..."
sudo useradd -m -s /bin/bash nagios || echo "User nagios already exists."
sudo groupadd nagcmd || echo "Group nagcmd already exists."
sudo usermod -a -G nagcmd nagios
sudo usermod -a -G nagcmd www-data

# 3. Download and Install Nagios Core
echo "Downloading and installing Nagios Core..."
cd /tmp
wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-4.5.3/nagios-4.5.3.tar.gz
tar xzf nagioscore.tar.gz
cd nagios-4.5.3/
./configure --with-httpd-conf=/etc/apache2/sites-enabled
make all
sudo make install
sudo make install-init
sudo make install-commandmode
sudo make install-config
sudo make install-groups-users
sudo make install-daemoninit
sudo make install-webconf

# 4. Download and Install Nagios Plugins
echo "Downloading and installing Nagios Plugins..."
cd /tmp
wget -O nagios-plugins.tar.gz https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.4.6/nagios-plugins-2.4.6.tar.gz
tar xzf nagios-plugins.tar.gz
cd nagios-plugins-2.4.6/
./configure
make
sudo make install

# 5. Configure Apache
echo "Configuring Apache..."
sudo a2enmod rewrite cgi
echo "Setting up nagiosadmin user. The password is 'nagios'."
sudo htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin nagios

# 6. Start Nagios and Apache
echo "Starting Nagios and Apache..."
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
sudo systemctl restart nagios
sudo systemctl restart apache2

echo "----------------------------------------"
echo "Nagios installation is complete."
echo "Access the Nagios web interface at http://<your-server-ip>/nagios"
echo "Username: nagiosadmin"
echo "Password: nagios"
echo "----------------------------------------"
