locals {
  credentials          = jsondecode(file("/opt/credentials/terraform.json"))
  proxmox_api_username = local.credentials.proxmox_api_username
  proxmox_api_secret   = local.credentials.proxmox_api_secret
}