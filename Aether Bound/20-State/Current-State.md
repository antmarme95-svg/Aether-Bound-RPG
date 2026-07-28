---
status: vivo
updated: 2026-07-27
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

## Estado general (2026-07-27, cierre de sesión)

**Sprint de reparación de QA post-lunes 27:** ejecutados los 2 QA con Opus (congruencia + narrativo). Plan de 4 fases aprobado (`~/.claude/plans/cozy-floating-unicorn.md`). Estado del sprint:

- **✅ Fase 0 completa** — 4 documentos-fuente reescritos:
  - `Los 4 Finales.md` → 5 finales (F1/F2a/F2b/F3/F4) con matriz 5×3
  - `Grove of Cycles — Escena del Acto 2.md` (nuevo) con debate del Elder Circle
  - `Geografía y Ciudades.md §ACTO 3` reescrito a 5 sub-beats
  - `Geografía y Ciudades.md §THE RECKONING` con tabla Tobin corregida (señala a fijos C1/C2/C4, no a Pivotes inactivos) + Wanderer's Goggles 40+ años
- **✅ Fase 1 al 100%** — 9/9 fichas de Pivote reescritas al canon nuevo + `Los 9 Pivotes.md`:
  - Maren, Sereth, Iven (Aritmética/Manipulación — Sereth movido a manipulación pura, Iven con Council mintiendo)
  - Torgan, Vekka, Dagna (Deber Institucional — Torgan aritmética 55 años + cadena resuelta; **Vekka reescritura completa** con Darro como "flawed forging viviente" + superlativo "la traición más precisa"; **Dagna reescritura mayor** con entrada Roen+Dagna canónica que canoniza que Dagna quiebra a Roen — no Lyris — y sección duplicada eliminada)
  - Bram, Lyris, Nyael (Rechazo/Ausencia + institucional — Bram canon NO traiciona con mecanismo del "segundo agente")
- **✅ Fase 3 completa** (invertido orden 2↔3) — Haiku 4.5, lint mecánico:
  - `El Quinteto.md` → `The Bound Five.md` (rename + 10 cross-refs actualizados)
  - Longevidad élfica corregida (Estructura Política + El Mundo y la Muda: hoy 570-700 años, cataclismo hace ~550 años)
  - King Borran genealogía → tataranieto (4 generaciones, coherente con vida enana 200-250 años)
  - Contradicciones de origen resueltas: Bram → Rivermeet (House Thorne), Iven → Iven's Settlement, Mistbound Frontier = tierra interior no fronteriza
  - "Maestra del Gremio" → Guild Master de the Great Forging Clan; "Gran Clan" → the Great Forging Clan
  - Typos: deixada, assassinato, appecia, Localizé, Misbound, Socópata, sabará, recostruir, began visiting, Dargo (2) — todos corregidos
  - Género de Speck femenino uniforme en Darro-Ficha
  - Frontmatters actualizados
  - Todos los greps de verificación = 0
- **✅ Fase 2 completa** — Sonnet 5, propagación semántica + cross-cutting:
  - Roen-Ficha: entrada Roen+Dagna canónica agregada (8 menciones); línea de flashes corregida (Roen intuye, no ve — canon Speck §Capa 2); Lyris "repliega" a Roen, Dagna "rompe genuinamente" (corrige contradicción)
  - Torgan y Lyris: The Reckoning integrado (Tobin señala a Darro para Torgan, a Valen para Lyris)
  - Valen-Ficha: Grove of Cycles Vector A + lectura de inscripción Warden en Sunken Archive
  - Darro-Ficha: The Reckoning (Tobin lo señala por error cuando el Pivote es enano) + escena del escudo caído de Roen (ruta Dagna)
  - Speck.md: párrafo "El Pivote como testigo natural" en §Momentos de Persona
  - **Desambiguación "el Consejo":** ~50 hits en 17 archivos resueltos → 0 residuales ambiguos. Distribución: ~42 → the Triune Council, 2 → the Great Forging Clan, 8 → el consejo del clan menor de Torgan, 3 glosario/scoped sin cambio
- **🔴 Fase 4 pendiente** — verificación end-to-end con re-corrida de los 2 QAs (criterio: 0 CRÍTICOS)

**Worldbuilding narrativo previo:** COMPLETO como fuente para guión (3 reinos + Triune Council + The Elder Circle + Lady Isolde Marrow + Old Tobin Hale + The Reckoning + 12 personajes con fichas + Speck).

**Concept art:** catalogado y trackeado. Ver `90-Raw/concept/CATALOGO.md`.
- §9 (gobernantes + Council): 5/6 ✅, King Borran 🟡 provisional
- §10 (elenco político nuevo): 6/6 ✅ cerrado
- §6d (keyframes ciudades, QA retroactivo): Emberdeep/Stillspire/Mistbound ✅, Rivermeet daylight 🟡, Driftmarket 🔴 (pendiente re-corrida)
- Fenotipos / Speck / Finales: renombrados y trackeados

**Motor:** GODOT confirmado (ADR-002). Branch: `feat/c6-anatomy-rework`.

---

## Hechos vigentes

- **Branch actual:** `feat/c6-anatomy-rework`. Playtest: `Start-Playtest-Greybox.bat`. Gates: `autotest_combat.gd`, `autotest_springboard.gd`.
- **Speck:** último Warden cristalino superviviente, shapeshifteada como zorro. Narrativa + diseño visual 100% completo. Detalle en [[Current-State-Historico]].
- **Anatomía/rework (C6):** oreja élfica 75%, nacimiento de oreja 74/70/78%. Queda: ROM por raza (C4), pies sin IK.
- **Motor:** GODOT confirmado (ADR-002).
- **Bloqueos:** ninguno.
- **Deuda técnica visible:** pies sin IK, ROM enano/elfo (C4 restante), mesh de bloques = etapa.
- **Riesgos abiertos:** frame budget frágil RTX 2060 (~58 fps warm); export a consolas requiere partner externo.

---

## Pendientes — ordenados por fecha

### 🗓 Próxima sesión — cierre del sprint QA (Fase 4)

**Sprint QA 78% completo al cierre de 2026-07-27:** Fases 0, 1, 2 y 3 ratificadas (ver commits `7b4dbe6`, `51dba0c`, `1bf1fec`, `16588b1`). Único frente restante para cerrar el sprint completo:

**Fase 4 — Verificación end-to-end con re-corrida de los 2 QAs:**
- Re-correr **QA de congruencia** (Haiku 4.5 o Opus según presupuesto): mismo prompt del original, contra el vault actual. Criterio: los 10 CRÍTICOS + 18 IMPORTANTES del reporte original deben estar resueltos (marcar cada uno ✅/🟡/🔴). Se esperan solo hallazgos MENORES o nuevos que Fases 0-3 no anticiparon.
- Re-correr **QA narrativo** (Opus 5): mismo prompt del original, con instrucción explícita de verificar los 4 bloqueos duros resueltos (Archive→First Wound, eje 5 finales, Bram NO traiciona, Roen quebrado por Dagna) y los críticos creativos (Sereth vs Maren diferenciados, beat Warden en 9 fichas, Iven+Council mintiendo, poder innato del jugador consistente).
- Ambos QAs deben devolver **0 CRÍTICOS** para declarar el sprint cerrado.
- Si aparecen nuevos hallazgos: decidir si son parche corto en la misma sesión o si abren un sprint pequeño de seguimiento.

**Nota estratégica:** el sprint dejó al vault listo como fuente para el próximo frente real — **guión y diálogos por actos**. Después de Fase 4, no hay razón técnica para postergar más el guión.

### 🔜 Próximas sesiones (sin fecha fija)

**Concept art pendiente:**
- **✅ 14 briefs NB2 nuevos escritos (2026-07-27)** en [[Briefs de Concept Art]] §11 (Haiku 4.5). Batch completo listo para correr en NB2 al ritmo que Boris quiera. Cubre: Driftmarket re-corrida, Wanderer's Goggles (item — inaugura carpeta `90-Raw/concept/props/`), Sunken Archive interior, First Wound clímax jugable, Grove of Cycles interior, oficina de Tobin, 3 torres de guardia (Aethelgard/Ignis Reach/Stillwood Watch), Rivermeet Council Chamber, Emberdeep vertical, Ascending Falls, Iven's Settlement, Mistbound Frontier interior. Todos con regla anti-texto + estilo maestro canónico.
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
