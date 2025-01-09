locals {
  credentials          = jsondecode(file("/opt/credentials/packer.json"))
  proxmox_api_username = local.credentials.proxmox_api_username
  proxmox_api_token    = local.credentials.proxmox_api_token
}

variable "proxmox_url" {
  type        = string
  description = "The URL of the Proxmox server"
  default     = "https://10.3.2.43:8006/api2/json"
}

variable "iso_url" {
  type        = string
  description = "The URL of the ISO to use for the VM"
  default     = "https://releases.ubuntu.com/24.04.1/ubuntu-24.04.1-live-server-amd64.iso"
}