#!/usr/bin/env bash

# Note: this should be run AFTER all Android devices finish backing up over
# WebDAV and Syncthing

#########
# SETUP #
#########

set -e
cd "$(dirname "$0")"

# Prints an error in bold red
function err() {
    echo
    echo -e "\e[1;31m$@\e[0m"
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

# Polyfill ionice
if ! type ionice > /dev/null; then
    function ionice() {
        shift
        shift
        "$@"
    }
fi

hdr "Preparing to backup..."

# Populate backup information
rm -fr info
mkdir info
date > info/date
apt-mark showmanual > info/apt_pkgs.list
sudo -u postgres pg_dumpall > info/pg_databases.sql


################
# PHONE BACKUP #
################

hdr "Performing VPS backup..."

pushd repo-vps > /dev/null

# TODO: log & email
ionice -c 3 duplicacy backup -stats

msg "Pruning old VPS backups..."
# Prune backups:
#   - Keep no snapshots older than 360 days
#   - Keep 1 snapshot every 30 day(s) if older than 180 day(s)
#   - Keep 1 snapshot every 7 day(s) if older than 30 day(s)
#   - Keep 1 snapshot every 1 day(s) if older than 7 day(s)
ionice -c 3 duplicacy prune -keep 0:360 -keep 30:180 -keep 7:30 -keep 1:7

popd > /dev/null


############
# FINALIZE #
############

# TODO: trap this
# Remove backup information
rm -fr info
