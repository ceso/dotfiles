#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if command -v softwareupdate; then
	softwareupdate --install --all
fi

if command -v apt >/dev/null; then
	sudo apt update
	sudo apt full-upgrade --assume-yes
	sudo apt autoremove --purge
fi

if command -v flatpak >/dev/null; then
	sudo flatpak update --assumeyes --system
	flatpak update --assumeyes --user
fi

if command -v snap >/dev/null; then
	sudo snap refresh
fi

if command -v brew >/dev/null; then
	brew update
	brew upgrade
	brew autoremove
	brew cleanup --prune=all --scrub
fi

if command -v vim >/dev/null; then
	vim -es +PlugUpgrade +PlugUpdate +PlugClean +qa || true
fi
