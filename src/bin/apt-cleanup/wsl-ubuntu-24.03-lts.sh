#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck source=SCRIPTDIR/apt-cleanup.sh
source "$(dirname "$0")"/apt-cleanup.sh

export DEBIAN_FRONTEND=noninteractive
export PACKAGES_TO_KEEP=(
    ubuntu-minimal ubuntu-wsl wsl-pro-service

    cron logrotate manpages networkd-dispatcher rsyslog snapd systemd-hwe-hwdb
    systemd-resolved systemd-timesyncd unattended-upgrades update-manager-core
    update-motd
)

apt_cleanup
