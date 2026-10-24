# ADR 0001 — Entrega da plataforma e da API com Argo CD (GitOps)

- Status: aceita
- Data: 2026-10-23

## Contexto

O cluster precisa de Kong, da stack de observabilidade e da API em dois
ambientes. Aplicar tudo pelo Terraform (`helm_release` por componente) aumenta o
state, deixa o `plan` dependente do cluster e não corrige desvios quando o AWS
Academy para e recria os nós. As pipelines também precisariam de credencial do
cluster para cada deploy.

## Decisão

- O Terraform instala apenas a infraestrutura e o Argo CD (`helm_release` enxuto:
  sem Dex e sem notifications) com uma Application raiz apontando para
  `gitops/` deste repositório.
- `gitops/` é um chart Helm app-of-apps: cada componente é uma Application com
  `automated`, `prune` e `selfHeal`, ordenada por sync wave (0 kube-prometheus-stack
  e CRDs; 1 Loki, Tempo, OpenTelemetry Collector, dashboards e alertas; 2 Kong;
  3 rotas e Mailpit; 4 API).
- Values dos charts versionados em `gitops/platform/<componente>/values.yaml`,
  com `values-kind.yaml` só para as diferenças do cluster local.
- O Argo CD é publicado pelo Kong em `/argocd`; o login usa o Secret inicial
  `argocd-initial-admin-secret`.

## Consequências

- Mudanças de plataforma passam por PR e são aplicadas pelo Argo CD após o merge;
  a UI mostra o estado de cada componente (bom para a demonstração).
- O Terraform não precisa acessar o cluster no `plan` (a Application raiz é
  instalada pelo chart `argocd-apps`, não por `kubernetes_manifest`).
- O mesmo `gitops/` roda no kind (`terraform/local`) para validação local.
- O Argo CD consome ~0,5 GiB do cluster.
