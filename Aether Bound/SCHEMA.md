---
status: ratificado
source: "90-Raw/LLM-WIKI.md + 90-Raw/Vault-Driven Development (VDD).md"
updated: 2026-07-04
---

# SCHEMA — Modelo de trabajo del Aether Bound Vault

> **Regla de oro.** Toda sesión empieza leyendo [[Current-State]]. Toda operación
> sigue un loop de `30-Loops/`. Ningún loop termina sin actualizar [[00-Index]],
> [[LOG]] y [[Current-State]]. *El Vault no documenta el desarrollo: lo dirige.*

Este vault es la **fuente viva de verdad** de AETHER BOUND. Es la síntesis de dos
frameworks (ambos archivados en `90-Raw/`):

- **LLM-WIKI** (Karpathy): el LLM *compila* fuentes inmutables en una wiki
  interlinkeada — la síntesis se paga una vez en el ingest, no en cada consulta.
  Primitivas: **ingest / query / lint**. Navegación: **Index + Log**.
- **VDD** (Vault-Driven Development): el vault como sistema operativo del
  proyecto — capas **Knowledge / State / Execution**, Programming Loops como
  procedimientos permanentes, sincronización código↔docs↔estado.

**Versión del framework: v1 (híbrido pragmático).** Diferido a v2: Scheduler
formal, contratos de loop exhaustivos (12 campos), orquestación multi-agente
declarativa, búsqueda BM25/embeddings (innecesaria bajo ~300 páginas).

---

## 1. Las capas y sus dueños

| Capa | Dónde | Qué contiene | Quién escribe |
|---|---|---|---|
| **Raw** | `docs/` (repo) + `90-Raw/` | GDD v2.2 **congelado**, frameworks, transcripts, referencias del director | El humano deposita; **nadie edita jamás** |
| **Schema** | `SCHEMA.md` (este archivo) | Convenciones, plantillas, contratos | Co-autoría humano+Claude; cambia despacio |
| **Knowledge** | `10-Knowledge/` | Páginas atómicas del diseño del juego, compiladas de raw | Claude compila; **el director ratifica** |
| **State** | `20-State/` | Dónde está el proyecto (nunca cómo funciona el juego) | Claude, después de **cada** tarea |
| **Execution** | `30-Loops/` | Procedimientos operativos reutilizables | Co-autoría; evolucionan por retroalimentación |
| **Navegación** | `00-Index.md`, `LOG.md` | Catálogo + bitácora append-only | Claude, en cada operación |

Separación estricta de roles: **el director cura y decide; Claude escribe,
enlaza y reconcilia.**

## 2. Plantilla de página (Knowledge)

```markdown
---
status: ratificado | propuesto | borrador
source: "GDD §x.y"        # o la fuente raw que la respalda
updated: YYYY-MM-DD
---

# Título

Contenido. Enlazar densamente con [[wikilinks]] a toda página relacionada.
```

- `ratificado` = bendecido por el director; solo un Design Loop puede cambiarlo.
- `propuesto` = escrito por Claude, esperando ratificación.
- `borrador` = trabajo en curso, puede mutar libremente.
- Un `[[wikilink]]` a una página que aún no existe **no es un error**: marca
  trabajo pendiente (aparecerá en el Lint Loop).

## 3. Contrato mínimo de loop

Cada archivo en `30-Loops/` define: **Objetivo · Estado de entrada · Fases ·
Validación · Artefactos que actualiza · Estado de salida**. Un loop es un
contrato, no una conversación. Si un loop produce errores repetidos, se mejora
el loop, no solo el resultado.

## 4. Index y Log

- [[00-Index]]: una línea por página, agrupada por capa. Se lee **primero** en
  toda consulta; a esta escala sustituye cualquier infraestructura de búsqueda.
- [[LOG]]: append-only. Formato de entrada: `## [YYYY-MM-DD] op | título`
  donde `op ∈ {ingest, design, feature, playtest, lint, state}`.

## 5. Inmutabilidad del GDD

`docs/GDD.md` v2.2 es el snapshot bendecido del reseteo creativo — **capa raw,
congelado**. La verdad viva está en `10-Knowledge/`. Si el diseño evoluciona,
evoluciona aquí (Design Loop); el GDD monolítico no se vuelve a editar.

## 6. Sincronización

Código, Knowledge, State, Index y Log deben representar la misma realidad
siempre. Checkpoint tras **cada tarea** (herencia del protocolo de sprints):
flush de State + memoria de Claude antes de abrir la siguiente tarea.
