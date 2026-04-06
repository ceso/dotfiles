#!/usr/bin/env bash
# shellcheck shell=bash
# Build and install Ghostty terminal from source (tarball) using Podman
# Using this script until ghostty is official either in
# * Fedora/Debian repos
# * Flathub
set -euo pipefail

LOG_FILE="/tmp/ghostty_installer_$(date -u +"%Y_%m_%d").log"
GHOSTTY_REPO="ghostty-org/ghostty"
DOCKERFILE_DIR_PATH="${HOME}/.local/share/ghostty/dockerfiles"
INSTALL_BASE_PATH="${HOME}/.local"
CONTAINER_OUTPUT_PATH="/output${INSTALL_BASE_PATH}"
INSTALL_BIN_PATH="${INSTALL_BASE_PATH}/bin"
INSTALL_SHARE_PATH="${INSTALL_BASE_PATH}/share"
ARCH="$(uname -m)"
OS_ID=""
DOCKERFILE_PATH=""
IMAGE_PREFIX=""
ACTION="install"
TARGET_VERSION=""

usage() {
  cat <<'EOF'
Usage: bash ghostty-installer.sh [OPTIONS]

Options:
  --version <ver>     Install a specific Ghostty version (default: latest)
  --downgrade         Switch to the previous installed version
  --uninstall         Remove all Ghostty files and container images
  -h, --help          Show this help message

Default behavior:
  If Ghostty is not installed, builds and installs the latest version.
  If already installed, checks for updates and upgrades if available.
EOF
  exit 0
}

logger() {
  local level="$1"
  shift
  local msg="$*"
  local datetime
  local color=""
  local reset='\033[0m'

  case "${level}" in
    INFO)  color='\033[0;32m' ;;
    WARN)  color='\033[0;33m' ;;
    ERROR) color='\033[0;31m' ;;
    *)     color="" ;;
  esac

  datetime="$(date -u +"%Y-%m-%d %H:%M:%S")"
  echo -e "${datetime} ${color}${level}${reset} ${msg}" >&2
  echo "${datetime} ${level} ${msg}" >>"${LOG_FILE}"

  if [[ "${level}" = "ERROR" ]]; then
    exit 1
  fi
}

get_installed_versions() {
  find "${INSTALL_BIN_PATH}" -maxdepth 1 -name "ghostty-*.${ARCH}" -printf '%f\n' 2>/dev/null \
    | sed "s/^ghostty-//;s/\\.${ARCH}$//" \
    | sort -V
}

get_current_version() {
  local target
  local suffix

  if [[ -L "${INSTALL_BIN_PATH}/ghostty" ]]; then
    target=$(readlink "${INSTALL_BIN_PATH}/ghostty")
    target="${target#ghostty-}"
    suffix=".${ARCH}"
    echo "${target%"${suffix}"}"
  fi
}

binary_name() {
  local version="$1"
  echo "ghostty-${version}.${ARCH}"
}

prune_old_versions() {
  local installed_versions=()
  local num_installed_versions
  local current_version
  local version_to_remove
  local binary_to_remove
  local versions_output

  versions_output=$(get_installed_versions)
  mapfile -t installed_versions <<< "${versions_output}"
  num_installed_versions=${#installed_versions[@]}

  # keep at least 3 versions, nothing to prune
  if (( num_installed_versions <= 3 )); then
    return 0
  fi

  current_version=$(get_current_version)

  for ((i = 0; i < num_installed_versions - 3; i++)); do
    version_to_remove=${installed_versions[i]}

    if [[ "${version_to_remove}" == "${current_version}" ]]; then
      continue
    fi

    binary_to_remove=$(binary_name "${version_to_remove}")
    logger INFO "Pruning old version: ${binary_to_remove}"

    rm -f -- "${INSTALL_BIN_PATH:?}/${binary_to_remove}"
  done
}

install_artifacts() {
  local version="$1"
  local artifacts_dir="$2"
  local bin_name
  bin_name=$(binary_name "${version}")

  logger INFO "Installing ${bin_name} to ${INSTALL_BASE_PATH}"
  mkdir -p "${INSTALL_BIN_PATH}" "${INSTALL_SHARE_PATH}"

  cp "${artifacts_dir}/bin/ghostty" "${INSTALL_BIN_PATH}/${bin_name}"
  chmod +x "${INSTALL_BIN_PATH}/${bin_name}"

  # set SELinux context (bin_t) so the binary runs under proper SELinux policy
  if command -v chcon &>/dev/null; then
    chcon -t bin_t "${INSTALL_BIN_PATH}/${bin_name}" 2>/dev/null || \
      logger WARN "Could not set SELinux context on ${bin_name} (SELinux may be disabled)"
  fi

  ln -sf "${bin_name}" "${INSTALL_BIN_PATH}/ghostty"
  logger INFO "Symlink: ghostty -> ${bin_name}"

  if [[ -d "${artifacts_dir}/share" ]]; then
    cp -r "${artifacts_dir}/share/." "${INSTALL_SHARE_PATH}/"
  fi

  rm -rf "${artifacts_dir}"
  logger INFO "Enabling & initiating Ghostty systemd service"
  
  # reload dbus & systemd to recognize ghostty systemd files
  dbus-send --session --type=method_call --dest=org.freedesktop.DBus / org.freedesktop.DBus.ReloadConfig
  systemctl --user daemon-reload
  
  for action in enable start; do
    systemctl --user "${action}" "app-com.mitchellh.ghostty.service"
  done

  logger INFO "Ghostty ${version} installed successfully"
}

build_ghostty() {
  local version="$1"
  local zig_version="$2"
  local image_tag="${IMAGE_PREFIX}:${version}"
  local build_log="${LOG_FILE%.log}_build.log"
  local container_id
  local tmpdir
  local podman_build_args=(
    --build-arg "GHOSTTY_VERSION=${version}"
    --build-arg "ZIG_VERSION=${zig_version}"
    --build-arg "ARCH=${ARCH}"
    --build-arg "INSTALL_DIR=${CONTAINER_OUTPUT_PATH}"
    -f "${DOCKERFILE_PATH}"
    -t "${image_tag}"
    --rm
  )

  logger INFO "Building Ghostty ${version} with Zig ${zig_version} for ${OS_ID}/${ARCH} (this typically takes ~10 minutes)"
  logger INFO "Build output: ${build_log}"

  if ! podman build "${podman_build_args[@]}" "${DOCKERFILE_DIR_PATH}" > "${build_log}" 2>&1; then
    logger WARN "Build failed - last 30 lines:"
    tail -30 "${build_log}" >&2
    logger ERROR "Podman build failed. Full log: ${build_log}"
  fi

  logger INFO "Build complete"
  logger INFO "Extracting build artifacts from container"
  container_id=$(podman create "${image_tag}")
  tmpdir=$(mktemp -d)
  podman cp "${container_id}:${CONTAINER_OUTPUT_PATH}/." "${tmpdir}/"
  podman rm -f "${container_id}" >/dev/null

  echo "${tmpdir}"
}

get_zig_version() {
  local ghostty_version="$1"
  local zig_version
  
  logger INFO "Detecting required Zig version from build.zig.zon"
  zig_version=$(curl -fsSL \
    "https://raw.githubusercontent.com/${GHOSTTY_REPO}/v${ghostty_version}/build.zig.zon" \
    | grep -oP '\.minimum_zig_version\s*=\s*"\K[^"]+')

  if [[ -z "${zig_version}" ]]; then
    logger ERROR "Could not detect Zig version for Ghostty ${ghostty_version}"
  fi

  if [[ ! "${zig_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    logger ERROR "Unexpected Zig version format: '${zig_version}'"
  fi

  logger INFO "Ghostty ${ghostty_version} requires Zig ${zig_version}"
  echo "${zig_version}"
}

get_latest_version() {
  local latest_version
  
  logger INFO "Fetching latest Ghostty release version"
  latest_version=$(git ls-remote -q --refs --sort="v:refname" --tags \
    "https://github.com/${GHOSTTY_REPO}.git" \
    | awk '{print $2}' \
    | sed 's|^refs/tags/||' \
    | grep -v '^tip$' \
    | sed 's/^v//' \
    | tail -1)

  if [[ -z "${latest_version}" ]]; then
    logger ERROR "Could not determine latest Ghostty version"
  fi

  if [[ ! "${latest_version}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    logger ERROR "Unexpected version format from GitHub: '${latest_version}'"
  fi

  logger INFO "Latest Ghostty version: ${latest_version}"
  echo "${latest_version}"
}

do_uninstall() {
  logger WARN "Uninstalling all Ghostty versions"

  find "${INSTALL_BIN_PATH}" -mindepth 1 -name "*ghostty*" \
    ! -name "ghostty-installer.sh" \
    -exec rm -rf {} + 2>/dev/null

  find "${INSTALL_SHARE_PATH}" -mindepth 1 -name "*ghostty*" \
    ! -path "${DOCKERFILE_DIR_PATH%/*}" \
    ! -path "${DOCKERFILE_DIR_PATH}" ! -path "${DOCKERFILE_DIR_PATH}/*" \
    -exec rm -rf {} + 2>/dev/null

  find "${INSTALL_SHARE_PATH}" -name "com.mitchellh.ghostty.*" \
    -exec rm -f {} + 2>/dev/null

  local images
  images=$(podman images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep '^ghostty-' || true)
  
  if [[ -n "$images" ]]; then
    echo "$images" | xargs -r podman rmi -f >/dev/null 2>&1 || true
  fi

  logger INFO "Ghostty uninstalled"
}

do_downgrade() {
  local installed_versions=()
  local num_installed_versions
  local current_version
  local previous
  local prev_name
  local current_name

  local versions_output
  versions_output=$(get_installed_versions)
  mapfile -t installed_versions <<< "${versions_output}"

  num_installed_versions=${#installed_versions[@]}

  if (( num_installed_versions < 2 )); then
    logger ERROR "No previous version available for downgrade (only ${num_installed_versions} version(s) installed)"
  fi

  current_version=$(get_current_version)

  if [[ -z "${current_version}" ]]; then
    logger ERROR "No current version detected (is Ghostty installed?)"
  fi

  previous=$(printf '%s\n' "${installed_versions[@]}" | grep -v "^${current_version}$" | sort -rV | head -1)

  if [[ -z "${previous}" ]]; then
    logger ERROR "Could not determine previous version"
  fi

  prev_name=$(binary_name "${previous}")
  current_name=$(binary_name "${current_version}")
  logger INFO "Downgrading: ${current_name} -> ${prev_name}"
  ln -sf "${prev_name}" "${INSTALL_BIN_PATH}/ghostty"
  logger INFO "Ghostty now points to ${previous}"
}

do_install() {
  local target_version="${TARGET_VERSION}"
  local current_version
  local bin_name
  local zig_version
  local artifacts_dir
  local image_tag

  if [[ -z "${target_version}" ]]; then
    target_version=$(get_latest_version)
  fi

  image_tag="${IMAGE_PREFIX}:${target_version}"
  current_version=$(get_current_version)

  if [[ "${current_version}" == "${target_version}" ]]; then
    logger INFO "Ghostty ${target_version} is already installed and current"
    return
  fi

  bin_name=$(binary_name "${target_version}")

  if [[ -x "${INSTALL_BIN_PATH}/${bin_name}" ]]; then
    logger INFO "Ghostty ${target_version} already built, updating symlink"
    ln -sf "${bin_name}" "${INSTALL_BIN_PATH}/ghostty"
    logger INFO "Symlink: ghostty -> ${bin_name}"
    return
  fi

  zig_version=$(get_zig_version "${target_version}")
  artifacts_dir=$(build_ghostty "${target_version}" "${zig_version}")

  install_artifacts "${target_version}" "${artifacts_dir}"
  prune_old_versions
  logger INFO "Removing build image: ${image_tag}"
  podman rmi -f "${image_tag}" 2>/dev/null || true
}

detect_os() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck source=/etc/os-release
    . /etc/os-release
    OS_ID="${ID}"

    case "${OS_ID}" in
      fedora)
        DOCKERFILE_PATH="${DOCKERFILE_DIR_PATH}/fedora.Dockerfile"
        IMAGE_PREFIX="ghostty-fedora"
        ;;
      debian | ubuntu)
        DOCKERFILE_PATH="${DOCKERFILE_DIR_PATH}/debian.Dockerfile"
        IMAGE_PREFIX="ghostty-debian"
        ;;
      *)
        logger ERROR "Unsupported OS: ${OS_ID}. Supported: fedora, debian, ubuntu"
        ;;
    esac
  else
    logger ERROR "Cannot detect OS: /etc/os-release not found"
  fi

  if [[ ! -f "${DOCKERFILE_PATH}" ]]; then
    logger ERROR "Dockerfile not found: ${DOCKERFILE_PATH}"
  fi

  logger INFO "Detected OS: ${OS_ID} (${ARCH}) - using ${DOCKERFILE_PATH##*/}"
}

check_dependencies() {
  local deps=("podman" "git" "curl")
  
  for dep in "${deps[@]}"; do
    if ! command -v "${dep}" &>/dev/null; then
      logger ERROR "'${dep}' is required but not installed"
    fi
  done
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
      usage
      ;;
    --version)
      TARGET_VERSION="${2:-}"
      if [[ -z "${TARGET_VERSION}" ]]; then
        logger ERROR "--version requires a value"
      fi
      if [[ ! "${TARGET_VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        logger ERROR "Invalid version format '${TARGET_VERSION}' - expected X.Y.Z (e.g. 1.3.0)"
      fi
      shift 2
      ;;
    --downgrade)
      ACTION="downgrade"
      shift
      ;;
    --uninstall)
      ACTION="uninstall"
      shift
      ;;
    *)
      logger ERROR "Unknown argument: $1"
      ;;
    esac
  done
}

main() {
  parse_args "$@"
  check_dependencies
  detect_os

  case "${ACTION}" in
    install)   do_install ;;
    downgrade) do_downgrade ;;
    uninstall) do_uninstall ;;
    *)         logger ERROR "Unknown action: ${ACTION}" ;;
  esac

  logger INFO "Log saved to ${LOG_FILE}"
}

main "$@"
