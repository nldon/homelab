locals {
  credentials          = jsondecode(file("/opt/credentials/packer.json"))
  proxmox_api_username = local.credentials.proxmox_api_username
  proxmox_api_token    = local.credentials.proxmox_api_token
}