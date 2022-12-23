# Set the source and destination directories
src="/path/to/mongodb/data/directory"
dst="user@remote.server:/path/to/backup/directory"

# Set the email address to send alerts to
email_address="your@email.com"

# Set the log file
log_file="/path/to/log/file.log"

# Decrypt the password using the private key
password=$(gpg --decrypt password.gpg)

# Create a temporary directory to store the encrypted backups
tmp_dir=$(mktemp -d)

# Dump the MongoDB database to the temporary directory
mongodump --host localhost --db mydatabase --out "$tmp_dir"
if [ $? -ne 0 ]; then
  echo "$(date): Dump of the MongoDB database failed." >> "$log_file"
  echo "The dump of the MongoDB database failed." | mail -s "Backup Failure" "$email_address"
  rm -rf "$tmp_dir"
  exit 1
fi

# Compress the dump using tar
tar -czvf "$tmp_dir/dump.tar.gz" "$tmp_dir/mydatabase"
if [ $? -ne 0 ]; then
  echo "$(date): Compression of the MongoDB dump failed." >> "$log_file"
  echo "The compression of the MongoDB dump failed." | mail -s "Backup Failure" "$email_address"
  rm -rf "$tmp_dir"
  exit 1
fi

# Encrypt the backups using openssl
openssl enc -aes-256-cbc -salt -in "$tmp_dir/dump.tar.gz" -out "$tmp_dir/encrypted.tar.gz" -pass "pass:$password"
if [ $? -ne 0 ]; then
  echo "$(date): Encryption of the MongoDB dump failed." >> "$log_file"
  echo "The encryption of the MongoDB dump failed." | mail -s "Backup Failure" "$email_address"
  rm -rf "$tmp_dir"
  exit 1
fi

# Perform the backup using rsync
rsync -av "$tmp_dir/encrypted.tar.gz" "$dst"
if [ $? -eq 0 ]; then
  echo "The backup of the MongoDB database to $dst completed successfully." | mail -s "Backup Success" "$email_address"
else
  echo "The backup of the MongoDB database to $dst failed." | mail -s "Backup Failure" "$email_address"
  echo "$(date): Backup of the MongoDB database to $dst failed." >> "$log_file"
  exit 1
fi

# Remove the temporary directory and its contents
rm -rf "$tmp_dir"
