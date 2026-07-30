---
status: código de gating EJECUTADO (2026-07-14 noche) — 3 estilos reales + None listos; 3 estilos rotos identificados para rework de atlas aparte
source: "Aclaración de Boris tras el PRD de geometría nueva: el warpaint personalizable NO es un toggle binario ni exponer el slider existente — el jugador debe poder elegir entre VARIOS estilos distintos con buena pinta, incluyendo Ninguno, en creación de personaje antes de la campaña"
updated: 2026-07-14
---

# PRD — Warpaint personalizable (elección real de estilo)

## Aclaración de Boris

No alcanza con exponer `PhenotypeData.PHENOTYPE_FIELDS["warpaint"]` (ya
existe como dato) en una UI — antes de que la elección tenga sentido, cada
índice tiene que verse REALMENTE distinto y con buena pinta. Se resuelve
en paralelo con la ventana de geometría nueva (mismo momento del proyecto);
la pantalla de selección en sí sigue siendo Fase 4 del
[[Plan-de-Produccion]].

## Bug real encontrado y corregido

`character_rig.gd apply_phenotype()`: la "V" bilateral geométrica
(`_face_mark`, construida en la Fase C/Rework Fenotipo) se dibujaba para
**CUALQUIER** `warpaint_idx > 0` — es decir, elegir cualquiera de los 5
patrones del atlas (`warpaint_atlas.gd`, índices 1-5: Slash Crimson/
Hexbrand/Tribal Tide/Eye of Ash/Jagged Crown) mostraba ESE patrón CON la
"V" dibujada encima. Cada índice nunca fue visualmente distinto de los
demás — condición mínima para que la personalización tenga sentido. Fix:
la "V" ahora es exclusiva de `warpaint_idx == 6` ("Scout Marks", el único
índice que el atlas deja vacío a propósito porque su marca es geometría).

`phenotype_data.gd`: `WARPAINTS` tenía 6 entradas (0-5) pero el
atlas/geometría soportaban un 7º valor (6, Scout Marks) que nunca estuvo
expuesto como opción seleccionable. Agregado `"Scout Marks"` al array.

## Evaluación visual de los 6 estilos (banco nuevo `tmp_warpaint_gallery.gd`)

Render de cada índice 1-6 con el mismo personaje/color, aislado (sin la
"V" superpuesta, ya corregido el bug):

| # | Nombre | Veredicto |
|---|--------|-----------|
| 1 | Slash Crimson | ❌ Rayas verticales delgadas cubriendo toda la cara — lee como camuflaje/rejas, no como marca tribal. Probable distorsión de UV cerca de la ceja (lección ya documentada: "el mapeo v del atlas se comprime no-linealmente hacia la ceja"). |
| 2 | Hexbrand | ✅ Glifo pequeño y sutil en el centro de la frente (forma de "Y"). Limpio, con personalidad, no compite con el resto de la cara. |
| 3 | Tribal Tide | ❌ **Invisible de frente** — confirmado con zoom, cero pattern visible en `warpaint_3_tribal_tide.png`. Roto, no solo débil. |
| 4 | Eye of Ash | ✅ Banda sólida horizontal cruzando ambos ojos, tipo antifaz — bold, silueta muy reconocible a cualquier distancia. |
| 5 | Jagged Crown | ⚠️ Línea zigzag delgada pegada al nacimiento del pelo — casi tapada por el flequillo nuevo (Fase Geometría Nueva), sin peso visual. |
| 6 | Scout Marks | ✅ La "V" bilateral (Rework Fenotipo ronda 3, ya pulida en 3 rondas de QA) — el más terminado de los 6. |

**Resultado: 3 estilos reales con buena pinta (Hexbrand, Eye of Ash, Scout
Marks) + None = 4 opciones — cumple el mínimo pedido por Boris.** 3
quedan identificados como rotos/débiles (Slash Crimson, Tribal Tide,
Jagged Crown) — necesitan rework de las funciones de dibujo del atlas
(`warpaint_atlas.gd _draw_pattern()`, casos 1/3/5), no es un ajuste
rápido de parámetro. Capturas en `godot/test_out/warpaint_*.png`.

## Pendiente (no resuelto en esta sesión — fuera del scope de "reparar el bug + curar opciones viables")

- Rework de Slash Crimson/Tribal Tide/Jagged Crown en el atlas, o
  reemplazo por 3 patrones geométricos nuevos (mismo enfoque que Scout
  Marks) si el atlas UV sigue siendo poco confiable para trazos que
  crucen la ceja/frente.
- La UI de creación de personaje que expone la elección al jugador —
  confirmado como Fase 4, no de esta ventana.

## Definición de terminado (de ESTE sub-PRD)

Cierra con: bug de doble-dibujo corregido ✅, `WARPAINTS` con las 7
entradas reales ✅, evaluación visual honesta de las 6 ✅. La curación a
"solo 3-4 buenas" es una decisión de UI/datos que puede esperar a Fase 4
(mostrar solo las que pasaron la evaluación) sin bloquear el resto de la
ventana C6.
