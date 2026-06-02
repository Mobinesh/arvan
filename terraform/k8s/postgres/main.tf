terraform {
  required_version = ">= 1.5"
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

provider "kubectl" {
  config_path = var.kubeconfig_path
}

resource "kubectl_manifest" "local_path_provisioner" {
  for_each  = toset(split("---", file("${path.module}/templates/local-path-storage.yaml")))
  yaml_body = each.value
}

resource "kubectl_manifest" "default_storage_class" {
  depends_on = [kubectl_manifest.local_path_provisioner]
  yaml_body  = <<-YAML
    apiVersion: storage.k8s.io/v1
    kind: StorageClass
    metadata:
      name: local-path
      annotations:
        storageclass.kubernetes.io/is-default-class: "true"
    provisioner: rancher.io/local-path
    volumeBindingMode: WaitForFirstConsumer
    reclaimPolicy: Delete
  YAML
}

resource "kubectl_manifest" "postgres_namespace" {
  depends_on = [kubectl_manifest.default_storage_class]
  yaml_body  = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: postgres
  YAML
}

resource "kubectl_manifest" "postgres_secret" {
  depends_on = [kubectl_manifest.postgres_namespace]
  yaml_body  = <<-YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: postgres-secret
      namespace: postgres
    type: Opaque
    stringData:
      POSTGRES_PASSWORD: "${var.postgres_password}"
      POSTGRES_USER: "appuser"
      POSTGRES_DB: "appdb"
  YAML
}

resource "kubectl_manifest" "postgres_statefulset" {
  depends_on = [kubectl_manifest.postgres_secret]
  yaml_body  = file("${path.module}/templates/postgres-statefulset.yaml")
}
