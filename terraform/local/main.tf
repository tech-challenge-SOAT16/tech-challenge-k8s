resource "kind_cluster" "this" {
  name           = var.cluster_name
  node_image     = var.node_image
  wait_for_ready = true

  # Kubeconfig próprio: não altera o contexto atual de ~/.kube/config.
  kubeconfig_path = abspath("${path.module}/kubeconfig")

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"

      # NodePort do proxy do Kong (gitops/platform/kong/values-kind.yaml).
      extra_port_mappings {
        container_port = 30080
        host_port      = var.kong_host_port
        listen_address = "127.0.0.1"
      }
    }
  }
}

provider "kubernetes" {
  host                   = kind_cluster.this.endpoint
  client_certificate     = kind_cluster.this.client_certificate
  client_key             = kind_cluster.this.client_key
  cluster_ca_certificate = kind_cluster.this.cluster_ca_certificate
}

provider "helm" {
  kubernetes = {
    host                   = kind_cluster.this.endpoint
    client_certificate     = kind_cluster.this.client_certificate
    client_key             = kind_cluster.this.client_key
    cluster_ca_certificate = kind_cluster.this.cluster_ca_certificate
  }
}

module "platform" {
  source = "../modules/platform"

  namespaces                = var.namespaces
  argocd_chart_version      = var.argocd_chart_version
  argocd_apps_chart_version = var.argocd_apps_chart_version
  gitops_repo_url           = var.gitops_repo_url
  gitops_revision           = var.gitops_revision
  gitops_values = {
    profile = "kind"
    apps = {
      enabled = var.deploy_apps
    }
  }
}
