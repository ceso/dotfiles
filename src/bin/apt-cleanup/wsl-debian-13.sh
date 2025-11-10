#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck source=SCRIPTDIR/apt-cleanup.sh
source "$(dirname "$0")"/apt-cleanup.sh

export DEBIAN_FRONTEND=noninteractive
export PACKAGES_TO_KEEP=(
    # core os
    ca-certificates cron debconf-i18n dhcpcd-base ifupdown less libpam-systemd
    linux-sysctl-defaults locales logrotate man-db manpages procps rsyslog
    sudo whiptail

    # extra
    curl git gpg make vim
)

apt_cleanup
