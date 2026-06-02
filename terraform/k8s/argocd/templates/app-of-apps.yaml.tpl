apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app-of-apps
  namespace: argocd
spec:
  project: ${project}

  source:
    repoURL: ${repo_url}
    targetRevision: main
    path: ${path}

  destination:
    server: https://kubernetes.default.svc
    namespace: argocd

  syncPolicy:
    automated:
      prune: true
      selfHeal: true
