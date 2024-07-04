# user_management

## Description
The `create_users.sh` script automates the process of creating new users and groups on a Linux system. It reads a text file containing usernames and associated groups, creates users with their respective home directories, assigns them to the specified groups, generates random passwords, and logs all actions. The generated passwords are stored securely.

For a detailed explanation of the script implementation, you can read the technical article; https://dev.to/njambibetty/automating-user-management-with-bash-a-streamlined-approach-2p9f

## Dependancies 
The script requires root privileges to create users, groups, set passwords, and modify system files. Ensure bash is installed and standard Linux commands (like useradd, groupadd, usermod, chpasswd) are available.

## Error Handling
The script handles errors by logging and skipping existing users, creating missing groups before adding users, and logging errors while continuing to the next user if any command fails.

## Logging
All script actions, including user and group creation, adding users to groups, setting passwords, and errors, are logged to /var/log/user_management.log

## Security
Passwords are generated randomly using tr and /dev/urandom and securely stored in /var/secure/user_passwords.txt with chmod 600 permissions.

## Usage
To run the script, use the following command:

```bash
sudo bash create_users.sh


