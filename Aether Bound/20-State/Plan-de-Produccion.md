---
status: ratificado
source: "Design Loop 2026-07-05 (A1, RATIFICADO por el director), dimensionado sobre [[Slice of Bond]] ratificado"
updated: 2026-07-05
---

# Plan de Producción (macro)

> Norte único de la preproducción: **shippear el [[Slice of Bond]]** (45–60
> min jugables que duelen dos veces) y evaluar ahí. Todo lo que no acerca el
> slice se difiere. Equipo: director + orquestación Claude
> ([[Lecciones]]: Opus orquesta, Sonnet/Haiku ejecutan).

## Principios del plan

1. **El slice es el plan.** Cada fase produce algo jugable/observable que el
   director acepta con un [[Playtest Loop]] antes de abrir la siguiente.
2. **Diseño solo just-in-time:** del frente B entra únicamente lo que el
   slice consume (B10). B2–B8 y las 8 fichas restantes de B1 son
   post-slice.
3. **Reusar antes que construir:** locomoción PRD-005, pipeline visual
   golden-scene, character creation y flujo OFFICE→WILDS ya existen
   ([[Inventario del Prototipo]]).
4. **Riesgo primero:** lo nunca-probado (companion AI + link de aliado +
   beat emocional) se ataca en las fases tempranas; el contenido (escenas,
   arte) después.

## Fases

### Fase 0 — Higiene (corta, sin gate) ✅ 2026-07-05

- C1: renombrar V&V → AETHER BOUND (repo/README/strings). ✅
- C5: fix `--skip=wilds` en boot live. ✅ (verificado live por log FSM)
- Sanity: gates QA verdes en frío (test_core + autotests). ✅
  (test_core ALL_PASS · scenes 10/10 · slice ALL_PASS · wilds_fps 372 frío)

### Fase 1 — Fundaciones: el link vivo *(el mayor riesgo técnico)*

Objetivo jugable: **en un greybox plano, pelear junto a Dagna y usar el
Springboard T1 se siente bien.**

- **B10 Game Feel Bible** (Design Loop, ANTES de implementar: hit-stop,
  screen-shake budget, cámara de combate — gatea el feel de todo lo demás).
- **PRD-006 — Combate §4.2 mínimo:** 4 componentes + HitPayload; kit Humano
  Duelist (combos largos, momentum→daño, parry "Roba"); 2 enemigos sobre
  los mismos componentes.
- **PRD-007 — Dagna companion + Seismic Springboard T1:** AI de compañera
  (follow/combate, kit Enano Vanguard reducido) + el link como PushPull
  sobre aliado. Incluye botón único de [[Bond y el Bond Vacío|Bond]].
- **C4 (parcial) — rig/ROM:** solo lo que el greybox exige — humano
  (jugador) primero, enana después. Modelos placeholder.
- **Gate 1 (Playtest Loop):** el director juega el greybox; el combate y el
  T1 pasan el filtro de feel (B10) a ≥60 FPS.

### Fase 2 — La espina: Cinder Ascent + tiers

Objetivo jugable: **escena 2 completa en greybox — el Springboard ES la
progresión, y el Bond crece por usarlo.**

- **PRD-008 — Greybox del Cinder Ascent corto:** layout vertical donde
  T1/T2 abren rutas (metroidvania-lite por link); C2 (mantling/escalada)
  solo si el layout lo exige — decisión en el PRD.
- **PRD-009 — Tether solo-Bond + camp scene:** cordón trenzado sin números,
  crecimiento por uso real, la camp scene del ritual → T2 Fault Line
  (encadena con el slide).
- **T3 The Mountain's Answer** (relanzamiento aéreo + escena firma).
- **Gate 2:** el Ascent greybox se recorre de punta a punta con los 3 tiers;
  el director siente la progresión por intimidad.

### Fase 3 — El arco completo: las 4 escenas

Objetivo jugable: **el slice entero en greybox, del Nido a la coda.**

- **PRD-010 — Cold open El Nido:** incidente incitante comprimido, Speck
  scriptado, pregón del Consejo, reclutamiento (reusa flujo del prototipo).
- **PRD-011 — Eco del Sunken Archive + traición:** mini-dungeon, Fragmento,
  beat de la Primera Cuña (+martillo si T3), orfandad mecánica (links
  degradados = mismos assets, parámetros reducidos, GDD §4.2.B.6).
- **PRD-012 — Coda Bond vacío:** desandar sin verticalidad; la cornisa;
  picar Bond sin respuesta. Ratio 80/20.
- **Gate 3:** el slice greybox completo se juega en 45–60 min y la coda ya
  incomoda (aunque sin arte).

### Fase 4 — Vestir y doler: arte, audio, tuning

Objetivo: **el slice shippeable al criterio de éxito.**

- Look golden-scene aplicado: Wilds (existente) + **registro montaña del
  Ascent** (nuevo) + interior del eco-Archive.
  - **Metodología del pase visual (RATIFICADA 2026-07-09):** playtests por
    capa **ACUMULATIVOS y con gate secuencial** en The Wilds sobre
    `melancolia_post.gdshader` (las 4 capas del [[Art Bible]] ya implementadas
    y parametrizadas por uniforms; toggles en vivo por tecla, precedente del
    A/B de animación). Orden del pipeline: **L1 → L1+2 → L1+2+3 → full**, y
    **cada capa se LIBERA con VoBo del director ANTES de apilar la
    siguiente** — nada se monta sobre una capa no aprobada. Criterio por capa:
    acercarse al comicbook look de los keyframes canónicos dawn/dusk (la
    escena persigue la imagen) **+ costo de FPS medido por capa** (presupuesto
    térmico RTX 2060; si no llegamos a 60, se sabe qué degradar). Costo real a
    especificar en el PRD: **migración de materiales de The Wilds a variantes
    opacas** (`toon.gdshader` escribe ALPHA → invisible al post screen-space,
    [[Lecciones]]).
- **Dagna modelo/rig final** (lámina canónica `dagna-v1.png`; garantizar la
  cuña miniatura en la trenza) + C4 completo (constraints + IK + ROM enana).
- Audio mínimo: sting de dos notas (semilla B8) en camp scene, traición y
  Bond vacío.
- Montage + Playtest Loops de tuning; fine-tuning diferido de B11 (corteza,
  facetas, banding) donde la cámara lo exija.
- **Gate final:** playtest con al menos 1 persona ajena al proyecto —
  criterio del slice: **siente la pérdida dos veces**.

## Qué se difiere explícitamente (post-slice)

B1 (8 fichas), B2 (Quinteto), B3 (Momentos de Persona/Standing), B4
(desambiguación — el slice tiene 1 companion), B5 (Rueda logística), B6
(finales), B7 (progresión), B8 completo (dirección de audio), C3 más allá
del mínimo del slice, export a consolas (partner externo).

## Riesgos del plan

- **Companion AI** es territorio nuevo del prototipo → por eso vive en
  Fase 1, no en la 3.
- **Frame budget térmico** (RTX 2060 warm ~58 FPS): gates en corrida fría
  ([[Lecciones]]) y el Ascent diseñado con presupuesto de foliage menor que
  The Wilds.
- **Beat emocional no garantizable por ingeniería:** la coda se prueba con
  personas, no con autotests — de ahí el gate final externo.

**Regla de salida de A1:** al cerrar cada fase se actualiza este plan y
[[Current-State]]; si un gate falla dos veces, el plan se re-abre (Design
Loop) antes de forzar la fase siguiente.
