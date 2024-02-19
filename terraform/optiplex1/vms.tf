resource "proxmox_vm_qemu" "slurm-vms" {
  count       = 5
  name        = format("slurm-cn%02d", count.index + 1)
  vmid        = 111 + count.index
  target_node = "optiplex1"
  clone       = "template"
  full_clone  = true
  scsihw      = "virtio-scsi-single"

  memory  = 2048
  cores   = 1
  qemu_os = "other"
  onboot  = false

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
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  vm_state = "stopped" # alt is 'running'
}

