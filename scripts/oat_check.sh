#!/usr/bin/env bash
# Copyright (c) 2026 Southeast University.
# This program is free software, you can redistribute it and/or modify it under the terms and conditions of
# CANN Open Software License Agreement Version 2.0 (the "License").
# Please refer to the License for details. You may not use this file except in compliance with the License.
# THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT, MERCHANTABILITY, OR FITNESS FOR A PARTICULAR PURPOSE.
# See LICENSE in the root of the software repository for the full text of the License.

set -euo pipefail

readonly PROJECT_NAME="its-matrix-computation"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPOSITORY_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly OAT_CONFIG="${REPOSITORY_ROOT}/OAT.xml"
readonly REPORT_DIR="${REPOSITORY_ROOT}/oat_reports"

log() {
    printf '[OAT] %s\n' "$*"
}

fail() {
    printf '[OAT] ERROR: %s\n' "$*" >&2
    exit 1
}

find_python() {
    if command -v python3 >/dev/null 2>&1; then
        printf '%s\n' "python3"
        return
    fi

    if command -v python >/dev/null 2>&1; then
        printf '%s\n' "python"
        return
    fi

    fail "Python 3 was not found."
}

check_environment() {
    local python_cmd="$1"

    "${python_cmd}" -c "import oat" >/dev/null 2>&1 || fail         "oat-py is not installed. Run: ${python_cmd} -m pip install 'oat-py>=1.0.0'"
}

to_relative_path() {
    local input_path="$1"

    input_path="${input_path//\\//}"
    input_path="${input_path#./}"

    case "${input_path}" in
        "${REPOSITORY_ROOT}/"*)
            input_path="${input_path#"${REPOSITORY_ROOT}/"}"
            ;;
    esac

    printf '%s\n' "${input_path}"
}

collect_files() {
    local input_path
    local relative_path

    for input_path in "$@"; do
        relative_path="$(to_relative_path "${input_path}")"
        [[ -n "${relative_path}" ]] || continue
        [[ -f "${REPOSITORY_ROOT}/${relative_path}" ]] || continue

        if [[ "${relative_path}" == *"|"* ]]; then
            fail "OAT incremental mode does not support '|' in file paths: ${relative_path}"
        fi

        printf '%s\0' "${relative_path}"
    done
}

run_full_scan() {
    local python_cmd="$1"

    log "Running a full OAT scan for ${PROJECT_NAME}..."
    "${python_cmd}" -m oat         -mode s         -s "${REPOSITORY_ROOT}/"         -r "${REPORT_DIR}/"         -n "${PROJECT_NAME}"         -w 0         -k
}

run_incremental_scan() {
    local python_cmd="$1"
    shift

    local -a files=()
    local file_path

    while IFS= read -r -d '' file_path; do
        files+=("${file_path}")
    done < <(collect_files "$@")

    if [[ "${#files[@]}" -eq 0 ]]; then
        log "No existing files were supplied; no incremental scan is required."
        return
    fi

    local file_list
    file_list="$(IFS='|'; printf '%s' "${files[*]}")"

    log "Running an incremental OAT scan for ${#files[@]} file(s)..."
    "${python_cmd}" -m oat         -mode s         -s "${REPOSITORY_ROOT}/"         -r "${REPORT_DIR}/"         -n "${PROJECT_NAME}"         -w 1         -f "${file_list}"         -k
}

main() {
    [[ -f "${OAT_CONFIG}" ]] || fail         "OAT.xml was not found in the repository root: ${OAT_CONFIG}"

    local python_cmd
    python_cmd="$(find_python)"
    check_environment "${python_cmd}"

    rm -rf "${REPORT_DIR}"
    mkdir -p "${REPORT_DIR}"

    if [[ "${1:-}" == "--all" || "$#" -eq 0 ]]; then
        run_full_scan "${python_cmd}"
    else
        run_incremental_scan "${python_cmd}" "$@"
    fi

    log "OAT check completed successfully."
    log "Reports are available in: ${REPORT_DIR}"
}

main "$@"
