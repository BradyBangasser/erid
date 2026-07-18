packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.0"
      source  = "github.com/hashicorp/amazon"
    }
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "image_version" {
  type    = string
  default = "0.1.0"
}

# ---------------------------------------------------------------------------
# BUILDER: On-prem (KVM/QEMU) — AlmaLinux 10, produces a qcow2
# ---------------------------------------------------------------------------
source "qemu" "onprem" {
  iso_url          = "https://repo.almalinux.org/almalinux/10/isos/x86_64/AlmaLinux-10-latest-x86_64-minimal.iso"
  iso_checksum     = "file:https://repo.almalinux.org/almalinux/10/isos/x86_64/CHECKSUM"
  output_directory = "images/erid-golden-${var.image_version}"
  vm_name          = "erid-golden-${var.image_version}.qcow2"
  disk_size        = "5G"
  format           = "qcow2"
  accelerator      = "kvm"
  ssh_username     = "erid"
  ssh_password     = "erid"
  ssh_timeout      = "30m"
  http_directory   = "http" # holds the kickstart (ks.cfg) file
  boot_command = [
    "<up><tab> inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait>"
  ]
  shutdown_command = "sudo shutdown -P now"
}

# ---------------------------------------------------------------------------
# BUILDER: AWS — AlmaLinux 10, produces an AMI
# ---------------------------------------------------------------------------
source "amazon-ebs" "cloud-x86" {
  region        = "us-east-2"
  instance_type = "t3.micro"
  ssh_username  = "ec2-user"
  ami_name      = "erid-golden-${var.image_version}-{{timestamp}}.x86"

  source_ami_filter {
    filters = {
      name                = "AlmaLinux OS 10*x86_64*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["764336703387"] # AlmaLinux OS Foundation
    most_recent = true
  }
}

source "amazon-ebs" "cloud-arm" {
  region        = "us-east-2"
  instance_type = "t4g.micro"
  ssh_username  = "ec2-user"
  ami_name      = "erid-golden-${var.image_version}-{{timestamp}}.arm"

  source_ami_filter {
    filters = {
      name                = "AlmaLinux OS 10*arm*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["764336703387"] # AlmaLinux OS Foundation
    most_recent = true
  }
}

# ---------------------------------------------------------------------------
# BUILD: same provisioning steps run against every builder above
# ---------------------------------------------------------------------------
build {
  name = "golden"
  sources = [
    "source.qemu.onprem",
    "source.amazon-ebs.cloud-x86"
  ]

  provisioner "shell" {
    inline = [
      "sudo dnf update -y",
      "sudo dnf install -y curl git cloud-init",
      "sudo cloud-init clean" # reset cloud-init state so it re-runs fresh on first boot
    ]
  }

  # Hand off environment-specific setup to cloud-init at boot, not baked in here
  provisioner "file" {
    source      = "cloud-init/99-erid.cfg"
    destination = "/tmp/99-erid.cfg"
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/99-erid.cfg /etc/cloud/cloud.cfg.d/99-erid.cfg"
    ]
  }
}
