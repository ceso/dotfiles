#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

CURDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
SOURCE=${CURDIR}/src

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

execute_make() {
	local cfg_path=$1
	local cfg_make=${cfg_path}/GNUmakefile
	if [[ -f ${cfg_make} ]]; then
		make -C "${cfg_path}"
	fi
}

process_config() {
	mkdir -p "${HOME}/.config"
	find "${SOURCE}/config" -type d -mindepth 1 -maxdepth 1 | while IFS= read -r cfg_path; do
		cfg_name=$(basename "${cfg_path}")
		link "${cfg_path}" "${HOME}/.config/${cfg_name}"
		execute_make "${cfg_path}"
	done
}

find "${SOURCE}" -mindepth 1 -maxdepth 1 | while IFS= read -r cfg_path; do
	cfg_name=$(basename "${cfg_path}")
	case "${cfg_name}" in
	config)
		process_config
		;;
	*)
		link "${cfg_path}" "${HOME}/${cfg_name}"
		execute_make "${cfg_path}"
		;;
	esac
done
