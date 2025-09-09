#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# DOMAIN: 1password.com
# DOMAIN: 1password.eu
# DOMAIN: 1password.ca
# DOMAIN: addons-api.adguard.com
# DOMAIN: api.adguard.com
# DOMAIN: ping.*.adguard.io
# DOMAIN: static.adguard.com
# DOMAIN: api.apple-cloudkit.com
# DOMAIN: apple.com
# DOMAIN: icloud.com
# DOMAIN: icloud.com.cn
# DOMAIN: idmsa.apple.com
# DOMAIN: updates.cdn-apple.com
# DOMAIN: accounts.google.com
# DOMAIN: meet.google.com
# DOMAIN: login.live.com
# DOMAIN: santander.com.uy
# DOMAIN: web.whatsapp.com

awk '/^# DOMAIN: / { print $3 }' "${0}" |
    xargs defaults write com.adguard.mac.adguard SslExceptionDomains -array
