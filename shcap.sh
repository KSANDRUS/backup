#!/usr/bin/env bash

set -e

login_shell="$(getent passwd $LOGNAME | cut -d: -f7)"

exec sudo systemd-run \
    -p User="$(id -u)" -p Group="$(id -g)" \
    -p CapabilityBoundingSet=CAP_DAC_READ_SEARCH \
    -p AmbientCapabilities=CAP_DAC_READ_SEARCH \
    -p WorkingDirectory="$PWD" \
    -t \
    "$login_shell"
