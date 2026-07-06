---
status: propuesto
source: "Deep dive 2026-07-06 (pedido del director): entrevistas/artículos de Shedworks (Sable), Microbird (Hinterberg), técnica Guilty Gear Xrd / Spider-Verse. v2 (B14, 2026-07-06): GDC/entrevistas de Ubisoft (motion matching), IOI (Glacier Next), Guerrilla (HZD), Respawn (Jedi), Sloclap (Sifu). v3 (B15, 2026-07-06): clips 60fps grabados por el director en C:/Users/tonom/Videos/NVIDIA/ (Sifu 13.25, Fortnite 13.21, Sable 13.30) — análisis frame a frame propio"
updated: 2026-07-06
---

# Benchmark Biomecánico — qué hacen Sable y Hinterberg en realidad

> Pedido del director (2026-07-06): "estamos muy lejos de ese benchmark".
> El deep dive confirma la distancia — pero la brecha NO está donde
> esperábamos. Fuentes al pie.

## El hallazgo central (plot twist)

**Sable no es biomecánicamente realista. Es lo contrario — y por eso lee
tan bien.** Micah Holland (animador de Sable, Shedworks):

- Anima **en 2s** (12 poses por segundo, cada una sostenida 2 frames),
  frame a frame en Blender — "hojear un cómic". Exactamente la técnica de
  Spider-Verse y Guilty Gear Xrd: 3D poseado con keys escalonados, sin
  interpolación suave.
- **"Sometimes you need to push [poses] to the extreme. You may think
  'no one moves like that', but your character does."** Cita a Mario como
  movimiento irreal pero creíble. Legibilidad y carácter > realismo.
- El carácter vive en la pose: Sable troteando balancea los brazos a los
  lados; esprintando se encorva hacia adelante. Cloth secundario (Magica
  Cloth) para las telas.
- Sus propias referencias: **BotW, Ghibli, Trigger** — que sí usan peso e
  IK reales por debajo del estilo.

**Hinterberg:** no hay data pública de su sistema de animación (el deep
dive técnico publicado es de rendering: deferred custom con material IDs,
normales→líneas dibujadas). Las lecciones documentadas de Microbird son de
**eficiencia con equipo mínimo** (assets sin texturas, estilo que abarata
producción) y su feel de combate es herencia BotW. Benchmark de animación
real: el de Sable.

## Diagnóstico de nuestra brecha

Nuestro rig procedural hoy es **suave y continuo (senoidales interpoladas
a 60 fps)**: no es ni realista ni expresivo — es *gomoso*, que es la peor
esquina del cuadrante. La brecha contra el benchmark no se cierra con más
anatomía; se cierra con **timing escalonado y poses extremas**.

## Síntesis con nuestro canon (no hay contradicción)

[[Movilidad Realista]] (§4.3) dice: *la estilización vive en el render,
nunca en el esqueleto*. El benchmark agrega la capa que faltaba — la
estilización también vive en el **timing**:

| Capa | Regla | Estado |
|---|---|---|
| **Esqueleto** (ROM, constraints, cadena de peso) | REALISTA — el mandato §4.3 intacto; BotW (referencia de Sable) también lo hace | ✅ vivo (PRD-006 alcance 0) |
| **Pose** (keys del movimiento) | EXTREMA y legible — empujada al borde del ROM | 🔄 empezado (feedback del coil) |
| **Timing** (muestreo visual) | **EN 2s** — pose sostenida ~1/12 s, sin interpolación; el ritmo "brusco pero expresivo" del cómic ([[Art Bible]]: *novela gráfica pintada a mano*) | ✅ vivo — A/B 2026-07-06 (3 rondas): **CANON = 12 Hz SOLO en extremidades; cuerpo suave a 60**. El body pop se probó completo (lag), con moving hold y a 24 Hz — descartado por ahora; el mecanismo queda tras toggle por si el alcance 1 reabre la pregunta. Tecla T cicla los 3 modos |
| **Secundario** (tela, pelo, follow-through) | Simulado suave POR ENCIMA del stepping (como Sable: Magica Cloth) | ⬜ Fase 4 |

Regla de oro derivada: **el gameplay nunca se escalona** — hitboxes,
ventanas de combate ([[Game Feel Bible]]) e input corren continuos a
60 fps; solo la POSE visible se muestrea en 2s. El cuerpo decide continuo,
el cómic se dibuja a 12.

## Acciones concretas (alimentan PRD-006)

1. **Pose stepping en el rig** (toggle `animation_on_twos`): muestrear la
   pose procedural a ~12 Hz con hold, gameplay intacto a 60. A/B con el
   director en vivo/montage. ← primera consecuencia, implementable ya.
2. **Curvas con anticipación/overshoot** en el strike (reemplazar
   smoothstep por curvas snap: hold largo en el coil, release violento,
   settle con rebote pequeño). ✅ implementado en PRD-006 alcance 1
   (2026-07-06): `rig_biomech.segment_offset` v2 — coil con moving hold
   (+6% drift), release back-out (~10% overshoot), settle con contra-swing
   de −7%; fracciones de fase (= ventanas de combate) intactas.
3. **Moving holds** si el stepping puro se siente muerto (micro-drift
   dentro del hold, técnica estándar de stop-motion/Xrd).
4. La capa de constraints (alcance 0) queda como red de seguridad — las
   poses extremas se empujan CONTRA el ROM, nunca a través de él.

## v2 — State of the art AAA (B14, 2026-07-06)

Encargo del director: mapear las técnicas de AC, 007 First Light, HZD,
Star Wars Jedi y Sifu, y decidir qué vale para un equipo de 1+LLM en
Godot. **Hallazgo estructural: el AAA se divide en dos familias.**

### Familia A — data-driven (motion matching): SE DESCARTA

- **Assassin's Creed / For Honor (Ubisoft):** motion matching nació ahí
  (Simon Clavet, post-AC III; GDC 2016). Filosofía "declarativa": en vez
  de clips cortos en máquinas de estado, tomas LARGAS de mocap con markup,
  y una función de costo (~10 factores: huesos, velocidades locales, pies,
  arma) elige cada frame el mejor segmento. Requiere *dance cards* de
  captura (caminatas, giros 45/90/135/180°, paradas, arranques, evasivas),
  actores, infra de motor y presupuesto de memoria.
- **007 First Light (IOI, 2026):** confirma que motion matching es EL
  estándar AAA actual — Glacier Next añadió motion matching, motion
  warping e interacciones full-body.
- **Veredicto 1+LLM:** ❌ el combustible es una base de datos masiva de
  mocap; sin ella no hay nada que "matchear". Se descarta por costo, sin
  ambigüedad. **Ideas rescatables sin el sistema:** (1) el dial explícito
  responsividad↔fidelidad como parámetro de diseño; (2) *motion warping* —
  deformar la trayectoria de una acción hacia el objetivo real — que
  nuestro strike ya hace en versión procedural (drive de cadera al target).

### Familia B — autorada + capas: NUESTRO CAMINO (validado)

- **Sifu (Sloclap) — el benchmark real para nosotros.** Combate ~100%
  **handkey** (Maya); mocap solo en takedowns y retrabajado ~80%. Con un
  maestro de pak mei eligieron ~200 movimientos de referencia. Claves:
  - **Estructura trifásica de todo ataque:** *build-up* (señala la
    intención) → *impacto* (generación de fuerza) → *release* (energía
    consumida, devuelve el control). Es EXACTAMENTE nuestra curva
    anticipación/golpe/settle (acción #2) y las ventanas de la
    [[Game Feel Bible]].
  - **Legibilidad sin UI:** silueta ante todo, timing manipulado para
    destacar la extremidad que golpea, y **ralentización deliberada** del
    pak mei real (una secuencia de <1 s se expande para leerse). Refuerza
    el hallazgo v1: el timing es material de diseño, no output del rig.
  - **Movilidad:** golpes cerrados, rápidos, sin saltos de florete —
    utilidad táctica sobre espectáculo. Su economía de posición/guardia es
    pariente del Equilibrio de [[Combate]].
  - **El costo real es iteración, no tecnología:** cada ataque se retrabaja
    "docenas de veces"; equipo de 2 → 15 animadores; combo editor propio
    (nodos in-engine). Para 1+LLM la lección es doble: nuestras curvas
    procedurales iteran barato (ventaja), pero hay que presupuestar
    MUCHAS rondas de feedback del director por ataque (es el pipeline,
    no un extra).
- **Horizon Zero Dawn (Guerrilla/Decima):** mocap anotado (markup de
  contacto de pie) + **foot IK contra el terreno** cada frame; suite de
  locomoción explícita: stand/crouch, starts, cycles, banks, strafing,
  turns, stops, hit reactions, dive roll. **Rescatable:** (1) el foot IK
  con anotación de contacto mapea directo a C4 (pies IK) con
  `SkeletonIK3D`/modifiers de Godot — barato y de alto valor; (2) la suite
  de locomoción es nuestro checklist de estados para [[Locomoción]].
- **Star Wars Jedi: Fallen Order (Respawn, GDC 2020):** **physical
  animation** — simulación física mezclada POR ENCIMA de animación
  autorada (UE4+PhysX, blend por hueso), activada en golpes, impactos y
  transiciones; aporta fluidez y respuesta al contacto. **Rescatable
  parcialmente:** en Godot existe la pieza (`PhysicalBone3D` / physics
  modifiers), pero nuestra versión barata es respuesta a impulso
  procedural sobre la pose — y respeta la regla v1: lo secundario corre
  SUAVE por encima del stepping (como el cloth de Sable). → Fase 4 /
  alcances tardíos de PRD-006, no ahora.

### Tabla de veredictos

| Técnica | Juego | Qué resuelve | Costo real | Veredicto 1+LLM/Godot |
|---|---|---|---|---|
| Motion matching | AC, For Honor, 007 | locomoción fluida y responsiva | base mocap + infra motor + memoria | ❌ descartado |
| Motion warping | 007 | acción llega al target real | medio | ✅ ya lo hacemos procedural (hip drive) |
| Handkey trifásico + timing manipulado | Sifu | combate legible AAA sin mocap | iteración (docenas de rondas) | ✅✅ ES nuestro camino; presupuestar feedback |
| Foot IK + anotación de contacto | HZD | pies creíbles en terreno | bajo (Godot lo trae) | ✅ → C4 |
| Suite de locomoción explícita | HZD | cobertura de estados | medio (por estado) | ✅ checklist para [[Locomoción]] |
| Physical animation (blend físico) | Jedi FO | respuesta al contacto, fluidez | medio-alto | 🔶 versión procedural barata; Fase 4 |

**Conclusión v2:** el state of the art AAA no invalida nada de la v1 — la
confirma. Sifu demuestra que se llega a feel de combate AAA sin mocap,
con pose autorada + estructura trifásica + timing manipulado; HZD aporta
la única pieza de "realismo" que falta (foot IK); el resto del AAA
(motion matching) es una economía de escala que no es la nuestra. La
pila de 4 capas de la síntesis v1 queda ratificada como arquitectura, y
PRD-006 alcance 1 (curvas anticipación/overshoot = trifásico de Sifu)
es exactamente el paso correcto.

## v3 — B15: mediciones observacionales con clips (2026-07-06)

Clips grabados por el director (60 fps, 1080p; 1 frame = 16.7 ms):
Sifu (combate, sala de entrenamiento, 79 s) · Fortnite (movilidad en campo
abierto, 50 s) · Sable (interior de la cabeza gigante, 54 s). Método:
hojas de contacto frame a frame (ffmpeg) + perfil de movimiento por frame
(YDIF de `signalstats`: un hit-stop es una racha de frames idénticos, un
impacto es un pico). Los números de abajo son **medidos**, no estimados.

### Sifu — timings de combate

| Acción | Medición (frames @60) | Segundos |
|---|---|---|
| Golpe de combo: viaje de extensión→contacto | ~2–3 f | 0.03–0.05 |
| Golpe de combo: cadencia entre impactos | 16 f | 0.27 |
| Par rápido dentro del combo (1-2) | 8 f entre impactos | 0.13 |
| Pausa de re-chamber antes del remate | 28–29 f | ~0.47 |
| Patada (remate): chamber + barrido | ~8 f + ~5 f | ~0.22 |
| Double Palm (cargado): windup | ~32 f | 0.53 |
| Double Palm: follow-through sostenido | ~24 f | 0.40 |
| **Hit-stop golpe normal** | **2 f congelado TOTAL** | **0.033** |
| **Hit-stop golpe pesado (arma)** | **3 f** | **0.050** |
| Reacción del enemigo (head-snap) | arranca al frame siguiente del contacto | <0.02 |

Impactos del primer combo medidos en 0.999 / 1.266 / 1.400 / 1.883 /
2.349 s (patada): el ritmo es **sincopado** — pares rápidos + pausa
larga antes del remate, no un metrónomo. El hit-stop congela TODO el
frame (ambos personajes), no solo al que pega.

**Contra `weapons.json` actual:** `unarmed` (dur 0.34/0.38) está en la
zona correcta pero un pelín lento vs los 0.27 de Sifu; el contacto de
Sifu cae ≈60% del ciclo del golpe → **nuestra frontera de release 0.58
queda validada por medición**. `heavy_maul` (0.80/1.00 con interrupt) ≈
Double Palm (0.53 windup + 0.40 follow ≈ 0.93 total) — validado. La
síncopa sugiere que las `dur` de un combo NO deben ser uniformes:
variar cadencia y meter un hueco antes del interrupt.

**Faltantes del clip** (no capturados con claridad): parry y guard
break. Si el director quiere esos números, pedir un clip corto contra
un enemigo agresivo (defensa deliberada).

### Fortnite — timings de movilidad

| Acción | Medición | Segundos |
|---|---|---|
| Ciclo completo de carrera (2 pasos) | 27–30 f | 0.45–0.50 |
| Cadencia de pasos | — | ~4.3 pasos/s |
| Salto: tiempo en el aire | ~34 f | 0.57 |
| Aterrizaje → carrera (no bloqueante) | ~6 f | ~0.10 |
| Slide: entrada carrera→pose completa | ~6 f | ~0.10 |
| Slide: duración sostenida (cuesta abajo) | — | 2.0–2.3 |
| Slide → carrera (salida) | sin corte perceptible | ~0.1 |

Lección de feel: **ningún estado de movilidad bloquea al siguiente** —
aterrizar no interrumpe el sprint, el slide entra y sale en ~6 frames.
El peso se comunica con polvo (ráfaga al arrancar sprint, estela
continua en el slide), no con frames de bloqueo. Mantle no aparece en
el clip (terreno abierto sin bordes).

### Sable — el lenguaje del timing, medido

| Capa | Medición |
|---|---|
| Extremidades (carrera Y escalada) | poses sostenidas **~4 frames** (≈15 Hz efectivos) |
| **Raíz** | **avanza CONTINUA cada frame** — cero pop, cero stepping |
| Secundario (poncho) | simulación suave continua POR ENCIMA del stepping |
| Idle | cuasi-estático (respiración lenta); lo "vivo" son los VFX del entorno |
| Contactos de escalada | puffs de polvo en mano/pie por agarre |

**LA respuesta a la pregunta clave (raíz vs body pop):** confirmado
frame a frame — Sable NO escalona la raíz. En carrera, el personaje se
desplaza suavemente respecto a las baldosas del piso en cada frame
mientras las piernas/brazos sostienen poses de 4 frames. **Es
exactamente nuestro canon del A/B (stepping solo en extremidades,
cuerpo/raíz a 60): validación 1:1; el descarte del body pop coincide
con la referencia.** Nota: medimos ~4 f de hold (15 Hz), nuestro toggle
está en 12 Hz — misma familia; el A/B con el director ya eligió y no
hay motivo para reabrir.

### B15b — catálogo de lecciones de Sifu (28 clips, 2026-07-06 tarde)

El director grabó el tutorial COMPLETO de Sifu (lecciones ejecutadas en
vivo, con fallos incluidos — oro: los fallos muestran el feedback de
timing del juego) + 2 peleas reales. Mapa del material (copias
analizadas; originales en `C:/Users/tonom/Videos/NVIDIA/Sifu/`,
serie 16.03–16.25):

| Clips | Lección | Qué contiene |
|---|---|---|
| 01–03 | Structure & Block | bloqueo, daño de estructura, **guard break al jugador** |
| 04–06 | Deflect ×3 | timing del deflect, con fallos "Too Early" |
| 07–11 | Parry ×5 | parry → throw / contraataque / stun |
| 12–16 | Avoid ×5 | weave alto/bajo, castigo con slowdown |
| 17–19 | Special Attacks | extremidades brillantes, throws |
| 20–26 | Command Attacks | palm strike, sweep, knockdowns, crowd control |
| 27–28 | Peleas reales | ritmo de combate en contexto (The Club) |

**Mediciones nuevas (los 3 faltantes de la v3, ahora cerrados):**

| Mecánica | Medición | Detalle |
|---|---|---|
| **Parry exitoso** | hit-stop **3 f (50 ms)** en el clang | MÁS peso que un golpe normal (2 f): el parry se premia con el freeze más gordo |
| Parry → contraataque | conecta ~0.25–0.30 s tras el clang | la ventana de riposte abre inmediato |
| Parry → stun del enemigo | **≥0.85 s medidos** doblado e indefenso | la lección corta antes del final; el juego dice "a short while" (~2 s en juego real) |
| **Guard break (al jugador)** | burst blanco + golpe gratis + **stagger ~1.0 s sin control** | brazos en molinete, retrocede tambaleando, luego recupera guardia |
| Ventana de deflect/parry | estricta, con castigo | feedback "Too Early" en pantalla: presionar antes NO cuenta — el spam se castiga, no se perdona |
| Bloqueo bajo presión | el jugador bloqueando CEDE TERRENO | el special con extremidad brillante lo empuja deslizando en pose de guardia; la barra de estructura es el presupuesto visible |

Nota de método: los congelados de ~18 f cada 4–5 s en los clips de
lección son pausas pedagógicas/fades de reset del tutorial, NO
hit-stops de gameplay — no calibrar con ellos. Igual que el demo
fantasma del menú (slow-mo). Los números de arriba salen de las
ejecuciones en vivo.

### B15c — gaits extra de Sable: crouch walk y sprint (2026-07-06 tarde)

Dos clips más del director (serie 16.40/16.43). Confirman el sistema y
agregan LA lección de gaits:

| Gait | Timing medido | Silueta (el hallazgo) |
|---|---|---|
| Crouch walk | holds ~4 f, raíz continua | torso plegado ~90°, una mano ROZANDO el suelo — pose extrema, se lee a un pixel |
| Sprint | holds ~4 f, raíz continua, ciclo ~0.4–0.5 s | encorvada hacia ADELANTE, cabeza baja, brazos bombeando — la cita de Holland ("sprinting se encorva") verificada frame a frame |

**Lección para [[Locomoción]] / C4:** cada gait tiene UNA pose de
silueta propia empujada al borde del ROM — no es el mismo ciclo más
rápido o más agachado. Crouch ≠ walk agachado: es otra pose. Sprint ≠
run acelerado: es otra postura de columna. Nuestro rig con columna en
2 segmentos ya puede plegar el torso por gait (lumbar+torácico); los
gaits L5/L6 deberían adoptar posturas de columna DISTINTAS por estado
de la FSM (idle erguida / crouch plegada / sprint encorvada).

### Consecuencias directas (alimentan PRD-006 alcance 2)

1. **Hit-stop del [[Game Feel Bible]]:** 2 f (33 ms) golpe normal,
   3 f (50 ms) pesado, congelado global. Presupuesto exacto, medido.
2. **`weapons.json`:** mantener fases (0.58 validado); acelerar un poco
   `unarmed`; romper la uniformidad de `dur` dentro de cada combo
   (síncopa: par rápido + pausa + remate).
3. **Reacción del que recibe: al frame siguiente.** El head-snap
   inmediato es la mitad de la legibilidad del golpe — el HitPayload
   debe aplicar la reacción en el mismo tick del contacto.
4. **Locomoción ([[Locomoción]]):** estados no bloqueantes estilo
   Fortnite — aterrizaje ~0.1 s que no corta el sprint; slide con
   entrada/salida de ~6 f.
5. La pila de 4 capas (v1) y el camino Sifu (v2) quedan **ratificados
   por medición propia** — tercera fuente independiente que apunta al
   mismo lugar.
6. **Parry Roba (B15b):** hit-stop del parry = 3 f (un frame MÁS que el
   golpe normal — el premio se siente en el freeze); ventana estricta
   con castigo al input temprano (nada de spam perdonado — casa con el
   buffer generoso PERO ventana de parry exigente); riposte inmediato
   (~0.3 s) y stun de ~1–2 s como recompensa.
7. **Guard break (B15b):** romper la guardia = burst + golpe gratis +
   ~1.0 s de stagger sin control. Número directo para el presupuesto de
   `balance` y el interrupt de `weapons.json`.
8. **El bloqueo cede terreno:** bloquear un golpe pesado desplaza al
   que bloquea (desliza hacia atrás en pose de guardia) — barato de
   implementar con nuestro PushPullComponent y vende el peso sin animación
   extra.

## Fuentes

- gamedeveloper.com — "Emotion in motion: expressive character animation"
  (entrevista a Micah Holland, Sable).
- gamedeveloper.com — "How Shedworks refined the art of Sable in pursuit
  of readability".
- awn.com / imageworks.com — técnica "on twos" de Spider-Verse.
- 80.lv — "Dungeons of Hinterberg: Shaders, Gameplay & More" (Microbird,
  rendering).

Fuentes v2 (B14):

- GDC Vault — "Motion Matching and The Road to Next-Gen Animation"
  (Kristjan Zadziuk, Ubisoft; GDC 2016).
- gameanim.com — "Motion-Matching in Ubisoft's For Honor" (Simon Clavet).
- Digital Foundry / resetera — "007 First Light: A Deep Dive Into The
  Evolved Glacier Engine" (Glacier Next: motion matching, motion warping).
- Guerrilla Games (slideshare) — "Player Traversal Mechanics in the Vast
  World of Horizon Zero Dawn" (GDC 2017); jonathan-colin.com (gameplay
  animator, suite de locomoción de Aloy).
- GDC Vault / gameanim.com — "Physical Animation in Star Wars Jedi:
  Fallen Order" (Bartlomiej Waszak, Respawn; GDC Summer 2020).
- pointnthink.fr — entrevista a Kevin Roger, animation director de Sifu
  (estructura trifásica, handkey, combo editor, 2→15 animadores).
- digitaltrends.com — "How Sifu's developers made Kung Fu easy to
  understand" (Sloclap: pak mei, ralentización, legibilidad).
