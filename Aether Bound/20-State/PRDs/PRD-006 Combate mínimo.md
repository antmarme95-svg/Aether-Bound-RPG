---
status: propuesto
source: "[[Combate]] (§4.2) + [[Game Feel Bible]] (ratificadas); Fase 1 del [[Plan-de-Produccion]]"
updated: 2026-07-05
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

## Alcance

1. **Arquitectura:** `CombatComponent` · `GuardComponent` (barra de
   Equilibrio) · `EnergyComponent` (Aether) · `PushPullComponent` — en
   jugador Y enemigos, sin scripts especiales. Datos externos `WeaponData`
   / `AbilityData` (JSON/Resource, mismo patrón del prototipo).
2. **Kit Humano Duelist:** combo ×4 con ventanas amplias; multiplicador de
   momentum (la velocidad al conectar escala el daño — sinergia
   slide/leap, ley sprint↔arma §4.2.B.5 respetada); parry Roba.
3. **2 enemigos, mismos componentes:** un **light** (rápido, postura
   frágil — muere al combo) y un **heavy** (torre de Equilibrio — obliga a
   romper postura o parry-desarmar). Telegraphs legibles (windup visible,
   regla de anticipación de la Bible).
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
  desarma; caps de hit-stop/trauma respetados.
- Montage strips del combo y las reacciones (patrón [[Lecciones]]).
- Gate ≥60 FPS en frío con 6 enemigos activos.
- **Aceptación del director (Playtest Loop), criterio literal: "no se
  siente como el prototipo 0".** Si falla, se tunea contra la Bible antes
  de abrir PRD-007.

## Riesgos

Ventanas AnimNotify sobre las anims procedurales actuales del rig (sin
C4 completo) — se resuelve con ventanas por timer normalizado del clip;
la ley sprint↔arma toca la FSM de locomoción conservada (PRD-005): cambios
mínimos y gateados por `autotest_slice` histórico.
