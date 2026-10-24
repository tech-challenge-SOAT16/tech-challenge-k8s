variable "cluster_name" {
  description = "Nome do cluster kind."
  type        = string
  default     = "techchallenge"
}

variable "node_image" {
  description = "Imagem do nó kind (mesma minor do EKS)."
  type        = string
  default     = "kindest/node:v1.35.8@sha256:07b2536e30b803ed61d1677a79df6115f798ce64c80f9e22f6ed45afd09323c0"
}

variable "kong_host_port" {
  description = "Porta do host que publica o proxy do Kong."
  type        = number
  default     = 9080
}

variable "namespaces" {
  description = "Namespaces criados no cluster."
  type        = list(string)
  default     = ["techchallenge", "techchallenge-homolog", "monitoring", "kong", "argocd"]
}

variable "argocd_chart_version" {
  description = "Versão do chart argo/argo-cd."
  type        = string
  default     = "10.11.1"
}

variable "argocd_apps_chart_version" {
  description = "Versão do chart argo/argocd-apps."
  type        = string
  default     = "2.0.7"
}

variable "gitops_repo_url" {
  description = "Repositório lido pela Application raiz do Argo CD."
  type        = string
  default     = "https://github.com/tech-challenge-SOAT16/tech-challenge-k8s"
}

variable "gitops_revision" {
  description = "Branch testada no kind (normalmente a branch de trabalho)."
  type        = string
  default     = "develop"
}

variable "deploy_apps" {
  description = "Cria as Applications da API. Desligado por padrão: no kind não há imagem no ECR, banco nem Secret da API."
  type        = bool
  default     = false
}
