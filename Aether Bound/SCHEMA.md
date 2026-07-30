---
status: ratificado
source: "90-Raw/LLM-WIKI.md + 90-Raw/Vault-Driven Development (VDD).md + ../VAULT-STARTER.md v2 (fusión con project-context, 2026-07-20)"
updated: 2026-07-20
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

**Versión del framework: v1.1 (híbrido pragmático + dieta de arranque).**
Añade sobre v1 la auditoría de peso de sesión (§8) incorporada desde
`project-context` — completitud del Vault y costo de arrancarlo son dos
ejes que se auditan por separado (ver [[Lint Loop]]). Diferido a v2:
Scheduler formal, contratos de loop exhaustivos (12 campos), orquestación
multi-agente declarativa, búsqueda BM25/embeddings (innecesaria bajo ~300
páginas).

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

## 7. Cierre de sesión *(añadido 2026-07-11 — pendiente VoBo del director)*

> Antes existía repartido entre CLAUDE.md (regla 4), la regla de oro, §6 y la
> memoria persistente de Claude; aquí queda consolidado como checklist único.

1. **[[Current-State]] refleja la realidad** — incluida la sección de
   ARRANQUE DE LA PRÓXIMA SESIÓN (qué sigue, qué decisión espera al director,
   qué quedó bloqueado y con qué sospecha). **Higiene de contexto
   (2026-07-16):** este archivo se auto-carga en CADA sesión (regla de oro) —
   describe SOLO lo vigente, con techo razonable (~2,500-3,000 tokens). Si un
   punto deja de ser "lo que sigue" y pasa a ser "lo que ya pasó", se mueve a
   [[Current-State-Historico]] (o vive solo en [[LOG]], que ya es el
   append-only autoritativo) — no se acumula aquí como relato.
2. **[[LOG]]**: una entrada por operación de la sesión
   (`op ∈ {ingest, design, feature, playtest, lint, state}`).
3. **[[00-Index]]**: al día si hubo páginas nuevas, movidas o re-descritas.
4. **[[Lecciones]]**: si la sesión pagó una lección (técnica o de entorno),
   se escribe ANTES de cerrar — es la memoria dura del proyecto.
5. **Working tree limpio**: commit descriptivo (sin comillas dobles en el
   mensaje, [[Lecciones]]) + push del branch de trabajo. Nada queda
   uncommitted salvo decisión explícita del director (y se anota en
   Current-State como WIP).
6. **Nada se reporta como terminado sin evidencia** — gates verdes o
   capturas revisables; lo no verificado se marca pendiente de VoBo.

## 8. Dieta de arranque: auditoría, semáforo y palancas
*(añadido 2026-07-20 — fusión con `project-context`, pendiente VoBo del
director)*

Un Vault puede estar **completo** (nada falta, nada contradice) y aun así
ser **caro de arrancar**. Son dos ejes independientes; este framework solo
auditaba el primero hasta ahora. La métrica que importa es cuántos tokens
se pagan ANTES del primer mensaje de la sesión.

**Medir.** `python3 "Aether Bound/scripts/check_vault.py" --json` reporta,
por archivo, si se auto-carga (hard = CLAUDE.md, siempre; soft = [[Current-State]],
por protocolo; no = bajo demanda), su peso en tokens, y a nivel proyecto el
**arranque_tokens** total con semáforo: 🟢 <10,000 · 🟡 10,000–30,000 ·
🔴 >30,000. También detecta `@imports` en `CLAUDE.md` (peso escondido que se
paga cada sesión aunque la tarea no lo toque) y si el Vault es
**colaborativo** (más de un autor en el historial de [[Current-State]]/
[[LOG]]/`CLAUDE.md` — hoy es individual, un solo autor).

**Palancas, de menor a mayor fricción:**
1. `@imports` en `CLAUDE.md` → bajo demanda (hoy no hay ninguno — sano).
2. No auto-cargar el LOG completo; leer solo la entrada más reciente.
3. Notas privadas (si se usan) separadas de lo vivo — fricción nula.
4. [[Current-State]] recortado a solo-presente bajo su techo de
   ~2,500-3,000 tokens (ya documentado en el punto 1 de arriba desde
   2026-07-16; el script de este punto solo lo convierte en número
   verificable en vez de juicio a ojo).

**Colaborativo vs individual:** el script detecta autores reales vía
`git log`. Con un solo autor (caso actual), hay libertad total para
reestructurar [[Current-State]]/[[LOG]]; si algún día se suma otro
colaborador, aplica la regla de `project-context`: no reestructurar esos
dos archivos, solo sacarlos del auto-load.

**Niveles equipo/privado (opcional):** si en algún momento se necesita
separar estrategia cruda o contexto sensible de lo que vive en el repo,
el patrón es `20-State/Notas-Privadas.md` + `20-State/Bitacora-Privada.md`
(gitignored con glob `Notas-Privadas*`/`Bitacora-Privada*`, verificado con
`git check-ignore`, nunca a ojo). Hoy no existen — se crean solo si Boris
los pide (VDD: no se construye lo que no se necesita).

Detalle completo del método (script íntegro, puentes a claude.ai, hook de
cierre): `../VAULT-STARTER.md` §9.
