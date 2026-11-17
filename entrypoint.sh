#!/usr/bin/env bash

set -Eeuo pipefail

# Config file for markdown-link-check
export CONFIG_FILE=${INPUT_CONFIG_FILE:-}

# Debug mode - enable by setting to "true"
export DEBUG=${INPUT_DEBUG:-}

# Exclude files or directories that should not be checked
export EXCLUDE=${INPUT_EXCLUDE:-}

# Replaces the default fd options ("exclude" and "search_paths" are still added, keep "-0")
export FD_CMD_PARAMS="${INPUT_FD_CMD_PARAMS:- . -0 --extension md --type f --hidden}"

# Quiet mode - enable by setting to "true"
export QUIET=${INPUT_QUIET:-}

# Directories that will be searched for Markdown files
export SEARCH_PATHS=${INPUT_SEARCH_PATHS:-}

# Verbose mode - enable by setting to "true"
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

[ "${DEBUG}" = "true" ] && set -x

declare -a MARKDOWN_LINK_CHECK_CMD_PARAMS

if [ -n "${CONFIG_FILE}" ]; then
  MARKDOWN_LINK_CHECK_CMD_PARAMS+=("--config" "${CONFIG_FILE}")
elif [ -s .mlc_config.json ]; then
  MARKDOWN_LINK_CHECK_CMD_PARAMS+=("--config" ".mlc_config.json")
fi

if [ "${QUIET}" = "true" ]; then
  MARKDOWN_LINK_CHECK_CMD_PARAMS+=("--quiet")
fi

if [ "${VERBOSE}" = "true" ] || [ "${DEBUG}" = "true" ]; then
  MARKDOWN_LINK_CHECK_CMD_PARAMS+=("--verbose")
fi

print_info "Start checking..."

if [ -n "${EXCLUDE}" ]; then
  print_info "Files/dirs that will be excluded:\n${EXCLUDE}"
fi

echo "${EXCLUDE}" > /tmp/fd_exclude_file

# shellcheck disable=SC2086
fd ${FD_CMD_PARAMS} --ignore-file /tmp/fd_exclude_file ${SEARCH_PATHS} > /tmp/fd_files
mapfile -d '' MARKDOWN_FILE_ARRAY < /tmp/fd_files
# Without file names markdown-link-check reads stdin and passes with 0 links checked
if [ "${#MARKDOWN_FILE_ARRAY[@]}" -eq 0 ]; then
  print_error "No Markdown files found"
  exit 1
fi

print_info "Running: markdown-link-check ${MARKDOWN_LINK_CHECK_CMD_PARAMS[*]} ${MARKDOWN_FILE_ARRAY[*]}"
markdown-link-check "${MARKDOWN_LINK_CHECK_CMD_PARAMS[@]}" "${MARKDOWN_FILE_ARRAY[@]}"

print_info "Checks completed..."
