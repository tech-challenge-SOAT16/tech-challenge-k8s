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
  `tech-challenge-application`, um diretório por ambiente na branch `main`:
  `k8s/overlays/aws-eks-homolog` (namespace `techchallenge-homolog`) e
  `k8s/overlays/aws-eks` (namespace `techchallenge`). Não há branch por
  ambiente: o que roda em cada ambiente é sempre o que está na `main`, e
  promover é copiar a tag de um overlay para o outro.
- As Applications `techchallenge-homolog` e `techchallenge-production` deste
  repositório leem esses overlays. Os repositórios são públicos: não há
  credencial cross-repo.
- A pipeline da aplicação publica a imagem no ECR, grava a nova tag no
  `kustomization.yaml` do overlay do ambiente e abre a branch
  `deploy/<overlay>-<run>`. A tag entra na `main` por Pull Request revisado,
  com os mesmos checks de qualquer mudança; o commit toca apenas
  `k8s/overlays/**`. O ruleset da `main` não tem bypass para a pipeline.

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
- O PR de deploy exige um revisor, o que adiciona um passo manual entre o
  build e o rollout; em troca, ninguém (humano ou bot) commita direto na `main`
  e o deploy fica registrado como PR no histórico.
- Branch por ambiente foi descartada: as branches divergem com o tempo e fica
  difícil saber qual código roda em cada ambiente.
