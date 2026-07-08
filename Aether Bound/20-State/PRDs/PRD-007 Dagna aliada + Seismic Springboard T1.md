---
status: ratificado
source: "[[Slice of Bond]] (A2b ratificado) + [[Dagna]] + [[Los 9 Links del Pivote]] + [[Acoplamientos]] + [[Game Feel Bible]] (ratificadas); Fase 1 del [[Plan-de-Produccion]]; Design Loop 2026-07-08 — RATIFICADO por el director (2 ejes + 4 detalles)"
updated: 2026-07-08
---

# PRD-007 — Dagna aliada + Seismic Springboard T1 (Fase 1)

**Objetivo:** en el greybox de combate (`combat_arena.gd`, del alcance 5),
**Dagna pelea a tu lado** como aliada mínima-pero-real, y su **ground-pound te
da el Seismic Springboard T1** — un lanzamiento vertical "imposible" que
alcanza cornisas fuera de tu salto normal. Cierra el **Gate 1** de la Fase 1
(*pelear junto a Dagna en greybox ≥60 FPS*). Referencia visual:
`90-Raw/concept/Seismic Springboard.png` (onda de choque teal + anillos).

## Decisiones del director (Design Loop 2026-07-08)

1. **Trigger T1 = onda + salto en ventana** (co-op de timing). Dagna golpea
   el suelo → onda temporal; si el jugador SALTA dentro de la zona/ventana,
   sale lanzado. El **input único es Bond** (canon [[Acoplamientos]]). Reusa el
   supersalto/momentum del PRD-005 + `PushPullComponent`.
2. **Dagna aliada = mínima pero real.** Sigue al jugador, hace ground-pound
   (su ataque *y* la fuente del springboard) + bloqueo-muralla + defensa
   propia básica. NO companion AI rica.

## Modelo del Seismic Springboard T1

- El **golpe de suelo de Dagna** spawnea una **zona de onda** temporal
  (radio + ventana de frames) — un caso del `PushPullComponent`, con VFX teal
  (burst + anillos concéntricos, per la lámina).
- El pound se dispara por **(a) Bond** — el jugador lo pide (co-op deliberado)
  — y **(b) la IA de Dagna** en momentos de contexto.
- Si el jugador **salta dentro de la zona durante la ventana**, el salto se
  **amplifica a un impulso vertical grande** (PushPull + la ley de leap del
  PRD-005: air control conservado). Fuera de la ventana → salto normal.
- Es **traversal y combate**: alcanzas cornisas *y* reposicionas en pelea.
  Canon [[Los 9 Links del Pivote]]: *"su golpe crea la onda; tú usas la
  inercia"*. Su pérdida (fuera de alcance del PRD, es la coda del slice) =
  *se acabó la verticalidad*.
- **Feel** ([[Game Feel Bible]]): el lanzamiento merece su lenguaje de tiempo
  (hit-stop/curva de subida) y su tell de ventana — la onda DEBE leerse como
  "salta AHORA".

## Dagna aliada (mínima pero real)

- Montada por el **pipeline de personajes** (`data/characters.gd` config
  `"dagna"` + `character_signature.gd`) sobre los **4 componentes canónicos**
  (sin scripts especiales — mismo mandato que los enemigos, [[Combate]] §A).
- **Kit Enano Vanguard reducido:** bloqueo-muralla (torre de Equilibrio) +
  **ground-pound** (doble uso: ataque propio + fuente del springboard).
- **Comportamiento:** te sigue / mantiene posición de ancla, hace pounds
  (Bond o IA), se defiende. NO: revivir, targeting complejo, combos ricos.

## Anti-objetivos (alcance CERRADO)

- **Solo T1.** T2 Fault Line y T3 The Mountain's Answer → PRDs posteriores
  (dependen de la camp scene + tiers de [[The Tether]]).
- **Sin medidor de Bond / Tether.** El input Bond existe (pide el pound) +
  cordón trenzado visual mínimo; **sin números, sin tiers, sin tope por acto**
  ([[Slice of Bond]]: el Tether va simplificado y llega con T2/T3). Standing
  fuera.
- **Sin camp scene, sin quest de Dagna, sin la traición** (son escenas del
  slice, no del gate técnico).
- **C6 (rework anatómico) NO se adelanta** salvo cláusula de escape ratificada:
  si en el Gate 1 los cuerpos corruptos impiden juzgar el FEEL, C6 entra aquí.

## Alcance (orden de construcción propuesto)

0. **Dagna aliada spawnea en el greybox** sobre los 4 componentes (config
   `"dagna"`), del lado del jugador. Extiende el spawn parametrizable del
   alcance 5 (flag de aliado, p. ej. `--ally=dagna`). Te sigue; sin combate aún.
1. **Ground-pound → zona de onda** (`PushPullComponent`) + VFX teal (burst +
   anillos de la lámina). El golpe de suelo como ataque propio de Dagna.
2. **Springboard T1:** input **Bond** pide el pound; **salto-en-ventana** →
   lanzamiento vertical amplificado (PushPull + supersalto PRD-005) + air
   control + feel/tell de ventana ([[Game Feel Bible]]).
3. **IA de combate mínima de Dagna:** muralla-block + defensa propia + pounds
   en contexto (pelea a tu lado).
4. **Gate 1:** escenario greybox con una **cornisa/objetivo solo alcanzable vía
   Springboard** + enemigos; `tests/autotest_springboard.gd`; **≥60 FPS frío**.

## Gate 1 — criterio de éxito

En el greybox: Dagna spawnea como aliada, **pelea a tu lado**, y usas el
**Springboard T1 sobre su onda para alcanzar una cornisa imposible**, todo a
**≥60 FPS** (corrida fría). Autotest verde. (El "sentir la pérdida" de la coda
es criterio del slice, no de este gate.)

## Reuso / dependencias (media mecánica ya construida)

- `PushPullComponent` (los links son casos de él, [[Combate]]).
- Supersalto / leap / air control del **PRD-005** (`player_controller.gd`).
- **Pipeline de personajes** (`characters.gd` / `signature.gd`) — Dagna ya
  montada in-engine (LOOK) desde 2026-07-07.
- **Greybox** `combat_arena.gd` + spawns parametrizables + `autotest_combat`
  (alcance 5).
- `Feel` autoload + [[Game Feel Bible]] (canales 1–3).

## QA (gates)

`test_core` + `autotest_combat` (regresión) + **`autotest_springboard`** (nuevo:
spawn de aliada, pound→onda, salto-en-ventana→altura de lanzamiento, cornisa
alcanzada) + gate de FPS ≥60 frío.

## Detalles ratificados (2026-07-08)

1. **Tecla de Bond (input único): `R`** (dedicada; `Q`=overclock aetherborn,
   `E`=interact ya usadas). El único botón de vínculo del juego.
2. **Tell de la ventana:** los **anillos de la onda** marcan el "salta AHORA"
   (lectura diegética) **+ un pulso sutil de HUD** de refuerzo.
3. **Spawn de Dagna:** flag **`--ally=dagna`** para pruebas **+** presente en
   el escenario del Gate 1.
4. **Pounds de la IA:** T1 arranca **solo-Bond** (alcances 1–2); el pound
   autónomo de la IA de Dagna se suma en el **alcance 3**.
