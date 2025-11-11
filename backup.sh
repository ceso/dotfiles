#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

declare -a files
files=(
    .config/copier/settings.yaml
    #.config/fish/config.local.fish
    .config/git/allowed_signatures
    .config/git/config.local
    .ssh/config.local
    .vimrc.local
)

declare -a options
options=(
    --directory "${HOME}"
    --gzip
    --create
    --verbose
    --file private.tar.gz
)

tar "${options[@]}" "${files[@]}"
