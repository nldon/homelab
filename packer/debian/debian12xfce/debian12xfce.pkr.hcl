packer {
  required_plugins {
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "debian_12_xfce" {
  # Authentication
  proxmox_url              = var.proxmox_url
  username                 = local.proxmox_api_username
  token                    = local.proxmox_api_token
  insecure_skip_tls_verify = true

  # Communicator settings
  ssh_username         = "root"
  ssh_password         = "packer"
  ssh_timeout          = "60m"

  # Proxmox VM settings
  node                 = "node1"
  vm_id                = "1001"
  vm_name              = "debian-12-xfce"
  template_name        = "debian-12-xfce"
  template_description = "Debian 12 - Bookworm - XFCE Desktop"
  qemu_agent           = true

  # VM Resources
  cpu_type        = "host"
  sockets         = "1"
  cores           = "2"
  memory          = "2048"
  os              = "l26"
  scsi_controller = "virtio-scsi-pci"

  # Cloud-init settings
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"
  http_directory          = "./"

  # Boot settings
  boot      = "c"
  boot_wait = "5s"
  boot_iso {
    type             = "scsi"
    iso_file         = "local:iso/debian-live-12.8.0-amd64-xfce.iso"
    iso_storage_pool = "local"
    unmount          = true
  }
  boot_command = [
    "<esc><wait>",
    "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/data/preseed.cfg",
    "<enter>"
  ]

  # Display settings
  vga {
    type   = "virtio"
    memory = 512
  }

  # Disk settings
  disks {
    disk_size    = "30G"
    format       = "raw"
    storage_pool = "local-lvm"
    type         = "virtio"
  }

  # Network settings
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

}

build {
  name = "debian-12-xfce"
  sources = [
    "proxmox-iso.debian_12_xfce"
  ]

  provisioner "file" {
    destination      = "/etc/cloud/cloud.cfg"
    source = "./data/cloud.cfg"
  }
}