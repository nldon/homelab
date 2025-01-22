variable "vm_name" {
  description = "The name of the VM"
  type        = string
  default     = "k3s-server"
}

variable "proxmox_host" {
  description = "The Proxmox host to connect to"
  type        = string
  default     = "10.3.2.104"
}

variable "template_name" {
  description = "The name of the template to clone"
  type        = string
  default     = "ubuntu-24-04"
}