#!/usr/bin/env bash

set -e

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
getpcaps $BASHPID
exit
cd "$(dirname "$0")"
hostname="$(hostname)"

if [[ "$hostname" == "pinwheel" ]]; then
    # PC
    exec ./backup_pc_phone.sh "$@"
elif [[ "$hostname" == "triangulum" ]]; then
    # VPS
    exec ./backup_vps.sh "$@"
else
    die "Running on unknown host '$hostname'!"
fi
