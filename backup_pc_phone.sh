#!/usr/bin/env bash

# Note: this should be run AFTER all Android devices finish backing up over
# WebDAV and Syncthing

#########
# SETUP #
#########

set -e
cd "$(dirname "$0")"

export GOOGLE_DRIVE_SETTINGS="$PWD/secrets/pydrive.conf"
export PASSPHRASE="$(cat secrets/enc_password.txt)"

# Prints an error in bold red
function err() {
    echo
    echo "\e[1;31m$@\e[0m"
    echo
}

# Prints an error in bold red and exits the script
function die() {
    err "$@"
    builtin exit 1
}

# Shows an informational message
function msg() {
    echo -e "\e[1;32m$@\e[0m"
}

# Shows an informational header
function hdr() {
    echo
    msg "$@"
    echo "Current time: $(date)"
    echo
}

hdr "Preparing to backup..."

# Populate backup information
rm -fr info
mkdir info
date > info/date
pacman -Qqe > info/pacman_pkgs_all.list
pacman -Qqen > info/pacman_pkgs_from_repos.list
pacman -Qqem > info/pacman_pkgs_from_aur.list


################
# PHONE BACKUP #
################

hdr "Performing phone backup..."

dup_args=(
    # Do a full backup if chain is longer than 1 month or doesn't exist,
    # otherwise do an incremental backup
    --full-if-older-than 2M

    # Localize archive cache/datbase directory
    --archive-dir "$PWD/duplicity_archive_cache"

    # Upload while preparing the next volume for speed
    --asynchronous-upload

    # List of files and directories to back up
    --include-filelist dup_glob_phone.list

    # Glob list expects to be from /
    /

    # Target: "d001" folder on Google Drive
    pydrive+gdocs://developer.gserviceaccount.com/d001/
)

# TODO: log & email
duplicity "${dup_args[@]}"

msg "Pruning old phone backups..."
# Prune backups older than 3 months
duplicity remove-older-than 3M --force pydrive+gdocs://developer.gserviceaccount.com/d001/


#############
# PC BACKUP #
#############

hdr "Performing PC backup..."

dup_args=(
    # Do a full backup if chain is longer than 1 month or doesn't exist,
    # otherwise do an incremental backup
    --full-if-older-than 2M

    # Localize archive cache/datbase directory
    --archive-dir "$PWD/duplicity_archive_cache"

    # Upload while preparing the next volume for speed
    --asynchronous-upload

    # List of files and directories to back up
    --include-filelist dup_glob_pc.list

    # Glob list expects to be from /
    /

    # Target: "d002" folder on Google Drive
    pydrive+gdocs://developer.gserviceaccount.com/d002/
)

# TODO: log & email
duplicity "${dup_args[@]}"

msg "Pruning old PC backups..."
# Prune backups older than 3 months
duplicity remove-older-than 3M --force pydrive+gdocs://developer.gserviceaccount.com/d002/


############
# FINALIZE #
############

# TODO: trap this
# Remove backup information
rm -fr info
