variable "kubeconfig_path" {
  type    = string
  default = "/home/binesh/.kube/config"
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "chart_version" {
  type    = string
  default = "7.7.0"
}

variable "service_type" {
  type    = string
  default = "NodePort"
}

variable "git_repo" {
  type = string
}

variable "git_path" {
  type    = string
  default = "apps"
}

variable "project" {
  type    = string
  default = "default"
}
