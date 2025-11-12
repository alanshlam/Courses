# Nagios Setup Lab Manual

## Introduction

This manual provides a step-by-step guide to installing and configuring Nagios Core on a Linux system. Nagios is a powerful open-source monitoring system that enables organizations to identify and resolve IT infrastructure problems before they affect critical business processes.

This manual also provides an automated installation script `setup_nagios.sh` for a quicker setup.

## Prerequisites

*   A Linux system (e.g., Ubuntu, Debian).
*   `sudo` or root access.
*   An internet connection.

## Manual Installation Steps

### 1. Update System and Install Dependencies

First, update your system's package index and install the required dependencies for Nagios.

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y autoconf gcc libc6 make wget unzip apache2 php libapache2-mod-php libgd-dev libssl-dev openssl
```

### 2. Create User and Group

Create a new user and group for Nagios. Add the `www-data` user to the `nagcmd` group to allow the web interface to issue commands.

```bash
sudo useradd -m -s /bin/bash nagios
sudo groupadd nagcmd
sudo usermod -a -G nagcmd nagios
sudo usermod -a -G nagcmd www-data
```

### 3. Download and Install Nagios Core

Download the latest version of Nagios Core, extract it, and then compile and install it.

```bash
cd /tmp
wget https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-4.5.3/nagios-4.5.3.tar.gz
tar xzf nagios-4.5.3.tar.gz
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
```

### 4. Download and Install Nagios Plugins

Nagios Core needs plugins to monitor services. Download, compile, and install the Nagios Plugins.

```bash
cd /tmp
wget https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.4.6/nagios-plugins-2.4.6.tar.gz
tar xzf nagios-plugins-2.4.6.tar.gz
cd nagios-plugins-2.4.6
./configure
make
sudo make install
```

### 5. Configure Apache

Enable the `rewrite` and `cgi` Apache modules. Then, create a user account (`nagiosadmin`) to access the Nagios web interface.

```bash
sudo a2enmod rewrite cgi
sudo htpasswd -cb /usr/local/nagios/etc/htpasswd.users nagiosadmin nagios
```
This command will create the `nagiosadmin` user with the password `nagios`.

### 6. Start Nagios and Apache

Verify the Nagios configuration and then start the Nagios and Apache services.

```bash
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg
sudo systemctl restart nagios
sudo systemctl status nagios
sudo systemctl restart apache2
```

## Automated Installation

An automated installation script `setup_nagios.sh` is available in this directory. To use it, simply run the following command:

```bash
./setup_nagios.sh
```

The script will perform all the installation steps automatically.

## Verification

You can now access the Nagios web interface by navigating to `http://<your-server-ip>/nagios` in your web browser. You will be prompted to log in with the `nagiosadmin` user.

**Username:** `nagiosadmin`
**Password:** `nagios` (if you used the automated script or the `htpasswd -cb` command)

If you used the interactive `htpasswd -c` command, use the password you created.