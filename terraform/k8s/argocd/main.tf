terraform {
  required_version = ">= 1.5"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version

  set {
    name  = "server.service.type"
    value = var.service_type
  }

  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }
}

resource "kubernetes_manifest" "app_of_apps" {
  depends_on = [helm_release.argocd]

  manifest = yamldecode(templatefile("${path.module}/templates/app-of-apps.yaml.tpl", {
    repo_url = var.git_repo
    path     = var.git_path
    project  = var.project
  }))
}
