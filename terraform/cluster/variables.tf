variable "region" {
  description = "Região AWS (AWS Academy Learner Lab usa us-east-1)."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefixo dos recursos."
  type        = string
  default     = "techchallenge"
}

variable "cluster_name" {
  description = "Nome do cluster EKS."
  type        = string
  default     = "techchallenge-eks"
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes no EKS."
  type        = string
  default     = "1.35"
}

variable "vpc_cidr" {
  description = "CIDR da VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Cria um NAT Gateway e coloca os nós nas subnets privadas. Com false, os nós ficam nas subnets públicas (mais barato)."
  type        = bool
  default     = true
}

variable "create_iam_roles" {
  description = "Cria as roles do cluster e dos nós. Com false usa a LabRole existente (AWS Academy não permite criar roles)."
  type        = bool
  default     = false
}

variable "lab_role_name" {
  description = "Role usada pelo cluster e pelos nós quando create_iam_roles = false."
  type        = string
  default     = "LabRole"
}

variable "node_instance_types" {
  description = "Tipos de instância do node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_min_size" {
  description = "Mínimo de nós."
  type        = number
  default     = 2
}

variable "node_desired_size" {
  description = "Quantidade desejada de nós."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Máximo de nós."
  type        = number
  default     = 3
}

variable "ecr_repository_name" {
  description = "Repositório ECR da imagem da API."
  type        = string
  default     = "techchallenge-application"
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
  description = "Branch do repositório GitOps acompanhada pelo cluster."
  type        = string
  default     = "main"
}
