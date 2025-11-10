#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if command -v apt-get >/dev/null; then
    sudo apt-get update
    sudo apt-get --assume-yes upgrade
fi

if command -v snap >/dev/null; then
    sudo snap refresh
fi

if command -v brew >/dev/null; then
    brew update
    brew upgrade
    brew autoremove
    brew cleanup --prune=all -s
fi

if command -v vim >/dev/null; then
    vim -es +PlugUpgrade +PlugUpdate +PlugClean +qa || true
fi
