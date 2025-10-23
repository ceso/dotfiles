#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

set -x
brew update
brew upgrade
brew autoremove
brew cleanup --prune=all -s
vim -es +PlugUpgrade +PlugUpdate +PlugClean +qa || true
