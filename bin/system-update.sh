#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if command -v apt >/dev/null; then
	sudo apt update
	sudo apt full-upgrade --assume-yes
	sudo apt autoremove --purge
elif command -v dnf >/dev/null; then
	sudo dnf upgrade --assumeyes
	sudo dnf autoremove --assumeyes
fi

if command -v brew >/dev/null; then
	brew update
	brew upgrade
	brew autoremove
	brew cleanup --prune=all --scrub
fi

if command -v appimageupdatetool >/dev/null; then
	appimageupdatetool --self-update || true
	for f in "$HOME"/.local/bin/*.AppImage; do
		[ -f "$f" ] || continue
		appimageupdatetool --overwrite "$f" || true
	done
fi

if command -v flatpak >/dev/null; then
	flatpak update -y
fi

if command -v nvim >/dev/null; then
	nvim --headless "+Lazy! sync" +qa || true
fi
