resource "kubernetes_namespace_v1" "this" {
  for_each = toset(var.namespaces)

  metadata {
    name = each.key
  }
}

# Senha fixa por cluster: o Argo CD renderiza o chart a cada sync, então uma
# senha aleatória gerada pelo próprio chart do Grafana nunca ficaria estável.
resource "random_password" "grafana_admin" {
  length  = 24
  special = false
}

resource "kubernetes_secret_v1" "grafana_admin" {
  metadata {
    name      = "grafana-admin"
    namespace = kubernetes_namespace_v1.this["monitoring"].metadata[0].name
  }

  data = {
    admin-user     = "admin"
    admin-password = random_password.grafana_admin.result
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace_v1.this["argocd"].metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  timeout    = 900

  values = [file("${path.module}/values/argocd.yaml")]
}

# Application raiz (app-of-apps). O chart argocd-apps evita kubernetes_manifest,
# que exige o cluster acessível já no plan.
resource "helm_release" "root" {
  name       = "argocd-root"
  namespace  = helm_release.argocd.namespace
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  version    = var.argocd_apps_chart_version

  values = [yamlencode({
    applications = {
      root = {
        namespace  = helm_release.argocd.namespace
        project    = "default"
        finalizers = ["resources-finalizer.argocd.argoproj.io"]
        source = {
          repoURL        = var.gitops_repo_url
          targetRevision = var.gitops_revision
          path           = var.gitops_path
          helm = {
            valuesObject = merge(var.gitops_values, {
              repoURL        = var.gitops_repo_url
              targetRevision = var.gitops_revision
            })
          }
        }
        destination = {
          server    = "https://kubernetes.default.svc"
          namespace = helm_release.argocd.namespace
        }
        syncPolicy = {
          automated = {
            prune    = true
            selfHeal = true
          }
        }
      }
    }
  })]
}
