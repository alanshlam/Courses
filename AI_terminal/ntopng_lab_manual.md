# Lab Manual: Setting up ntopng

This guide will walk you through the process of setting up ntopng, a web-based network traffic monitoring tool.

## 1. System Update

First, let's update our system.

```bash
sudo apt update && sudo apt upgrade -y
```

## 2. Add ntop Repository and Install ntopng

The ntopng packages are not in the default Ubuntu repositories. We need to add the official ntop repository to our system.

```bash
wget https://packages.ntop.org/apt/24.04/all/apt-ntop.deb
sudo dpkg -i apt-ntop.deb
sudo apt update
sudo apt install -y ntopng
```

## 3. Configure ntopng

Now, we will configure ntopng to monitor our network.

### 3.1. Find your network interface

You need to tell ntopng which network interface to monitor. Use the `ifconfig -a` or `ip a` command to list all network interfaces and find the name of your primary network interface (e.g., `ens33`, `eth0`).

```bash
ifconfig -a
```

### 3.2. Backup the configuration file

It's a good practice to create a backup of the original configuration file before editing.

```bash
cd /etc/ntopng/
sudo cp ntopng.conf ntopng.conf.orig
```

### 3.3. Edit the configuration file

Open the `ntopng.conf` file in a text editor (e.g., `nano` or `vi`).

```bash
sudo vi /etc/ntopng/ntopng.conf
```

You will need to make the following changes:

*   **Set the network interface:** Find the line starting with `-i=` and set it to the interface you found in step 3.1. For example:
    ```
    -i=ens33
    ```
*   **Set the local networks:** Find the line starting with `-m=` and set it to your local network ranges. This tells ntopng which traffic is local. For example:
    ```
    -m=192.168.0.0/16,172.17.0.0/16
    ```

## 4. Start and Enable ntopng Service

Now we can start the ntopng service and enable it to start automatically on boot.

```bash
sudo systemctl start ntopng
sudo systemctl status ntopng
sudo systemctl enable ntopng
```

## 5. Access the ntopng Web Interface

ntopng provides a web interface for viewing traffic data. By default, it is accessible at `http://<your_server_ip>:3000`.

You can use the `lsof -Pi` command to see which ports are being used by which services.

```bash
sudo lsof -Pi
```

Open your web browser and navigate to `http://<your_server_ip>:3000`. The default login is `admin` with password `admin`. You will be prompted to change the password on your first login.

Congratulations! You have successfully set up ntopng.
