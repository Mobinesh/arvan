variable "nodes" {
  description = "Kubernetes cluster nodes"
  type = map(object({
    role   = string
    cpu    = number
    memory = number
  }))
  default = {
    k8s-master  = { role = "master", cpu = 2, memory = 2048 }
    k8s-worker1 = { role = "worker", cpu = 2, memory = 2048 }
    k8s-worker2 = { role = "worker", cpu = 2, memory = 2048 }
  }
}

variable "disk_size" {
  description = "Disk size in bytes (20GB)"
  default     = 21474836480
}

variable "ubuntu_image" {
  description = "Ubuntu cloud image URL"
  default = "/tmp/k8s-images/jammy-server-cloudimg-amd64.img"
}
variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  default     = "/home/binesh/.ssh/id_rsa.pub"
}
