#!/bin/bash
# shellcheck disable=SC1090

# =======================================================================================
# LIBRARY: SYNC
# =======================================================================================

# Load helper lib

. "${FLOWNATIVE_LIB_PATH}/log.sh"
. "${FLOWNATIVE_LIB_PATH}/files.sh"
. "${FLOWNATIVE_LIB_PATH}/validation.sh"
. "${FLOWNATIVE_LIB_PATH}/os.sh"
. "${FLOWNATIVE_LIB_PATH}/process.sh"

# ---------------------------------------------------------------------------------------
# sync_env() - Load global environment variables for configuring file sync
#
# @return "export" statements which can be passed to eval()
#
sync_env() {
    cat <<"EOF"
export SYNC_ENABLE=${SYNC_ENABLE:-false}
export SYNC_BASE_PATH=${SYNC_BASE_PATH}
export SYNC_TMP_PATH=${SYNC_TMP_PATH}
EOF
}

# ---------------------------------------------------------------------------------------
# sync_get_pid() - Return the sync daemon process id
#
# @global SYNC_* The SYNC_ environment variables
# @return Returns the sync process id, if it is running, otherwise 0
#
sync_get_pid() {
    local pid
    pid=$(process_get_pid_from_file "${SYNC_TMP_PATH}/sync.pid")

    if [[ -n "${pid}" ]]; then
        echo "${pid}"
    else
        false
    fi
}

# ---------------------------------------------------------------------------------------
# sync_start() - Start the file sync daemon
#
# @global SYNC_* The SYNC_ environment variables
# @return void
#
sync_start() {
    local pid

    trap 'sync_stop' SIGINT SIGTERM

    info "Sync: Starting ..."
    gosu 1000:1000 "${SYNC_BASE_PATH}/bin/watch.sh" &
    pid="$!"

    echo "${pid}" >"${SYNC_TMP_PATH}/sync.pid"
    touch "${SYNC_APPLICATION_PATH}/.sync.ready"

    info "Sync: Running as process #${pid}"
}

# ---------------------------------------------------------------------------------------
# sync_stop() - Stop the sync process based on the current PID
#
# @global SYNC_* The SYNC_ environment variables
# @return void
#
sync_stop() {
    local pid
    pid=$(sync_get_pid)

    is_process_running "${pid}" || (info "Sync: Could not stop, because the process was not running (detected pid: ${pid})" && return)
    info "Sync: Stopping ..."

    process_stop "${pid}" TERM

    info "Sync: Stopped"
}

# ---------------------------------------------------------------------------------------
# sync_copy() - Copies all files (except excluded) from application on host to application
#
# @global SYNC_* The SYNC_ environment variables
# @return void
# @todo Make excludes configurable
#
sync_copy() {
    info "Sync: Copying files from ${SYNC_APPLICATION_ON_HOST_PATH} to ${SYNC_APPLICATION_PATH} ..."
    rsync -Ca \
        --delete \
        --chown=1000:0 \
        --exclude .Docker/ \
        --exclude .LocalBeach/ \
        --exclude .DS_Store \
        --exclude .bundle/ \
        --exclude .git/ \
        --exclude .svn/ \
        --exclude .idea/ \
        --exclude .sass-cache/ \
        --exclude bundle/ \
        --exclude node_modules/ \
        --exclude tmp/ \
        --exclude /Data/ \
        --exclude /Web/ \
        --include core \
        "${SYNC_APPLICATION_ON_HOST_PATH}/" "${SYNC_APPLICATION_PATH}"
    info "Sync: Finished copying"
}

#---------------------------------------------------------------------------------------
# sync_initialize() - Initialize the sync setup
#
# @global SYNC_* The SYNC_* environment variables
# @return void
#
sync_initialize() {
    info "Sync: Initializing ..."

    if [[ $(id --user) != 0 ]]; then
        error "Sync: Container is not running as root, but a privileged user is required for file sync to work"
        exit 1
    fi

    rm -f "${SYNC_APPLICATION_PATH}/.sync.ready"
    sync_copy

    mkdir -p "${SYNC_APPLICATION_PATH}/Data"
    chown 1000 "${SYNC_APPLICATION_PATH}" "${SYNC_APPLICATION_PATH}/Data"
}
