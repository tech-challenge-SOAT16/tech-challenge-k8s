# Security groups consumidos pelos outros repositórios:
# - lambda: anexado à Function de autenticação quando ela roda dentro da VPC;
# - database: anexado ao RDS do tech-challenge-terraform.
resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-lambda"
  description = "Function de autenticacao dentro da VPC"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-lambda"
  }
}

resource "aws_vpc_security_group_egress_rule" "lambda_all" {
  security_group_id = aws_security_group.lambda.id
  description       = "Saida liberada"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_security_group" "database" {
  name        = "${var.project_name}-database"
  description = "PostgreSQL acessivel pelos pods do EKS e pela Lambda"
  vpc_id      = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-database"
  }
}

resource "aws_vpc_security_group_ingress_rule" "database_from_eks" {
  security_group_id            = aws_security_group.database.id
  description                  = "PostgreSQL a partir dos nos e pods do EKS"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

resource "aws_vpc_security_group_ingress_rule" "database_from_lambda" {
  security_group_id            = aws_security_group.database.id
  description                  = "PostgreSQL a partir da Lambda"
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
  referenced_security_group_id = aws_security_group.lambda.id
}
