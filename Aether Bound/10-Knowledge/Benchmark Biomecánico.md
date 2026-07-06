---
status: propuesto
source: "Deep dive 2026-07-06 (pedido del director): entrevistas/artículos de Shedworks (Sable), Microbird (Hinterberg), técnica Guilty Gear Xrd / Spider-Verse"
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
| **Timing** (muestreo visual) | **EN 2s** — pose sostenida ~1/12 s, sin interpolación; el ritmo "brusco pero expresivo" del cómic ([[Art Bible]]: *novela gráfica pintada a mano*) | ⬜ NUEVO — la pieza que nos faltaba |
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
   settle con rebote pequeño).
3. **Moving holds** si el stepping puro se siente muerto (micro-drift
   dentro del hold, técnica estándar de stop-motion/Xrd).
4. La capa de constraints (alcance 0) queda como red de seguridad — las
   poses extremas se empujan CONTRA el ROM, nunca a través de él.

## Pendiente (❓) — v2 encargada por el director (2026-07-06)

Extender el benchmark al **state of the art AAA de animación biomecánica**:
Assassin's Creed (locomoción/parkour por motion matching), 007 First
Light, Horizon Zero Dawn, Star Wars Jedi — y **Sifu** con foco triple:
biomecánica, movilidad y puntos de combate (su economía de posición/
guardia es pariente del Equilibrio de [[Combate]]). Objetivo: mapear qué
técnicas (motion matching, IK full-body, animation-driven vs physics)
valen para un equipo de 1+LLM en Godot, y qué se descarta por costo.
→ Task-Board B14, PRIMERA tarea de la próxima sesión.

## Fuentes

- gamedeveloper.com — "Emotion in motion: expressive character animation"
  (entrevista a Micah Holland, Sable).
- gamedeveloper.com — "How Shedworks refined the art of Sable in pursuit
  of readability".
- awn.com / imageworks.com — técnica "on twos" de Spider-Verse.
- 80.lv — "Dungeons of Hinterberg: Shaders, Gameplay & More" (Microbird,
  rendering).
