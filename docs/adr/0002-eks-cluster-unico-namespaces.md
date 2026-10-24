# ADR 0002 — Um cluster EKS com namespaces por ambiente

- Status: aceita
- Data: 2026-10-23

## Contexto

O Tech Challenge exige homologação e produção com deploy automático. O AWS
Academy Learner Lab tem orçamento limitado, não permite criar roles IAM (usa a
`LabRole`) e para as instâncias EC2 ao fim de cada sessão de 4 horas.

## Decisão

- Um único cluster EKS 1.35 (`techchallenge-eks`) criado com recursos nativos
  `aws_eks_*` (sem o módulo terraform-aws-modules/eks), node group gerenciado
  t3.medium de 2 a 3 nós e add-ons gerenciados (vpc-cni com prefix delegation,
  kube-proxy, coredns, metrics-server e aws-ebs-csi-driver).
- Ambientes separados por namespace: `techchallenge` (produção) e
  `techchallenge-homolog` (homologação). Plataforma compartilhada em
  `monitoring`, `kong` e `argocd`.
- `create_iam_roles = false` por padrão: cluster e nós usam a `LabRole`. Com
  `true` o mesmo código cria as roles para uso fora do Academy.
- VPC com 2 AZs, subnets públicas e privadas e um NAT Gateway opcional
  (`enable_nat_gateway`); sem NAT, os nós ficam nas subnets públicas.
- Um state Terraform (S3 com `use_lockfile`). A pipeline aplica no push em
  `develop` e em `main`, uma execução por vez; a plataforma GitOps acompanha
  `main`.

## Consequências

- Custo de um control plane só e nós compartilhados entre os ambientes.
- Isolamento entre homologação e produção é lógico (namespace, Secret e banco
  próprios), não de cluster.
- Dados de observabilidade ficam em armazenamento efêmero: são perdidos quando o
  Academy para os nós, o que é aceitável para a demonstração.
