---
status: propuesto
source: "[[Combate]] (§4.2) + [[Game Feel Bible]] + [[Movilidad Realista]] (§4.3) (ratificadas); Fase 1 del [[Plan-de-Produccion]]; iterado 2026-07-06 con el mandato del director: la movilidad realista es la columna vertebral"
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
