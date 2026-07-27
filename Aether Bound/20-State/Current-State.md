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
- **🟡 Fase 1 al 78%** — 7/9 fichas de Pivote reescritas al canon nuevo:
  - ✅ Maren, Sereth, Iven (arquetipo Aritmética/Manipulación — Sereth movido a manipulación pura, Iven con Council mintiendo)
  - ✅ Torgan (aritmética unificada 55 años, cadena de mando resuelta)
  - ✅ Bram, Lyris, Nyael (arquetipo Rechazo/Ausencia + institucional — Bram canon NO traiciona con mecanismo del "segundo agente")
  - ✅ `Los 9 Pivotes.md` (fila de Bram actualizada al canon nuevo)
  - 🔴 **Vekka y Dagna PENDIENTES** — Agente B falló con server errors 2 veces; requieren reescritura mayor (Vekka completa 139→~450 líneas; Dagna 242→~450 con arco por acto + entrada Roen+Dagna canónica)
- **🔴 Fase 2 sin arrancar** — Sonnet 5, propagación mecánica + cross-cutting (Roen/Valen/Darro fichas, Estructura Política, El Mundo y la Muda, Speck.md, El Quinteto.md)
- **🔴 Fase 3 sin arrancar** — Haiku 4.5, lint mecánico verificable (renombrar El Quinteto→The Bound Five, retraducciones "el Consejo" con desambiguación, typos, cross-refs)
- **🔴 Fase 4 sin arrancar** — verificación end-to-end con los 2 QA re-corridos

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

### 🗓 Próxima sesión — retomar sprint de reparación

**Bloqueo pendiente (Fase 1):** Vekka + Dagna. Ambos son reescritura mayor porque:
- **Vekka** hoy tiene 139 líneas sin arco por acto, sin persecución, sin Acto 3 real, y 4 finales de una línea que no mencionan a Speck. Necesita ~450 líneas al nivel de las otras 7 fichas. Instrucciones detalladas en el plan `~/.claude/plans/cozy-floating-unicorn.md`.
- **Dagna** hoy tiene 242 líneas con sección "Roen y la Quiebre" duplicada verbatim y sin arco por acto claro. Necesita reescritura + entrada Roen+Dagna canónica (canonizar que Dagna es quien quiebra a Roen, no Lyris — corrección al hallazgo del QA narrativo).

**Después de Vekka+Dagna:** arrancar Fase 2 (Sonnet 5, propagación mecánica + cross-cutting sobre Roen/Valen/Darro/Estructura Política/etc.), Fase 3 (Haiku 4.5, lint verificable), Fase 4 (verificación end-to-end con los 2 QA re-corridos).

### 🔜 Próximas sesiones (sin fecha fija)

**Concept art pendiente:**
- Re-correr **Driftmarket** en NB2 con regla anti-texto (caption quemado en la imagen)
- Revisar las **4 escenas de traición** (`Traición_Dagna.png`, `La traición ejecutada.png`, `El primer viso de la muda.png`, `El Último Vínculo.png`) — confirmar si son legacy o canon, decidir si archivar o catalogar
- Evaluar el **set de arte de combos** como conjunto (Arcane Ballistics, Skyhook, Mobile Foundry, Weaver's Net, Skipping Stone, Riposte Runner, Guided Avalanche, Warforging, Seismic Springboard + videos) — no tienen doc en `10-Knowledge/` todavía
- QA de las **4 variantes de The Wilds** sin procesar (`Arterias`, `Interior`, `Noche con Muda`, `Ruinas`)
- Evaluar **videos Higgsfield** (bloqueo técnico ffmpeg activo): `Arcane Ballistics.mp4`, `Las Tres Razas.mp4`, `El Mundo.mp4`, `SKYHOOK.mp4`, `Seismic Springboard (2).mp4`, `Speck video.mp4`, `THE WEAVER'S NET.mp4`
- **King Borran** 🟡 — si se retoma: reescribir el prompt en prosa corta (mismo formato que resolvió Kadrun v2)
- **The Wanderer's Goggles — brief NB2 pendiente.** Único item con peso dramático propio (entregado por Tobin en The Reckoning, revelan proyecciones Warden en el Sunken Archive, parte del gate compuesto de F4). Diseño canónico: latón viejo, lentes ambar-doradas, correa de cuero desgastada por 40+ años de guarda en el cajón de Tobin. Instrumento sin adornos — se ven exactamente como lo que son. Referencia estilo: mismo tratamiento que asset props de Sable/BotW (baja saturación, linework nítido, textura visible). Es el primer item del vault con brief propio — probablemente inaugura una carpeta de "props narrativos" para futuros items diegéticos (Fragmento, God-Cores individualizados, etc.).

**Keyframes faltantes (sin brief escrito todavía) — pendiente Boris (2026-07-27):** escribir briefs NB2 para los spots del mapa que faltan. Priorizar los que se citan en el guión ya escrito (Grove of Cycles, Sunken Archive, First Wound son de Acto 2/3 y ya tienen escenas ratificadas).
- **Prioridad alta** (citados en el guión escrito):
  - Sunken Archive (interior con cadáveres calcificados + proyecciones Warden — Acto 3 §2)
  - The First Wound (cráter climático — diferente al keyframe God-Core Night ya ratificado, este es del clímax jugable con el core central respondiendo a Speck)
  - Grove of Cycles (interior del templo élfico donde ocurre la escena del Elder Circle)
  - Interior de la oficina de Tobin en The Driftmarket (escena de The Reckoning con los Wanderer's Goggles)
- **Prioridad media** (mundo abierto, exploración):
  - Torres de guardia por raza (Aethelgard Watch / Ignis Reach Watch / Stillwood Watch)
  - Rivermeet Triune Council Seat (interior de sesión del Council)
  - Interior Emberdeep detallado (forjas activas, múltiples niveles)
  - The Ascending Falls (cadena de cascadas Gloomvault → Stillspire)
- **Prioridad baja** (color / POIs secundarios):
  - Iven's Settlement (asentamiento moribundo)
  - Mistbound Frontier (postas defensivas — hay keyframe aprobado, pero puede complementarse)
  - POIs de The Wilds sueltos según necesidad narrativa

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
