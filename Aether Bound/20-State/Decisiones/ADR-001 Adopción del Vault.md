---
status: ratificado
updated: 2026-07-04
---

# ADR-001 — Adopción del Aether Bound Vault (VDD × LLM-WIKI)

- **Fecha:** 2026-07-04
- **Contexto:** el GDD v2.2 quedó cerrado (965 líneas) y la preproducción va a
  multiplicar el volumen documental; el conocimiento vivía repartido entre un
  monolito, BACKLOG.md y la memoria de Claude. El director aportó dos
  frameworks (archivados en `90-Raw/`).
- **Alternativas:** (a) seguir con GDD monolítico + BACKLOG; (b) wiki pura
  LLM-WIKI sin capa de estado; (c) VDD completo con Scheduler y multi-agente
  formal; (d) **híbrido pragmático** ← elegida.
- **Decisión:** Vault Obsidian `Aether Bound/` trackeado en git como fuente
  viva; GDD v2.2 congelado como raw; capas Knowledge/State/Loops; primitivas
  ingest/query/lint; 5 loops v1; Scheduler y multi-agente diferidos a v2.
- **Razón:** máxima ganancia (single source of truth, resume frío, síntesis
  compilada) con mínima ceremonia para un equipo de un director + Claude.
- **Consecuencias:** `docs/GDD.md` no se edita más; `BACKLOG.md` raíz queda
  como stub/archivo histórico; toda sesión arranca en [[Current-State]]; el
  checkpoint tras cada tarea ahora fluye al Vault.
