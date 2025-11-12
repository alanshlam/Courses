# User Manual: Setting up MRTG Service

This guide will walk you through the process of setting up the MRTG (Multi Router Traffic Grapher) service on your system. MRTG is a tool used to monitor and graph network traffic.

## 1. System Update and Upgrade

First, we need to make sure our system is up-to-date. Open your terminal and run the following commands:

```bash
sudo apt update
sudo apt upgrade -y
```

## 2. Install Required Packages

We need to install `net-tools`, `snmpd`, and `snmp`. `snmpd` is the SNMP agent that will provide the data to MRTG.

```bash
sudo apt install net-tools
sudo apt install snmpd snmp
```

## 3. Configure SNMP

Next, we need to configure the SNMP agent.

### 3.1. Backup the original configuration file

It's always a good practice to backup the original configuration file before making any changes.

```bash
cd /etc/snmp
sudo cp snmpd.conf snmpd.conf.orig
```

### 3.2. Edit the configuration file

Open the `snmpd.conf` file in a text editor. The log file uses `vi`, but you can use any editor you are comfortable with (like `nano`).

```bash
sudo vi /etc/snmp/snmpd.conf
```

You need to make the following changes to the file:

*   Find the line `#rocommunity public default -V systemonly` and comment it out (add a `#` at the beginning if it's not already there).
*   Add a new line `rocommunity public default`.
*   Add a new line `disk /` to enable disk monitoring for the root partition.
*   Find the line `#includeAllDisks 10%` and uncomment it (remove the `#`).

The `diff` in the log file shows the changes that were made. You can use it as a reference.

### 3.3. Start the SNMP service

Now, we can start the `snmpd` service and check its status.

```bash
sudo systemctl restart snmpd
sudo systemctl status snmpd
```

### 3.4. Test SNMP

Let's test if SNMP is working correctly. The following command should return the system information.

```bash
snmpwalk -v2c -c public localhost .1.3.6.1.2.1.1.1.0
```

## 4. Install and Configure MRTG

Now we will install and configure MRTG.

### 4.1. Install Apache and MRTG

MRTG uses a web server to display the graphs. We will use Apache.

```bash
sudo apt install apache2
sudo apt install mrtg
```

### 4.2. Create the MRTG configuration file

The `cfgmaker` command creates the MRTG configuration file. We will also set the `WorkDir` to `/var/www/html/mrtg`.

```bash
sudo cfgmaker public@localhost | sudo tee /etc/mrtg/mrtg.cfg > /dev/null
sudo sed -i '1iWorkDir: /var/www/html/mrtg' /etc/mrtg/mrtg.cfg
```

### 4.3. Add custom monitoring targets

We will add custom targets to monitor CPU, RAM, and disk usage.

#### 4.3.1. Find the disk index

Before adding the disk target, you need to find the correct index for the root partition (`/`). Use the following command:

```bash
snmpwalk -v2c -c public localhost .1.3.6.1.4.1.2021.9.1.2
```

Look for the line that ends with `STRING: "/"`. The number at the end of the OID on that line is the index for the root partition. For example, if you see `iso.3.6.1.4.1.2021.9.1.2.1 = STRING: "/"`, the index is `1`.

#### 4.3.2. Append the targets

Append the following content to the `/etc/mrtg/mrtg.cfg` file. **Remember to replace `<disk_index>` with the index you found in the previous step.**

```
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

Target[disk]: .1.3.6.1.4.1.2021.9.1.9.<disk_index>&.1.3.6.1.4.1.2021.9.1.9.<disk_index>:public@localhost
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
```

### 4.4. Run MRTG

Run MRTG to generate the initial graphs. You need to run it three times.

```bash
sudo env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
sudo env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
sudo env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
```

### 4.5. Create the index page

The `indexmaker` command creates an index page for the MRTG graphs.

```bash
sudo indexmaker --output=/var/www/html/mrtg/index.html /etc/mrtg/mrtg.cfg
```

You can view the index page by opening `http://<your_server_ip>/mrtg/` in your web browser.

## 5. Automate MRTG Data Collection

Finally, we will set up a cron job to run MRTG every 5 minutes to keep the graphs updated.

```bash
echo "*/5 * * * * root env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg" | sudo tee /etc/cron.d/mrtg
```

Congratulations! You have successfully set up the MRTG service.
