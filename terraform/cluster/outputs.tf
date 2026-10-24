output "region" {
  description = "Região AWS."
  value       = var.region
}

output "cluster_name" {
  description = "Nome do cluster EKS."
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint da API do Kubernetes."
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_security_group_id" {
  description = "Security group do cluster, usado pelos nós e pods."
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "vpc_id" {
  description = "VPC compartilhada com o banco e a Lambda."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR da VPC."
  value       = aws_vpc.this.cidr_block
}

output "private_subnet_ids" {
  description = "Subnets privadas (RDS, Lambda e nós quando há NAT)."
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "Subnets públicas (NLB do Kong)."
  value       = aws_subnet.public[*].id
}

output "database_security_group_id" {
  description = "Security group a ser anexado ao RDS."
  value       = aws_security_group.database.id
}

output "lambda_security_group_id" {
  description = "Security group a ser anexado à Lambda dentro da VPC."
  value       = aws_security_group.lambda.id
}

output "ecr_repository_url" {
  description = "URI do repositório ECR da API."
  value       = aws_ecr_repository.api.repository_url
}

output "grafana_admin_password" {
  description = "Senha do admin do Grafana (terraform output -raw grafana_admin_password)."
  value       = module.platform.grafana_admin_password
  sensitive   = true
}

output "kubeconfig_command" {
  description = "Comando para configurar o kubectl."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.this.name}"
}
