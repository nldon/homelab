variable "vm_name" {
  description = "The name of the VM"
  type        = string
  default     = "ubuntu-workstation"
}

variable "proxmox_host" {
  description = "The Proxmox host to deploy the VM on"
  type        = string
  default     = "10.3.2.43"
}

variable "template_name" {
  description = "The name of the template to clone"
  type        = string
  default     = "ubuntu-24-04"
}
