terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
    }
  }
}

variable "ssh_pub_key_path" {
  description = "path to ssh public key"
  type        = string
}
variable "ssh_private_key_path" {
  description = "path to ssh public key"
  type        = string
}
variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "url_portal" {
  description = "DNS name to assign to instance"
  type        = string
}

variable "ifpconfig_private" {
  description = "ipconfig for private bridge/interface, e.g. ip=10.200.100.20/24,gw=10.200.100.1"
  type        = string
}

variable "ifpconfig_public" {
  description = "ipconfig for public bridge/interface"
  type        = string
}

variable "pm_user" {
  description = "Proxmox API user"
  type        = string
}

variable "pm_password" {
  description = "Proxmox API password"
  type        = string
  sensitive   = true
}

variable "pm_tls_insecure" {
  description = "Skip TLS verification"
  type        = bool
  default     = true
}

variable "pm_source_template" {
  description = "jambonz base template to clone"
  type        = string
}

variable "pm_target_node" {
  description = "proxmox target node"
  type        = string
}

variable "pm_storage" {
  description = "proxmox storage string"
  type        = string
}

variable "pve_user" {
  description = "ssh user for proxmox node"
  type        = string
}

variable "pve_host" {
  description = "proxmox host IP or name"
  type        = string
}

variable "nameserver" {
  description = "nameserver IP address"
  type        = string
  default     = "8.8.8.8"
}

variable "vm_count" {
  description = "number of instances to deploy"
  type = number
  default = 1
}

provider "proxmox" {
  pm_api_url       = var.pm_api_url
  pm_user          = var.pm_user
  pm_password      = var.pm_password
  pm_tls_insecure  = var.pm_tls_insecure
}

resource "local_file" "cloud_init_user_data_file" {
  count    = var.vm_count
  content  = templatefile("${path.module}/files/cloud-init.cloud_config.tftpl", {
    ssh_key = file(var.ssh_pub_key_path)
    hostname = var.url_portal
    url_portal = var.url_portal
  })
  filename = "${path.module}/files/user_data_${count.index}.cfg"
}

resource "null_resource" "cloud_init_config_files" {
  count    = var.vm_count
  connection {
    type     = "ssh"
    user     = var.pve_user
    password = var.pm_password
    host     = var.pve_host
  }

  provisioner "file" {
    source      = local_file.cloud_init_user_data_file[count.index].filename
    destination = "/var/lib/vz/snippets/user_data_vm-jambonz-mini-${count.index}.yml"
  }
}

resource "proxmox_vm_qemu" "jambonz-mini-v084-3" {
  depends_on = [
    null_resource.cloud_init_config_files,
  ]

  count             = var.vm_count
  name              = "jambonz-mini-v084-3"
  target_node       = var.pm_target_node
  clone             = var.pm_source_template  
  full_clone        = true

  cores             = 4
  sockets           = 1  
  cpu               = "host"
  memory            = 8192
  os_type           = "cloud-init"

  network {
    model           = "virtio"
    bridge          = "vmbr0"
  }

  network {
    model           = "virtio"
    bridge          = "vmbr1"
  }

  disk {
    type            = "scsi"
    size            = "600G"
    format          = "raw"
    storage         = var.pm_storage
  }

  ssh_user          = "admin"
  ssh_private_key   = file(var.ssh_private_key_path)

  # Cloud Init settings
  ipconfig0         = var.ifpconfig_public
  ipconfig1         = var.ifpconfig_private
  sshkeys           = file(var.ssh_pub_key_path)
  nameserver        = var.nameserver

  cicustom = "user=local:snippets/user_data_vm-jambonz-mini-${count.index}.yml"

}
