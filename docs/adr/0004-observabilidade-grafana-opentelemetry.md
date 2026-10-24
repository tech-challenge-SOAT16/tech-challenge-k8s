# ADR 0004 — Observabilidade com OpenTelemetry e stack Grafana no cluster

- Status: aceita
- Data: 2026-10-23

## Contexto

A Fase 3 pede latência, consumo de recursos, healthchecks, alertas de falha em
ordens de serviço, logs JSON correlacionados e dashboards de negócio. A API já
exporta traces, métricas e logs por OTLP e o repositório da aplicação tem os
dashboards e alertas usados com `grafana/otel-lgtm` no docker compose.

## Decisão

- Stack self-hosted no namespace `monitoring`: kube-prometheus-stack
  (Prometheus com receivers OTLP e remote write, Alertmanager e Grafana), Loki
  monolítico com filesystem, Tempo e um OpenTelemetry Collector (deployment)
  como único endpoint OTLP da API
  (`otel-collector.monitoring.svc.cluster.local:4317`).
- O Collector envia métricas ao receiver OTLP do Prometheus (mesma tradução de
  nomes do otel-lgtm), logs ao endpoint OTLP do Loki e traces ao Tempo.
- Datasources com UIDs `prometheus`, `loki` e `tempo`, iguais aos do compose:
  os dashboards 19924, 19925 e "TechChallenge - Ordens de Serviço" são copiados
  sem alteração como ConfigMaps.
- Alertas do compose convertidos em `PrometheusRule`; o Alertmanager envia e-mail
  ao Mailpit de produção.

## Consequências

- Os mesmos dashboards funcionam no compose e no cluster.
- Métricas de pods e nós vêm do kube-state-metrics e do node-exporter, com os
  dashboards padrão do kube-prometheus-stack.
- Sem armazenamento persistente (ver ADR 0002).
