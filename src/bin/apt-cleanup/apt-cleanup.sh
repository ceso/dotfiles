# DON'T USE THIS WITHOUT MODIFICATIONS

# This script was made to clean Debian like systems of unused packages.
# It will silently remove most of your system if you don't modify it!
# You have been warned.:w

# Templates (write_* functions) *must* preserve \t at the beginning of each
# line or <<- would not work.

set -euo pipefail
IFS=$'\n\t'

declare -a APT_MARK_AUTO
declare -a APT_MARK_HOLD
declare -a APT_MARK_MANUAL

backup_apt_marks() {
    mapfile -t APT_MARK_AUTO < <(apt-mark showauto || true)
    mapfile -t APT_MARK_HOLD < <(apt-mark showhold || true)
    mapfile -t APT_MARK_MANUAL < <(apt-mark showmanual || true)
}

restore_apt_marks() {
    test "${#APT_MARK_AUTO[@]}" -gt 0 &&
        printf "%s\n" "${APT_MARK_AUTO[@]}" | xargs apt-mark auto >/dev/null
    test "${#APT_MARK_HOLD[@]}" -gt 0 &&
        printf "%s\n" "${APT_MARK_HOLD[@]}" | xargs apt-mark hold >/dev/null
    test "${#APT_MARK_MANUAL[@]}" -gt 0 &&
        printf "%s\n" "${APT_MARK_MANUAL[@]}" | xargs apt-mark manual >/dev/null
}

container_warning() {
    local docker_clean=/etc/apt/apt.conf.d/docker-clean
    if [[ -f ${docker_clean} ]]; then
        echo 2>&1 "[WRN] ${docker_clean} is present. Consider removing it and use caches"
        echo 2>&1 "[WRN] RUN \\"
        echo 2>&1 "[WRN]   --mount=type=cache,target=/var/cache/apt \\"
        echo 2>&1 "[WRN]   --mount=type=cache,target=/var/lib/apt \\"
        echo 2>&1 "[WRN]   apt-get ..."
    fi
}

update_privileges() {
    local target=$1
    chown root:root "${target}"
    chmod 0644 "${target}"
}

write_apt_90local() {
    # before using this and possibly break your system read apt.conf(5)
    local target=/etc/apt/apt.conf.d/90local
    cat >"${target}" <<-__EOF__
	// Allows automatic removal of metapackages and tasks
	#clear APT::Never-MarkAuto-Sections;

	// 0: normal, 1: suppress progress, 2: no message, implies -y
	quiet "1";

	APT {
	    Install-Suggests "false";
	    Install-Recommends "false";

	    AutoRemove {
	        RecommendsImportant "false";
	        SuggestsImportant "false";
	    };

	    Get {
	        Assume-Yes "false";
	        AutomaticRemove "false";
	        Fix-Broken "true";
	        Fix-Missing "true";
	        Purge "true";
	        Show-Upgraded "true";
	        Upgrade-Allow-New "true";
	    };
	};
	__EOF__
    update_privileges "${target}"
}

write_debian_apt_sources() {
    local target=/etc/apt/sources.list.d/debian.sources
    cat >"${target}" <<-__EOF__
	Types: deb
	URIs: http://deb.debian.org/debian
	Suites: ${VERSION_CODENAME} ${VERSION_CODENAME}-backports ${VERSION_CODENAME}-updates
	Components: main contrib non-free
	Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

	Types: deb
	URIs: http://deb.debian.org/debian-security
	Suites: ${VERSION_CODENAME}-security
	Components: main contrib non-free
	Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
	__EOF__
    rm -f /etc/apt/sources.list
    update_privileges "${target}"
}

write_ubuntu_apt_sources() {
    local target=/etc/apt/sources.list.d/ubuntu.sources
    cat >"${target}" <<-__EOF__
	Types: deb
	URIs: http://archive.ubuntu.com/ubuntu/
	Suites: ${VERSION_CODENAME} ${VERSION_CODENAME}-updates ${VERSION_CODENAME}-backports
	Components: main restricted universe multiverse
	Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

	Types: deb
	URIs: http://security.ubuntu.com/ubuntu/
	Suites: ${VERSION_CODENAME}-security
	Components: main restricted universe multiverse
	Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
	__EOF__
    update_privileges "${target}"
}

write_apt_sources() {
    # shellcheck source=SCRIPTDIR/examples/os-release.debian
    source /etc/os-release

    case "${ID}" in
    debian) write_debian_apt_sources ;;
    ubuntu) write_ubuntu_apt_sources ;;
    *)
        echo 2>&1 "[ERR] Unsupported distribution ${ID}."
        exit 1
        ;;
    esac
}

apt_cleanup() {
    if [[ -z ${PACKAGES_TO_KEEP:-} ]]; then
        echo 2>&1 "[ERR] PACKAGES_TO_KEEP is empty or undefined."
        exit 2
    fi

    container_warning
    write_apt_90local
    write_apt_sources

    # Refresh metadata.
    apt-get update

    # Mark every package as automatically installed, in doing so they get
    # scheduled for purging.
    backup_apt_marks
    dpkg-query --show --showformat '${Package}\n' |
        xargs apt-mark auto >/dev/null

    # The packages we want to keep are now installed. This actions is a noop
    # unless PACKAGES_TO_KEEP changed between runs. Everything that's not a
    # direct dependency of this packages will be purged.
    if [[ ${DESTROY_MY_SYSTEM:-} != "YES" ]]; then
        apt-get --simulate install "${PACKAGES_TO_KEEP[@]}"
        restore_apt_marks
        return
    fi
    apt-get --assume-yes --auto-remove install "${PACKAGES_TO_KEEP[@]}"
    apt-mark manual "${PACKAGES_TO_KEEP[@]}" >/dev/null

    # Remove everything else that may be broken.
    dpkg-query --show --showformat '${db:Status-Abbrev}%${Package}\n' |
        awk -F% '!/^ii / {print $2}' |
        xargs apt-get --assume-yes purge

    # dist-upgrade handles changing dependencies with new versions
    apt-get --assume-yes --auto-remove dist-upgrade
}
