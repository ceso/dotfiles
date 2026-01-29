#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

case "$(uname)" in
Darwin)
	CODE_SETTINGS_DIR="${HOME}/Library/Application Support/Code/User"
	;;
Linux)
	CODE_SETTINGS_DIR="${HOME}/.config/Code/User"
	;;
*)
	# shellcheck disable=SC2312
	echo >&2 "[ERR] Unsupported platform $(uname)."
	exit 1
	;;
esac

CODE_SETTINGS="${CODE_SETTINGS_DIR}/settings.json"

update_profiles() {
	# default profile
	code --update-extensions

	# user defined profiles
	cfg="${CODE_SETTINGS_DIR}/globalStorage/storage.json"
	while IFS= read -r profile; do
		code --profile "${profile}" --update-extensions
	done < <(jq -r '.userDataProfiles[].name' <"${cfg}" || true)
}

verify_settings() {
	# ensure all settings are applied to all profiles
	jq -r '
        def definedSettings:
            keys - ["workbench.settings.applyToAllProfiles"] | map(select(startswith("[")|not));
        def appliedSettings:
            .["workbench.settings.applyToAllProfiles"];
        (definedSettings - appliedSettings) + (appliedSettings - definedSettings) | .[]
    ' <"${CODE_SETTINGS}" | awk 'END {if (NR != 0) exit 2 } { print }'
}

verify_settings
update_profiles
