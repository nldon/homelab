packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }
  }
}

variable "aws_access_key" {
  type        = string
  description = "Pass to Terraform via environment variable PKR_VAR_aws_access_key"
}

variable "aws_secret_key" {
  type        = string
  description = "Pass to Terraform via environment variable PKR_VAR_aws_secret_key"
}

source "amazon-ebs" "ubuntu2404" {
  access_key                  = var.aws_access_key
  secret_key                  = var.aws_secret_key
  region                      = "eu-west-2"
  instance_type               = "t2.micro"
  ssh_username                = "ubuntu"
  ami_name                    = "ubuntu2404-{{timestamp}}"
  associate_public_ip_address = true

  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
    }
    owners      = ["099720109477"]
    most_recent = true
  }

  vpc_filter {
    filters = {
      "tag:Class" : "build",
      "isDefault" : "false"
    }
  }

  subnet_filter {
    filters = {
      "tag:Class" : "build"
    }
    most_free = true
    random    = false
  }
}

build {
  sources = [
    "source.amazon-ebs.ubuntu2404"
  ]

  provisioner "shell" {
    inline = [
      "sudo apt update",
      "sudo apt upgrade -y"
    ]
  }

  provisioner "ansible" {
    playbook_file = "playbook.yml"
  }
}