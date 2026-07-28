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
  - **🔴 Bloque B pendiente** (Sonnet 5, 1 corrida) — propagación a las 3 fichas de fijos **Roen / Valen / Darro**, que Fase 2 nunca tocó en sus secciones de finales:
    - **Bram no traiciona** — las 3 lo hacen traicionar o rendirse. `Roen:270` ("Cuando Bram acepta la oferta del Triune Council… *I get it. Goodbye.*"), `Valen:329` ("Cuando Bram se rinde… *Twenty years of drainage*"), `Darro:348` ("Cuando Bram se rinde… *Veinte años es mucho*"). Reescribir al beat del corredor del Archive, tomando el diálogo ya canonizado en `Bram-Ficha:356-388`. De paso corrige la aritmética: son **cuarenta** años, no veinte.
    - **Migrar al eje de 5 finales** — las 3 conservan el bloque viejo (Final 1 Perdón / Final 2 Muerte / Final 3 Encadenamiento / Final 4 Síntesis = destino del Pivote). Debe ser destino de Speck, con F2a/F2b.
    - **Roen:** separar el beat de traición (Archive) del quiebre (cráter) — hoy `:175-196` los colapsa en First Wound. Aritmética de edad rota (`:11` dice 35-40; `:72` "edades 25-40" + `:84` "5 años presente" = 45).
    - **Valen:** reencuadrar su cosmología como **creencia errónea** (decisión de Boris — cree en "Mudas cada 300 años, última hace 110" porque lo enseña the Academy of Sages; está equivocado, y descubrirlo es un beat). Conservar el texto, cambiar el marco. Aritmética: `:11` dice 180-250 años pero `:191` dice "hace 300 años"; alterna 250 y 200.
    - **Darro:** rechazo del gremio a **versión Vekka** (decisión de Boris — fue su aprendiz ~30 años atrás, 2 años de enseñanza, ella lo rechazó en persona sin explicar). Hoy `:44-57` dice otra cosa (aceptado a los 30, aislamiento gradual, sin Vekka). Género de Speck femenino (`:184`, `:263`).
    - **Tablas de dinámicas:** 6 de 9 entradas tienen raza/rol falsos, idénticos en Roen y Valen. Ej. *"Roen + Lyris (Enana Duelist)"* — Lyris es **Elfa**, y la celda del jugador es Enano Vanguard. Mismo error en Nyael, Bram, Sereth.
  - **🔴 Bloque C pendiente** (Haiku 4.5, 1 corrida) — lint final, todo verificable con grep:
    - **Headcount >5** en 3 fichas: `Lyris:195-197` (**8 personas**, el peor caso), `Sereth:156` (7) + su cena "con Maren delante" `:174` + comparación con Maren `:396`, `Nyael:170` ("El Bound Five **+ otros**").
    - **Sync de `Los 9 Pivotes.md`:** línea 20 describe a Sereth con el arquetipo y la línea canónica **de Maren** ("Aritmética pura… *Millions against one*"); debe ser *"No te llevé a esta decisión. Te llevé a la persona que la toma."* Línea 24 tiene la línea vieja de Nyael ("You taught me to set the trap…"), reemplazada en su ficha por *"I set traps my teacher would have waited on…"*.
    - **Timeline:** `Geografía:739` dice Sunken Archive = Acto 2 → debe ser **Acto 3**. `Grove:9` dice "dos de los tres sub-actos" → debe ser **los tres** (así cuadra el conteo de 4 God-Cores).
    - **Bram 40 años:** residuos de "veinte años" en `Estructura Política:239-246`.
    - **Sereth "el Consejo"** (`:364-365`) — último residuo ambiguo de Fase 2.
    - **`Los 5 Finales`:** `Geografía:1042` dice "retroceder es F2" → desambiguar F2a/F2b.
    - **Mistbound orientación:** `Bram:30,48` dice "noroeste", `Geografía` dice "oeste profundo".
    - **`Geografía:96`** pone a Torgan y Dagna en "el Clan de Forja" — contradice sus fichas (Torgan en clan menor, Dagna en subclán Deepstone).
    - **Menores:** género de Speck en Darro, "Roen ve las manos de Vekka temblar" (Vekka no tiembla — su única grieta visible es un segundo con los ojos cerrados), fórmula "por primera vez en la historia registrada" repetida 3 veces.

  **Reportes completos de los 2 QAs de Fase 4** (con líneas exactas y citas textuales): ver entrada del 2026-07-28 en [[LOG]].

**Decisiones de lore tomadas por Boris (2026-07-28), aplicables a los Bloques A/B/C:**
- **Los 9 Pivotes existen simultáneamente** en el mundo; solo 1 conoce al jugador (ya documentado en Bloque D)
- **Rechazo de Darro:** versión Vekka — fue su aprendiz ~30 años atrás, le enseñó 2 años, al tercero lo rechazó del programa formal en persona y nunca le explicó por qué
- **Cosmología de Valen:** su creencia en "Mudas cada 300 años" es **errónea** — la enseña the Academy of Sages, y descubrirlo es un beat del personaje. Se conserva el texto, cambia el marco
- **Timeline:** Sunken Archive = Acto 3; Grove of Cycles tras cerrar **los 3** sub-actos; 4 God-Cores destruidos antes del Grove

**Worldbuilding narrativo previo:** COMPLETO como fuente para guión (3 reinos + Triune Council + The Elder Circle + Lady Isolde Marrow + Old Tobin Hale + The Reckoning + 12 personajes con fichas + Speck).

**Concept art:** catalogado y trackeado. Ver `90-Raw/concept/CATALOGO.md`.
- §9 (gobernantes + Council): 5/6 ✅, King Borran 🟡 provisional
- §10 (elenco político nuevo): 6/6 ✅ cerrado
- §6d (keyframes ciudades, QA retroactivo): Emberdeep/Stillspire/Mistbound ✅, Rivermeet daylight 🟡, Driftmarket 🔴 (pendiente re-corrida)
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

### 🗓 Próxima sesión — cerrar Fase 5 (Bloques B y C)

Los 2 bloques restantes están detallados arriba con líneas exactas y citas textuales. Orden recomendado: **B primero** (Sonnet 5, contenido semántico), **C después** (Haiku 4.5, lint que barre también lo que B pueda dejar).

Al cerrar B y C: **re-correr los 2 QAs una última vez** (criterio 0 CRÍTICOS) para declarar el sprint terminado.

**Nota estratégica:** con el sprint cerrado, el próximo frente real es **guión y diálogos por actos** — no queda razón técnica para postergarlo.

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
