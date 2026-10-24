# ADR 0005 — Tag da imagem nos overlays do repositório da aplicação

- Status: aceita
- Data: 2026-10-23

## Contexto

O Argo CD precisa saber qual imagem da API rodar em cada ambiente. As opções
eram guardar a tag neste repositório (a pipeline da aplicação abriria PR ou
commitaria aqui, com credencial cross-repo) ou nos overlays Kustomize que já
existem no repositório da aplicação.

## Decisão

- Os manifests e a tag da imagem ficam no repositório
  `tech-challenge-application`: `k8s/overlays/aws-eks-homolog` (branch
  `develop`, namespace `techchallenge-homolog`) e `k8s/overlays/aws-eks`
  (branch `main`, namespace `techchallenge`).
- As Applications `techchallenge-homolog` e `techchallenge-production` deste
  repositório leem esses overlays. Os repositórios são públicos: não há
  credencial cross-repo.
- A pipeline da aplicação publica a imagem no ECR, roda
  `kustomize edit set image` no overlay do ambiente e commita a tag direto na
  mesma branch (`chore(deploy): ... [skip ci]`), sem PR. Para isso o ruleset de
  `develop`/`main` do repositório da aplicação tem bypass somente para
  `github-actions[bot]`, e o commit toca apenas `k8s/overlays/**`.

## Por que não vale para este repositório

Terraform e plataforma mudam infraestrutura compartilhada pelos dois ambientes;
um erro aqui derruba homologação e produção ao mesmo tempo. Por isso toda
mudança em `tech-challenge-k8s` passa por PR com fmt, validate, tflint,
`terraform test`, render dos charts e plan. Nenhum ator tem bypass neste
repositório.

## Consequências

- Deploy da API sem credencial do cluster na pipeline da aplicação; o Argo CD
  detecta o commit da tag e faz o rollout (OutOfSync → Synced).
- O histórico de versões implantadas fica no Git do repositório da aplicação.
- Risco: o bypass precisa ser restrito ao ator da pipeline; nenhum humano commita
  direto em `develop`/`main`.
