#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# PLUGIN: catppuccin/vim => catppuccin
# PLUGIN: editorconfig/editorconfig-vim => editorconfig
# PLUGIN: itchyny/lightline.vim => lightline
# PLUGIN: junegunn/fzf.vim => fzf

VIM_PACK=~/.vim/pack/plugins/start
mkdir -p "${VIM_PACK}"

declare -A VIM_PLUGINS
while IFS=' ' read -r repo pack; do
	VIM_PLUGINS["$pack"]="$repo"
done < <(awk '/^# PLUGIN: / { print $3, $5 }' "${BASH_SOURCE[0]}" || true)

while IFS= read -r pack_path; do
	pack=$(basename "${pack_path}")
	if [[ ! -v VIM_PLUGINS["${pack}"] ]]; then
		>&2 echo "[WRN] removing unused plugin: ${pack}"
		rm -rf "${pack_path}"
	fi
done < <(find "${VIM_PACK}" -mindepth 1 -maxdepth 1 -type d || true)

for pack in "${!VIM_PLUGINS[@]}"; do
	repo=${VIM_PLUGINS[$pack]}
	pack=${VIM_PACK}/${pack}
	if [[ -d "${pack}" ]]; then
		echo "[INF] updating ${repo}"
		git -C "${pack}" pull --ff-only --quiet origin HEAD
	else
		echo "[INF] installing ${repo}"
		git clone --depth=1 --quiet "https://github.com/${repo}" "${pack}"
	fi
done
