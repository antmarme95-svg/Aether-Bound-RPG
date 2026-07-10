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

---

# Extensión — Springboard dirigido (alcance 2b)

> **status: RATIFICADO (Design Loop 2026-07-09) — el director aprobó las 3
> decisiones (dos modos · arco emergente + empuje · extensión del PRD-007).**
> Nace de un playtest del alcance 2 (el director aprobó el feel base). Amplía el
> springboard con **colocación**: hoy la onda nace pegada a Dagna (tu hombro), no
> se puede *poner adelante* para arcar hacia una cornisa. Esto lo resuelve.
> **✅ CONSTRUIDO EN CÓDIGO (2026-07-09, Feature Loop)** — los 5 sub-pasos de
> abajo implementados: apuntado (`RMB` + raycast + decal clampeado a 11 m), orden
> `R` + viaje de Dagna (`traveling` → pound en el punto), arco dirigido (empuje
> 3 m/s hacia el punto), cooldown 4.5 s + rango + costo de dejar el slot. **Nota
> de control (decisión del director):** `RMB` pasó a apuntar y la guardia/parry se
> mudó al **botón lateral trasero del mouse (`XBUTTON1`)**; `SPACE` sigue siendo
> salto. Sonda `tmp_springboard_directed.gd` ALL_PASS. **✅ PLAYTEST DEL DIRECTOR
> APROBADO (2026-07-09): "ambos se sienten muy bien, nada que ajustar"** — los dos
> modos y el esquema de control validados en vivo; sin tuning pendiente (rango 11 m
> / cooldown 4.5 s / empuje 3 m/s quedan como están). Alcance 2b CERRADO.

**Insight del playtest:** el problema real no era el ángulo (el arco ya emerge de
tu momentum, sembrado en `_air_vel`), sino que **no puedes colocar la onda**: está
fija en el slot de Dagna a tu lado. La designación resuelve exactamente eso; el
45° cae solo al esprintar hacia una onda puesta adelante.

## Los dos modos (RATIFICADO 2026-07-09 — decisión del director)

1. **Reactivo (alcance 2, ya construido):** `R` → Dagna golpea **donde está** →
   relanzamiento rápido en combate. Barato e inmediato. **No se toca.**
2. **Dirigido (2b, nuevo):** `RMB` (mantener) entra en **modo apuntado**; `R`
   confirma la orden → Dagna **viaja al punto** designado → hace el pound ahí →
   esprintas hacia la onda y saltas en la ventana → **arco** hacia/sobre el
   objetivo. Traversal deliberado. Aterriza el *"es traversal Y combate"* del PRD.

## Modelo del modo dirigido

- **Apuntado (`RMB` mantener):** raycast cámara→suelo proyecta un **decal/retícula
  teal** en el punto objetivo, **clampeado al rango máx** de orden. Suelta RMB sin
  R = cancela.
- **Orden (`R` con RMB activo):** fija el destino y Dagna **viaja** a él
  (locomoción de seguimiento que ya tiene + ground-snap; **sin pathfinding rico**,
  línea directa). Al llegar → `ground_pound()` en el punto → la onda nace **ahí**,
  no en su slot.
- **Arco emergente + pequeño empuje (RATIFICADO):** el lanzamiento reusa el
  momentum sembrado en `_air_vel` (arco de tu sprint) **y suma un empuje
  horizontal pequeño hacia el punto** de la onda, para asegurar el arco aunque tu
  entrada sea imperfecta. Magnitud chica, tunable. **Cero física nueva** — capa
  sobre lo del alcance 2.

## Reglas de juego (números de arranque, a tunear en playtest)

- **Rango máx de apuntado/orden:** ~10–12 m (clamp del decal; fuera de rango el
  cursor se queda en el borde y/o se pinta "fuera de alcance").
- **Viaje de Dagna:** a su `MOVE_SPEED_MAX` (5.6) → ~2 s a rango full. Mientras
  viaja **abandona su slot de guardia a tu lado** — costo táctico real (te quedas
  sin muralla). Conecta con su IA de combate del **alcance 3**.
- **Cooldown tras un pound comandado:** ~4–5 s (evita spam; da rima). El modo
  reactivo puede tener su propio cooldown menor o compartir.
- **Ventana de la onda:** sigue 0.6 s (canon alcance 1).
- **Estados de Dagna:** `idle/follow → traveling → pounding → cooldown`. Solo una
  orden dirigida en vuelo a la vez.

## Feel / tell (GFB)

- **Decal de destino** teal en el suelo durante el apuntado (dónde caerá la onda).
- **Estado legible:** "Dagna en camino" vs. "lista" (los anillos siguen siendo el
  "salta AHORA" al pound; el cue de HUD del alcance 2 se reusa).
- El **empuje hacia el punto** debe leerse como intención, no como teleport.

## Canon (resuelto)

- **RMB+R preserva "R = el botón del vínculo":** RMB es **contexto de apuntado**
  (misma gramática que el ADS del ranged), R sigue siendo el disparo del Bond. No
  se rompe el "input único" de [[Acoplamientos]] — se contextualiza.

## Anti-objetivos (2b)

- **Sin pathfinding rico** (Dagna viaja en línea + ground-snap, como ya sigue).
- **Sin ondas múltiples simultáneas** (una orden dirigida en vuelo).
- **El modo reactivo NO cambia** (el alcance 2 queda intacto).
- **Sin medidor/tiers de Bond** (sigue fuera, como todo el PRD-007).

## Orden de construcción (2b)

1. **Apuntado:** modo `RMB` → raycast cámara→suelo + decal teal clampeado a rango.
2. **Orden + viaje:** `R` fija destino → Dagna `traveling` → al llegar, pound en el
   punto (reusa `ground_pound()` con posición objetivo).
3. **Arco dirigido:** al lanzarte desde una onda comandada, suma el pequeño empuje
   horizontal hacia el punto (sobre el `_air_vel` del alcance 2).
4. **Reglas:** cooldown + rango máx + estados de Dagna + costo de dejar el slot.
5. **QA:** extender `tmp_springboard.gd` (o probe nuevo): apuntar→ordenar→viaje→
   llegada→pound en el punto→arco que cubre distancia horizontal hacia el objetivo;
   verificar clamp de rango y cooldown.

## QA / dependencias (2b)

Reusa todo lo del alcance 2 (`_wave_at`, `_air_vel`/`_leaping`, `Feel`, HUD cue) +
la locomoción de seguimiento de `ally_dagna.gd`. El único sistema nuevo es el
apuntado (raycast + decal) y la máquina de estados de la orden.
