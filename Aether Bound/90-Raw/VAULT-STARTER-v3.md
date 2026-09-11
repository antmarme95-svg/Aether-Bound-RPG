# VAULT-STARTER — Arranca tu proyecto con un Vault dirigido por IA (v3)

> **Qué es esto:** un archivo único y autocontenido para arrancar un proyecto
> bajo el método **VDD × LLM-WIKI**, ahora con **dieta de arranque** — el
> conocimiento vive en un Vault de markdown versionado, no en las
> conversaciones; el agente lo mantiene y el humano lo dirige; y el arranque
> de cada sesión se mide y se mantiene barato a propósito, no por accidente.
> Destilado de un proyecto real de desarrollo continuo a lo largo de meses
> bajo este esquema, y de tres fuentes: *LLM-WIKI* (A. Karpathy),
> *Vault-Driven Development v1.0*, y el playbook de optimización de contexto
> `project-context` (auditoría de tokens, niveles equipo/privado, puentes).
>
> **Cómo usarlo:** copia este archivo a la raíz de tu repositorio y dile a
> tu agente (Claude Code o equivalente):
> *"Lee VAULT-STARTER.md e inicializa el Vault de este proyecto."*
> La sección §10 contiene las instrucciones de bootstrap que el agente debe
> ejecutar, incluyendo extraer el script de auditoría de §9 a un archivo real.
> Todo lo demás es la teoría y los contratos que gobiernan el sistema
> después del arranque.

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

**El problema con los Vaults que sí se mantienen:** un Vault que crece sano
en *contenido* puede pudrirse en *costo* — cada sesión nueva puede terminar
pagando 100k+ tokens de arranque antes del primer mensaje, aunque la
auditoría de completitud salga perfecta. Un Vault completo y caro de leer
falla exactamente igual que uno incompleto: el humano deja de confiar en
que abrir sesión sea barato, y empieza a evitarlo.

**La síntesis (tres ideas, un sistema):**

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
3. **Dieta de arranque (project-context):** un Vault correcto puede seguir
   siendo un Vault caro. La completitud del contenido y el costo de leerlo
   son dos ejes independientes — se auditan y se optimizan por separado.
   Solo lo que de verdad se necesita en CADA sesión se auto-carga; el resto
   vive a una ruta de distancia. Esto se mide, no se estima a ojo.

**Separación estricta de roles** (el principio que sostiene todo):
**el humano cura y decide; el agente escribe, enlaza, reconcilia y vigila
el peso.**

**Principios VDD irrenunciables:**

- *Single Source of Truth* — la información permanente existe SOLO en el
  Vault. Nunca solo en conversaciones, ni solo en la memoria del modelo, ni
  solo en los entregables.
- *Reproducibilidad* — cualquier agente (incluso de otro proveedor, vía
  `AGENTS.md` — ver §5.5) debe poder continuar el proyecto leyendo
  únicamente el Vault. El sistema es agnóstico de modelo por diseño.
- *Mínimo cambio* — cambios pequeños, reversibles, fáciles de revisar.
- *Evidencia* — lo que no puede justificarse con información del Vault no se
  asume: se documenta o se pregunta.
- *Sincronización* — entregables, documentación, estado y backlog
  representan la misma realidad SIEMPRE.
- *Arranque barato* — el costo de abrir sesión es una métrica de primera
  clase, con semáforo propio (§9), no un efecto colateral que se revisa
  cuando "se siente lento".
- *Diagnóstico antes que acción* — confirmar que algo pasó (o que "se ve
  bien") no autoriza a escribir/ajustar. Un dato 0% o 100% poblado es
  sospechoso por igual: antes de concluir "nadie lo hace" o "no aplica",
  probar UNA escritura/lectura de prueba — a veces la causa es que es
  *imposible*, no que falte disciplina. Presenta el diagnóstico y espera luz
  verde explícita antes de tocar nada que otros dependan de leer.

---

## §2 — Regla de oro

> **Toda sesión empieza leyendo `Current-State.md`. Toda operación sigue un
> loop. Ningún loop termina sin actualizar `00-Index.md`, `LOG.md` y
> `Current-State.md`. El Vault no documenta el desarrollo: lo dirige — y su
> arranque se mantiene barato a propósito.**

(Versión VDD: *antes de modificar el proyecto, comprender el estado; antes
de cambiar el estado, seguir un loop; antes de finalizar un loop, actualizar
el Vault; antes de dar por sano el Vault, medir cuánto pesa arrancarlo.*)

---

## §3 — Estructura y capas

```
<TuProyecto>/
├── CLAUDE.md                  ← reglas de arranque (ver §10) — se auto-carga (hard)
├── AGENTS.md                  ← índice corto para otras IA (ver §5.5) — bajo demanda
├── VAULT-STARTER.md           ← este archivo (queda como referencia)
├── src/                       ← tu trabajo (código, manuscrito, análisis…)
└── Vault/
    ├── SCHEMA.md              ← el modelo de trabajo (este contenido, §2–§9) — bajo demanda
    ├── 00-Index.md            ← catálogo: una línea por página — bajo demanda
    ├── LOG.md                 ← bitácora append-only, EQUIPO (curada) — bajo demanda
    ├── 10-Knowledge/          ← QUÉ es el proyecto (diseño, dominio) — bajo demanda
    ├── 20-State/              ← DÓNDE está el proyecto
    │   ├── Current-State.md   ← punto de entrada de TODA sesión — se auto-carga (soft), techo ~2,500 tokens
    │   ├── Task-Board.md      ← tablero de tareas por frente — bajo demanda
    │   ├── Lecciones.md       ← anti-patrones + entorno técnico — lectura obligatoria antes de ejecutar
    │   ├── Notas-Privadas.md  ← 🔴 PRIVADO, gitignored: estrategia, contexto crudo (ver §5.5)
    │   ├── Bitacora-Privada.md← 🔴 PRIVADO, gitignored: diario crudo append-only (ver §5.5)
    │   └── Decisiones/        ← ADRs (decisiones estructurales) — bajo demanda
    ├── 30-Loops/              ← CÓMO se trabaja (procedimientos) — bajo demanda
    ├── 90-Raw/                ← fuentes inmutables (nadie las edita jamás)
    └── scripts/
        └── check_vault.py     ← auditoría de peso de arranque (ver §9), extraído en bootstrap
```

| Capa | Dónde | Qué contiene | Quién escribe | Nivel |
|---|---|---|---|---|
| **Raw** | `90-Raw/` | Fuentes originales: documentos, transcripts, referencias, specs congeladas, reviews del humano *verbatim* | El humano deposita; **nadie edita jamás** | 🟢 equipo* |
| **Schema** | `SCHEMA.md` | Convenciones, plantillas, contratos de loop | Co-autoría humano+agente; cambia despacio | 🟢 equipo |
| **Knowledge** | `10-Knowledge/` | Páginas atómicas del diseño/dominio, compiladas desde raw. Cambia lento. Describe cómo FUNCIONA el proyecto, nunca su progreso | El agente compila; **el humano ratifica** | 🟢 equipo |
| **State** | `20-State/` | Dónde está el proyecto: milestone, tareas, bloqueos, deuda, decisiones recientes, próxima prioridad. Nunca explica el diseño | El agente, después de **cada** tarea | mixto (ver abajo) |
| **Execution** | `30-Loops/` | Procedimientos operativos reutilizables. No contiene conocimiento: contiene procesos | Co-autoría; evolucionan por retroalimentación | 🟢 equipo |
| **Navegación** | `00-Index.md`, `LOG.md` | Catálogo + bitácora curada | El agente, en cada operación | 🟢 equipo |
| **Privado** | `20-State/Notas-Privadas.md`, `Bitacora-Privada.md` | Estrategia cruda, contexto de cliente, diario honesto — nunca se comparte | El agente, a pedido; el humano, libremente | 🔴 privado |
| **Torre de control** | `PROYECTOS.md` (fuera del repo, en tu carpeta de trabajo) | Panorama de TODOS tus proyectos | El humano principalmente | 🔴 privado |

`*` — si una fuente en `90-Raw/` contiene información sensible (ej. una
review con contexto de cliente crudo), táchala como 🔴 en `00-Index.md` y
no la subas a un repo compartido; el resto de Raw es equipo por defecto.

**El Vault como máquina de estados:** cada loop es una transición
`Estado A → Loop → Estado B`, con estado de entrada, condiciones,
resultados esperados y estado de salida. El agente nunca ejecuta un loop
cuyo estado de entrada no se cumple.

### §3.5 — Acceso al Vault: filesystem antes que el MCP de tu app de notas

Si tu Vault vive en una app con su propio MCP (Obsidian, Notion, etc.), **el
agente debería tocarlo por filesystem** (leer/escribir el `.md` directamente)
en vez de por ese MCP, salvo que necesites una función que solo el MCP
expone. Motivo, pagado en un proyecto real: el MCP de una app de notas puede
**desincronizarse a media sesión sin ningún error visible** — devuelve
contenido fantasma (un archivo que en disco tiene páginas de historia
aparece con solo el último párrafo, un listado de directorio muestra 2 de 24
archivos) mientras el resto del Vault sigue intacto en disco. Si algo se ve
raro (pocos archivos, contenido corto) tras usar el MCP, **verifica contra
el filesystem antes de asumir pérdida de datos** — probablemente el MCP es
el que está roto, no el Vault.

Segundo riesgo de la misma familia: un **Vault anidado** (una subcarpeta del
repo que la app trata como Vault independiente, ej. `.obsidian/` propio en
`Proyectos/<X>/`) puede quedar registrado en la configuración **global** de
la app aunque lo borres del filesystem — cada arranque de la app se lo
reabre y regenera la carpeta de la nada, semanas después de haberlo dado por
resuelto. Cuando el síntoma es "algo que ya se había borrado vuelve a
aparecer solo", sospecha de un registro externo al repo (el archivo de
config global de la app), no solo del filesystem/git; la corrección real se
hace desde el selector de Vaults de la app, nunca editando su config a mano
mientras puede estar corriendo.

---

## §4 — Navegación: Index y LOG

- **`00-Index.md`** — una línea por página con resumen, agrupada por capa.
  **Se lee primero en toda consulta.** A escala moderada (~300 páginas)
  sustituye cualquier infraestructura de búsqueda/embeddings — no la
  construyas antes de necesitarla.
- **`LOG.md`** — bitácora **append-only** (las entradas nuevas van arriba;
  las viejas no se reescriben), **curada y de equipo** (🟢). Formato
  parseable:

  ```
  ## [YYYY-MM-DD] op | título corto
  Párrafo(s) con lo que pasó, decisiones y punteros.
  ```

  donde `op ∈ {ingest, design, build, review, lint, state}` (adapta el
  conjunto a tu dominio). Distinto de `Bitacora-Privada.md` (§5.5): el LOG
  es lo que el equipo necesita saber que pasó; la bitácora privada es tu
  diario crudo — de ahí puede salir, curado, una entrada del LOG.

---

## §5 — Plantilla de página (Knowledge y State)

```markdown
---
status: ratificado | propuesto | borrador
source: "de dónde viene (fuente raw, sesión, decisión)"
updated: YYYY-MM-DD
access: equipo | privado        <!-- default: equipo. Márcalo privado explícitamente -->
---

# Título

Contenido. Enlazar densamente con [[wikilinks]] a toda página relacionada.
```

- `ratificado` = bendecido por el humano; **solo un Design Loop lo cambia**.
- `propuesto` = escrito por el agente, esperando ratificación.
- `borrador` = trabajo en curso, muta libremente.
- Un `[[wikilink]]` a una página inexistente **no es un error**: marca
  trabajo pendiente (el Lint Loop lo recoge).
- `access: privado` en una página de `10-Knowledge/` es una señal de alerta:
  casi siempre esa página debería vivir en `Notas-Privadas.md` en lugar de
  mezclarse con conocimiento compartido. Úsalo solo como bandera transitoria
  mientras la mueves.

### §5.5 — Niveles de acceso: equipo vs privado

- 🟢 **Equipo** (git-tracked, todo el Vault salvo lo listado abajo): lo que
  cualquier colaborador o IA del equipo necesita. Sin secretos, sin
  estrategia cruda, sin contexto de cliente sin filtrar.
- 🔴 **Privado** (gitignored o fuera del repo): `20-State/Notas-Privadas.md`
  (estrategia real, contexto de cliente/político, pendientes personales),
  `20-State/Bitacora-Privada.md` (diario crudo, append-only, de donde sale
  el resumen curado del LOG), y `PROYECTOS.md` (torre de control — vive
  fuera de cualquier repo, en tu carpeta de trabajo general).

**Seguridad de los privados:**
- **`.gitignore` con glob, no línea literal:** `Notas-Privadas*` y
  `Bitacora-Privada*` cubren el archivo y cualquier split futuro
  (`Bitacora-Privada-archivo/2026-07.md`) de una vez. Una línea literal es
  el diseño frágil que filtra confidenciales al crear variantes.
- **Verifica con `git check-ignore -q <archivo>`**, no leyendo el
  `.gitignore` a ojo — un glob no aparece como string literal en el
  archivo. El script de §9 lo hace por ti.
- **Nunca credenciales en ningún `.md`** — solo *referencias* a dónde viven
  (gestor de secretos). Si una credencial ya se filtró a git: **rótala y
  purga el historial** — estar en un commit viejo es estar comprometida
  aunque borres el archivo hoy.

**AGENTS.md (opcional, puente multi-herramienta):** si tu equipo mezcla
Claude Code con Codex, Cursor, Gemini u otros, genera un `AGENTS.md` corto
en la raíz — apunta a `Current-State.md` → `CLAUDE.md`/`SCHEMA.md` →
`Lecciones.md`, sin duplicar reglas. Las reglas viven en un solo lugar
(`CLAUDE.md`); `AGENTS.md` es solo el índice de entrada para quien no lee
formato Claude-específico.

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
en silencio**; si la fuente no encaja claramente en ninguna página/categoría
existente, márcala "sin categorizar" en el LOG — **no la adivines**. Salida:
conocimiento compilado; contradicción → Design Loop.
- **Fuentes recurrentes y homogéneas** (dailies, standups, el mismo tipo de
  reporte cada semana) van a una **bitácora** (una página que crece
  cronológicamente), no a una página nueva por ocurrencia — páginas sueltas
  por sesión duplican y ensucian el Index. Reserva la página individual para
  fuentes densas y distintas entre sí (ej. una sesión de diseño larga).
- **Un resumen automático de la fuente (transcripción, meeting notes) puede
  subcubrir sesiones largas o densas sin avisarlo.** Antes de compilar desde
  un `summary`, revisa el tamaño del verbatim disponible; si la fuente es
  larga o estratégica, lee el verbatim por rangos y compila de ahí — el
  resumen automático sirve para fuentes cortas y homogéneas, no para todas.

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

**Lint Loop** — salud del Vault (periódico). Dos ejes independientes:
1. *Completitud/coherencia* — contradicciones (entre páginas, y entre
   páginas y los entregables); wikilinks rotos (= backlog, listar sin
   borrar) y páginas huérfanas; status desactualizados; Index vs. realidad
   (toda página en el Index y viceversa); State vs. repo (Current-State
   refleja el branch/commit real).
2. *Peso de arranque* (§9) — corre `check_vault.py`; si el semáforo sale
   🟡/🔴, es trabajo de este mismo loop aunque no falte ni sobre ningún
   archivo. Ver §9 para las palancas ordenadas por fricción.

Fixes menores en el momento; contradicciones de diseño → Design Loop; peso
de arranque alto → aplicar palancas de §9.

### §6.5 — Loops automatizados (tareas programadas/cron)

Cuando un loop corre solo, sin humano en el prompt (una tarea programada,
un cron), su definición canónica suele vivir **fuera del Vault** (en el
scheduler de tu herramienta de IA), y el archivo espejo en `30-Loops/` es
solo de lectura para el humano. Esto crea un riesgo específico que un loop
manual no tiene: **el espejo puede driftear del schema real sin que nadie lo
note**, porque nadie edita el archivo fuente en cada cambio de estructura
del Vault (ej. una migración de layout). Señal típica: una corrida instruye
leer una ruta que ya no existe, y en vez de corregir el archivo fuente,
cada corrida "lo parcha al vuelo" — el mismo error reaparece semanas después
porque el archivo fuente sigue apuntando a lo viejo. Cuando una corrida
detecta que su propia definición apunta a algo obsoleto, no basta con
improvisar esa corrida: **corrige el archivo fuente** (o dilo como tarea
explícita) para que no se repita. Si tu scheduler no permite elegir modelo
por tarea, documenta en Lecciones cuál es el modelo mínimo viable con el que
SÍ corren todas las rutinas — no asumas que puedes bajar de ahí.

Vale la pena, además, un lugar para **patrones compartidos entre varios
loops** — no todo conocimiento operativo es un loop completo (Objetivo →
Fases → Estado de salida); a veces son 3-5 pasos que 2-3 loops distintos
repiten con la misma fricción (ej. "cómo generar un correo desde el estado
del Vault", usado por tres rutinas de distinto horario). Documentarlo una
vez en un archivo de patrón (`30-Loops/Patrones/<nombre>.md`, referenciado
por los loops que lo usan) evita que cada loop nuevo reinvente los mismos
pasos y la misma fricción.

---

## §7 — Current-State, Lecciones y la rutina de cierre de sesión

Estos tres mecanismos son los que hacen que el sistema sobreviva al cambio
de sesión, de contexto y hasta de modelo. Son la parte más importante de
todo el método.

### Current-State.md — el punto de entrada (y la pieza que se auto-carga)

Describe SOLO dónde está el proyecto (milestone, qué se cerró, qué está en
curso, qué está bloqueado y con qué sospecha, deuda visible, riesgos) y
**termina siempre con una sección "ARRANQUE DE LA PRÓXIMA SESIÓN"**: qué
sigue, en qué orden, y **qué decisiones esperan al humano** (lista
explícita). Un agente que arranca en frío — posiblemente OTRO modelo — debe
poder continuar leyendo solo `CLAUDE.md → Current-State.md`, sin perder
ninguna decisión.

**Techo ~2,500 tokens.** Se lee al abrir cada sesión (por instrucción/
protocolo, aunque el harness no lo auto-inyecte como a `CLAUDE.md` — es
"soft-load": el costo real es el mismo si el protocolo se respeta). Es la
palanca más sensible de la dieta de arranque (§9): un `Current-State.md`
que narra CÓMO llegamos aquí crece sin techo. Si te descubres narrando
historia aquí, muévela a `LOG.md` (curado) o a `Vault/20-State/
Estado-Historico.md` (archivo, opcional). Se **sobrescribe** (refleja el
presente); la historia vive en el LOG.

### Lecciones.md — la memoria dura

Anti-patrones técnicos y datos del entorno, ganados con dolor real. Cada
entrada es una regla accionable con su porqué (ej.: "nunca X — en tal fecha
causó Y; hacer Z en su lugar"). Reglas de mantenimiento:

- **Lectura obligatoria antes de empezar a ejecutar** (todo Build Loop, y en
  el brief de todo subagente ejecutor) — deliberadamente NO se auto-carga:
  es de bajo-demanda pero de lectura forzada por protocolo, no por harness.
- Si una sesión paga una lección nueva, **se escribe ANTES de cerrar** — una
  lección no escrita se volverá a pagar.
- Se **sobrescribe/refina**: si una lección resulta incompleta o queda
  obsoleta, se corrige o retira en el momento (no es append-only; es la
  versión VIVA del cuidado operativo). Incluye también una sección "Entorno"
  (rutas, comandos de build/test, gates de calidad, peculiaridades de la
  máquina).

### Disciplina de fecha

**La fecha de "hoy" nunca sale del prompt, del nombre de un archivo ni de la
memoria del agente — se corre el comando de fecha del sistema en el primer
turno que vaya a escribir algo fechado** (un archivo en `90-Raw/`, una
entrada de `LOG.md`, un `updated:` de frontmatter, una nota en un sistema
externo). Un prompt escrito el viernes y ejecutado el lunes es una fuente de
fecha tan desactualizada como un reloj de sesión — y una corrida larga
(reintentos, fallos de red) puede cruzar medianoche a mitad de ejecución, así
que si la sesión se alarga mucho, vuelve a correr el comando de fecha antes
de fijar la fecha de captura de cualquier snapshot nuevo. Cuando el artefacto
fechado ya salió a un sistema externo (un comentario posteado, un correo
enviado) con la fecha equivocada, corregirlo cuesta una escritura en
producción — razón de más para verificar la fecha ANTES del primer `create`,
no después.

### La rutina de cierre de sesión (checklist de 7 pasos)

Ejecutar al final de cada sesión — y en versión reducida (checkpoint) tras
CADA tarea, porque las sesiones largas mueren por compaction, límites de
tokens o cambios de modelo sin avisar:

1. **`Current-State.md` refleja la realidad** — incluida la sección de
   ARRANQUE (qué sigue, qué decisión espera al humano, qué quedó bloqueado
   y con qué sospecha) — y sigue bajo el techo de ~2,500 tokens.
2. **`LOG.md`**: una entrada por operación de la sesión (`op | título`).
3. **`00-Index.md`**: al día si hubo páginas nuevas, movidas o re-descritas.
4. **`Lecciones.md`**: si la sesión pagó una lección, se escribe antes de
   cerrar.
5. **`Bitacora-Privada.md`** (si la usas): una entrada cruda de la sesión —
   nunca se sube al repo.
6. **Working tree limpio**: commit descriptivo + push del branch de trabajo.
   Nada queda sin commitear salvo decisión explícita del humano (y se anota
   en Current-State como WIP).
7. **Nada se reporta como terminado sin evidencia** — gates verdes o
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
- **Verifica que un reintento anunciado en el chat de verdad se ejecutó** —
  no solo que se redactó la intención. Es fácil que un agente orquestador
  "diga" que va a relanzar un subagente y nunca emita la llamada. Confirma
  con evidencia externa (¿el archivo que ese subagente debía escribir
  existe?), no con la propia narración del turno anterior.
- **Un subagente en background que se estanca no predice su tamaño de
  tarea** — uno con datos triviales puede colgarse igual que uno que pagina
  miles de registros. Tras **2 reintentos fallidos** (error o timeout) del
  mismo agente, deja de relanzarlo a ciegas y ejecuta la consulta
  **directamente en el hilo principal** (misma llamada, mismo procesamiento
  determinista si el resultado excede el límite de tokens) — es más rápido
  que un tercer intento, y evita que el agente fantasma reaparezca después
  e intente sobrescribir un archivo que ya arreglaste a mano.
- **Si tu orquestación corre como tarea programada (cron/scheduler) sobre el
  mismo filesystem que usas interactivamente, verifica que SÍ pueda escribir
  sobre archivos preexistentes del Vault**, no solo crear archivos nuevos —
  algunos entornos (permisos de sesión heredados del SO) dejan crear pero no
  editar, y el síntoma es un error de permisos silencioso o poco claro en
  Read/Edit/git sobre archivos que ya existían antes de que la tarea
  programada corriera por primera vez. Pruébalo con una escritura trivial
  antes de confiarle un loop completo.

**Difiere a v4 (no lo construyas el día 1):** scheduler formal, contratos
de loop exhaustivos, orquestación multi-agente declarativa, búsqueda
BM25/embeddings (innecesaria bajo ~300 páginas). Empieza híbrido y
pragmático; el Lint Loop (§6) te dirá cuándo creciste.

---

## §9 — Dieta de arranque: auditoría, semáforo y palancas

Esto es lo que aporta `project-context` al método: una métrica objetiva
para "¿este Vault pesa demasiado?" — en vez de esperar a que la sesión "se
sienta lenta".

### 9.1 — Medir (solo lectura)

Extrae el script de abajo a `Vault/scripts/check_vault.py` (paso de
bootstrap, §10) y corre:

```bash
python3 Vault/scripts/check_vault.py --json
```

```python
#!/usr/bin/env python3
"""Auditoría de salud y peso de arranque del Vault (VAULT-STARTER §9).

Solo lectura. Reporta, por archivo: existe/falta/viejo, nivel
(equipo/privado), peso en tokens estimados, y si se auto-carga al arrancar
la sesión (hard/soft/no). Y a nivel proyecto: TOTAL de tokens de arranque
con semáforo, @imports detectados en CLAUDE.md, estado de git, si los
privados están realmente ignorados (git check-ignore real), y si el Vault
es colaborativo (varios autores tocan Current-State.md/LOG.md/CLAUDE.md).

Uso:
    python3 check_vault.py [ruta]          # tabla legible (default: cwd)
    python3 check_vault.py [ruta] --json   # JSON para que lo consuma el LLM
"""
import os, sys, re, json, subprocess, datetime

OLD_DAYS = 14
CURRENT_STATE_CEILING = 2500   # techo sugerido para Current-State.md
ARRANQUE_VERDE = 10000
ARRANQUE_AMARILLO = 30000

DATE_RE = re.compile(r"(\d{4})-(\d{2})-(\d{2})")
IMPORT_RE = re.compile(r"^@(\S+)", re.MULTILINE)  # sintaxis @import de Claude Code

# (ruta relativa, nivel, ¿chequear antigüedad?, autoload: hard/soft/no)
MANIFEST = [
    ("CLAUDE.md",                         "equipo",  False, "hard"),
    ("AGENTS.md",                         "equipo",  False, "no"),
    ("Vault/SCHEMA.md",                   "equipo",  False, "no"),
    ("Vault/00-Index.md",                 "equipo",  False, "no"),
    ("Vault/LOG.md",                      "equipo",  False, "no"),
    ("Vault/20-State/Current-State.md",   "equipo",  True,  "soft"),
    ("Vault/20-State/Lecciones.md",       "equipo",  False, "no"),
    ("Vault/20-State/Notas-Privadas.md",       "privado", False, "no"),
    ("Vault/20-State/Bitacora-Privada.md",     "privado", True,  "no"),
]
PRIVADOS_GITIGNORE = ["Vault/20-State/Notas-Privadas.md", "Vault/20-State/Bitacora-Privada.md"]
CONTEXT_LOGS = ["Vault/20-State/Current-State.md", "Vault/LOG.md", "CLAUDE.md"]


def estimar_tokens(path):
    try:
        return os.path.getsize(path) // 4
    except OSError:
        return 0


def fecha_mas_reciente(path):
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            head = f.read(4000)
    except OSError:
        return None
    fechas = []
    for y, m, d in DATE_RE.findall(head):
        try:
            fechas.append(datetime.date(int(y), int(m), int(d)))
        except ValueError:
            pass
    return max(fechas) if fechas else None


def estado_archivo(full, check_age):
    if not os.path.isfile(full):
        return "falta", None
    if check_age:
        fecha = fecha_mas_reciente(full)
        if fecha is not None:
            edad = (datetime.date.today() - fecha).days
            return ("viejo" if edad > OLD_DAYS else "existe"), f"última fecha {fecha.isoformat()} ({edad}d)"
    return "existe", None


def detectar_imports(root):
    claude = os.path.join(root, "CLAUDE.md")
    if not os.path.isfile(claude):
        return []
    try:
        with open(claude, encoding="utf-8", errors="replace") as f:
            texto = f.read()
    except OSError:
        return []
    out = []
    for ruta in IMPORT_RE.findall(texto):
        full = os.path.join(root, ruta)
        out.append({"ruta": ruta, "existe": os.path.isfile(full),
                    "tokens": estimar_tokens(full) if os.path.isfile(full) else 0})
    return out


def git_check_ignore(root, archivo):
    try:
        r = subprocess.run(["git", "-C", root, "check-ignore", "-q", archivo],
                           capture_output=True, timeout=5)
        return r.returncode == 0
    except (subprocess.SubprocessError, OSError):
        return None


def detectar_colaborativo(root):
    autores = set()
    for archivo in CONTEXT_LOGS:
        full = os.path.join(root, archivo)
        if not os.path.isfile(full):
            continue
        try:
            r = subprocess.run(["git", "-C", root, "log", "--format=%an", "--", archivo],
                               capture_output=True, text=True, timeout=10)
            if r.returncode == 0:
                autores.update(l.strip() for l in r.stdout.splitlines() if l.strip())
        except (subprocess.SubprocessError, OSError):
            pass
    return (len(autores) > 1, sorted(autores))


def semaforo(tokens):
    if tokens < ARRANQUE_VERDE:
        return "verde"
    if tokens < ARRANQUE_AMARILLO:
        return "amarillo"
    return "rojo"


def construir_reporte(root):
    items = []
    for rel, level, check_age, autoload in MANIFEST:
        full = os.path.join(root, rel)
        status, nota = estado_archivo(full, check_age)
        tokens = estimar_tokens(full) if status != "falta" else 0
        item = {"file": rel, "level": level, "status": status, "nota": nota,
                "tokens": tokens, "autoload": autoload}
        if rel.endswith("Current-State.md") and status != "falta" and tokens > CURRENT_STATE_CEILING:
            item["sobre_techo"] = tokens - CURRENT_STATE_CEILING
        items.append(item)

    imports = detectar_imports(root)
    imports_tokens = sum(i["tokens"] for i in imports)

    arranque = sum(it["tokens"] for it in items if it["status"] != "falta" and it["autoload"] in ("hard", "soft"))
    arranque += imports_tokens

    es_git = os.path.isdir(os.path.join(root, ".git"))
    privados_protegidos = {p: git_check_ignore(root, p) for p in PRIVADOS_GITIGNORE} if es_git else {}
    colaborativo, autores = detectar_colaborativo(root) if es_git else (False, [])

    return {
        "root": root, "items": items, "imports": imports,
        "imports_tokens": imports_tokens, "arranque_tokens": arranque,
        "arranque_semaforo": semaforo(arranque),
        "current_state_ceiling": CURRENT_STATE_CEILING,
        "git": es_git, "colaborativo": colaborativo, "autores_contexto": autores,
        "privados_ignorados": privados_protegidos,
    }


def imprimir_tabla(r):
    icon = {"existe": "OK", "falta": "FALTA", "viejo": "VIEJO"}
    load_tag = {"hard": "hard", "soft": "soft", "no": "-"}
    sem = {"verde": "VERDE", "amarillo": "AMARILLO", "rojo": "ROJO"}
    print(f"\nVault: {r['root']}\n")
    for nivel, etiqueta in (("equipo", "EQUIPO (repo)"), ("privado", "PRIVADO")):
        print(etiqueta)
        for it in r["items"]:
            if it["level"] != nivel:
                continue
            nota = f"  - {it['nota']}" if it["nota"] else ""
            tok = f"{it['tokens']:>6,}t" if it["tokens"] else "     ."
            sobre = f"  +{it['sobre_techo']:,}t SOBRE TECHO" if it.get("sobre_techo") else ""
            print(f"  [{icon[it['status']]:>5}] {load_tag[it['autoload']]:>4} {tok}  {it['file']}{nota}{sobre}")
        print()
    print(f"[{sem[r['arranque_semaforo']]}] ARRANQUE DE SESION: ~{r['arranque_tokens']:,} tokens")
    if r["imports"]:
        print(f"\n@imports en CLAUDE.md (se auto-cargan): {r['imports_tokens']:,} tokens")
        for imp in r["imports"]:
            mark = "" if imp["existe"] else "  NO EXISTE"
            print(f"   @{imp['ruta']} - {imp['tokens']:,}t{mark}")
    print(f"\nRepo git: {'si' if r['git'] else 'no'}")
    if r["git"]:
        for p, ok in r["privados_ignorados"].items():
            mark = {True: "ignorado", False: "NO IGNORADO (fuga)", None: "?"}[ok]
            print(f"   {p}: {mark}")
        if r["colaborativo"]:
            print(f"   COLABORATIVO - autores: {', '.join(r['autores_contexto'])}")
            print("      -> NO reestructures Current-State.md/LOG.md; solo sacalos del auto-load.")
    print()


def main():
    argv = sys.argv[1:]
    as_json = "--json" in argv
    pos = [a for a in argv if not a.startswith("--")]
    root = os.path.abspath(pos[0]) if pos else os.getcwd()
    reporte = construir_reporte(root)
    print(json.dumps(reporte, ensure_ascii=False, indent=2)) if as_json else imprimir_tabla(reporte)


if __name__ == "__main__":
    main()
```

### 9.2 — Leer el diagnóstico

El semáforo de **arranque_tokens** es la métrica que importa, no si algún
archivo individual "se ve grande". 🟢 < 10,000 · 🟡 10,000–30,000 · 🔴 más de
30,000. Si sale 🟡/🔴, es trabajo del Lint Loop (§6) **aunque la auditoría de
completitud salga perfecta y no falte ningún archivo**.

### 9.3 — Palancas, ordenadas por fricción (ataca primero la de fricción cero)

1. **`@imports` → bajo demanda.** Quita `@` de los docs de `10-Knowledge/`
   que no se necesitan cada sesión (arquitectura ya construida, specs de
   features cerradas). Suele ser la palanca grande y de fricción cero: solo
   edita `CLAUDE.md`, no toca ningún contenido.
2. **Sacar `Bitacora-Privada.md`/`LOG.md` del hábito de auto-lectura** si tu
   protocolo los está leyendo completos cada vez. El ahorro viene de NO
   auto-cargarlos, no de recortarlos — pídele al agente que lea solo la
   última entrada.
3. **`Notas-Privadas.md`:** separa lo vivo de lo histórico/pesado a
   `Notas-Privadas-Archivo.md` (cubierto por el mismo glob). Fricción nula
   (es privado, tuyo).
4. **`Current-State.md` → techo.** Recorta a solo-presente; histórico
   verbatim a `Vault/20-State/Estado-Historico.md`. **Mayor fricción** si el
   Vault es colaborativo (ver 9.4).

### 9.4 — Ajustar por modo del Vault

- **Individual:** libertad para reestructurar.
- **Colaborativo** (el script lo marca vía autores en el historial de
  `Current-State.md`/`LOG.md`/`CLAUDE.md`): **NO reestructures
  `Current-State.md`/`LOG.md`** — son append/edición compartida;
  reestructurarlos choca con el próximo cambio de otro colaborador. Solo
  sácalos del auto-load, recorta con cuidado, y documenta el patrón nuevo en
  `CLAUDE.md`. Si el cambio va a la rama principal, avisa al equipo antes
  (sincronicen ramas).

### 9.5 — Salvaguardas al ejecutar

- **Cero pérdida de dato:** nada sale de un archivo sin aparecer íntegro en
  su destino; verifica con diff de contenido. Para archivos trackeados,
  contra `git show HEAD:`; para gitignored, contra una copia temporal.
- **Cero fuga de dato:** todo destino de contenido confidencial verificado
  con `git check-ignore` ANTES de escribirlo.
- **Trabaja en rama aparte** si es colaborativo (`chore/optimizar-vault`),
  no en la rama principal.
- **Presenta el plan y espera OK** antes de tocar nada; muestra el diff
  antes de commitear.
- **Verificar:** re-corre el script — confirma que el arranque bajó al
  verde y que `Current-State.md` está bajo techo; confirma con `git status`
  que los privados siguen fuera de git.

### 9.6 — Puentes (ofrecer, no imponer)

- **claude.ai / Projects:** genera `_contexto_para_chat.md` concatenando
  `CLAUDE.md` + `Current-State.md` + `SCHEMA.md`, para subir como knowledge
  a un Project. Avisa si algún archivo viene inflado (mismo criterio que
  §9.1: > ~5k tokens por archivo es señal de que se infló).
- **Hook de cierre de sesión (opcional):** un script no-bloqueante que
  recuerda los 7 pasos de §7 al terminar (evento `Stop`/`SessionEnd` en
  `.claude/settings.json`).
- **Aviso en `SessionStart` (opt-in):** solo si lo piden explícitamente.

---

## §10 — BOOTSTRAP (instrucciones para el agente)

Si un humano te pidió inicializar el Vault desde este archivo:

1. Pregunta (una sola tanda): nombre del proyecto, dominio (software,
   investigación, escritura, producto, operaciones… lo que sea), qué fuentes
   raw existen ya, cómo se valida un entregable en este proyecto (tests,
   revisión, criterios de aceptación…), y si el proyecto será **individual o
   colaborativo** (cambia la estrategia de §9.4 desde el día 1).
2. Crea la estructura de §3 (carpeta `Vault/` o en la raíz, a gusto del
   humano — respeta lo que ya exista).
3. Genera `SCHEMA.md` con el contenido de §2–§9 de este archivo (adaptando
   nombres de loops al dominio).
4. Genera semillas: `00-Index.md` (catálogo inicial), `LOG.md` (primera
   entrada: `state | Vault inicializado`), `Current-State.md` (estado real
   actual + ARRANQUE, bajo el techo de ~2,500 tokens), `Task-Board.md`
   (frentes vacíos o migrando el backlog existente), `Lecciones.md`
   (sección Entorno con build/test/rutas), los 5 loops de §6 como archivos
   en `30-Loops/`, y `AGENTS.md` si el proyecto mezclará herramientas de IA.
5. Extrae el script de §9.1 a `Vault/scripts/check_vault.py`. Córrelo una
   vez para tener la línea base de peso de arranque.
6. Genera o actualiza `CLAUDE.md` con el bloque de §11.
7. **Privacidad:** si hay repo git, asegura que `.gitignore` use los globs
   `Notas-Privadas*` y `Bitacora-Privada*` (crea el archivo si no existe);
   verifica con `git check-ignore`, no a ojo. Sin repo, anota que esos
   archivos quedan fuera de cualquier repo futuro. `PROYECTOS.md` (torre de
   control) vive fuera del repo, en la carpeta general de trabajo.
8. Si hay fuentes existentes (README, specs, docs): ejecuta un primer
   Ingest Loop para compilarlas a Knowledge.
9. Ofrece los puentes de §9.6 (no los impongas).
10. Cierra con la rutina de §7 (incluido el primer commit) y muestra el
    reporte de `check_vault.py` como línea base de arranque.

---

## §11 — CLAUDE.md sugerido (copia y adapta)

```markdown
# <PROYECTO> — reglas del repo

1. Toda sesión empieza leyendo `Vault/20-State/Current-State.md`.
2. El modelo de trabajo (capas, loops, plantillas, dieta de arranque) está
   en `Vault/SCHEMA.md` — toda operación sigue un loop de `Vault/30-Loops/`.
3. Las fuentes de `Vault/90-Raw/` son inmutables — jamás se editan. La
   verdad viva vive en `10-Knowledge/`; el estado, en `20-State/`.
4. Ningún loop termina sin actualizar `00-Index.md`, `LOG.md` y
   `Current-State.md` (checkpoint tras CADA tarea; rutina completa de
   cierre en SCHEMA §7).
5. Lecciones obligatorias antes de empezar a ejecutar:
   `Vault/20-State/Lecciones.md`.
6. Arranque de sesión barato por diseño: nada pesado se auto-carga vía
   `@import` salvo lo que se necesita en CADA sesión (ver SCHEMA §9). Si
   `check_vault.py` marca amarillo/rojo, es trabajo del Lint Loop.
7. Lo sensible va a `Vault/20-State/Notas-Privadas.md` o
   `Bitacora-Privada.md` (gitignored), nunca a un archivo de equipo.
8. El humano cura y decide; el agente escribe, enlaza, reconcilia y vigila
   el peso. Nada `ratificado` se cambia sin Design Loop.
9. Otras IA (Codex, Cursor…) entran por `AGENTS.md`, que apunta aquí — las
   reglas viven en un solo lugar.
```

---

## §12 — Consejos de campo (pagados con sesiones reales)

- **Las reviews del humano se archivan *verbatim* en `90-Raw/`** y se usan
  como checklist de aceptación — no las parafrasees al compilarlas.
- **El LOG lleva lo que pasó (curado, equipo); Current-State lleva lo que
  ES; la Bitácora Privada lleva lo crudo (tuyo).** Si te descubres narrando
  historia en Current-State, muévela al LOG o a la bitácora privada según
  si es de equipo o personal.
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
- **Un Vault completo puede seguir siendo un Vault caro.** Completitud y
  peso de arranque son dos ejes distintos — audítalos por separado
  (§9) y no confundas "no falta nada" con "arranca barato".
- **En Vault colaborativo, nunca reestructures `Current-State.md`/`LOG.md`
  para ahorrar tokens** — solo sácalos del auto-load. Reestructurar un
  archivo de append/edición compartida choca con el próximo cambio de otro
  colaborador; ya causó conflictos reales.
- La ratificación del humano es **explícita o no es** — "me gusta" en chat
  no cambia un status; pídela y regístrala con fecha.
- **Trabaja el Vault por filesystem, no por el MCP de tu app de notas**
  (ver §3.5) — es más rápido y no se desincroniza a media sesión.
- **La fecha de "hoy" se corre, nunca se hereda** de un prompt, un nombre de
  archivo o la memoria del agente (ver §7, Disciplina de fecha).
- **`write_uid`/"última modificación" dice quién tocó el registro AL
  ÚLTIMO, no quién ejecutó una acción concreta** — para atribuir una acción
  a una persona, busca el log de auditoría/actividad con autor y hora
  (chatter, audit log), no el campo de última escritura.

---

## §13 — Registro de cambios

**v3 — generada 2026-09-11**, a partir de ~2 meses de operación real de un
Vault bajo este esquema (29 lecciones pagadas, 9 ADRs, 7 loops automatizados
corriendo por scheduler). Adiciones sobre v2, todas trazables a incidentes
reales:
1. Principio VDD *Diagnóstico antes que acción* (§1).
2. §3.5 — Acceso por filesystem y riesgo de Vault anidado en apps de notas
   con MCP propio.
3. Ingest Loop: bitácora vs. página-por-sesión, y verificar tamaño del
   verbatim antes de confiar en un resumen automático (§6).
4. §6.5 — Loops automatizados (tareas programadas): drift del espejo vs. la
   definición fuente, y la noción de patrones compartidos entre loops.
5. §7 — Disciplina de fecha (correr el comando de fecha, nunca heredarla).
6. §8 — Verificar que un reintento anunciado se ejecutó de verdad; límite de
   2 reintentos para un subagente en background estancado antes de pasar la
   consulta al hilo principal; probar que una tarea programada puede
   escribir sobre archivos preexistentes, no solo crear nuevos.
7. §12 — Tres consejos de campo reforzando 1, 2 y 5, más el matiz de
   `write_uid` para atribución de acciones.

**v2 — generada 2026-07-20**, fusionando el VAULT-STARTER original
(2026-07-13) con el playbook de optimización de contexto `project-context`
(auditoría de tokens, niveles equipo/privado, puentes).

Fuentes teóricas: "LLM-WIKI — A Self-Maintaining Personal Knowledge Base
Architecture Using LLMs" (A. Karpathy), "Vault-Driven Development v1.0", y
el patrón probado de proyectos reales con arranque de sesión medido en
tokens. Licencia: compártelo y adáptalo libremente.
