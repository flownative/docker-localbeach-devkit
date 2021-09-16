#!/bin/bash
# shellcheck disable=SC1090

# =======================================================================================
# SYNC: Inotify-based file watcher and synchronization script
# =======================================================================================

# Load helper lib

. "${FLOWNATIVE_LIB_PATH}/log.sh"

# ---------------------------------------------------------------------------------------
# sync_loop() - The actual sync loop
#
# @return void
#
sync_loop() {
    local exclude

    debug "Sync: Starting sync loop for process #$$"

    exclude="\.Docker\/|\.LocalBeach\/|\.DS_Store\/|\.bundle\/|\.git\/|\.svn\/|\.idea\/|\.sass-cache\/|\/bundle\/|\/node_modules\/|\/tmp\/|\/Data\/|\/Web\/|___jb_"
    if [ -z "${SYNC_EXTRA_EXCLUDE}" ]; then
        exclude="(${exclude})"
    else
        exclude="(${exclude}|${SYNC_EXTRA_EXCLUDE})"
    fi

    debug "Sync: Exlcuding ${exclude}"

    inotifywait -m -q -r -e CREATE -e DELETE -e MODIFY -e MOVED_FROM -e MOVED_TO --exclude "${exclude}" --format '%e %w%f' /application-on-host | while read EVENT FILE; do
        case ${EVENT} in
        'DELETE' | 'MOVED_FROM')
            COMMAND="rm -f '${FILE/\/application-on-host\//\/application\/}'"
            ;;
        'DELETE,ISDIR' | 'MOVED_FROM,ISDIR')
            COMMAND="rm -rf '${FILE/\/application-on-host\//\/application\/}'"
            ;;
        'CREATE,ISDIR' | 'MOVED_TO,ISDIR' | 'MODIFY,ISDIR')
            COMMAND="[ -d "${FILE}" ] && cp -rpLf '${FILE}' '$(dirname ${FILE/\/application-on-host\//\/application\/})'"
            ;;
        'CREATE' | 'MOVED_TO' | 'MODIFY')
            COMMAND="[ -f "${FILE}" ] && cp -pLf '${FILE}' '${FILE/\/application-on-host\//\/application\/}'"
            ;;
        *)
            COMMAND="warn "Unhandled event ${EVENT}""
            ;;
        esac

        debug "Sync: ${EVENT} ${FILE}"
        debug "Sync: -> ${COMMAND}"

        eval "${COMMAND}"
    done
}

sync_loop
