variable "pm_user" {
  description = "Proxmox User"
  type        = string
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
