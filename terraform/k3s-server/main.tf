data "template_file" "k3s_server_cloud_init" {
  template = file("${path.module}/files/k3s_server.yml")

  vars = {
    ssh_key  = file("~/.ssh/terraform_ed25519.pub")
    hostname = var.vm_name
  }
}

resource "local_file" "k3s_server_cloud_init" {
  content  = data.template_file.k3s_server_cloud_init.rendered
  filename = "${path.module}/files/k3s_server.cfg"
}

resource "null_resource" "k3s_server_cloud_init" {
  connection {
    type        = "ssh"
    host        = var.proxmox_host
    user        = "terraform"
    private_key = file("~/.ssh/terraform_ed25519")
  }

  provisioner "file" {
    source      = local_file.k3s_server_cloud_init.filename
    destination = "/tmp/k3s_server.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/k3s_server.yml /var/lib/vz/snippets/k3s_server.yml",
      "sudo chown root:root /var/lib/vz/snippets/k3s_server.yml"
    ]
  }
}

resource "proxmox_vm_qemu" "k3s_server" {
  name        = var.vm_name
  target_node = "node1"
  desc        = "K3s Server - Ubuntu 24.04"
  clone       = var.template_name
  agent       = 1
  os_type     = "cloud-init"
  cores       = 2
  sockets     = 1
  cpu_type    = "host"
  memory      = 4096
  scsihw      = "virtio-scsi-pci"
  full_clone  = false
  qemu_os     = "l26"
  ipconfig0   = "ip=dhcp"
  skip_ipv6   = true
  tags        = "kubernetes"

  cicustom = "user=nfs-storage:snippets/k3s_server.yml"

  disks {
    ide {
      ide3 {
        cloudinit {
          storage = "nfs-storage"
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