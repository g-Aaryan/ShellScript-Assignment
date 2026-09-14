#!/bin/bash

# ==========================================
# User Account Management Script
# ==========================================
# Features:
# - Create user
# - Delete user
# - Reset password
# - List users and UIDs
# - Display help
# ==========================================

# ------------------------------------------
# Part 1: Create a new user
# ------------------------------------------
create_user() {

    read -p "Enter new username: " username


    # Check if the username already exists
    if id "$username"; then
        echo "Error: Username '$username' already exists."
        return 1
    fi

    # Ask for password without displaying it
    read -s -p "Enter password: " password
    echo

    # Confirm password
    read -s -p "Confirm password: " confirm_password
    echo

    if [[ "$password" != "$confirm_password" ]]; then
        echo "Error: Passwords do not match."
        return 1
    fi

    # Create the user account
    sudo useradd -m -s /bin/bash "$username"

    # Set the password
    echo "$username:$password" | sudo chpasswd

    echo "Success: User '$username' created successfully."
}

# ------------------------------------------
# Part 2: Delete an existing user
# ------------------------------------------
delete_user() {

    read -p "Enter username to delete: " username

    # Check if username exists
    if ! id "$username" ; then
        echo "Error: Username '$username' does not exist."
        return 1
    fi

    # Protect important system accounts
    if [[ "$username" == "root" || "$username" == "ubuntu" ]]; then
        echo "Error: Cannot delete protected user '$username'."
        return 1
    fi

    # Ask for confirmation
    read -p "Are you sure you want to delete '$username'? (y/n): " confirm

    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Deletion cancelled."
        return 0
    fi

    # Delete user and home directory
    if ! sudo userdel -r "$username"; then
        echo "Error: Failed to delete user '$username'."
        return 1
    fi

    echo "Success: User '$username' deleted successfully."
}

# ------------------------------------------
# Part 3: Reset an existing user's password
# ------------------------------------------
reset_password() {

    read -p "Enter username: " username

    # Check if username exists
    if ! id "$username" &>/dev/null; then
        echo "Error: Username '$username' does not exist."
        return 1
    fi

    # Ask for the new password
    read -s -p "Enter new password: " new_password
    echo

    # Confirm the new password
    read -s -p "Confirm new password: " confirm_password
    echo

    if [[ "$new_password" != "$confirm_password" ]]; then
        echo "Error: Passwords do not match."
        return 1
    fi

    # Reset the password
    if ! echo "$username:$new_password" | sudo chpasswd; then
        echo "Error: Failed to reset password."
        return 1
    fi

    # Never display the actual password
    echo "Success: Password updated for user '$username'."
}

# ------------------------------------------
# Part 4: List user accounts and UIDs
# ------------------------------------------
list_users() {

    echo "Username                 UID"
    echo "----------------------------"

    # Read usernames and UIDs from /etc/passwd
    awk -F: '{printf "%-24s %s\n", $1, $3}' /etc/passwd
}

# ------------------------------------------
# Part 5: Display help and usage
# ------------------------------------------
show_help() {

    echo "Usage: $0 [OPTION]"
    echo
    echo "User Account Management Script"
    echo
    echo "Options:"
    echo "  -c, --create    Create a new user account"
    echo "  -d, --delete    Delete an existing user account"
    echo "  -r, --reset     Reset a user's password"
    echo "  -l, --list      List all users and their UIDs"
    echo "  -h, --help      Display this help message"
    echo
}

# ------------------------------------------
# Main program
# ------------------------------------------

# Check if an option was provided
if [[ $# -eq 0 ]]; then
    show_help
    exit 0
fi

# Process the command-line option
case "$1" in

    -c|--create)
        create_user
        ;;

    -d|--delete)
        delete_user
        ;;

    -r|--reset)
        reset_password
        ;;

    -l|--list)
        list_users
        ;;

    -h|--help)
        show_help
        ;;

    *)
        echo "Error: Invalid option '$1'."
        echo
        show_help
        exit 1
        ;;

esac
