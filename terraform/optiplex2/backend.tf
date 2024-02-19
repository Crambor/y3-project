terraform {
  required_version = "~> 1.5"

  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}

provider "proxmox" {
  pm_api_url  = var.proxmox_api_url
  pm_user     = var.pm_user
  pm_password = var.pm_pass
}
