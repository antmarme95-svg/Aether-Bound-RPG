# VAULT-STARTER — Arranca tu proyecto con un Vault dirigido por IA

> **Qué es esto:** un archivo único y autocontenido para arrancar un proyecto
> bajo el método **VDD × LLM-WIKI** — el conocimiento vive en un Vault de
> markdown versionado, no en las conversaciones; el agente de IA lo mantiene
> y el humano lo dirige. Destilado de un proyecto real de desarrollo
> continuo a lo largo de meses bajo este esquema, y de sus dos fuentes
> teóricas: *LLM-WIKI* (A. Karpathy) y *Vault-Driven Development v1.0*.
>
> **Cómo usarlo:** copia este archivo a la raíz de tu repositorio y dile a
> tu agente (Claude Code o equivalente):
> *"Lee VAULT-STARTER.md e inicializa el Vault de este proyecto."*
> La sección §9 contiene las instrucciones de bootstrap que el agente debe
> ejecutar. Todo lo demás es la teoría y los contratos que gobiernan el
> sistema después del arranque.

---

## §1 — La tesis (por qué existe esto)

**El problema con el desarrollo asistido por IA basado en conversaciones:**
el contexto vive dentro del chat; las decisiones importantes quedan
enterradas entre cientos de mensajes; los prompts crecen sin límite; y cada
sesión nueva arranca en frío re-explicándole al modelo cómo funciona el
proyecto. No escala para proyectos de meses o años.

**El problema con las wikis personales:** capturar es fácil, mantener es lo
que nadie sostiene. Cincuenta notas interlinkeadas, consistentes y al día
son un trabajo de editor que las wikis humanas no pagan — por eso se pudren.

**La síntesis (dos ideas, un sistema):**

1. **LLM-WIKI (Karpathy):** usa al modelo como *compilador*, no como capa de
   búsqueda. A diferencia de RAG — que re-deriva las mismas relaciones en
   cada consulta y no acumula nada — aquí la síntesis se paga UNA vez al
   ingerir cada fuente, y queda escrita en una wiki interlinkeada que
   *compone* con cada fuente nueva. El costo de mantenimiento que mata a las
   wikis humanas es casi cero para un LLM: no se aburre, no olvida
   cross-referencias, y puede tocar quince archivos en una pasada.
2. **VDD:** el Vault no documenta el desarrollo — **lo dirige**. Es el
   sistema operativo del proyecto: conocimiento, estado y procedimientos
   viven en él; el agente solo lo consulta, interpreta el estado actual y
   ejecuta el siguiente procedimiento. Los prompts son efímeros; los
   procesos (loops) son permanentes. El verdadero activo no es el entregable
   ni los prompts: es el sistema capaz de producir ambos.

**Separación estricta de roles** (el principio que sostiene todo):
**el humano cura y decide; el agente escribe, enlaza y reconcilia.**

**Principios VDD irrenunciables:**

- *Single Source of Truth* — la información permanente existe SOLO en el
  Vault. Nunca solo en conversaciones, ni solo en la memoria del modelo, ni
  solo en los entregables.
- *Reproducibilidad* — cualquier agente (incluso de otro proveedor) debe
  poder continuar el proyecto leyendo únicamente el Vault. El sistema es
  agnóstico de modelo por diseño.
- *Mínimo cambio* — cambios pequeños, reversibles, fáciles de revisar.
- *Evidencia* — lo que no puede justificarse con información del Vault no se
  asume: se documenta o se pregunta.
- *Sincronización* — entregables, documentación, estado y backlog
  representan la misma realidad SIEMPRE.

---

## §2 — Regla de oro

> **Toda sesión empieza leyendo `Current-State.md`. Toda operación sigue un
> loop. Ningún loop termina sin actualizar `00-Index.md`, `LOG.md` y
> `Current-State.md`. El Vault no documenta el desarrollo: lo dirige.**

(Versión VDD: *antes de modificar el proyecto, comprender el estado; antes
de cambiar el estado, seguir un loop; antes de finalizar un loop, actualizar
el Vault.*)

---

## §3 — Estructura y capas

```
<TuProyecto>/
├── CLAUDE.md                  ← reglas de arranque (ver §10)
├── VAULT-STARTER.md           ← este archivo (queda como referencia)
├── src/                       ← tu trabajo (código, manuscrito, análisis…)
└── Vault/
    ├── SCHEMA.md              ← el modelo de trabajo (este contenido, §2–§8)
    ├── 00-Index.md            ← catálogo: una línea por página
    ├── LOG.md                 ← bitácora append-only
    ├── 10-Knowledge/          ← QUÉ es el proyecto (diseño, dominio)
    ├── 20-State/              ← DÓNDE está el proyecto
    │   ├── Current-State.md   ← punto de entrada de TODA sesión
    │   ├── Task-Board.md      ← tablero de tareas por frente
    │   ├── Lecciones.md       ← anti-patrones + entorno técnico
    │   └── Decisiones/        ← ADRs (decisiones estructurales)
    ├── 30-Loops/              ← CÓMO se trabaja (procedimientos)
    └── 90-Raw/                ← fuentes inmutables (nadie las edita jamás)
```

| Capa | Dónde | Qué contiene | Quién escribe |
|---|---|---|---|
| **Raw** | `90-Raw/` | Fuentes originales: documentos, transcripts, referencias, specs congeladas, reviews del humano *verbatim* | El humano deposita; **nadie edita jamás** |
| **Schema** | `SCHEMA.md` | Convenciones, plantillas, contratos de loop | Co-autoría humano+agente; cambia despacio |
| **Knowledge** | `10-Knowledge/` | Páginas atómicas del diseño/dominio, compiladas desde raw. Cambia lento. Describe cómo FUNCIONA el proyecto, nunca su progreso | El agente compila; **el humano ratifica** |
| **State** | `20-State/` | Dónde está el proyecto: milestone, tareas, bloqueos, deuda, decisiones recientes, próxima prioridad. Nunca explica el diseño | El agente, después de **cada** tarea |
| **Execution** | `30-Loops/` | Procedimientos operativos reutilizables. No contiene conocimiento: contiene procesos | Co-autoría; evolucionan por retroalimentación |
| **Navegación** | `00-Index.md`, `LOG.md` | Catálogo + bitácora | El agente, en cada operación |

**El Vault como máquina de estados:** cada loop es una transición
`Estado A → Loop → Estado B`, con estado de entrada, condiciones,
resultados esperados y estado de salida. El agente nunca ejecuta un loop
cuyo estado de entrada no se cumple.

---

## §4 — Navegación: Index y LOG

- **`00-Index.md`** — una línea por página con resumen, agrupada por capa.
  **Se lee primero en toda consulta.** A escala moderada (~300 páginas)
  sustituye cualquier infraestructura de búsqueda/embeddings — no la
  construyas antes de necesitarla.
- **`LOG.md`** — bitácora **append-only** (las entradas nuevas van arriba;
  las viejas no se reescriben). Formato parseable:

  ```
  ## [YYYY-MM-DD] op | título corto
  Párrafo(s) con lo que pasó, decisiones y punteros.
  ```

  donde `op ∈ {ingest, design, build, review, lint, state}` (adapta el
  conjunto a tu dominio).

---

## §5 — Plantilla de página (Knowledge y State)

```markdown
---
status: ratificado | propuesto | borrador
source: "de dónde viene (fuente raw, sesión, decisión)"
updated: YYYY-MM-DD
---

# Título

Contenido. Enlazar densamente con [[wikilinks]] a toda página relacionada.
```

- `ratificado` = bendecido por el humano; **solo un Design Loop lo cambia**.
- `propuesto` = escrito por el agente, esperando ratificación.
- `borrador` = trabajo en curso, muta libremente.
- Un `[[wikilink]]` a una página inexistente **no es un error**: marca
  trabajo pendiente (el Lint Loop lo recoge).

---

## §6 — Los loops (contratos, no conversaciones)

Cada archivo en `30-Loops/` define: **Objetivo · Estado de entrada · Fases ·
Validación · Artefactos que actualiza · Estado de salida**. Si un loop
produce errores repetidos, **se mejora el loop, no solo el resultado** — el
sistema aprende de sí mismo. Estructura interna típica de cualquier loop
(VDD): leer estado → leer docs relevantes → planear (impacto/riesgos/
archivos) → implementar → validar → actualizar Vault → notificar siguiente
estado.

Los 5 loops base (adapta nombres a tu dominio):

**Ingest Loop** — fuente nueva → conocimiento compilado.
Entrada: archivo nuevo en `90-Raw/`. Fases: leer Current-State + Index;
leer la fuente completa (NUNCA editarla); crear/actualizar las páginas
Knowledge afectadas (un ingest puede tocar 10–15 páginas) con status
`propuesto` (o `ratificado` solo si la fuente ya viene bendecida);
interlinkear; **señalar contradicciones explícitamente, jamás resolverlas
en silencio**. Salida: conocimiento compilado; contradicción → Design Loop.

**Design Loop** — frente de diseño abierto → decisión ratificada.
Entrada: un ítem elegido por el humano o una contradicción detectada.
Fases: leer estado + páginas afectadas + raw relevante; **proponer con
recomendación** (opciones argumentadas, no encuestas exhaustivas); iterar
con el humano; escribir el resultado como `propuesto`; **ratificación
explícita del humano** → `ratificado`; propagar coherencia a toda página
enlazada. Decisión estructural → ADR en `20-State/Decisiones/` (título,
fecha, contexto, alternativas, razón, consecuencias, estado).

**Build Loop** — tarea de trabajo → entregable con gates verdes.
Entrada: tarea del Task-Board con criterios de aceptación y specs
`ratificado`. Fases: leer Current-State + **Lecciones (obligatorio antes de
empezar)** + specs; planear; ejecutar en branch propio con cambios
mínimos; **gates de validación** (los checks propios del proyecto —
defínelos y automatízalos pronto); actualizar Task-Board + Current-State +
LOG + Lecciones si algo dolió; checkpoint. Salida: tarea ✅.

**Review Loop** — de "funciona" a "está bien" (calidad subjetiva).
Entrada: entregable con gates verdes cuyo valor es cualitativo (UX,
estética, redacción, tono). Fases: generar evidencia revisable barata
(capturas, borradores, prototipos, demos — iterar sobre artefactos, no en
vivo); ajustar; cuando convence, **revisión en vivo del humano**; capturar
su feedback como ítems concretos; iterar. Cierre = aceptación explícita
registrada.

**Lint Loop** — salud del Vault (periódico).
Buscar: contradicciones (entre páginas, y entre páginas y los entregables);
wikilinks rotos (= backlog, listar sin borrar) y páginas huérfanas; status
desactualizados; Index vs. realidad (toda página en el Index y viceversa);
State vs. repo (Current-State refleja el branch/commit real). Fixes menores
en el momento; contradicciones de diseño → Design Loop.

---

## §7 — Current-State, Lecciones y la rutina de cierre de sesión

Estos tres mecanismos son los que hacen que el sistema sobreviva al cambio
de sesión, de contexto y hasta de modelo. Son la parte más importante de
todo el método.

### Current-State.md — el punto de entrada

Describe SOLO dónde está el proyecto (milestone, qué se cerró, qué está en
curso, qué está bloqueado y con qué sospecha, deuda visible, riesgos) y
**termina siempre con una sección "ARRANQUE DE LA PRÓXIMA SESIÓN"**: qué
sigue, en qué orden, y **qué decisiones esperan al humano** (lista
explícita). Un agente que arranca en frío — posiblemente OTRO modelo — debe
poder continuar leyendo solo `CLAUDE.md → Current-State.md`, sin perder
ninguna decisión. Se actualiza tras **cada** tarea, no solo al final. Se
**sobrescribe** (refleja el presente); la historia vive en el LOG.

### Lecciones.md — la memoria dura

Anti-patrones técnicos y datos del entorno, ganados con dolor real. Cada
entrada es una regla accionable con su porqué (ej.: "nunca X — en tal fecha
causó Y; hacer Z en su lugar"). Reglas de mantenimiento:

- **Lectura obligatoria antes de empezar a ejecutar** (todo Build Loop, y en
  el brief de todo subagente ejecutor).
- Si una sesión paga una lección nueva, **se escribe ANTES de cerrar** — una
  lección no escrita se volverá a pagar.
- Se **sobrescribe/refina**: si una lección resulta incompleta o queda
  obsoleta, se corrige o retira en el momento (no es append-only; es la
  versión VIVA del cuidado operativo). Incluye también una sección "Entorno"
  (rutas, comandos de build/test, gates de calidad, peculiaridades de la
  máquina).

### La rutina de cierre de sesión (checklist de 6 pasos)

Ejecutar al final de cada sesión — y en versión reducida (checkpoint) tras
CADA tarea, porque las sesiones largas mueren por compaction, límites de
tokens o cambios de modelo sin avisar:

1. **`Current-State.md` refleja la realidad** — incluida la sección de
   ARRANQUE (qué sigue, qué decisión espera al humano, qué quedó bloqueado
   y con qué sospecha).
2. **`LOG.md`**: una entrada por operación de la sesión (`op | título`).
3. **`00-Index.md`**: al día si hubo páginas nuevas, movidas o re-descritas.
4. **`Lecciones.md`**: si la sesión pagó una lección, se escribe antes de
   cerrar.
5. **Working tree limpio**: commit descriptivo + push del branch de trabajo.
   Nada queda sin commitear salvo decisión explícita del humano (y se anota
   en Current-State como WIP).
6. **Nada se reporta como terminado sin evidencia** — gates verdes o
   artefactos revisables; lo no verificado se marca "pendiente de VoBo".

---

## §8 — Orquestación (opcional pero rentable)

- **Un solo orquestador** (el modelo más capaz disponible): lee el Vault,
  selecciona el loop, planifica, divide el trabajo, elige modelos, integra
  resultados y actualiza el estado. No debe implementarlo todo él mismo.
- **Tiering de modelos**: cada tarea usa el modelo más adecuado, no el más
  grande — lógica/arquitectura al modelo grande; ejecución mecánica
  (boilerplate, formateo, inventarios, QA repetitivo) a modelos
  medianos/chicos como subagentes. Paraleliza lo independiente.
- **Gate de validación antes de aprobar cualquier cambio**: los checks del
  proyecto en verde, documentación actualizada, State actualizado, backlog
  consistente. Solo entonces la máquina de estados avanza.

**Difiere a v2 (no lo construyas el día 1):** scheduler formal, contratos
de loop exhaustivos, orquestación multi-agente declarativa, búsqueda
BM25/embeddings (innecesaria bajo ~300 páginas). Empieza híbrido y
pragmático; el Lint Loop te dirá cuándo creciste.

---

## §9 — BOOTSTRAP (instrucciones para el agente)

Si un humano te pidió inicializar el Vault desde este archivo:

1. Pregunta (una sola tanda): nombre del proyecto, dominio (software,
   investigación, escritura, producto, operaciones… lo que sea), qué fuentes
   raw existen ya, y cómo se valida un entregable en este proyecto (tests,
   revisión, criterios de aceptación…).
2. Crea la estructura de §3 (carpeta `Vault/` o en la raíz, a gusto del
   humano — respeta lo que ya exista).
3. Genera `SCHEMA.md` con el contenido de §2–§8 de este archivo (adaptando
   nombres de loops al dominio).
4. Genera semillas: `00-Index.md` (catálogo inicial), `LOG.md` (primera
   entrada: `state | Vault inicializado`), `Current-State.md` (estado real
   actual + ARRANQUE), `Task-Board.md` (frentes vacíos o migrando el backlog
   existente), `Lecciones.md` (sección Entorno con build/test/rutas), los 5
   loops de §6 como archivos en `30-Loops/`.
5. Genera o actualiza `CLAUDE.md` con el bloque de §10.
6. Si hay fuentes existentes (README, specs, docs): ejecuta un primer
   Ingest Loop para compilarlas a Knowledge.
7. Cierra con la rutina de §7 (incluido el primer commit).

---

## §10 — CLAUDE.md sugerido (copia y adapta)

```markdown
# <PROYECTO> — reglas del repo

1. Toda sesión empieza leyendo `Vault/20-State/Current-State.md`.
2. El modelo de trabajo (capas, loops, plantillas) está en
   `Vault/SCHEMA.md` — toda operación sigue un loop de `Vault/30-Loops/`.
3. Las fuentes de `Vault/90-Raw/` son inmutables — jamás se editan. La
   verdad viva vive en `10-Knowledge/`; el estado, en `20-State/`.
4. Ningún loop termina sin actualizar `00-Index.md`, `LOG.md` y
   `Current-State.md` (checkpoint tras CADA tarea; rutina completa de
   cierre en SCHEMA §7).
5. Lecciones obligatorias antes de empezar a ejecutar:
   `Vault/20-State/Lecciones.md`.
6. El humano cura y decide; el agente escribe, enlaza y reconcilia. Nada
   `ratificado` se cambia sin Design Loop.
```

---

## §11 — Consejos de campo (pagados con sesiones reales)

- **Las reviews del humano se archivan *verbatim* en `90-Raw/`** y se usan
  como checklist de aceptación — no las parafrasees al compilarlas.
- **El LOG lleva lo que pasó; Current-State lleva lo que ES.** Si te
  descubres narrando historia en Current-State, muévela al LOG.
- **Registra también los WIP y los bloqueos** con la sospecha diagnóstica
  ("se cuelga; sospecha: contención de recursos; próximo paso: X") — la
  sesión siguiente arranca investigando, no redescubriendo.
- **Sesiones paralelas se sincronizan por el Vault**, no por chat: la que
  decide escribe en Current-State/LOG y commitea; la otra hace pull y lee.
- **Nada se muestra al humano como terminado sin evidencia** (captura, test
  verde, demo). Marca "pendiente de VoBo" sin vergüenza.
- **Edita archivos del Vault solo con herramientas que preserven encoding**
  (UTF-8); los one-liners de shell tipo `Get-Content | Set-Content` en
  Windows corrompen acentos. Lección pagada.
- **Un `[[wikilink]]` roto es backlog, no basura.** El Lint Loop vive de
  ellos.
- La ratificación del humano es **explícita o no es** — "me gusta" en chat
  no cambia un status; pídela y regístrala con fecha.

---

*Generado desde un Vault vivo el 2026-07-13. Fuentes teóricas: "LLM-WIKI —
A Self-Maintaining Personal Knowledge Base Architecture Using LLMs"
(A. Karpathy) y "Vault-Driven Development v1.0". Licencia: compártelo y
adáptalo libremente.*
