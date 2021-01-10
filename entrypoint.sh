#!/usr/bin/env bash

set -Eeuo pipefail

# Config file for markdown-link-check
export CONFIG_FILE=${INPUT_CONFIG_FILE:-}

# Debug variable - enable by setting non-empty value
export DEBUG=${INPUT_DEBUG:-}

# Exclude files or directories which should not be checked
export EXCLUDE=${INPUT_EXCLUDE:-}

# Command line parameters for fd ("exclude" and "search_paths" parameters are ignored if this is set)
export FD_CMD_PARAMS="${INPUT_FD_CMD_PARAMS:- . -0 --extension md --type f --hidden --no-ignore}"

# Debug variable - enable by setting non-empty value
export QUIET=${INPUT_QUIET:-}

# Files or paths which will be checked
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

IFS=' ' read -r -a FD_CMD_PARAMS <<< "$FD_CMD_PARAMS"

# Change FD_CMD_PARAMS variable only if INPUT_FD_CMD_PARAMS was not defined or is empty
if [ -z "${INPUT_FD_CMD_PARAMS+x}" ] || [ -z "${INPUT_FD_CMD_PARAMS}" ]; then
  if [ -n "${EXCLUDE}" ]; then
    for EXCLUDED in ${EXCLUDE}; do
      FD_CMD_PARAMS+=("--exclude" "${EXCLUDED}")
    done
  fi

  if [ -n "${SEARCH_PATHS}" ]; then
    for SEARCH_PATH in ${SEARCH_PATHS}; do
      FD_CMD_PARAMS+=("${SEARCH_PATH}")
    done
  fi
fi

print_info "Running: fd ${FD_CMD_PARAMS[*]}"

while IFS= read -r -d '' FILE; do
  print_info "Running: markdown-link-check ${MARKDOWN_LINK_CHECK_CMD_PARAMS[*]} ${FILE}"
  markdown-link-check "${MARKDOWN_LINK_CHECK_CMD_PARAMS[@]}" "${FILE}"
  echo -e '\n'
done < <(fd "${FD_CMD_PARAMS[@]}")

print_info "Checks completed..."
