#!/usr/bin/env bash

readonly SCRIPT_NAME="$(basename "$0")"
readonly PACKER_TEMPLATE_FILE="$(dirname "$0")/files/wazuh_ossec.json"

function log {
  local readonly level="$1"
  local readonly message="$2"
  local readonly timestamp=$(date +"%Y-%m-%d %H:%M:%S")
  >&2 echo -e "${timestamp} [${level}] [$SCRIPT_NAME] ${message}"
}

function log_info {
  local readonly message="$1"
  log "INFO" "$message"
}

function log_warn {
  local readonly message="$1"
  log "WARN" "$message"
}

function log_error {
  local readonly message="$1"
  log "ERROR" "$message"
}

function assert_is_installed() {
  local readonly name="$1"

  if [[ ! $(command -v ${name}) ]]; then
    log_error "The binary '$name' is required by this script but is not installed or in the system's PATH."
    exit 1
  fi
}

assert_is_installed "packer"
assert_is_installed "terraform"

log_info "Building AMI with packer..."
log_info "Using AWS profile $AWS_PROFILE"

packer build "${PACKER_TEMPLATE_FILE}"
if [ $? -ne 0 ]; then
  log_error "Error: Packer build failed"
  exit 1
fi

exit 0
