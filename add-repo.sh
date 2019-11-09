#!/usr/bin/bash

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
    echo
}

function usage() {
    echo "Usage: $0 [repo name] [target root path]"
    exit 1
}

[[ -z "$1" ]] && usage
[[ -z "$2" ]] && usage

repo_name="$1"
repo_dir="repo-$1"
tgt_path="$2"
filter_list="../filters/$repo_name.list"
mkdir "$repo_dir" || die "Duplicacy repository '$repo_name' already exists!"

password="$(cat secrets/enc_password.txt)"
pushd "$repo_dir" > /dev/null

msg "Initializing repository..."
DUPLICITY_GCD_TOKEN="../secrets/gcd-token.json" DUPLICITY_PASSWORD="$password" duplicacy init -e -repository "$tgt_path" "$repo_name" gcd://d001 || die "Error initializing repository"

msg "Saving storage credentials..."
duplicacy set -key gcd_token -value "../secrets/gcd-token.json" || die "Error saving Google Drive token file path"
duplicacy set -key password -value "$password" || doe "Error saving encryption password"

msg "Linking filter list..."
touch "$filter_list"
ln "$filter_list" .duplicacy/filters

popd > /dev/null

hdr "Repository '$repo_name' created with path '$tgt_path'!"
