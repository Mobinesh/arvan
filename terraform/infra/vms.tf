resource "libvirt_volume" "ubuntu_base" {
  name   = "ubuntu-focal-base"
  source = var.ubuntu_image
  format = "qcow2"
}

resource "libvirt_volume" "node_disk" {
  for_each       = var.nodes
  name           = "${each.key}.qcow2"
  base_volume_id = libvirt_volume.ubuntu_base.id
  size           = var.disk_size
}

resource "libvirt_cloudinit_disk" "node_init" {
  for_each = var.nodes
  name     = "${each.key}-init.iso"
  user_data = templatefile("${path.module}/cloud-init.tpl", {
    hostname       = each.key
    ssh_public_key = file(var.ssh_public_key_path)
  })
}

resource "libvirt_domain" "k8s_nodes" {
  for_each  = var.nodes
  name      = each.key
  memory    = each.value.memory
  vcpu      = each.value.cpu
  cloudinit = libvirt_cloudinit_disk.node_init[each.key].id

  disk {
    volume_id = libvirt_volume.node_disk[each.key].id
  }

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}
