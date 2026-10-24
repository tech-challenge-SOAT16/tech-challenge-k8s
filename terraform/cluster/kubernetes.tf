# Desde o EKS 1.30 nenhuma StorageClass vem marcada como padrão.
resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name = "gp3"

    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }

  depends_on = [aws_eks_addon.after_nodes]
}

module "platform" {
  source = "../modules/platform"

  namespaces                = var.namespaces
  argocd_chart_version      = var.argocd_chart_version
  argocd_apps_chart_version = var.argocd_apps_chart_version
  gitops_repo_url           = var.gitops_repo_url
  gitops_revision           = var.gitops_revision
  gitops_values = {
    profile = "eks"
    apps = {
      repoURL = var.app_repo_url
      environments = {
        techchallenge-homolog    = { targetRevision = var.app_revision }
        techchallenge-production = { targetRevision = var.app_revision }
      }
    }
  }

  depends_on = [aws_eks_addon.after_nodes]
}
