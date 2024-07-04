#!/bin/bash

set -x

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Check if the input file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <name-of-text-file>"
  exit 1
fi

# Define log and password files
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Create /var/secure directory if it doesn't exist
mkdir -p /var/secure
chmod 700 /var/secure

# Clear or create log and password files
> "$LOG_FILE"
> "$PASSWORD_FILE"
chmod 600 "$PASSWORD_FILE"

# Function to generate random password
generate_password() {
  tr -dc 'A-Za-z0-9' </dev/urandom | head -c 12
}

# Read the input file
while IFS=';' read -r username groups; do
  username=$(echo "$username" | xargs)  # Trim whitespace
  groups=$(echo "$groups" | xargs)      # Trim whitespace

  if id "$username" &>/dev/null; then
    echo "User $username already exists." | tee -a "$LOG_FILE"
  else
    # Create user with home directory and password
    useradd -m "$username"

    if [ $? -ne 0 ]; then
      echo "Failed to create user $username." | tee -a "$LOG_FILE"
      continue
    fi

    echo "Created user $username." | tee -a "$LOG_FILE"

    # Generate password
    password=$(generate_password)

    # Set password
    echo "$username:$password" | chpasswd

    if [ $? -ne 0 ]; then
      echo "Failed to set password for user $username." | tee -a "$LOG_FILE"
      continue
    fi

    echo "Set password for user $username." | tee -a "$LOG_FILE"
    echo "$username,$password" >> "$PASSWORD_FILE"

    # Set ownership and permissions for password file
    chown root:root "$PASSWORD_FILE"
    chmod 600 "$PASSWORD_FILE"
  fi

  # Create groups if they don't exist and add user to groups
  IFS=',' read -r -a group_array <<< "$groups"
  for group in "${group_array[@]}"; do
    group=$(echo "$group" | xargs)  # Trim whitespace

    if ! getent group "$group" &>/dev/null; then
      groupadd "$group"
      echo "Created group $group." | tee -a "$LOG_FILE"
    fi

    usermod -aG "$group" "$username"

    if [ $? -ne 0 ]; then
      echo "Failed to add user $username to group $group." | tee -a "$LOG_FILE"
    else
      echo "Added user $username to group $group." | tee -a "$LOG_FILE"
    fi
  done

done < "$1"

echo "User creation process completed." | tee -a "$LOG_FILE"

