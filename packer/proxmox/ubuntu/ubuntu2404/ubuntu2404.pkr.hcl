packer {
  required_plugins {
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "proxmox-iso" "k3s-server-ubuntu-24-04" {
  # Authentication
  proxmox_url              = var.proxmox_url
  username                 = local.proxmox_username
  password                 = local.proxmox_password
  insecure_skip_tls_verify = true

  # Communicator settings
  ssh_username         = "packer"
  ssh_private_key_file = var.ssh_private_key_file
  ssh_timeout          = "30m"

  # Proxmox VM settings
  node                 = "node1"
  vm_id                = "1001"
  vm_name              = "k3s-server-ubuntu-24-04"
  template_name        = "k3s-server-ubuntu-24-04"
  template_description = "K3s Server running on Ubuntu 24.04"
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
  cloud_init_storage_pool = "nfs-storage"
  http_directory          = "${path.root}/data"

  # Boot settings
  boot      = "c"
  boot_wait = "5s"
  boot_iso {
    type             = "scsi"
    iso_file         = var.iso_file
    iso_storage_pool = "local"
    unmount          = true
  }
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]

  # Display settings
  vga {
    type = "virtio"
  }

  serials = [
    "socket"
  ]

  # Disk settings
  disks {
    disk_size    = "20G"
    format       = "raw"
    storage_pool = "nfs-storage"
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
  name = "k3s-server-ubuntu-24-04"
  sources = [
    "source.proxmox-iso.k3s-server-ubuntu-24-04"
  ]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 5; done",
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo rm -rf /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "sudo rm -rf /etc/netplan/00-installer-config.yaml",
      "sudo sync"
    ]
  }

  # Cant move directly to root owned locations with this provisioner
  provisioner "file" {
    source      = "${path.root}/files/99-datasource.cfg"
    destination = "/tmp/99-datasource.cfg"
  }

  # Sudo elevate to move config file to root location
  provisioner "shell" {
    inline = [
      "sudo mv /tmp/99-datasource.cfg /etc/cloud/cloud.cfg.d/99-datasource.cfg",
      "sudo chmod 0644 /etc/cloud/cloud.cfg.d/99-datasource.cfg"
    ]
  }

  provisioner "ansible" {
    ansible_env_vars = [ "SOPS_AGE_KEY=${var.sops_age_key}" ]
    command = "${path.root}/../../../files/scripts/sops_wrapper.sh"
    playbook_file = "${path.root}/../../../../ansible/k3_server.yml"
    extra_arguments = [ "-vv" ]
  }
}
