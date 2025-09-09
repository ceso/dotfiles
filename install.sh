#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

link() {
    local src="$1"
    local dst="$2"

    if [[ -e "${dst}" && ! -L "${dst}" ]]; then
        echo >&2 "WRN: ${dst} already exists and it is not a symlink, ignoring"
        return
    fi

    if rm -f "${dst}" && ln -sf "${src}" "${dst}"; then
        echo "INF: ${dst} was properly updated"
    else
        echo >&2 "ERR: failed to link ${src} to ${dst}"
        exit 1
    fi
}

SRC=${PWD}/src

mkdir -p "${HOME}/.config"
for app in copier fish ghostty git; do
    link "${SRC}/config/${app}" "${HOME}/.config/${app}"
done

link "${SRC}/bin" "${HOME}/bin"
link "${SRC}/cspell.dictionary.txt" "${HOME}/.cspell.dictionary.txt"
link "${SRC}/hushlogin" "${HOME}/.hushlogin"
link "${SRC}/vim" "${HOME}/.vim"
link "${SRC}/vimrc" "${HOME}/.vimrc"
