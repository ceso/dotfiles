#!/usr/bin/env bash
IFS=$'\n\t'

NOTIFY_ICON=/usr/share/icons/Adwaita/symbolic/status/computer-fail-symbolic.svg

action-notify() {
	local target=$1
	local nunits=$2

	notify-send \
		--app-name systemd --urgency critical --icon "${NOTIFY_ICON}" \
		"systemd is degraded (${target})" \
		"Found ${nunits} failed unit(s)."
}

action-report() {
	local target=$1
	local nunits=$2

	# shellcheck disable=SC2312
	mapfile -t units < <(failed-units "${target}" | awk '{ print $1 }')
	printf "\n== %s\n" "SYSTEM IS DEGRADED (${nunits} UNIT(S) FAILED)"
	for unit in "${units[@]}"; do
		printf "\n** %s\n" "${unit}"
		journalctl --no-pager --boot=0 --lines=3 --unit "${unit}" "${target}"
		echo
	done
}

failed-units() {
	systemctl list-units --state=failed,degraded --no-legend --plain "${@}"
}

main() {
	local action=${1:-report}

	if [[ ${action} == "notify" || ${action} == "report" ]]; then
		for target in --user --system; do
			if systemctl is-failed --quiet "${target}"; then
				# shellcheck disable=SC2312
				"action-${action}" "${target}" "$(failed-units "${target}" | wc -l)"
			fi
		done
	else
		echo >&2 "Usage: ${0} notify|report"
		exit 1
	fi
}

main "$@"
