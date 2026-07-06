---
status: propuesto
source: "Design Loop 2026-07-05 (B10); semillas GDD §4.2.D/§6.3 + valores vivos del prototipo (locomotion.json, player_controller.gd)"
updated: 2026-07-05
---

# Game Feel Bible (§6.3) — cámara, peso, respuesta

> Gatea la Fase 1 del [[Plan-de-Produccion]]: PRD-006/007 implementan
> CONTRA esta página. Gate de aceptación: montage harness + juicio del
> director; ≥60 FPS es intocable.

## Principios

1. **El peso nace de la masa.** Todo feedback (hit-stop, shake, thump)
   escala con el perfil 9-cell — la misma fuente de datos que el
   Equilibrio ([[Combate]] B.3). Un martillo enano y una daga no comparten
   ningún número.
2. **El feel vivo es canon.** FOV-kick de sprint (+8° sobre base 50),
   landing stutter (0.03 s/m, cap 0.35 s) y cam-thump (0.18 s × masa, dip
   −0.12 m) ya pasaron playtest — la capa de combate se SUMA, nunca los
   reemplaza ni duplica.
3. **Presupuesto sensorial, no acumulación.** Los efectos no se apilan:
   cada canal (tiempo, cámara, shake) tiene un cap y una prioridad. La
   sopa de screen-shake es la anti-referencia.
4. **La gramática del Bond invade el combate.** El sting de dos notas
   ([[Bond y el Bond Vacío]]) puntúa parry y momentos de link — el feel
   también cuenta la historia.

## Canal 1 — Tiempo (hit-stop y dilation)

| Evento | Efecto | Valor |
|---|---|---|
| Hit conectado, arma light (dagas) | hit-stop | **40 ms** |
| Hit conectado, arma medium (espadas) | hit-stop | **70 ms** |
| Hit conectado, arma heavy (martillo de Dagna) | hit-stop | **110 ms** |
| Golpe de muerte (último enemigo del encuentro) | hit-stop | ×1.5 |
| **Parry** (canon §4.2.B.4) | time-dilation global | **0.2 × 0.35 s** + sting |
| Recibir daño | hit-stop reducido | 50% del valor del arma enemiga |

Reglas: la dilation del parry ANULA cualquier hit-stop simultáneo (no se
apilan); máximo un hit-stop por ventana de 100 ms (los combos rápidos del
Humano Duelist no deben sentirse como stop-motion).

## Canal 2 — Screen-shake (modelo trauma)

- Variable **trauma ∈ [0,1]**; shake efectivo = trauma² (Perlin, nunca
  jitter random). Decae **1.2/s** lineal.
- Amplitud máxima: **0.25 m** traslación + **2°** roll.
- Aportes: hit light **+0.15** · hit heavy **+0.30** · ground-pound de
  Dagna **+0.50** · lanzamiento Springboard **+0.35** · recibir hit heavy
  **+0.25**.
- **Cap 0.6** en gameplay; trauma 1.0 reservado a beats scriptados (la
  traición).
- Regla de reparto: el shake comunica **masa ajena** (lo que golpea cerca
  tuyo); el impacto **propio** habla por thump/stutter (canal ya vivo).

## Canal 3 — Cámara de combate

**Decisión propuesta: cámara LIBRE con soft-assist — sin lock-on duro.**

Razón: la celda del slice (Humano Duelist) vive del momentum encadenable
(sprint→slide→leap alimentan el daño); un lock-on duro estilo souls pelea
contra la locomoción, que es el corazón ya aceptado del prototipo. En su
lugar:

- **Soft-aim:** los ataques magnetizan hacia el enemigo más cercano al
  vector de input (cono de 30°, alcance del arma ×1.3).
- **Combat framing:** en combate la cámara abre FOV +4° y sube levemente;
  vuelve sola al explorar (histéresis 2 s).
- Revisión en el **Gate 1**: si el greybox lo desmiente, se re-abre aquí
  (regla de salida del plan). Lock-on como opción de accesibilidad queda
  anotado para post-slice.

## Canal 4 — El feel del Springboard (el link del slice)

- **Anticipación legible de Dagna:** windup del ground-pound **0.4 s**
  (ella "carga la montaña") + onda visible en el suelo.
- **Apex float:** al culminar el lanzamiento, gravedad ×0.5 durante
  **0.2 s** — el regalo del link es ese instante de silencio en el aire.
- FOV kick adicional **+6°** durante el ascenso (se suma al canal vivo).
- T2/T3: el sting de dos notas suena suave en cada lanzamiento — para que
  su ausencia post-traición se ESCUCHE ([[Bond y el Bond Vacío]]).
- Post-traición (links degradados, [[Combate]] B.6): mismos assets, sin
  float, sin sting, FOV kick a la mitad — la orfandad es feel, no solo
  números.

## Pendiente (❓)

Ratificación del director (decisión mayor: cámara libre + soft-assist);
tuning fino por montage en Fase 1 (los valores son puntos de partida, no
dogma); hit-stop de enemigos pesados (diseño de enemigos, post-PRD-006);
sonido más allá del sting (B8). → Task-Board B10.
