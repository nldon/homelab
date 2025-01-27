locals {
  credentials          = jsondecode(file("~/.config/credentials/packer.json"))
  proxmox_username     = local.credentials.proxmox_username
  proxmox_password     = local.credentials.proxmox_password
  proxmox_api_username = local.credentials.proxmox_api_username
  proxmox_api_token    = local.credentials.proxmox_api_token
}

variable "proxmox_url" {
  type        = string
  description = "The URL of the Proxmox server"
  default     = "https://10.3.2.104:8006/api2/json"
}

variable "iso_file" {
  type        = string
  description = "The path to the ISO file"
  default     = "nfs-storage:iso/ubuntu-24.04.1-live-server-amd64.iso"
}

variable "ssh_private_key_file" {
  type        = string
  description = "The path to the SSH private key file"
  default     = "/home/nld/.ssh/packer_ed25519"
}

variable "sops_age_key" {
  type        = string
  description = "SOPS_AGE_KEY environment variable to decrypt secrets"
}

