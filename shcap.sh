#!/usr/bin/env bash

set -e

login_shell="$(getent passwd $LOGNAME | cut -d: -f7)"

exec sudo systemd-run \
    -p User="$(id -u)" \
    -p Group="$(id -g)" \
    -p CapabilityBoundingSet=CAP_DAC_READ_SEARCH \
    -p AmbientCapabilities=CAP_DAC_READ_SEARCH \
    -p WorkingDirectory="$PWD" \
    -p Environment=VIRTUAL_ENV=shcap \
    -t \
    "$login_shell"
