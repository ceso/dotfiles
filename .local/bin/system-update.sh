#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

if command -v apt >/dev/null; then
	sudo apt update
	sudo apt full-upgrade
	sudo apt autoremove --purge
elif command -v dnf >/dev/null; then
	sudo dnf upgrade
	sudo dnf autoremove
elif command -v rpm-ostree >/dev/null; then
	rpm-ostree upgrade
fi

if command -v brew >/dev/null; then
	brew update
	brew upgrade
	brew autoremove
	brew cleanup --prune=all --scrub
fi

if command -v appimageupdatetool >/dev/null; then
	appimageupdatetool --self-update || true
	for appimage in "$HOME"/.local/bin/*.AppImage; do
		[[ -f "$appimage" ]] || continue
		appimageupdatetool --overwrite "$appimage" || true
	done
fi

if command -v flatpak >/dev/null; then
	flatpak update -y
fi

if command -v uv >/dev/null; then
	uv self update
	uv tool upgrade --all
fi

if command -v nvim >/dev/null; then
	nvim --headless "+lua vim.pack.update()" +qa
fi

if command -v ghostty >/dev/null; then
	bash "${HOME}/.local/bin/ghostty-installer.sh"
fi
