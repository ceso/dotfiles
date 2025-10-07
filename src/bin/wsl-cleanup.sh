#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# shellcheck source=SCRIPTDIR/deb-cleanup.sh
source "$(dirname "$0")"/deb-cleanup.sh

export DEBIAN_FRONTEND=noninteractive
export PACKAGES_TO_KEEP=(
    # core os
    apt-utils ca-certificates cron dbus debconf-i18n dhcpcd-base ifupdown
    iproute2 iputils-ping less libpam-systemd linux-sysctl-defaults locales
    logrotate netbase nftables procps sensible-utils sudo systemd systemd-sysv
    udev whiptail

    # extra
    curl git man-db openssh-client socat vim
)

system_cleanup
