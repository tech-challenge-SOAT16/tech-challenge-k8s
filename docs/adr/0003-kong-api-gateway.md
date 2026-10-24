# ADR 0003 — Kong como API Gateway no cluster

- Status: aceita
- Data: 2026-10-23

## Contexto

A aplicação já usa Kong no docker compose (rotas públicas, rate limiting de 60
requisições por minuto e IP). No cluster precisamos de um único ponto de entrada
para a API dos dois ambientes e para as interfaces de operação.

## Decisão

- Chart `kong/ingress` (Kong Ingress Controller + Kong Gateway 3.9 OSS) em modo
  DB-less no namespace `kong`, instalado pelo Argo CD.
- Proxy publicado por um Service `LoadBalancer` com
  `service.beta.kubernetes.io/aws-load-balancer-type: nlb` (NLB nas subnets
  públicas). No kind o proxy usa NodePort.
- Rotas como `Ingress` (`ingressClassName: kong`) em `gitops/platform/api-routes`
  e `gitops/platform/gateway`: produção em `/api`, `/orcamentos`, `/swagger` e `/openapi`; homologação sob
  `/homolog` (prefixo removido pelo Kong); Argo CD em `/argocd`; Grafana em
  `/grafana`.
- Plugins declarativos: `rate-limiting` por namespace e `prometheus` global
  (métricas do gateway no Prometheus via ServiceMonitor).

## Consequências

- Configuração do gateway versionada e aplicada pelo Argo CD, sem scripts contra
  a Admin API.
- Sem DNS próprio, homologação e produção são separadas por caminho no mesmo NLB.
- A validação de JWT continua na API (OIDC/JWKS); o plugin `jwt` do Kong e a rota
  da Lambda de autenticação entram quando o emissor estiver publicado.
