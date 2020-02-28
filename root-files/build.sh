#!/bin/bash
# shellcheck disable=SC1090
# shellcheck disable=SC2086
# shellcheck disable=SC2046

# Load helper libraries

. "${FLOWNATIVE_LIB_PATH}/log.sh"
. "${FLOWNATIVE_LIB_PATH}/packages.sh"

set -o errexit
set -o nounset
set -o pipefail

# ---------------------------------------------------------------------------------------
# build_create_directories() - Create directories and set access rights accordingly
#
# @global SYNC_BASE_PATH
# @return void
#
build_create_directories() {
    info "Creating directories ..."

    for path in "${SYNC_BASE_PATH}" "${SYNC_BIN_PATH}" "${SYNC_TMP_PATH}" "${SYNC_APPLICATION_PATH}" "${SYNC_APPLICATION_ON_HOST_PATH}"; do
        mkdir -p "${path}"
        chown -R 1000:1000 "${path}"
        chmod -R 777 "${path}"
    done
}

# ---------------------------------------------------------------------------------------
# build_get_packages() - Returns a list of packages to install
#
# @global SYNC_BASE_PATH
# @return List of packages
#
build_get_packages() {
    local packages="
        inotify-tools
        rsync
        gosu
   "
    echo $packages
}

# ---------------------------------------------------------------------------------------
# Main routine

case $1 in
    init)
        build_create_directories
        ;;
    build)
        packages_install $(build_get_packages) 1>$(debug_device)
        packages_remove_docs_and_caches 1>$(debug_device)
        ;;
esac
