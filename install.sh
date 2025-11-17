#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

link() {
    local src="$1"
    local dst="$2"

    if [[ -e ${dst} && ! -L ${dst} ]]; then
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

install_file() {
    local dname="$1"
    local fname="$2"
    local url="$3"
    test -d "${dname}" || mkdir -p "${dname}"
    test -f "${fname}" || curl -o "${dname}/${fname}" -fsSL "${url}"
}

SRC=${PWD}/src

mkdir -p "${HOME}/.config"
for app in bat fish ghostty git; do
    link "${SRC}/config/${app}" "${HOME}/.config/${app}"
done

link "${SRC}/bin" "${HOME}/bin"
link "${SRC}/cspell.dictionary.txt" "${HOME}/.cspell.dictionary.txt"
link "${SRC}/hushlogin" "${HOME}/.hushlogin"
link "${SRC}/homebrew" "${HOME}/.homebrew"
link "${SRC}/ssh" "${HOME}/.ssh"
link "${SRC}/vim" "${HOME}/.vim"
link "${SRC}/vimrc" "${HOME}/.vimrc"

install_file \
    ~/.config/micro/colorschemes "catppuccin-mocha.micro" \
    https://raw.githubusercontent.com/catppuccin/micro/refs/heads/main/themes/catppuccin-mocha.micro

install_file \
    ~/.config/fish/themes "Catppuccin Mocha.theme" \
    https://raw.githubusercontent.com/catppuccin/fish/refs/heads/main/themes/Catppuccin%20Mocha.theme

fish -c "yes | fish_config theme save 'Catppuccin Mocha'"
mkdir -p ~/.vim/tmp/{backup,swap,undo}
vim +PlugUpgrade +PlugUpdate +PlugClean +qa
