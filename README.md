# SOC-2-Backup-Utility

This repository contains a script for implementing a backup strategy that meets the requirements of SOC 2 Type II compliance. The script utilizes rsync, tar, and openssl to perform incremental file-based backups, compress and encrypt the data, and store it in a specified destination. The script also includes error handling and notification capabilities through email alerts and log file updates. Use this tool to ensure the backup of sensitive data and achieve compliance with the SOC 2 Type II framework.

# Getting Started

These instructions will get you a copy of the script up and running on your local machine for testing purposes.

## Prerequisites

- rsync
- tar
- openssl
- inotify-tools
- gpg
- mailutils

## Installing

1. Clone this repository to your local machine: `git clone https://github.com/securelayer7/SOC-2-Backup-Utility.git`
2. Navigate to the directory where you cloned the repository: `cd SOC-2-Backup-Utility`
3. Edit the script to specify the source and destination directories, email address, log file, and password file.
4. Make the script executable: `chmod +x backup.sh`
5. Run the script: `./backup.sh`

## Cronjob

To set up a cron job for the SOC 2 Backup Utility script, follow these steps:

- Open a terminal and enter the following command to edit the crontab file: `crontab -e`
- Add a line to the crontab file specifying the schedule and command for running the script. For example, to run the script every day at midnight: `0 0 * * * /path/to/backup.sh`

## Security Settings
To store the password in an encrypted form, you can use a tool like gpg to encrypt the password and store it in a separate file. gpg is a command-line utility that allows you to encrypt and decrypt files using public key cryptography.

## GPG Setup
Here is an example of how you can use gpg to encrypt the password and store it in a separate file:

### Generate a new GPG key pair
`gpg --full-generate-key`

### Enter your name, email address, and choose a password when prompted

### Export the public key
`gpg --export -a "Your Name <your@email.com>" > public.key`

### Encrypt the password using the public key
`echo -n "yourpassword" | gpg --encrypt --recipient "Your Name <your@email.com>" > password.gpg`

## Passwordless SSH Access for Remote Distination 

To set up passwordless SSH access to a remote server, you will need to generate a public-private key pair on the local machine and add the public key to the authorized_keys file on the remote host.

Here are the steps to set up passwordless SSH access using keys:

1. On the local machine, open a terminal and run the following command to generate a new public-private key pair:

`ssh-keygen`

This will prompt you to choose a file in which to save the key pair and a passphrase to protect the private key. You can accept the default location and leave the passphrase blank, or you can specify a different location and passphrase if desired.

2. Once the key pair has been generated, copy the public key to the remote host using the ssh-copy-id command:

`ssh-copy-id user@remotehost`

This will add the public key to the authorized_keys file on the remote host, allowing you to connect to the remote host without a password.

3. Test the passwordless SSH connection by running the following command on the local machine:

`ssh user@remotehost`

If the connection is successful, you will be logged in to the remote host without being prompted for a password.

That's it! You have now set up passwordless SSH access to the remote host. You can now use rsync to transfer files to the remote host without being prompted for a password.

## Restricting SSH to Specific IP Address 

To prevent brute-force attacks on the SSH port, you can configure the sshd daemon to allow connections only from specific IP addresses or networks.

To do this, you will need to edit the `/etc/ssh/sshd_config` file and add one or more `AllowUsers` or `AllowGroups` directives, followed by a list of the allowed users or groups. 

For example:

`AllowUsers user1 user2`
`AllowGroups ssh-users`

You can also use the `AllowUsers` and `AllowGroups` directives to specify specific IP addresses or networks that are allowed to connect to the SSH server. 

For example: 

`AllowUsers user1@192.168.0.0/24 user2@10.0.0.0/8`
`AllowGroups ssh-users@192.168.0.0/24`

After modifying the `sshd_config` file, you will need to restart the sshd daemon for the changes to take effect. On most systems, you can do this by running the following command:

`systemctl restart ssh`

This will allow connections to the SSH server only from the specified IP addresses or networks, and will block all other connections. This can help to prevent brute-force attacks on the SSH port and improve the security of your server.


## Deployment

To use this script in a production environment, add it to your crontab to run on a schedule.
Built With

1. rsync - A fast, versatile, remote (and local) file-copying tool
2. tar - A utility for creating, maintaining, modifying, and extracting files from archives
3. openssl - A toolkit for secure communication
4. inotify-tools - A set of command-line programs for Linux providing a simple interface to inotify
5. gpg - A tool for secure communication and data storage
6. mailutils - A set of utilities for handling email messages
