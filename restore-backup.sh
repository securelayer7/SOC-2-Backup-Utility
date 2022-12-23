#!/bin/bash

# Set the source and destination directories
src="/path/to/source/directory"
dst="/path/to/destination/directory"
# For the Remote Server Destination
#dst="user@remotehost:/path/to/destination/directory"

# Set the email address to send alerts to
email_address="your@email.com"

# Set the log file
log_file="/path/to/log/file.log"

# Decrypt the password using the private key
password=$(gpg --decrypt password.gpg)

# Check if the source directory exists
if [ ! -d "$src" ]; then
  # Create the source directory
  mkdir -p "$src"

  # Check the exit code of the mkdir command
  if [ $? -ne 0 ]; then
    # Append the error message to the log file
    echo "$(date): Creation of $src failed." >> "$log_file"

    # Send failure message
    echo "The restore process failed." | mail -s "Restore Failure" "$email_address"
    exit 1
  fi
fi

# Check if the destination directory exists
if [ ! -d "$dst" ]; then
  # Create the destination directory
  mkdir -p "$dst"

  # Check the exit code of the mkdir command
  if [ $? -ne 0 ]; then
    # Append the error message to the log file
    echo "$(date): Creation of $dst failed." >> "$log_file"

    # Send failure message
    echo "The restore process failed." | mail -s "Restore Failure" "$email_address"
    exit 1
  fi
fi

# Create a temporary directory to store the restored backups
tmp_dir=$(mktemp -d)

# Check the exit code of the mktemp command
if [ $? -ne 0 ]; then
  # Append the error message to the log file
  echo "$(date): Creation of temporary directory failed." >> "$log_file"

  # Send failure message
  echo "The restore process failed." | mail -s "Restore Failure" "$email_address"
  exit 1
fi

# Perform the restore using rsync
rsync -au "$src/encrypted.tar.gz" "$tmp_dir"

# Check the exit code of the rsync command
if [ $? -ne 0 ]; then
  # Append the error message to the log file
  echo "$(date): Restore from $src to $tmp_dir failed." >> "$log_file"

  # Send failure message
  echo "The restore process failed." | mail -s "Restore Failure" "$email_address"
  exit 1
fi

# Decrypt the backups using openssl
openssl enc -d -aes-256-cbc -in "$tmp_dir/encrypted.tar.gz" -out "$tmp_dir/decrypted.tar.gz" -pass "pass:$password"

# Check the exit code of the openssl command
if [ $? -ne 0 ]; then
  # Append the error message to the log file
  echo "$(date): Decryption of $src failed." >> "$log_file"

  # Send failure message
  echo "The restore process failed." | mail -s "Restore Failure" "$email_address"
  exit
