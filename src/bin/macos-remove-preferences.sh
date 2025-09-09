#!/usr/bin/env bash
set -euo pipefail
IFS=$'\t\n'

locations=(
    "${HOME}/Library/Application Support/"
    "${HOME}/Library/Caches/"
    "${HOME}/Library/Internet Plug-Ins/"
    "${HOME}/Library/LaunchAgents/"
    "${HOME}/Library/Logs/"
    "${HOME}/Library/PreferencePanes/"
    "${HOME}/Library/Preferences/"
    "${HOME}/Library/Saved Application State/"
    "${HOME}/Library/WebKit/"
)

options=()

if [[ $# -gt 0 ]]; then
    options+=(-iname "*$1*")
    shift
fi

if [[ $# -gt 0 ]]; then
    for pattern in "${@}"; do
        options+=(-o -iname "*${pattern}*")
    done
fi

find "${locations[@]}" "${options[@]}"
