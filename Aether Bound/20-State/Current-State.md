---
status: vivo
updated: 2026-07-24
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

## Estado general (2026-07-24, cierre de sesión)

**Worldbuilding narrativo:** COMPLETO como fuente para guión. 3 reinos + Triune
Council + The Elder Circle + Lady Isolde Marrow + Old Tobin Hale + The Reckoning
+ 12 personajes de grupo con fichas expandidas + Speck → todo documentado en
`10-Knowledge/`. El siguiente frente real es escribir guión y diálogos por actos.

**Concept art:** catalogado y trackeado por primera vez en un commit limpio. Ver
`90-Raw/concept/CATALOGO.md` para el índice completo.
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

### 🗓 Lunes 27 de julio

1. **QA de congruencia del Vault (sintaxis y semántica) con Opus** — revisar que todos los docs de `10-Knowledge/` sean internamente consistentes: nombres propios en inglés correctos, cross-references válidas, sin contradicciones de lore entre fichas y los docs de estructura. Arrancar con Geografía/Ciudades, Estructura Política, El Mundo y la Muda, fichas de Pivotes.

2. **QA narrativo con Opus** — revisión dramática del arco completo: ¿Los 9 patrones de traición son distintos entre sí (ninguno se pisa)? ¿Los epílogos de los 4 Finales son coherentes con la posición de cada Pivote? ¿The Reckoning tiene el peso dramático correcto antes del clímax? ¿Speck como Warden cambia algo en las fichas existentes que aún no se actualizó?

### 🔜 Próximas sesiones (sin fecha fija)

**Concept art pendiente:**
- Re-correr **Driftmarket** en NB2 con regla anti-texto (caption quemado en la imagen)
- Revisar las **4 escenas de traición** (`Traición_Dagna.png`, `La traición ejecutada.png`, `El primer viso de la muda.png`, `El Último Vínculo.png`) — confirmar si son legacy o canon, decidir si archivar o catalogar
- Evaluar el **set de arte de combos** como conjunto (Arcane Ballistics, Skyhook, Mobile Foundry, Weaver's Net, Skipping Stone, Riposte Runner, Guided Avalanche, Warforging, Seismic Springboard + videos) — no tienen doc en `10-Knowledge/` todavía
- QA de las **4 variantes de The Wilds** sin procesar (`Arterias`, `Interior`, `Noche con Muda`, `Ruinas`)
- Evaluar **videos Higgsfield** (bloqueo técnico ffmpeg activo): `Arcane Ballistics.mp4`, `Las Tres Razas.mp4`, `El Mundo.mp4`, `SKYHOOK.mp4`, `Seismic Springboard (2).mp4`, `Speck video.mp4`, `THE WEAVER'S NET.mp4`
- **King Borran** 🟡 — si se retoma: reescribir el prompt en prosa corta (mismo formato que resolvió Kadrun v2)

**Keyframes faltantes (sin brief escrito todavía):**
- Torres de guardia (Aethelgard Watch / Ignis Reach Watch / Stillwood Watch)
- Lugar de reunión del Triune Council (Rivermeet — el mapa maestro lo confirma, falta keyframe dedicado)
- Grove of Cycles (Elder Circle — existe en el mapa, sin keyframe)
- Sunken Archive, The First Wound (cráter final, diferente al God-Core Night ya ratificado)

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

**Mapa del mundo:**
- `Aether Bound universe.png` = referencia interna imperfecta (texto corrupto en etiquetas). Plan: documentar el mapa por escrito a medida que avanza el worldbuilding → cuando cierre el frente, escribir spec exhaustiva para re-generar con AI o dibujo a mano. Ver cabecera de [[Briefs de Mapa del Mundo]].

**POSPUESTO (post-lore):** trailer formal, cutscenes cinemáticas, banda sonora.

---

**Historial completo:** [[LOG]] y [[Current-State-Historico]].
