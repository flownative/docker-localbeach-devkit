#!/bin/bash
# shellcheck disable=SC1090

set -o errexit
set -o nounset
set -o pipefail

# Load lib
. "${FLOWNATIVE_LIB_PATH}/sync.sh"

eval "$(sync_env)"

if [[ "$*" = *"run"* ]]; then
    sync_initialize
    sync_start

    wait "$(sync_get_pid)"
    # This line will never be reached
else
    "$@"
fi
