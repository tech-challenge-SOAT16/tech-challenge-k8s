variable "namespaces" {
  description = "Namespaces criados pelo Terraform. Precisa conter argocd e monitoring."
  type        = list(string)

  validation {
    condition     = contains(var.namespaces, "argocd") && contains(var.namespaces, "monitoring")
    error_message = "A lista de namespaces precisa conter argocd e monitoring."
  }
}

variable "argocd_chart_version" {
  description = "Versão do chart argo/argo-cd."
  type        = string
}

variable "argocd_apps_chart_version" {
  description = "Versão do chart argo/argocd-apps (Application raiz)."
  type        = string
}

variable "gitops_repo_url" {
  description = "Repositório Git lido pela Application raiz."
  type        = string
}

variable "gitops_revision" {
  description = "Branch, tag ou commit do repositório GitOps."
  type        = string
}

variable "gitops_path" {
  description = "Diretório do chart app-of-apps dentro do repositório."
  type        = string
  default     = "gitops"
}

variable "gitops_values" {
  description = "Valores extras repassados ao chart app-of-apps (profile, apps etc.)."
  type        = any
  default     = {}
}
