output "kubeconfig" {
  description = "Kubeconfig do cluster kind (export KUBECONFIG=...)."
  value       = kind_cluster.this.kubeconfig_path
}

output "urls" {
  description = "Interfaces publicadas pelo Kong."
  value = {
    argocd  = "http://localhost:${var.kong_host_port}/argocd"
    grafana = "http://localhost:${var.kong_host_port}/grafana"
  }
}

output "grafana_admin_password" {
  description = "Senha do admin do Grafana (terraform output -raw grafana_admin_password)."
  value       = module.platform.grafana_admin_password
  sensitive   = true
}
