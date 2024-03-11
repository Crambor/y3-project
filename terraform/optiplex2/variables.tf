variable "pm_user" {
  description = "Proxmox User"
  type        = string
}

variable "pm_realm" {
  description = "Proxmox login realm"
  type        = string
  default     = "pve"
}

variable "pm_pass" {
  description = "Proxmox Password"
  type        = string
  sensitive   = true
}

variable "proxmox_api_url" {
  description = "Proxmox API url"
  type        = string
  default     = "https://10.10.10.13:8006/api2/json"
}

variable "enable_slurm" {
  description = "toggle to trigger slurm VMS"
  type        = bool
  default     = false
}

variable "ci_user" {
  description = "Cloud-init user"
  type        = string
  default     = "crambor"
}

variable "ci_pass" {
  description = "cloud-init user password"
  type        = string
  sensitive   = true
}
