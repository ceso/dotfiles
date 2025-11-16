#!/usr/bin/env bash
# shortcut: https://www.icloud.com/shortcuts/7f2b1c0ded6b467b94e8842d2ff08a9a

set -eou pipefail
IFS=$'\n\t'

case "${1:-}" in
1 | 2 | 3 | 4)
    echo "$(($1 * 25))" | shortcuts run Brightness
    ;;

*)
    echo >&2 "Usage: brightness < 1 | 2 | 3 | 4 >"
    exit 1
    ;;
esac
