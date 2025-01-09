packer {
  required_plugins {
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "ubuntu_server_2404" {
  proxmox_url              = var.proxmox_url
  username                 = local.proxmox_api_username
  token                    = local.proxmox_api_token
  insecure_skip_tls_verify = true
  node                     = "node1"
  vm_id                    = "1001"
  vm_name                  = "ubuntu-server-2404"
  template_description     = "Ubuntu Server Noble Numbat 24.04"
  template_name            = "packer-ubuntu-server-2404"
  qemu_agent               = true
  scsi_controller          = "virtio-scsi-pci"
  cores                    = "2"
  memory                   = "3072"
  cloud_init               = true
  cloud_init_storage_pool  = "local-lvm"
  boot                     = "c"
  boot_wait                = "5s"
  http_directory           = "./http"
  ssh_username             = "ubuntu"
  ssh_password             = "ubuntu"
  ssh_timeout              = "30m"

  boot_iso {
    type = "scsi"
    iso_url = var.iso_url
    iso_storage_pool = "local"
    iso_checksum = "file:http://releases.ubuntu.com/24.04/SHA256SUMS"
    unmount = true
  }

  disks {
    disk_size    = "20G"
    format       = "raw"
    storage_pool = "local-lvm"
    type         = "virtio"
  }

  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
  }

  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
}

build {
  name = "ubuntu_server_2404"
  sources = [
    "proxmox-iso.ubuntu_server_2404"
  ]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -f /etc/netplan/00-installer-config.yaml",
      "sudo sync"
    ]
  }

  provisioner "file" {
    source      = "files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  provisioner "shell" {
    inline = [
      "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg"
    ]
  }
}
