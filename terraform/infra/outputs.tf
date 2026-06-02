output "node_ips" {
  description = "IP addresses of all k8s nodes"
  value = {
    for name, vm in libvirt_domain.k8s_nodes :
    name => vm.network_interface[0].addresses[0]
  }
}

output "masters" {
  value = {
    for name, vm in libvirt_domain.k8s_nodes :
    name => vm.network_interface[0].addresses[0]
    if var.nodes[name].role == "master"
  }
}

output "workers" {
  value = {
    for name, vm in libvirt_domain.k8s_nodes :
    name => vm.network_interface[0].addresses[0]
    if var.nodes[name].role == "worker"
  }
}
