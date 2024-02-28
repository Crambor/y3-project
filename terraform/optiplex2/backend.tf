terraform {
  required_version = "~> 1.5"

  backend "s3" {
    endpoint                    = "http://10.10.10.25:9000"
    bucket                      = "terraform-state"
    key                         = "y3-project/optiplex2/terraform.tfstate"
    region                      = "eu-west-1"
    skip_requesting_account_id  = true
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    force_path_style            = true

  }

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
