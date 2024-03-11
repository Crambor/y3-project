locals {
  is_running        = true
  is_running_ubuntu = false
}

resource "proxmox_vm_qemu" "slurm-vms" {
  count       = 5
  name        = format("slurm-cn%02d", count.index + 6)
  vmid        = 115 + count.index
  target_node = "optiplex2"
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
  ipconfig0 = "ip=10.10.10.${55 + count.index}/24,gw=10.10.10.1"
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  cloudinit_cdrom_storage = "local-lvm"

  vm_state = local.is_running ? "running" : "stopped"
  onboot   = local.is_running
}

resource "proxmox_vm_qemu" "slurm-vms-ubuntu" {
  count       = 5
  name        = format("ubuntu-slurm-cn%02d", count.index + 6)
  vmid        = 125 + count.index
  target_node = "optiplex2"
  clone       = "ubuntu-2204-template"
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
  ipconfig0 = "ip=10.10.10.${75 + count.index}/24,gw=10.10.10.1"
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  # cloud init config
  ciuser     = var.ci_user
  cipassword = var.ci_pass
  sshkeys   = file("../id_ed25519.pub")

  cloudinit_cdrom_storage = "local-lvm"

  vm_state = local.is_running_ubuntu ? "running" : "stopped"
  onboot   = local.is_running_ubuntu
}

