locals {
  credentials           = jsondecode(file("/opt/credentials/packer.json"))
  proxmox_api_username  = local.credentials.proxmox_api_username
  proxmox_api_token     = local.credentials.proxmox_api_token
  proxmox_root_password = local.credentials.proxmox_root_password
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
