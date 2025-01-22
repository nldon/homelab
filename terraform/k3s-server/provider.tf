provider "proxmox" {
  pm_api_url          = "https://10.3.2.104:8006/api2/json"
  pm_tls_insecure     = true
  pm_api_token_id     = local.proxmox_api_username
  pm_api_token_secret = local.proxmox_api_token
}