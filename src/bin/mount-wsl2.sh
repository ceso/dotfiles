#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

WSL2_ROOT=/media/data/wsl2

get_instances() {
	# order matters
	local options=(
		-maxdepth 1
		-mindepth 1
		-type d
		-printf "%f\n"
	)
	find "${WSL2_ROOT}" "${options[@]}"
}

is_valid_instance() {
	local instance_name=$1
	get_instances | grep --max-count=1 --quiet "${instance_name}"
}

find_block_device() {
	sudo modprobe nbd

	local index=0
	while true; do
		local device=/sys/class/block/nbd${index}
		if [[ ! -d ${device} ]]; then
			echo >&2 "[ERR] no more NBD devices availables. Checked ${index}."
			exit 3
		fi

		local size
		size=$(cat "${device}"/size)
		if [[ ${size} == 0 ]]; then
			echo "/dev/nbd${index}"
			break
		fi

		# shellcheck disable=SC2219
		let 'index = index + 1'
	done
}

mount_instance() {
	local instance_name=$1

	local device
	device=$(find_block_device)
	echo "[INF] using device: ${device}"

	local instance_vhdx=${WSL2_ROOT}/${instance_name}/ext4.vhdx
	if [[ ! -f ${instance_vhdx} ]]; then
		echo >&2 "[ERR] missing VHDX ${instance_vhdx}"
		exit 4
	fi

	local mount_point=/media/wsl2-${instance_name}
	sudo qemu-nbd --connect="${device}" "${instance_vhdx}"
	sudo mkdir --mode=0755 --parent "${mount_point}"
	sudo mount "${device}" "${mount_point}"
	echo "[INF] ${instance_name} is available at ${mount_point}"
}

umount_instance() {
	local instance_name=$1
	local mount_point=/media/wsl2-${instance_name}

	local device
	device=$(findmnt --noheadings --output SOURCE /media/wsl2-ubuntu)
	if [[ -n ${device} ]]; then
		sudo umount "${mount_point}"
		sudo rmdir "${mount_point}"
	fi

	sudo qemu-nbd --disconnect "${device}"
}

usage() {
	local exit_code=${1:-0}
	local message=${2:-}
	local output_stream=1 # stdout
	local program=${BASH_SOURCE[0]##*/}

	if [[ $exit_code != 0 ]]; then
		output_stream=2 # stderr
	fi

	cat <<-__EOF__ >&"${output_stream}"
		Usage: ${program} [mount|umount] <instance>
	__EOF__

	if [[ -n $message ]]; then
		local available_instances
		available_instances=$(get_instances | xargs echo)

		echo >&"${output_stream}" "Available instances: ${available_instances}"
		echo >&"${output_stream}"
		echo >&"${output_stream}" "${message}"
	fi

	exit "${exit_code}"
}

main() {
	local command=${1:-}
	local instance_name=${2:-}

	case "${command}" in
	mount)
		# shellcheck disable=SC2310
		if ! is_valid_instance "${instance_name}"; then
			usage 2 "unknown instance ${instance_name}"
		fi
		mount_instance "${instance_name}"
		;;

	umount)
		# shellcheck disable=SC2310
		if ! is_valid_instance "${instance_name}"; then
			usage 2 "unknown instance ${instance_name}"
		fi
		umount_instance "${instance_name}"
		;;

	*)
		usage 1
		;;
	esac
}

main "$@"
