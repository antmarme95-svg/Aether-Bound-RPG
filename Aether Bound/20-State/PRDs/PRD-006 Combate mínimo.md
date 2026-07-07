---
status: ratificado
source: "[[Combate]] (§4.2) + [[Game Feel Bible]] + [[Movilidad Realista]] (§4.3) (ratificadas); Fase 1 del [[Plan-de-Produccion]]; iterado 2026-07-06 (movilidad realista = columna vertebral) y RATIFICADO por el director 2026-07-06"
updated: 2026-07-06
---

# PRD-006 — Combate §4.2 mínimo (Fase 1)

**Objetivo:** en un greybox plano, el kit del Humano Duelist contra 2 tipos
de enemigo, implementado sobre los 4 componentes canónicos y sintiéndose
según la [[Game Feel Bible]]. Alimenta directamente el Gate 1.

## Anti-objetivo (mandato del director)

**El combate del prototipo 0 se REEMPLAZA, no se extiende.** Lo viejo
(`try_attack()`: un botón con cooldown 0.45–0.65 s, chequeo de arco
instantáneo, daño plano, enemigo que responde con flash 0.12 s + empujón
0.35 m) queda intacto solo para que `autotest_slice` histórico siga verde;
**nada del combate nuevo lo llama**. La diferencia es estructural:

| Prototipo 0 | PRD-006 |
|---|---|
| Botón + cooldown | **Cadena de combo** 3–4 golpes con ventanas AnimNotify + input buffer generoso (el sello del Humano Duelist) |
| Daño plano | **HitPayload** (Daño, DañoEquilibrio, VectorFuerza, Interrupción) + el momentum de locomoción alimenta el daño |
| Flash + nudge | **Reacciones por Equilibrio:** flinch → stagger → posture break (ventana de castigo); knockback por VectorFuerza |
| Sin defensa | **GuardComponent:** bloqueo + parry "Roba" (dilation 0.2×0.35 s + sting + desarme, canon §4.2.B.4) |
| Sin lenguaje de tiempo | Hit-stop 40/70/110 ms por masa de arma + shake trauma² ([[Game Feel Bible]] canales 1–2) |
| Cámara indiferente | Combat framing (FOV +4°, histéresis 2 s) + soft-aim cono 30° |

## Columna vertebral: [[Movilidad Realista]] (§4.3)

**Mandato del director (2026-07-06): el combate se construye con foco en
la movilidad realista.** No es una capa de polish — es el orden de
construcción. Canon aplicado:

- **El moveset DERIVA del esqueleto**, nunca al revés (§4.3): los arcos,
  alcances y wind-ups del Duelist salen de los joint constraints del ROM
  humano de referencia — nada rota donde un cuerpo no rota.
- **Todo golpe nace en la cadera** y se encadena cadera→torso→hombro→brazo.
  Las ventanas de combo NO son timers arbitrarios: se anclan a las **fases
  biomecánicas** del golpe — *carga* (la cadera gira atrás) = windup
  cancelable, *transferencia* (la cadena descarga) = frames activos del
  hitbox, *re-equilibrio* = recovery donde vive la ventana de encadenar.
  El input buffer del Duelist es generoso porque su cuerpo re-equilibra
  rápido — la mecánica ES la biomecánica.
- **El momentum→daño es física corporal:** masa (perfil 9-cell) ×
  velocidad al conectar. Un golpe saliendo del slide pega más porque el
  cuerpo trae el peso, no por un multiplicador mágico.
- El gait procedural L5/L6 (aceptado en playtest) **se profundiza, no se
  reemplaza**: las anims de ataque son procedurales sobre el mismo rig,
  con constraints anatómicos clampeados (hombro 3-DOF, codo bisagra,
  columna segmentada).

## Alcance (en orden de construcción)

0. **Rig humano restringido (C4 parcial, PRIMERO):** joint constraints
   anatómicos sobre el rig procedural existente + cadena de transferencia
   de peso para los golpes (hip-first). Sin esto no se anima ningún ataque.
   El humano es el ROM de referencia ([[Movilidad Realista]]) — el
   esqueleto más barato de hacer bien primero ([[Slice of Bond]]).
1. **Arquitectura:** `CombatComponent` · `GuardComponent` (barra de
   Equilibrio) · `EnergyComponent` (Aether) · `PushPullComponent` — en
   jugador Y enemigos, sin scripts especiales. Datos externos `WeaponData`
   / `AbilityData` (JSON/Resource, mismo patrón del prototipo).
2. **Kit Humano Duelist:** combo ×4 animado DESDE el esqueleto (fases
   biomecánicas = ventanas); momentum corporal escala el daño (sinergia
   slide/leap, ley sprint↔arma §4.2.B.5 respetada); parry Roba — que es
   el parry humano precisamente porque usa la transferencia atlética:
   agarra el brazo y redirige el VectorFuerza del rival.
3. **2 enemigos, mismos componentes Y mismas reglas de esqueleto:** un
   **light** (palancas largas, arcos amplios y rápidos, postura frágil) y
   un **heavy** (arcos bajos de cadera estilo enano, torre de Equilibrio —
   obliga a romper postura o parry-desarmar). El telegraph ES la
   biomecánica: se lee la carga de cadera del rival, no un flash de color.
4. **Feel:** canales 1–3 de la [[Game Feel Bible]] implementados como
   sistema (TimeFeel/TraumaShake/CombatCamera reutilizables por PRD-007).
5. **Greybox:** arena plana con spawns parametrizables + harness de
   montage y autotest nuevo (`autotest_combat.gd`).

## Fuera de alcance

Marcas del Strategist (`MarkMultiplier` = 1.0 fijo), habilidades de Aether
más allá de un placeholder de coste, Dagna y los links (PRD-007), más
enemigos, DamageProfiles de las otras 8 celdas, integración con el flujo
CREATION→WILDS (la arena es escena propia hasta la Fase 3).

## QA y aceptación

- `autotest_combat.gd`: HitPayload aplica los 4 campos; combo encadena con
  buffer; posture break abre ventana; parry en ventana roba equilibrio y
  desarma; caps de hit-stop/trauma respetados; **assert de constraints:
  ninguna articulación excede su clamp anatómico durante el combo
  completo** (se loggea el máximo por joint).
- Montage strips del combo y las reacciones (patrón [[Lecciones]]) — la
  revisión biomecánica es criterio explícito: **¿el golpe nace en la
  cadera? ¿se lee la carga del enemigo?**
- Gate ≥60 FPS en frío con 6 enemigos activos.
- **Aceptación del director (Playtest Loop), doble criterio literal: "no
  se siente como el prototipo 0" y "el cuerpo importa más que el pixel".**
  Si falla, se tunea contra la Bible y §4.3 antes de abrir PRD-007.

## Decisiones de implementación (alcance 2, 2026-07-06)

- **Anti-objetivo resuelto por enrutamiento de input:** `try_attack()`
  (prototipo 0) queda byte-a-byte intacto; el input real (LMB/F) enruta a
  `duelist_attack()` cuando el estilo de la clase es melee. Solo los
  autotests históricos (`autotest_slice`, `autotest_duelist`) llaman al
  camino viejo, directamente. Verificado: `autotest_slice` ALL_PASS.
- **RMB contextual:** melee = guardia (hold bloquea; el PRESS abre la
  ventana de parry Roba — ventana estricta estilo Sifu/B15b, sin refresh
  por hold); clases ranged conservan ADS. `test_ads` no se ve afectado
  (asserts de datos/lógica).
- **Momentum capturado al ARRANCAR el swing** (no al conectar): la ley
  sprint↔arma frena el cuerpo el mismo tick, pero el golpe conserva el
  peso con el que salió (slide/leap → `move_speed_norm` > 1 → daño ↑).
- **Cadena con costo por paso:** cada golpe (incluido el encadenado por
  buffer) cobra 10 de stamina al disparar; sin stamina la cadena se corta
  limpio en el windup (cancel canónico).
- **Durs del combo sincopadas** con los números de B15 (Sifu): 0.40 /
  0.32 / 0.46 / 0.62 — par rápido, respiro, remate interrupt.
- **Lunge de la bestia → HitPayload** por `receive_hit()` del jugador
  (guardia resuelve bloqueo/parry/reacción); parry → bestia stunned ~2 s
  (recover extendido, B15b). Reacciones completas por Equilibrio de los
  enemigos = alcance 3.

## Decisiones de implementación (alcance 3, 2026-07-06)

- **Entrada canónica de daño enemigo:** `receive_strike(payload, attacker)`
  en todo enemigo — GuardComponent decide, el cuerpo anima. `hit()` del
  prototipo queda intacto (proyectiles + autotests históricos).
- **La reacción es CORPORAL y suspende la FSM:** stagger/broken congelan
  la IA (el cuerpo está ocupado perdiendo el equilibrio); posture break
  abre ventana de castigo con daño ×1.5 — reventar la torre paga.
- **Bestia (cuadrúpedo):** pose de reacción procedural por partes (head
  snap, roll lateral hacia el lado del impacto, derrumbe con patas
  abiertas) con pico el MISMO tick y decay smoothstep (B15: reacción al
  frame siguiente). El flash blanco queda como acento, ya no es el mensaje.
- **Jugador:** `rig.play_flinch(amp)` — head snap corre a 60 SIEMPRE
  (nunca stepped); el recoil de columna respira en el reloj de pose (2s).
  Amps: 0.35 bloqueado · 1.0 limpio · 1.4 stagger · 1.8 break.
- **Par light/heavy** (`enemy_humanoid.gd`): mismo CharacterRig y mismo
  `play_strike` hip-first que el jugador — el telegraph ES la carga de
  cadera. light: `raider_saber` (nuevo en weapons.json), masa 0.7,
  encadena con prob. 0.6; heavy: `heavy_maul`, masa 1.8, single hit con
  0.8–1.0 s de windup. Parry Roba contra ambos → desarme + stun 2 s
  (B15b). Spawn: solo vía sonda hasta el greybox (alcance 5).

## Riesgos

El rig restringido (alcance 0) es la apuesta grande del PRD: hacer anims
de ataque procedurales con transferencia de peso creíble sin animador es
territorio nuevo — mitigación: el gait L5/L6 ya probó el patrón (rodillas/
codos articulados aceptados en playtest) y el montage harness permite
iterar barato. La ley sprint↔arma toca la FSM de locomoción conservada
(PRD-005): cambios mínimos y gateados por `autotest_slice` histórico. Si
las fases biomecánicas como ventanas de combo resultan ilegibles en
playtest, fallback: ventanas por timer tuneadas a mano — pero se intenta
lo canónico primero.
