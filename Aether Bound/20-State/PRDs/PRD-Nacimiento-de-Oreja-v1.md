---
status: en curso (paso 1 humano CERRADO con VoBo al 74%, pasos 2-3 pendientes)
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

> **Corrección (2026-07-22, durante la ejecución del paso 1).** La primera
> versión de esta tabla usaba el semieje **ecuatorial** (0.123) para todas
> las filas. Mal: la oreja está desplazada en Y y Z, donde el cráneo mide
> **0.1179**, no 0.123. Las cifras de abajo ya están corregidas — la del
> fallback bajó de un supuesto 46% al **25% real**. La lección general:
> el semieje de un elipsoide **no es su radio en el punto que te importa**.

| Rama | Código | Geometría | Penetración en X | Piezas |
|---|---|---|---|---|
| **Humano/Mistbound** | `character_rig.gd:2996-3005` | `SphereMesh(0.030, 0.060)` en `x=±0.150`, **sin scale, sin rotación** | 0.120 vs 0.1226 → **~0.0026 (4.3% del ancho)** | 1 (esfera desnuda) |
| **Enano (ironblooded)** | `character_rig.gd:3012-3021` | `SphereMesh(0.032, 0.064)` en `x=±0.148`, idem | ~11% | 1 (esfera desnuda) |
| **Fallback neutro** | `character_rig.gd:3103-3146` | esfera `scale(0.40, 1.28, 0.75)`, `rot.x=-0.15`, `rot.z=±-0.06`, en `(±0.124, -0.010, -0.034)` | 0.112 vs 0.1179 → **~0.0059 (25% del ancho)** | **3** (pabellón + lóbulo + hélix toro) |
| **Elfo (aetherborn)** | `character_rig.gd:2904-2989` | 4 masas (cuerpo cónico + base + punta + hélix), base en `(±0.1645, 0.040, 0.004)` | no tiene costura dura, pero la base sale **derecha del cráneo** | 4 (sin pabellón/concha) |

**La causa raíz es una sola y es de solape, no de forma:** humano y enano
están prácticamente TANGENTES al cráneo, y el patrón de 3 piezas que sí
funde por overlap real vive únicamente en la rama de fallback, que las
razas reales no usan.

> **Segunda corrección, medida por el QA en la ronda 1 de ejecución: el
> fallback neutro NO era "la referencia buena".** Este PRD asumía que su
> geometría estaba validada y bastaba con portarla. Portada 1:1 al humano,
> el QA imparcial midió **55%** (objetivo 70%) con dos CRITICAL. Motivo: se
> afinó contra la cara de M9/Fase-C, que desde entonces cambió — sus
> números ya no rinden sobre el cráneo actual. Dos defectos suyos resultaron
> ser **heredados y nunca detectados**: de frente la oreja no se entintaba
> ni sobresalía (`scale.x=0.40` no llegaba al umbral del Sobel), y el hélix
> estaba **enterrado** bajo la superficie del pabellón, leyendo como brillo
> en vez de como reborde. **Corolario para los pasos 2 y 3: la rama neutra
> es un punto de partida, no un canon.** Los valores buenos son los que
> salieron de las 4 rondas de QA sobre el humano, no los suyos.
Esto coincide con la lección ya documentada: **fusión por overlap REAL,
no por tangencia** ([[Lecciones]], y [[QA Loop]] fase 2).

Diferencias por raza que sí deben sobrevivir (no homogeneizar):
- **Enano:** oreja más grande y compacta, cráneo más pesado.
- **Elfo:** el cono ya validado al 75% **no se toca en ángulo, largo ni
  punta** — solo se le suma pabellón/concha en la base.

## Alcance

### En alcance
1. ✅ **Humano/Mistbound** (paso 1, EJECUTADO 2026-07-22) — ver "Estado de
   ejecución" abajo.
2. **Enano:** mismo patrón de 3 piezas, reparametrizado (más volumen,
   cráneo distinto) — **partiendo de los valores del humano ya medidos**,
   no de los de la rama neutra.
3. **Elfo:** añadir pabellón/concha en la base del cono, sin alterar el
   eje (elev 28° / yaw 20°), el largo (≈0.167) ni la punta ya aprobados.
4. **Factorizar** el patrón en un helper reutilizable (candidato:
   `_build_ear_root(side, parent, mat, params)`) — **movido del paso 1 al
   paso 2** (decisión de ejecución, 2026-07-22): en el paso 1 habría
   tenido un solo call site real, y su firma no era deducible todavía
   porque el elfo no es consumidor del mismo patrón (sus masas cuelgan de
   `ear_body`, con una `Basis` propia, no de `feature_slot`). Con el enano
   ya existen dos casos reales y los ejes de variación se conocen.

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

## Estado de ejecución

### Paso 1 — Humano/Mistbound ✅ CERRADO (2026-07-22, VoBo de Boris)

**Fidelidad: 74%** (umbral 70%). Trayectoria QA imparcial: 55%→69%→71%→74%.

Código: `character_rig.gd`, rama `elif id == "miststalker"`. Se reemplazó la
esfera desnuda (1 pieza, 4.3% de penetración) por 3 piezas hermanas en
`feature_slot`: pabellón achatado (`scale 0.58/1.45/0.75`, penetración ~17%),
lóbulo colgante, hélix en toro (`scale.y=1.45`, lectura de C abierta). 4 rondas
de tuning dirigidas por QA imparcial (mismo agente, re-invocado 3 veces).

**Hallazgos cerrados:** costura circular eliminada (82/100), estructura interna
legible (70/100), cuña de tinta superior resuelta, hélix como C (colateral del
`scale.y`).

**Hallazgo abierto — techo de la técnica:** arco antero-superior sin tinta del
Sobel (68/100). Resistió 3 rondas de tuning en Z (0.034→0.030→0.024). La única
palanca restante (`rotation.x`) pagaría con la altura de implantación ya
validada. El QA lo declaró agotado.

**Concha / hueco interno:** imposible con 3 primitivas convexas aditivas —
requiere cambio de enfoque (primitiva oscura embebida, vertex-color, o custom
mesh). Decisión separada del tuning de parámetros.

**Corolarios para los pasos 2 y 3:** los valores de partida son los del humano
ya medido, NO los del fallback neutro (que midió 55% portado 1:1).
