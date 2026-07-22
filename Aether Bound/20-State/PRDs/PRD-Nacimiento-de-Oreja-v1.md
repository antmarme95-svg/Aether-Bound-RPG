---
status: propuesto (pendiente VoBo de Boris antes de ejecutar)
created: 2026-07-22
updated: 2026-07-22
owner: Boris (director) / orquestador
---

# PRD — Nacimiento de oreja (unión oreja↔cráneo) v1

> Frente detectado por Boris el 2026-07-22 al cerrar la ronda 10 de la
> oreja de elfo. Decisión suya: **frente aparte, PRD propio** — no colar
> los fixes dentro del QA loop del elfo. Este documento es ese PRD.

## Objetivo

Que la oreja **nazca** del cráneo en las 3 razas: que la unión lea como
carne continua con pabellón y lóbulo, no como una masa pegada encima.
Hoy humano y enano leen "canica pegada al costado de la cabeza" — se ve
la costura circular completa de la esfera contra el cráneo.

## Diagnóstico medido (no a ojo)

Semiejes reales del cráneo: `HairLibrary.SKULL_SEMI = (0.123, 0.141,
0.1425)`, centro `SKULL_C = (0, 0.012, 0)` ([[Lecciones]]: medir la
superficie, nunca inventarla — costó 3 rondas en el pelo).

| Rama | Código | Geometría | Penetración en X | Piezas |
|---|---|---|---|---|
| **Humano/Mistbound** | `character_rig.gd:2996-3005` | `SphereMesh(0.030, 0.060)` en `x=±0.150`, **sin scale, sin rotación** | borde interno 0.120 vs cráneo 0.123 → **~0.003 (≈5% del ancho)** | 1 (esfera desnuda) |
| **Enano (ironblooded)** | `character_rig.gd:3012-3021` | `SphereMesh(0.032, 0.064)` en `x=±0.148`, idem | 0.116 vs 0.123 → **~0.007 (≈11%)** | 1 (esfera desnuda) |
| **Fallback neutro ✅** | `character_rig.gd:3103-3146` | esfera `scale(0.40, 1.28, 0.75)`, `rot.x=-0.15`, `rot.z=±-0.06`, en `(±0.124, -0.010, -0.034)` | 0.112 vs 0.123 → **~0.011 (≈46% del ancho)** | **3** (pabellón + lóbulo + hélix toro) |
| **Elfo (aetherborn)** | `character_rig.gd:2904-2989` | 4 masas (cuerpo cónico + base + punta + hélix), base en `(±0.1645, 0.040, 0.004)` | no tiene costura dura, pero la base sale **derecha del cráneo** | 4 (sin pabellón/concha) |

**La causa raíz es una sola y es de solape, no de forma:** el fallback
neutro ya resuelve esto correctamente (achata la esfera en X y la hunde
casi la mitad de su ancho → sin costura), y humano/enano no lo usan —
tienen su propia versión simplificada al hueso, tangente al cráneo.
Esto coincide con la lección ya documentada: **fusión por overlap REAL,
no por tangencia** ([[Lecciones]], y [[QA Loop]] fase 2).

Diferencias por raza que sí deben sobrevivir (no homogeneizar):
- **Enano:** oreja más grande y compacta, cráneo más pesado.
- **Elfo:** el cono ya validado al 75% **no se toca en ángulo, largo ni
  punta** — solo se le suma pabellón/concha en la base.

## Alcance

### En alcance
1. **Humano/Mistbound + Enano:** portar el patrón de 3 piezas del
   fallback neutro (pabellón achatado y hundido + lóbulo colgando +
   hélix hundida), reparametrizado por raza — no un copy-paste literal.
2. **Elfo:** añadir pabellón/concha en la base del cono, sin alterar el
   eje (elev 28° / yaw 20°), el largo (≈0.167) ni la punta ya aprobados.
3. **Factorizar** el patrón en un helper reutilizable (candidato:
   `_build_ear_root(side, params)`), de modo que las 4 ramas dejen de
   duplicar geometría de oreja a mano.

### Fuera de alcance (anti-objetivos)
- **No** rediseñar la oreja de elfo: cerró con VoBo de Boris al 75%.
- **No** tocar pelo, mandíbula, ceja ni ningún otro rasgo facial.
- **No** reabrir el frente de proporciones ni ROM por raza (siguen en
  [[PRD-C6b-Enano-Elfo-v1]], pendientes de VoBo).
- **No** buscar realismo anatómico: el norte sigue siendo estilizado
  BotW/Palia, masas de silueta, nunca detalle fino.

## Plan de ejecución

Sigue [[Feature Loop]] para el código y [[QA Loop]] para la medición.

0. **Baseline visual:** correr el banco con `ANATOMY_ORIGIN=` humano /
   `ironblooded` / `aetherborn` + `ANATOMY_HAIR=8` (pelo fuera, si no
   tapa la zona) y guardar el set en `godot/test_out/` — perfil y 3/4
   son las vistas que exponen la costura.
1. **Helper + rama humana** (la más simple, valida el patrón).
2. **Rama enana** (reparametrizada: más volumen, cráneo distinto).
3. **Elfo:** pabellón en la base, verificando por píxel que el eje y la
   punta no se movieron respecto de la captura de la ronda 10.
4. **Gates:** `test_core.gd` ALL_PASS en cada paso, sin excepción.
5. **QA imparcial** ([[QA Loop]]): subagente sin contexto previo mide
   contra las láminas `90-Raw/concept/fenotipo-humano-rostro-v1.png`,
   `fenotipo-enano-varon-v1.png` y `fenotipo-elfo-porcelana-v1.png`, con
   % de fidelidad **solo del nacimiento de oreja** y hallazgos
   CRITICAL→LOW. Repetir 2→5 hasta objetivo o techo de la técnica.

**Riesgo conocido a vigilar:** hundir el pabellón puede hacer que el
Sobel deje de entintar el perímetro de la oreja (el borde queda dentro
del rango de profundidad del cráneo) — ya pasó antes y está en
[[Lecciones]]. Verificar con zoom, no a ojo desde la vista completa.

## Definición de terminado

- Las 3 razas muestran unión sin costura circular visible en perfil y
  3/4, a zoom.
- Lóbulo y hélix legibles en humano y enano; pabellón legible en elfo.
- Elfo verificado sin regresión contra la captura de la ronda 10.
- `test_core.gd` ALL_PASS.
- QA imparcial mide ≥ el umbral que fije Boris (sugerido: 70%, mismo
  orden que el 75% con que cerró la oreja de elfo).
- VoBo explícito de Boris — el % informa la decisión, no la reemplaza.
