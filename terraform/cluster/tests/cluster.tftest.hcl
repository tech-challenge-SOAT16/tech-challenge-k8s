# terraform test com providers simulados: não acessa AWS nem Kubernetes.
mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "123456789012"
    }
  }

  mock_data "aws_partition" {
    defaults = {
      partition = "aws"
    }
  }

  mock_data "aws_availability_zones" {
    defaults = {
      names = ["us-east-1c", "us-east-1a", "us-east-1b"]
    }
  }

  mock_data "aws_eks_addon_version" {
    defaults = {
      version = "v1.0.0-eksbuild.1"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/mock"
    }
  }

  mock_resource "aws_launch_template" {
    defaults = {
      id = "lt-0123456789abcdef0"
    }
  }

  mock_resource "aws_eks_cluster" {
    defaults = {
      endpoint = "https://example.eks.amazonaws.com"
      certificate_authority = [{
        data = "Y2E="
      }]
    }
  }
}

mock_provider "helm" {}

mock_provider "kubernetes" {}

mock_provider "random" {}

run "padrao_academy" {
  command = apply

  assert {
    condition     = aws_eks_cluster.this.role_arn == "arn:aws:iam::123456789012:role/LabRole"
    error_message = "O cluster deve usar a LabRole quando create_iam_roles = false."
  }

  assert {
    condition     = aws_eks_node_group.this.node_role_arn == "arn:aws:iam::123456789012:role/LabRole"
    error_message = "Os nós devem usar a LabRole quando create_iam_roles = false."
  }

  assert {
    condition     = length(aws_iam_role.cluster) == 0 && length(aws_iam_role.node) == 0
    error_message = "Nenhuma role IAM deve ser criada no AWS Academy."
  }

  assert {
    condition     = aws_eks_cluster.this.version == "1.35"
    error_message = "O cluster deve usar o Kubernetes 1.35."
  }

  assert {
    condition     = aws_subnet.public[*].availability_zone == ["us-east-1a", "us-east-1b"]
    error_message = "A VPC deve usar as duas primeiras AZs em ordem."
  }

  assert {
    condition     = alltrue([for s in aws_subnet.public : s.tags["kubernetes.io/role/elb"] == "1"])
    error_message = "Subnets públicas precisam da tag kubernetes.io/role/elb para o NLB."
  }

  assert {
    condition     = alltrue([for s in aws_subnet.private : s.tags["kubernetes.io/role/internal-elb"] == "1"])
    error_message = "Subnets privadas precisam da tag kubernetes.io/role/internal-elb."
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 1
    error_message = "Por padrão deve existir um NAT Gateway."
  }

  assert {
    condition     = toset(aws_eks_node_group.this.subnet_ids) == toset(aws_subnet.private[*].id)
    error_message = "Com NAT, os nós ficam nas subnets privadas."
  }

  assert {
    condition     = aws_eks_node_group.this.instance_types == tolist(["t3.medium"]) && aws_eks_node_group.this.scaling_config[0].min_size == 2 && aws_eks_node_group.this.scaling_config[0].max_size == 3
    error_message = "Node group deve ser t3.medium com 2 a 3 nós."
  }

  assert {
    condition     = aws_launch_template.nodes.metadata_options[0].http_put_response_hop_limit == 2
    error_message = "O launch template deve liberar o IMDS para os pods (hop limit 2)."
  }

  assert {
    condition     = toset(concat(keys(aws_eks_addon.before_nodes), keys(aws_eks_addon.after_nodes))) == toset(["vpc-cni", "kube-proxy", "coredns", "metrics-server", "aws-ebs-csi-driver"])
    error_message = "Add-ons esperados: vpc-cni, kube-proxy, coredns, metrics-server e aws-ebs-csi-driver."
  }

  assert {
    condition     = aws_ecr_repository.api.name == "techchallenge-application"
    error_message = "Repositório ECR esperado: techchallenge-application."
  }

  assert {
    condition     = module.platform.namespaces == tolist(["argocd", "kong", "monitoring", "techchallenge", "techchallenge-homolog"])
    error_message = "Namespaces esperados não foram criados."
  }
}

run "fora_do_academy" {
  command = apply

  variables {
    create_iam_roles = true
  }

  assert {
    condition     = length(aws_iam_role.cluster) == 1 && length(aws_iam_role.node) == 1
    error_message = "create_iam_roles = true deve criar as roles do cluster e dos nós."
  }

  assert {
    condition     = aws_eks_cluster.this.role_arn == aws_iam_role.cluster[0].arn
    error_message = "O cluster deve usar a role criada."
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.node) == 4
    error_message = "A role dos nós precisa das quatro policies gerenciadas."
  }
}

run "sem_nat" {
  command = apply

  variables {
    enable_nat_gateway = false
  }

  assert {
    condition     = length(aws_nat_gateway.this) == 0 && length(aws_eip.nat) == 0
    error_message = "Sem NAT Gateway nem EIP quando enable_nat_gateway = false."
  }

  assert {
    condition     = toset(aws_eks_node_group.this.subnet_ids) == toset(aws_subnet.public[*].id)
    error_message = "Sem NAT, os nós ficam nas subnets públicas."
  }
}
