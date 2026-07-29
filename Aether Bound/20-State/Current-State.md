---
status: vivo
updated: 2026-07-27
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

## Estado general (2026-07-28)

**Worldbuilding narrativo:** las 9 fichas de Pivote + los 3 fijos + Speck + toda la estructura política y geográfica están escritos. El vault soporta escribir guión en cuanto cierre el sprint QA.

**Sprint QA de reparación — Fase 5 en curso, 2 bloques restantes.** Relato completo de las fases 0-4 migrado a [[Current-State-Historico]] (2026-07-28); detalle operativo en [[LOG]]. Plan: `~/.claude/plans/cozy-floating-unicorn.md`.

- **✅ Fases 0-4 completas** — documentos-fuente reescritos (5 finales + Grove of Cycles + Acto 3 en 5 sub-beats + Reckoning), 9/9 fichas de Pivote al canon, lint mecánico, propagación semántica, y re-corrida de verificación que reveló los huecos de cobertura que la Fase 5 está cerrando.
- **✅ Fase 5 Bloque D** — canon "los 9 Pivotes existen simultáneamente" + regla de aparición como NPCs externos + caso Torgan/Bram; matriz de finales corregida; rename a `Los 5 Finales.md` (29 cross-refs).
- **✅ Fase 5 Bloque A** — Torgan (485→579 líneas) e Iven (511→767) reescritas. **9/9 fichas de Pivote migradas.** Torgan: F2b sin suavizar, beat Warden de oficio y linaje, aritmética 55 años, sección de segundo agente de la ruta Bram. Iven: mentira del Council explícita + §Las tres grietas, F2b corregido (el asentamiento muere), F1≠F4, único de los 9 que llora en escena.
  - **✅ Fase 5 Bloque B (2026-07-28)** — propagación completa a Roen/Valen/Darro. Bram ya no traiciona en las 3 fichas (beat del corredor del Archive, aritmética 40 años); las 3 migradas al eje de 5 finales (F1/F2a/F2b/F3/F4, destino de Speck); Roen separa traición (Archive) de quiebre (cráter) + edad corregida a 45; Valen con cosmología reencuadrada como creencia errónea de la Academy (beat en Grove of Cycles) + edad estandarizada a 230; Darro con rechazo-versión-Vekka (aprendiz 30 años atrás, 2 años, rechazo sin explicar) + sección Darro+Vekka reescrita + género de Speck corregido. Tablas de dinámicas: 7/9 entradas de raza/rol falsas corregidas en las 3 fichas (más de las 6 reportadas — Maren/Torgan/Iven también estaban mal). Detalle completo en [[LOG]].
  - **✅ Fase 5 Bloque C (2026-07-28)** — lint final cerrado. Headcount corregido en Lyris/Sereth/Nyael (solo Roen+Valen+Darro+Pivote, sin otros Pivotes en escena — consistente con "solo 1 conoce al jugador"); `Los 9 Pivotes.md` resincronizado (línea de Sereth y de Nyael ya no cruzadas); Sunken Archive = Acto 3; Grove of Cycles tras los 3 sub-actos; Bram 40 años en Estructura Política; Sereth "Royal Academy" en vez de "el Consejo" ambiguo; Geografía F2a/F2b desambiguado; Mistbound "suroeste profundo" en las 2 fichas; Torgan/Dagna ya no comparten "Clan de Forja" en Geografía; Vekka ya no tiembla (Roen); fórmula "primera vez en la historia registrada" desduplicada. **Sprint QA de reparación — Fase 5 CERRADA.** Detalle completo en [[LOG]].

- **✅ Segunda re-corrida (2026-07-28) — 12 críticos cerrados.** C1 + D1-D5, todos por decisión de Boris. Detalle en entradas previas de [[LOG]].

- **🔴 Tercera re-corrida (2026-07-28, post-ediciones-directas) — EL SPRINT SIGUE SIN CERRAR.** Lanzada tras procesar las ediciones directas de Boris en Nomenclatura/Speck/The Bound Five. Los 2 QAs re-corridos en frío con **Opus**: **4 CRÍTICOS de dramática (+1 MEDIUM) + 4 CRÍTICOS de congruencia (+2 MEDIUM) = 8 CRÍTICOS nuevos.** Reporte completo con citas textuales en [[LOG]].
  - **✅ Validado limpio (re-confirmado):** los 3 fixes de la 2ª re-corrida siguen en pie (Speck actora en Momentos, F2b elección activa, Nyael con antagonista funcional); Bram no traiciona; Speck femenina; Speck Warden anciana (0 residuos de "criatura joven"); los 9 existen simultáneamente/solo 1 conoce al jugador; Raza×Rol de los 9 correcta; Roen 45 cuadra.
  - **CRÍTICOS de dramática:**
    1. **Darro F1 (`Darro-Ficha:280-282`)** dice Speck "eligió" — colapsa que F4 sea "el único con consentimiento de Speck" (`Los 5 Finales:83,96`). F1 debe ser aceptación sin ser preguntada, no elección.
    2. **Darro F2b (`Darro-Ficha:298`)** — "al menos sé que la promesa era real. Seguimos" es un beat de "aprendimos algo", prohibido explícitamente en `Los 5 Finales:55` ("tragedia pura […] ningún beat de aprendimos algo"). Roen/Valen sí respetan la regla en sus epílogos F2b.
    3. **Nyael F2a (`Nyael-Ficha:285` vs `:261`)** — `:261` dice Speck "imposible de transportar sin importar quién la cargue" (sostiene la ausencia de Nyael); `:285` inventa que sí puede moverse "con consentimiento del jugador". Las dos no pueden ser verdad a la vez.
    4. **Cita rota (`Los 5 Finales:49`)** — F2b se apoya en "`Speck §Capa 4` — el Fragmento reacciona a fuerza física, no a inacción", pero esa regla no existe en `Speck.md §Capa 4`. La regla central que hace F2b agencia (no timeout) no tiene fuente real.
    - MEDIUM: `Grove of Cycles:68` sigue sembrando F2b como "el jugador se congela" — el gate ya es forcejeo, no parálisis.
  - **CRÍTICOS de congruencia:**
    5. **Darro/Vekka aritmética (`Darro-Ficha:44` vs `:376`, + `Vekka-Ficha:46,54,72,86,88`)** — la ficha de Darro dice que fue aprendiz de Vekka "a los 30" con presente en "edades 39-45" (rechazo hace ~12 años), pero la sección Darro+Vekka y toda la ficha de Vekka dicen "hace ~30 años". Contradice al mismo archivo.
    6. **Longevidad de los 3 fijos (`Roen:40,50`, `Valen:96,106`, `Darro:90,100`)** — elfos "150+ años" / enanos "~60-120 años" contra el canon de `Las Tres Razas:24-25` (elfos 650-700, enanos 200-250). Fijos quedaron pre-rework.
    7. **Valen vio "cinco Mudas" (`Valen-Ficha:100`, refuerzo en `:11`)** — imposible bajo cualquier marco: ninguna Muda se ha completado en los últimos 550 años (`El Mundo y la Muda`). No es la creencia errónea de la Academy (eso ya se resolvió) — es una experiencia personal declarada que no pudo pasar.
    8. **Isolde Marrow "tatara-tataranieta del último rey" (`Nomenclatura:51` vs `Estructura Política:154,175,190`)** — choca en 3 ejes: (a) Estructura Política dice que su sangre real es "leyenda, sin necesidad de ser verificable" — Nomenclatura la afirma como hecho; (b) 5 generaciones ≈125-150 años, pero el "último rey" debería preceder 550 años de Regencias; (c) no existe ningún "último rey" en el vault — `Nomenclatura:47` sella que el título humano nunca fue "King". **Ya estaba marcado como worldbuilding gap, pero el cambio ya está aplicado como canon — la contradicción está viva, no es solo un pendiente.**
    - MEDIUM: `Geografía:1017` + 9 fichas de Pivote describen "el jugador se pone los Goggles" como acto repetible (incluso "segundo uso"), pero Nomenclatura los declara no-retirables desde el primer uso — no rompe el gate de F4, pero el lenguaje narrativo asume que se los quita.
    - MEDIUM: `Valen-Ficha:52` — "la última Muda fue hace 110 años, no 300" sigue afirmándose como dato válido (`:217`: "el texto de sus cálculos sigue siendo correcto"), pero choca con `Geografía:748` (Muda rota hace ~550 años). Falta marcar el 110 explícitamente como parte del error de la Academy.
  - **Patrón de fondo:** los críticos de esta ronda son distintos en naturaleza a los de la 2ª — ya no son huecos de cobertura, son **contradicciones internas entre archivo y archivo** (Darro vs Vekka, Nyael consigo misma, F2b vs su propia fuente) y **fijos/ediciones directas que no se propagaron** (longevidad, Isolde, Valen-Mudas). Varios están interconectados: fijar Isolde toca worldbuilding (Último Reino); fijar longevidad/Valen-Mudas toca timeline general de los 3 fijos; fijar Darro toca 2 fichas a la vez.

  **📅 PRÓXIMA SESIÓN (mañana): sesión de diseño con Boris** para resolver los 8 críticos + decidir el mecanismo de bonds fijos (pregunta abierta de `The Bound Five.md`, ver abajo). No se toca nada de esto hasta entonces.

  **Reportes completos de los 3 QAs** (con líneas exactas y citas textuales): ver entradas del 2026-07-28 en [[LOG]].

**Decisiones de lore tomadas por Boris (2026-07-28), aplicables a los Bloques A/B/C:**
- **Los 9 Pivotes existen simultáneamente** en el mundo; solo 1 conoce al jugador (ya documentado en Bloque D)
- **Rechazo de Darro:** versión Vekka — fue su aprendiz ~30 años atrás, le enseñó 2 años, al tercero lo rechazó del programa formal en persona y nunca le explicó por qué
- **Cosmología de Valen:** su creencia en "Mudas cada 300 años" es **errónea** — la enseña the Academy of Sages, y descubrirlo es un beat del personaje. Se conserva el texto, cambia el marco
- **Timeline:** Sunken Archive = Acto 3; Grove of Cycles tras cerrar **los 3** sub-actos; 4 God-Cores destruidos antes del Grove

**Worldbuilding narrativo previo:** COMPLETO como fuente para guión (3 reinos + Triune Council + The Elder Circle + Lady Isolde Marrow + Old Tobin Hale + The Reckoning + 12 personajes con fichas + Speck).

---

## 🟡 Ediciones directas de Boris procesadas (2026-07-28)

Boris editó 4 archivos en Obsidian fuera de la conversación con Claude, con preguntas explícitas para retomar:

✅ **`Nomenclatura.md`** — 2 cambios aplicados:
- Lady Isolde Marrow: **tatara-tataranieta del último rey** (refuerza reclamo hereditario vs. Regency). ⚠️ **WORLDBUILDING GAP:** requiere construir backwards el Último Reino antes de las Regencias (pendiente de sesión worldbuilding).
- The Wanderer's Goggles: accesorio **no retirable** tras primer uso. ✅ Verificado consistente: Los 5 Finales §F4 + Geografía §The Reckoning — Tobin siempre los da.

✅ **`Speck.md`** — 2 cambios aplicados:
- "Giro Grogu" **eliminado deliberadamente** — Speck no crece, solo se revela. Párrafo reescrito: "Speck es Warden anciana desde el inicio (550+ años), no criatura juvenil aprendiendo".
- Pelaje: beige/gris → rojo/naranja ✅; Ojos: facetados-naranjas ✅.

🟡 **`The Bound Five.md`** — Pregunta de diseño abierta:
- Boris pregunta: desarrollar **bonds/links propios para Roen, Darro y Valen** a partir de raza/rol. Necesita mecanismo donde los 9 bonds sean protagonistas por igual. **Requiere sesión de diseño de sistema** (toca `The Tether`).

📋 **`Principios de Anatomía 3D.md`** — Referencia compilada (no código):
- DOF por región: escapulotorácico (+3), miembro superior (10), pelvis (+3), pierna (9), columna (72). Pendiente: reestructurar en tablas/secciones para documentación técnica agnóstica de motor.

**Concept art:** catalogado y trackeado. Ver `90-Raw/concept/CATALOGO.md`.
- §9 (gobernantes + Council): 5/6 ✅, King Borran 🟡 provisional
- §10 (elenco político nuevo): 6/6 ✅ cerrado
- §6d (keyframes ciudades, QA retroactivo): Emberdeep/Stillspire/Mistbound ✅, Rivermeet daylight 🟡, Driftmarket 🔴 (pendiente re-corrida)
- §L (UI Mockups, 2026-07-28): 3/3 ✅ aprobados (character-creation, main-menu, tether-screen); main-menu 🟡 ajuste visual menor
- §M (Marketing, 2026-07-28): 🟡 key-art-poster v2 genera v2 (tone → cozy-fantasy, Speck + Iron-Blooded presencia)
- Fenotipos / Speck / Finales: renombrados y trackeados

**Motor:** GODOT confirmado (ADR-002). Branch: `feat/c6-anatomy-rework`.

---

## 🔴 BLOQUEO ACTIVO — no se toca código

**[[ADR-003 Reset de desarrollo y motor]] está ABIERTO** (2026-07-28). El director planteó hard reset de código + revisión de la decisión de motor (Godot → posiblemente Unity).

**Mientras esté abierto:**
- ❌ No se escribe código de producción, ni en Godot ni en Unity. Frente C (técnico) del Task-Board congelado.
- ✅ **Sigue desbloqueado:** worldbuilding, guión, concept art, mockups de UI, diseño de sistemas en papel.

**5 criterios a resolver, en orden:** (1) vertical slice mínimo → (2) target de plataforma → (3) alcance v1 vs post-lanzamiento → (4) motor evaluado contra el slice → (5) inventario de qué se conserva. Requiere sesión con el director; no delegable.

**Nota clave del análisis:** el riesgo mayor no es el motor — es que el alcance narrativo (9 Pivotes × 5 finales × 9 celdas) creció a escala de estudio mediano. Ningún motor resuelve eso.

---

## Hechos vigentes

- **Branch actual:** `feat/c6-anatomy-rework`. Playtest: `Start-Playtest-Greybox.bat`. Gates: `autotest_combat.gd`, `autotest_springboard.gd`. **Congelados por ADR-003.**
- **Speck:** último Warden cristalino superviviente, shapeshifteada como zorro. Narrativa + diseño visual 100% completo. Detalle en [[Current-State-Historico]].
- **Anatomía/rework (C6):** oreja élfica 75%, nacimiento de oreja 74/70/78%. Queda: ROM por raza (C4), pies sin IK.
- **Motor:** GODOT confirmado (ADR-002).
- **Bloqueos:** ninguno.
- **Deuda técnica visible:** pies sin IK, ROM enano/elfo (C4 restante), mesh de bloques = etapa.
- **Riesgos abiertos:** frame budget frágil RTX 2060 (~58 fps warm); export a consolas requiere partner externo.

---

## Pendientes — ordenados por fecha

### 🗓 Próxima sesión (mañana) — sesión de diseño con Boris: 8 críticos + bonds fijos

**Agenda fijada por Boris (2026-07-28 noche):**

1. **8 críticos de la 3ª re-corrida** (detalle completo arriba y en [[LOG]]):
   - Darro F1/F2b (2 líneas de diálogo a reescribir)
   - Nyael F2a vs `:261` (decidir cuál regla manda: transporte imposible siempre, o condicionado a consentimiento)
   - Cita rota en `Los 5 Finales:49` (escribir la regla real en `Speck.md §Capa 4`)
   - Darro/Vekka aritmética (¿rechazo hace ~12 años o ~30? — 2 fichas a sincronizar)
   - Longevidad de Roen/Valen/Darro (alinear a `Las Tres Razas`: elfos 650-700, enanos 200-250)
   - Valen "vio cinco Mudas" (dato imposible bajo cualquier marco — necesita reescritura, no solo reframe)
   - Isolde Marrow "tatara-tataranieta del último rey" (worldbuilding gap real: construir el Último Reino pre-Regencias, o ajustar la afirmación)
   - 2 MEDIUM de arrastre (Grove siembra F2b como parálisis; Goggles "retirables" en 10 archivos)

2. **Pregunta de sistema de `The Bound Five.md`:** mecanismo de bonds/links propios para Roen, Darro y Valen (no solo jugador↔Pivote) — toca `The Tether` y `Bond y el Bond Vacío`.

**No se toca nada de esto hasta la sesión.** Después de resolverlo: re-correr los 2 QAs una cuarta vez (criterio real de cierre) → si dan 0, el sprint QA cierra y el frente siguiente es **guión y diálogos por actos**.

**Nota de método:** los críticos de esta 3ª ronda ya no son huecos de cobertura (como en la 2ª) — son contradicciones archivo-contra-archivo y ediciones directas que no se propagaron. Sugiere que el patrón "corregir sin barrer todas las menciones" sigue vivo; cualquier fix debe grep-ear el dato en todo el vault antes de darlo por cerrado.

### 🔜 Próximas sesiones (sin fecha fija)

**Concept art pendiente:**
- **✅ 14 briefs NB2 nuevos escritos (2026-07-27)** en [[Briefs de Concept Art]] §11 (Haiku 4.5). Batch completo listo para correr en NB2 al ritmo que Boris quiera. Cubre: Driftmarket re-corrida, Wanderer's Goggles (item — inaugura carpeta `90-Raw/concept/props/`), Sunken Archive interior, First Wound clímax jugable, Grove of Cycles interior, oficina de Tobin, 3 torres de guardia (Aethelgard/Ignis Reach/Stillwood Watch), Rivermeet Council Chamber, Emberdeep vertical, Ascending Falls, Iven's Settlement, Mistbound Frontier interior. Todos con regla anti-texto + estilo maestro canónico.
  - **✅ CERRADO (2026-07-27) — 14/14 briefs corridos en NB2 y con QA completo.** 13/14 ratificadas al primer o segundo intento; solo Sunken Archive requirió v2 (v1 se leía como catacumba egipcia con momias, v2 resuelve con cuerpos-cristal fundidos a la piedra). Todas las imágenes ya guardadas en `90-Raw/concept/` (Wanderer's Goggles en `90-Raw/concept/props/`). Detalle completo por brief en [[Briefs de Concept Art]] §11. **§11 del brief-writing y su QA quedan completamente cerrados** — próximo frente de concept art es evaluar el material fuera de este batch (escenas de traición legacy, set de combos, videos Higgsfield).
- Revisar las **4 escenas de traición** (`Traición_Dagna.png`, `La traición ejecutada.png`, `El primer viso de la muda.png`, `El Último Vínculo.png`) — confirmar si son legacy o canon, decidir si archivar o catalogar
- Evaluar el **set de arte de combos** como conjunto (Arcane Ballistics, Skyhook, Mobile Foundry, Weaver's Net, Skipping Stone, Riposte Runner, Guided Avalanche, Warforging, Seismic Springboard + videos) — no tienen doc en `10-Knowledge/` todavía
- QA de las **4 variantes de The Wilds** sin procesar (`Arterias`, `Interior`, `Noche con Muda`, `Ruinas`)
- Evaluar **videos Higgsfield** (bloqueo técnico ffmpeg activo): `Arcane Ballistics.mp4`, `Las Tres Razas.mp4`, `El Mundo.mp4`, `SKYHOOK.mp4`, `Seismic Springboard (2).mp4`, `Speck video.mp4`, `THE WEAVER'S NET.mp4`
- **King Borran** 🟡 — si se retoma: reescribir el prompt en prosa corta (mismo formato que resolvió Kadrun v2)

**Keyframes faltantes de brief (2026-07-27):** ✅ **14 briefs escritos** (ver arriba, §11 de Briefs de Concept Art). Pendiente solamente correr los 14 en NB2 y hacer QA de resultados. Único brief que sigue faltando por escribir:
- **POIs de The Wilds sueltos** según necesidad narrativa (no listados aún, van cuando aparezcan en el guión).

**Narrativa / guión (próximo frente real):**
- Guión completo por actos (GDD §1.2 tiene estructura, no hay diálogos)
- Voz narrativa definida (¿narrador? ¿silent protagonist? ¿qué tan verbose?)
- Momentos de Persona de Speck (~7 escenas sin UI)
- Diálogos del Bautizo de Speck (Darro la nombra)
- Los 4 Finales — scripting de diálogos/cinemática
- Estado post-final jugable
- Variantes C3 vivo/muerto en Finales 2-3

**Worldbuilding — cultura/lore (pendiente):**
- Culturas por raza — ceremonias, idioma, costumbres (Aether-Born/Iron-Blooded/Restless)
- Lore de civilización Warden pre-caída
- Estrategia militar de los 3 reinos en el clímax
- The First Wound (ficha lore completa), Sunken Archive (ficha lore)
- Cabeza de the Academy of Sages (baja prioridad)

**Fichas de personaje pendientes (2026-07-27):**
- **Old Tobin Hale — ficha expandida.** Solo aparece descrito en `Geografía y Ciudades §The Driftmarket` y en `Briefs de Concept Art §10b`. La escena de The Reckoning acaba de darle un peso dramático mayor (custodio inconsciente de los Wanderer's Goggles hace 40+ años) y necesita biografía formal para escribir su diálogo y las variantes por Pivote. Estimado: 1 ficha corta (~200-300 líneas), mismo formato que fichas de fijos pero más contenida (no tiene arco de traición).

**Mapa del mundo:**
- `Aether Bound universe.png` = referencia interna imperfecta (texto corrupto en etiquetas). Plan: documentar el mapa por escrito a medida que avanza el worldbuilding → cuando cierre el frente, escribir spec exhaustiva para re-generar con AI o dibujo a mano. Ver cabecera de [[Briefs de Mapa del Mundo]].

**POSPUESTO (post-lore):** trailer formal, cutscenes cinemáticas, banda sonora.

---

**Historial completo:** [[LOG]] y [[Current-State-Historico]].
