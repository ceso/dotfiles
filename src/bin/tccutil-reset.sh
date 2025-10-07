#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

print_array() {
    local variable=$1
    shift
    printf "export %s=(\n%s\n)\n\n" "${variable}" "$(printf "    %s\n" "${@}")"
}

prompt_confirmation() {
    local prompt=""
    prompt+="THIS ACTION WILL RESET ALL APPLICATION PRIVILESGES."
    prompt+="Are you sure? (y/N)?"

    read -p "${prompt}" -n 1 -r
    if [[ ! ${REPLY} =~ ^[Yy]$ ]]; then
        printf >&2 "\nAction canceled!"
        exit 2
    fi
}

case ${1:-} in
all)
    SCRIPTDIR=$(basename "$0")

    # shellcheck source-path=SCRIPTDIR
    source "${SCRIPTDIR}/tccutil-reset.data.sh"

    for service in "${SERVICES[@]}"; do
        tccutil reset "${service}"
    done
    ;;

common)
    SERVICES=(
        AddressBook
        Calendar
        Camera
        DeveloperTool
        Microphone
        Reminders
        MediaLibrary
        Photos
        ScreenCapture
        SystemPolicyDesktopFolder
        SystemPolicyDocumentsFolder
        SystemPolicyDownloadsFolder
    )
    for service in "${SERVICES[@]}"; do
        tccutil reset "${service}"
    done
    ;;

debug)
    sqlite3 -box \
        "/Library/Application Support/com.apple.TCC/TCC.db" \
        "SELECT service, client FROM access ORDER BY service, client"
    ;;

scan)
    SERVICES=()
    UNKNOWNS=()

    prompt_confirmation

    while read -r service; do
        if tccutil reset "${service}" >/dev/null 2>&1; then
            SERVICES+=("${service}")
        else
            UNKNOWNS+=("${service}")
        fi
    done < <(
        # shellcheck disable=SC2312
        strings /System/Library/PrivateFrameworks/TCC.framework/Support/tccd |
            perl -ne 'print "$1\n" if /kTCCService(?!All)([A-Za-z0-9]+)/' |
            sort -u
    )

    version=$(sw_vers | awk -v ORS=" " '{ print $2 }')
    printf "# TCC data for %s\n\n" "${version## }"
    print_array SERVICES "${SERVICES[@]}"
    print_array UNKNOWNS "${UNKNOWNS[@]}"

    ;;

*)
    echo >&2 "Usage: $0 all|common|debug|scan"
    exit 1
    ;;
esac
