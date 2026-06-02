resource "libvirt_network" "k8s_net" {
  name      = "k8s-network"
  mode      = "nat"
  domain    = "k8s.local"
  addresses = ["10.10.10.0/24"]
  dns {
    enabled = true
  }
}
