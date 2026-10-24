output "grafana_admin_password" {
  description = "Senha do usuário admin do Grafana."
  value       = random_password.grafana_admin.result
  sensitive   = true
}

output "namespaces" {
  description = "Namespaces criados."
  value       = sort(keys(kubernetes_namespace_v1.this))
}
