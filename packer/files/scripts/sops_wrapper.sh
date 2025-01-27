#!/bin/bash

SOPS_FILE="~/.config/credentials/ansible.yaml"

sops decrypt "$SOPS_FILE" | ansible-playbook --vault-password-file=/bin/cat "$@"
