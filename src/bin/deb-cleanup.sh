#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# DON'T USE THIS WITHOUT MODIFICATIONS

# This script was made to clean Debian like systems of unused packages.
# It will silently remove most of your system if you don't modify it!
# You have been warned.

# Templates (write_* functions) *must* preserve \t at the beginning of each
# line or <<- would not work.

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
	#clear APT::Never-MarkAuto-Sections;
	quiet "0";

	APT {
	    Install-Suggests "false";
	    Install-Recommends "false";

	    AutoRemove {
	        RecommendsImportant "false";
	        SuggestsImportant "false";
	    };

	    Get {
	        Assume-Yes "true";
	        AutomaticRemove "true";
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
    chmod 644 /etc/apt/sources.list.d/ubuntu.sources
}

write_apt_sources() {
    # shellcheck source=/etc/os-release
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

system_cleanup() {
    if [[ -z "${PACKAGES_TO_KEEP:-}" ]]; then
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
    dpkg-query --show --showformat '${Package}\n' |
        xargs apt-mark auto >/dev/null

    # The packages we want to keep are now installed. This actions is a noop
    # unless PACKAGES_TO_KEEP changed between runs. Everything that's not a
    # direct dependency of this packages will be purged.
    apt-get install "${PACKAGES_TO_KEEP[@]}"

    # For good measure we remove everything else that may be broken.
    dpkg-query --show --showformat '${db:Status-Abbrev}%${Package}\n' |
        { grep -Fv "ii " || test $? = 1; } |
        cut -d% -f2 |
        xargs apt-get purge

    # Fully update the remaining packages.
    apt-get dist-upgrade
}
