#!/usr/bin/env bash
# strings /System/Library/PrivateFrameworks/TCC.framework/Support/tccd | grep kTCCService

set -euo pipefail
IFS=$'\n\t'

SERVICES=(
    "Accessibility"
    "AddressBook"
    "AppleEvents"
    "BluetoothAlways"
    "Calendar"
    "Camera"
    "ContactsFull"
    "ContactsLimited"
    "DeveloperTool"
    "FileProviderDomain"
    "FileProviderPresence"
    "FocusStatus"
    "ListenEvent"
    "MediaLibrary"
    "Microphone"
    "Motion"
    "Photos"
    "PhotosAdd"
    "PostEvent"
    "Reminders"
    "ScreenCapture"
    "Siri"
    "SpeechRecognition"
    "SystemPolicyAllFiles"
    "SystemPolicyDesktopFolder"
    "SystemPolicyDeveloperFiles"
    "SystemPolicyDocumentsFolder"
    "SystemPolicyDownloadsFolder"
    "SystemPolicyNetworkVolumes"
    "SystemPolicyRemovableVolumes"
    "SystemPolicySysAdminFiles"
    "Willow"

    #"Location"
    #"Liverpool"
    #"ShareKit"
    #"Ubiquity"

    #"Facebook"
    #"LinkedIn"
    #"Prototype3Rights"
    #"Prototype4Rights"
    #"SinaWeibo"
    #"TencentWeibo"
    #"Twitter"
)

case ${1:-} in
all)
    for service in "${SERVICES[@]}"; do
        tccutil reset "${service}"
    done
    ;;

common)
    tccutil reset Accesibility
    tccutil reset AddressBook
    tccutil reset Calendar
    tccutil reset Camera
    tccutil reset DeveloperTool
    tccutil reset Microphone
    tccutil reset Reminders
    tccutil reset Photos
    tccutil reset ScreenCapture
    tccutil reset SystemPolicyAllFiles
    tccutil reset SystemPolicyDesktopFolder
    tccutil reset SystemPolicyDocumentsFolder
    ;;

debug)
    sqlite3 -box \
        "/Library/Application Support/com.apple.TCC/TCC.db" \
        "SELECT service, client FROM access ORDER BY service, client"
    ;;

*)
    echo >&2 "Usage: $0 all|common|debug"
    exit 1
    ;;
esac
