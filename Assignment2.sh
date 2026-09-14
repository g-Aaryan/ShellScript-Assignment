#!/bin/bash

SOURCE_DIR=$1
MAX_BACKUPS=3

if [ -z "$SOURCE_DIR" ]; then
    echo "Please provide a directory"
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    echo "Directory does not exist"
    exit 1
fi

TIME=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_DIR="$SOURCE_DIR/backup_$TIME"

mkdir "$BACKUP_DIR"

# Copy all files and folders except backup folders
cp -r "$SOURCE_DIR"/* "$BACKUP_DIR/" 2>/dev/null

# Remove copied backup folders
rm -rf "$BACKUP_DIR"/backup_*

echo "Backup created successfully"

# Store all backups in an array
BACKUPS=("$SOURCE_DIR"/backup_*)

# Delete old backups until only 3 remain
while [ ${#BACKUPS[@]} -gt $MAX_BACKUPS ]; do
    OLD_BACKUP="${BACKUPS[0]}"

    echo "Deleting old backup: $OLD_BACKUP"
    rm -rf "$OLD_BACKUP"

    BACKUPS=("$SOURCE_DIR"/backup_*)
done

echo "Backup rotation completed"
