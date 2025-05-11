#!/bin/bash

set +e

backup_location="/efs/master_backup"
source_location="/test123"

if ! command -v zip >/dev/null 2>&1; then
    if command -v apt >/dev/null 2>&1; then
        sudo apt install -y zip
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y zip
    else
        echo "Neither apt nor yum found. Cannot install zip." >&2
        exit 1
    fi
fi


# Check if /master_backup folder exists or not; if not, create the /master_backup folder
if [ ! -d "${backup_location}" ]; then
  echo "Creating /master_backup directory..."
  mkdir -p "${backup_location}"
  echo "Directory created successfully ${backup_location}"
else
  echo "${backup_location} directory already exists."
fi

# Set the path of the folder to be backed up
backup_folder="${source_location}"

# Get the folder name
folder_name=$(basename "${backup_folder}")

# Determine the next version number
version=1
existing_versions=$(ls "${backup_location}/v"*_"${folder_name}"*.zip 2>/dev/null | sed -E 's/^.*v([0-9]+)_.*$/\1/' | sort -n)
if [ -n "$existing_versions" ]; then
  highest_version=$(echo "$existing_versions" | tail -n 1)
  version=$((highest_version + 1))
fi

# Set the path of the backup file with versioning
timestamp=$(date +%d-%b-%Y_%H-%M-%S)
backup_file="v${version}_${folder_name}-${timestamp}.zip"

# Set the path of the backup destination
backup_destination="${backup_location}"

# Create the backup archive
zip -r "${backup_destination}/${backup_file}" "${backup_folder}"

# Send the backup to the destination
echo "Backup of ${backup_folder} created and sent to ${backup_destination}/${backup_file}"
exit_code=$?

# Check if the exit code is 0 (success)
if [ ${exit_code} -eq 0 ]; then
  echo "Command succeeded"
else
  echo "Command failed with exit code ${exit_code}"
fi
