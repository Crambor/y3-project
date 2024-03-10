locals {
  is_running = true
}

resource "proxmox_vm_qemu" "slurm-vms" {
  count       = 5
  name        = format("slurm-cn%02d", count.index + 1)
  vmid        = 110 + count.index
  target_node = "optiplex1"
  clone       = "template"
  full_clone  = true
  scsihw      = "virtio-scsi-single"
  agent       = 1

  memory  = 2458
  cores   = 1
  os_type = "cloud-init"
  qemu_os = "other"

  disks {
    scsi {
      scsi0 {
        disk {
          size       = 16
          storage    = "local-lvm"
          iothread   = true
          replicate  = true
          emulatessd = true
        }
      }
    }
  }

  # Network Configuration
  ipconfig0 = "ip=10.10.10.${50 + count.index}/24,gw=10.10.10.1"
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  cloudinit_cdrom_storage = "local-lvm"

  vm_state = local.is_running ? "running" : "stopped"
  onboot   = local.is_running
}

