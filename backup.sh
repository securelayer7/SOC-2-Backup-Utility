#!/bin/bash

# Set the source and destination directories
src="/path/to/source/directory"
dst="/path/to/destination/directory"
# For the Remote Server Distination 
#dst="user@remotehost:/path/to/destination/directory"


# Set the email address to send alerts to
email_address="your@email.com"

# Set the log file
log_file="/path/to/log/file.log"

# Decrypt the password using the private key
password=$(gpg --decrypt password.gpg)

# Start inotifywait in monitoring mode
inotifywait -mrq --format '%w%f' -e modify,create,delete "$src" | while read file; do
  # Create a temporary directory to store the encrypted backups
  tmp_dir=$(mktemp -d)
  if [ $? -ne 0 ]; then
    # Append the error message to the log file
    echo "$(date): Creation of temporary directory failed." >> "$log_file"

    # Restart the backup process
    continue
  fi

  # Compress the source directory using tar
  tar -czvf "$tmp_dir/source.tar.gz" "$src"

  # Check the exit code of the tar command
  if [ $? -ne 0 ]; then
    # Append the error message to the log file
    echo "$(date): Compression of $src failed." >> "$log_file"

    # Restart the backup process
    continue
  fi

  # Encrypt the backups using openssl
  openssl enc -aes-256-cbc -salt -in "$tmp_dir/source.tar.gz" -out "$tmp_dir/encrypted.tar.gz" -pass "pass:$password"

  # Check the exit code of the openssl command
  if [ $? -ne 0 ]; then
    # Append the error message to the log file
    echo "$(date): Encryption of $src failed." >> "$log_file"

    # Restart the backup process
    continue
  fi

  # Perform the backup using rsync
  rsync -au "$tmp_dir/encrypted.tar.gz" "$dst"

  # Check the exit code of the rsync command
  if [ $? -eq 0 ]; then
    # Send success message if the backup was successful
    echo "The incremental backup from $src to $dst completed successfully." | mail -s "Backup Success" "$email_address"
  else
    # Send failure message if the backup failed
    echo "The incremental backup from $src to $dst failed." | mail -s "Backup Failure" "$email_address"

    # Append the failure message to the log file
    echo "$(date): Backup from $src to $dst failed." >> "$log_file"

    # Restart the backup process
    continue
  fi

  # Check the exit code of the mail command
  if [ $? -ne 0 ]; then
    # Append the error message to the log file
    echo "$(date): Sending email notification failed." >> "$log_file"
  fi

  # Remove the temporary directory and its contents
  rm -rf "$tmp_dir"
