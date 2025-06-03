#!/usr/bin/env bash

set -Eeuo pipefail

# Config file for markdown-link-check
export CONFIG_FILE=${INPUT_CONFIG_FILE:-}

# Debug variable - enable by setting non-empty value
export DEBUG=${INPUT_DEBUG:-}

# Exclude files or directories that should not be checked
export EXCLUDE=${INPUT_EXCLUDE:-}

# Command-line parameters for fd (the "exclude" and "search_paths" parameters are ignored if this is set)
export FD_CMD_PARAMS="${INPUT_FD_CMD_PARAMS:- . -0 --extension md --type f --hidden --no-ignore}"

# Debug variable - enable by setting non-empty value
export QUIET=${INPUT_QUIET:-}

# Files or paths that will be checked
export SEARCH_PATHS=${INPUT_SEARCH_PATHS:-}

# Debug variable - enable by setting non-empty value
export VERBOSE=${INPUT_VERBOSE:-}

print_error() {
  echo -e "\e[31m*** ERROR: ${1}\e[m"
}

print_info() {
  echo -e "\e[36m*** ${1}\e[m"
}

error_trap() {
  print_error "Something went wrong - see the errors above..."
  exit 1
}

################
# Main
################

trap error_trap ERR

[ -n "${DEBUG}" ] && set -x

declare -a MARKDOWN_LINK_CHECK_CMD_PARAMS

if [ -n "${CONFIG_FILE}" ]; then
  MARKDOWN_LINK_CHECK_CMD_PARAMS+=("--config" "${CONFIG_FILE}")
elif [ -s .mlc_config.json ]; then
  MARKDOWN_LINK_CHECK_CMD_PARAMS+=("--config" ".mlc_config.json")
fi

if [ -n "${QUIET}" ]; then
  MARKDOWN_LINK_CHECK_CMD_PARAMS+=("--quiet")
fi

if [ -n "${VERBOSE}" ] || [ -n "${DEBUG}" ]; then
  MARKDOWN_LINK_CHECK_CMD_PARAMS+=("--verbose")
fi

print_info "Start checking..."

if [ -n "${EXCLUDE}" ]; then
  print_info "Files/dirs that will be excluded:\n${EXCLUDE}"
fi

echo "${EXCLUDE}" > /tmp/fd_exclude_file

# shellcheck disable=SC2086
mapfile -d '' MARKDOWN_FILE_ARRAY < <(fd ${FD_CMD_PARAMS} --ignore-file /tmp/fd_exclude_file ${SEARCH_PATHS})

print_info "Running: markdown-link-check ${MARKDOWN_LINK_CHECK_CMD_PARAMS[*]} ${MARKDOWN_FILE_ARRAY[*]}"
markdown-link-check "${MARKDOWN_LINK_CHECK_CMD_PARAMS[@]}" "${MARKDOWN_FILE_ARRAY[@]}"

print_info "Checks completed..."
