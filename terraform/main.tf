terraform {
  required_version = ">= 1.1.0"
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

locals {
  credentials          = jsondecode(file("/opt/credentials/packer.json"))
  proxmox_api_username = local.credentials.proxmox_api_username
  proxmox_api_token    = local.credentials.proxmox_api_token
}

provider "proxmox" {
  pm_api_url          = "https://10.3.2.43:8006/api2/json"
  pm_tls_insecure     = true
  pm_api_token_id     = local.proxmox_api_username
  pm_api_token_secret = local.proxmox_api_token
}

data "template_file" "ubuntu_workstation_cloud_init" {
  template = file("${path.module}/files/ubuntu_workstation.yml")

  vars = {
    ssh_key  = file("~/.ssh/terraform_ed25519.pub")
    hostname = var.vm_name
  }
}

resource "local_file" "ubuntu_workstation_cloud_init" {
  content  = data.template_file.ubuntu_workstation_cloud_init.rendered
  filename = "${path.module}/files/ubuntu_workstation.cfg"
}

resource "null_resource" "ubuntu_workstation_cloud_init" {
  connection {
    type        = "ssh"
    host        = var.proxmox_host
    user        = "terraform"
    private_key = file("~/.ssh/terraform_ed25519")
  }

  provisioner "file" {
    source      = local_file.ubuntu_workstation_cloud_init.filename
    destination = "/tmp/ubuntu_workstation.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/ubuntu_workstation.yml /var/lib/vz/snippets/ubuntu_workstation.yml",
      "sudo chown root:root /var/lib/vz/snippets/ubuntu_workstation.yml"
    ]
  }
}

resource "proxmox_vm_qemu" "ubuntu_workstation" {
  depends_on = [null_resource.ubuntu_workstation_cloud_init]

  name        = var.vm_name
  target_node = "node1"
  desc        = "Ubuntu Workstation"
  clone       = var.template_name
  agent       = 1
  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  cpu_type    = "host"
  memory      = 2048
  scsihw      = "virtio-scsi-pci"
  full_clone  = false
  qemu_os     = "l26"
  ipconfig0   = "ip=dhcp"
  skip_ipv6   = true
  tags        = "ubuntu,workstation"

  # Cloud-init settings
  cicustom = "user=local:snippets/ubuntu_workstation.yml"

  disks {
    ide {
      ide3 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    virtio {
      virtio0 {
        disk {
          size    = "20G"
          storage = "local-lvm"
          cache   = "none"
          format  = "raw"
        }
      }
    }
  }

  vga {
    type   = "virtio"
    memory = 512
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  boot = "order=virtio0"
}