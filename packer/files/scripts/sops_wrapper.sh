#!/bin/bash

SCRIPT_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )"

ANSIBLE_CREDENTIALS="$SCRIPT_DIR/../../../ansible/credentials/credentials.yml"

sops decrypt --extract '["vault_password"]' "$ANSIBLE_CREDENTIALS" | ansible-playbook --vault-password-file=/bin/cat "$@"
