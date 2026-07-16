---
status: propuesto
source: "Compilado 2026-07-16 por el orquestador a pedido de Boris: cruce de [[Current-State]] (hallazgos #0/#0.5/#0.6 + orden de impacto de la ronda 55%), [[Principios de Anatomía 3D]] (minado del libro), [[Catálogo Técnico Godot]] (verificación de campo de recursos sin ejecutar), [[Propuesta-Recursos-de-Modelado]] (ratificada 2026-07-12) y [[Lecciones]]. Anclas de código verificadas por grep directo el mismo día."
updated: 2026-07-16
---

# PRD — Rework de Modelado de Personajes v2 (instrucciones para el ejecutor)

> **Ejecutor previsto: Sonnet** (tiering de [[Lecciones]]). **Orquestador
> supervisa checkpoint por fase.** Este PRD traduce el conocimiento nuevo
> (anatomía 3D + catálogo técnico + hallazgos del pipeline) en fases
> ejecutables con archivo/línea/valor. Baseline: **55% de fidelidad**
> (QA imparcial, ronda 2026-07-14). Objetivo: superar el techo de ~50-55%
> que el ajuste de parámetros ya demostró no poder cruzar.

## Reglas de sesión (NO opcionales — el ejecutor las lee ANTES de tocar código)

1. **Leer [[Lecciones]] completo primero.** En particular: nunca
   `class_name` cruzado (usar `const _X = preload(...)`); esfera nunca da
   plano/borde (caja); escalón de profundidad = caras frontales en Z
   distinto (calcular `pos_z + radio`, no confiar en números "distintos");
   overlap real para fundir masas (semi-hundir, protrusión ≤30%); margen
   ≥8 mm fuera de superficie para pintura/marcas; matar procesos Godot
   huérfanos + apps de fondo (Epic/EA/Steam) antes de cada corrida.
2. **Gates de regresión tras CADA fase:** `test_core` + `autotest_biomech`
   + `test_combat` + `autotest_slice` + `autotest_ui` ALL_PASS, más
   captura fresca del banco (`tmp_anatomy.gd` → `test_out/anatomy_*.png`).
   Nada se reporta terminado sin gate verde + captura.
3. **QA visual imparcial al cierre de cada fase geométrica** (protocolo
   del [[QA Loop]]: subagente sin contexto de código, renders frescos vs
   `fenotipo-humano-v1.png` + `fenotipo-humano-torso-v1.png`) — el % se
   registra en [[LOG]]. No iterar más de 2 rondas por fase sin reportar
   al orquestador.
4. **La lámina es la autoridad de proporción; el libro es la autoridad de
   ESTRUCTURA.** Ante conflicto review-vs-lámina, auditar contra la lámina
   ([[Lecciones]], precedente SHOULDER_X +30%). El libro ([[Principios de
   Anatomía 3D]]) dice CÓMO construir, no CUÁNTO mide — las medidas salen
   de medir la lámina en píxeles.
5. **No tocar:** los `pec` (historial de debate orquestador↔QA, decisión
   de Boris pendiente); la barba (fuera del default, nota abierta); la UI
   de creación (Fase 4); la biomecánica/ROM del rig (`rig_biomech.gd`) —
   este PRD es geometría/superficie, no movimiento.

---

## FASE 0 — Pipeline de tinta en el banco de anatomía (BLOQUEANTE de todo lo demás)

**Por qué primero:** el QA visual (2026-07-16) detectó que los renders
`anatomy_*.png` NO muestran línea de tinta/acuarela mientras el entorno
del juego sí — si el banco no aplica el tratamiento completo, **todos los
% de fidelidad medidos hasta ahora (32→55%) están parcialmente
contaminados** y las fases siguientes se medirían mal.

**0.1 — Diagnóstico (solo lectura primero):**
- Comparar cómo `tmp_anatomy.gd` arma su escena/post vs. cómo lo hace
  `golden_scene.gd:657-669` (`attach_post`, quad manual con
  `extra_cull_margin` + `position.z=-1`).
- Verificar si el banco llama `attach_post` o equivalente; si los
  materiales del rig en el banco son los `toon_opaque` correctos (sin
  escritura de ALPHA — [[Lecciones]]); y si `ink_fade_dist`
  (`melancolia_post.gdshader:20`) apaga la tinta a la distancia de cámara
  de las capturas del banco.
- Verificar la divergencia conocida: `golden_scene.gd:97-99,115` hardcodea
  `ambient_lift=0.16`/`rim_strength=0.10` vs `pipeline_config.gd:11,15`
  (`0.14`/`0.18`) — unificar vía `PipelineConfig.apply_to()`.

**0.2 — Fix:** lo que salga del diagnóstico. Criterio de aceptación:
captura del banco donde el personaje muestre línea de tinta Sobel en
close-up (fina), agrisada a media distancia — lado a lado con una captura
del entorno para confirmar tratamiento IDÉNTICO.

**0.3 — Quick win de shading (cambio de una línea, A/B):**
`godot/rendering/toon_ramp.tres` tiene `interpolation_mode = 1`
(CONSTANT, 4 escalones duros en offsets 0/0.2/0.5/0.78). Probar `LINEAR`
(o un punto intermedio agregando paradas de gradiente cortas en cada
borde) y capturar A/B del personaje en close-up. **Decisión de Boris con
las capturas** — no comprometer sin su VoBo (toca el look global).

**0.4 — Re-baseline:** con la tinta funcionando en el banco, correr UN QA
visual imparcial ANTES de tocar geometría — ese número es el baseline real
de las fases siguientes (el 55% previo puede subir o bajar solo).

**0.5 — Aclarar el segundo hallazgo del QA:** confirmar si el rig de
cápsulas sin cara en `wilds_start/combat/city` es el rig real de gameplay
o un placeholder — si el juego real usa otro rig, anotar en
[[Current-State]] como frente aparte (integración del rig nuevo), NO
resolverlo en este PRD.

---

## FASE 1 — Torso/hombros: bloqueo de 3 masas + cintura escapular (prioridad #1, AUTORIZADA por Boris)

**Estado actual del código:** `character_rig.gd:39-40` (`SHOULDER_X 0.21`,
`SHOULDER_Y 0.26`), `:56-58` (`CHEST_X 1.16`, `WAIST_XZ 0.90`), `:446-449`
(clavícula = cápsula RECTA rotada), `:485-488` (waist = cilindro que copia
el x/z del torso — un solo taper continuo), `:525-527` (el brazo se monta
directo en `±SHOULDER_X` — no existe bloque escapular).

**1.1 — Medir la lámina en píxeles PRIMERO** (mandato explícito de Boris,
mismo método de la vez que se detectó el error del +30%): biacromial, ancho
de caja torácica, ancho de cintura, ancho de pelvis, alto de trapecio — en
"cabezas" sobre `fenotipo-humano-v1.png` y `fenotipo-humano-torso-v1.png`.
Registrar los números ANTES de tocar nada. Si la medición contradice la
hipótesis del libro, la lámina gana (regla 4).

**1.2 — Bloqueo de 3 masas** (hipótesis del libro, [[Principios de
Anatomía 3D]] §torso): reestructurar el torso desnudo de "cilindro cónico
continuo + waist que lo copia" a tres volúmenes legibles:
- **Caja torácica** (~2/3 del alto del torso): cilindro redondeado/huevo —
  NUNCA plana, siempre curvando alrededor del tronco. Puede reusar el
  `torso` actual acortado.
- **Cintura** (volumen intermedio): más angosta que caja torácica Y que
  pelvis, deformable — el `waist` actual (`:485`) deja de copiar
  exactamente el x/z del torso (`:1289-1293`) y toma su propio radio
  menor. **OJO masculino:** NO reloj de arena — el contraste es
  hombros-anchos vs cadera-más-angosta, no cintura femenina estrecha.
- **Pelvis** (~1/3 inferior): masa tipo caja (redondeada), ligeramente
  inclinada hacia atrás, más ancha que la cintura.
Técnica de unión: overlap real (semi-hundido) entre las 3 — el Sobel
entinta solo el contorno exterior ([[Lecciones]], patrón jaw/cheek).

**1.3 — Cintura escapular como bloque propio:** hoy el brazo nace directo
en `±SHOULDER_X` sobre `upper_spine`. Construir una masa
clavícula+acromion+trapecio SEPARADA que se monte sobre la caja torácica y
de la cual nazca el hombro:
- **Clavícula en "S"** — la actual (`:446-448`) es una cápsula recta con
  rotación fija; reconstruir con 2 segmentos (o curva) para el quiebre en
  S. Error #1 de principiante según el libro; hoy lo tenemos.
- **Trapecio con volumen real:** masa triangular base-cráneo→hombros que
  fluye del cuello y se ENSANCHA hacia la clavícula (hoy el QA lo reporta
  ausente: "sin trapecio real"). Elipsoide semi-hundida entre cuello y
  deltoide, aplastada en Z.
- **Acromion como plano** (caja chica, no esfera) en el tope del hombro.
- **Deltoides que "emerge de abajo" del trapecio** — el borde del deltoide
  nace escondido bajo el trapecio (overlap), no pegado junto a él.
**`SHOULDER_X` solo se mueve si la medición de 1.1 lo pide** — el libro
sugiere que el problema es de MASAS FALTANTES, no de ancho; es plausible
que 0.21 quede intacto y la silueta se arregle con trapecio+escápula.

**1.4 — Costura cuello-hombro** (punto 3 de la ronda 55%, se resuelve aquí
de paso): el parche visible en la unión torso/cabeza/collar
probablemente desaparece al construir el trapecio (esa masa ES la
transición cuello-hombro). Verificar en captura trasera y 3/4.

**Cierre de fase:** gates + QA imparcial + reporte al orquestador con
capturas frente/perfil/3-4/espalda. **VoBo de Boris antes de pasar a
Fase 2.**

---

## FASE 2 — Manos: convergencia + nudillos reales (prioridad #2)

**Estado actual del código:** `character_rig.gd:681-702` — dedos con
`finger_root` a curl fijo `-0.16` y `knuckle_joint` a `-0.36`, TODOS
IGUALES; los dedos nacen en línea recta sobre la palma (misma `y=-0.027`)
y son paralelos entre sí.

**2.1 — Curva de convergencia** ([[Principios de Anatomía 3D]] §manos):
los 4 dedos curvan levemente hacia el dedo medio — agregar una rotación Z
por dedo proporcional a su distancia del medio (índice y anular ±chico,
meñique ±mayor; el medio 0). "Dedos perfectamente rectos = mano de
plástico" (causa raíz #1 del síntoma "tabla").

**2.2 — Inserción en arco, no en línea:** las bases de los dedos sobre la
palma siguen un arco (el medio nace más arriba, meñique más abajo) — hoy
todas comparten `y=-0.027`. Ajustar `finger_root.position` por dedo.

**2.3 — Nudillos como protuberancias puntuales:** el nudillo es la cabeza
del metacarpiano ASOMANDO — no un pliegue del cilindro. Agregar una masa
chica (cápsula/esfera achatada) por dedo en la base (metacarpo-falángico),
semi-hundida en el dorso; el patrón del dorso es
protuberancia→canal→protuberancia. Asimetría deliberada: el nudillo del
índice ligeramente más prominente. Verificar Z real de cada masa
([[Lecciones]] del escalón).

**2.4 — Variación de curl por dedo:** romper el `-0.16`/`-0.36` uniforme —
cada dedo con curl levemente distinto (reposo natural: los dedos caen en
curva suave y se juntan, nunca rectos y separados).

**2.5 — Proporción (verificación, no rework):** validar contra el sistema
de mitades sucesivas (nudillo 1 = mitad del dedo; nudillo 2 = mitad de la
mitad; medio ≈ largo de palma; índice≈anular < medio; meñique llega al
último nudillo del anular). Los largos actuales ya se ajustaron en r5c-r5e
— solo corregir si difieren grueso.

**Cierre de fase:** gates + captura `anatomy_hands.png` en close-up
(el Sobel debe entintar nudillos y separaciones) + QA imparcial.

---

## FASE 3 — Pelo: loft + orden de trabajo invertido (prioridad #3)

**Contexto crítico:** van 3 intentos fallidos con cajas/conos. El loft
(`Curve3D` + `SurfaceTool`) está RATIFICADO desde 2026-07-12
([[Propuesta-Recursos-de-Modelado]] recurso 2, piloto natural = pelo) y
NUNCA se ejecutó (verificado por grep 2026-07-16). **Prohibido un 4º
intento con la misma técnica.**

**3.1 — Implementar el helper de loft** (nuevo, en `hair_library.gd` o
helper compartido): función que recibe una `Curve3D` (espina del mechón) +
perfil de radios por punto → genera malla continua con `SurfaceTool`.
Referencia de API: `RibbonTrailMesh`/`TubeTrailMesh` nativos (muestreo de
curva, [[Catálogo Técnico Godot]] Tier 2) — pero malla propia estática,
no trail. Material `toon_opaque` (nunca ALPHA).

**3.2 — Orden de trabajo del libro (invertido al de los 3 intentos):**
1. PRIMERO la masa/silueta completa del peinado (frontier crop: lados
   recortados, nuca expuesta, volumen barrido arriba-atrás) como una sola
   concha — la base ya existe en `_hair_frontier_crop`
   (`hair_library.gd:319`), conservar lo que ya funciona (nuca/orejas
   expuestas, confirmado por QA).
2. DESPUÉS subdividir el frente/coronilla en mechones de loft individuales
   sobre esa masa.
3. AL FINAL 2-3 mechones "rebeldes" que rompen el patrón.

**3.3 — Regla anti-paralelismo (causa probable de los "2-3 lóbulos"):**
variación deliberada de largo/grosor/ángulo entre mechones VECINOS — nunca
el mismo prefab repetido. **Adaptación al Sobel (NO copiar el libro
ciego, [[Principios de Anatomía 3D]] §pelo):** el libro pide "transiciones
suaves" para escultura sombreada, pero nuestra separación la dibuja la
TINTA — cada mechón necesita un escalón de profundidad REAL contra su
vecino (caras a Z/radio distinto) para que el Sobel lo entinte como trazo
propio. Mechones parejos y al ras = el Sobel también los agrupa en un
lóbulo.

**3.4 — Guardas anti-regresión:** vigilar el defecto histórico de
"dientes en la silueta frontal" (2 intentos previos lo reabrieron) y el
contrato de ejes de `_ribbon`/`_s_spine` ([[Lecciones]]: espina con Y
acorde al flow root→tip).

**Cierre de fase:** gates + turnaround (frente/perfil/3-4/espalda) + QA
imparcial. Si tras 2 rondas el loft no supera a la concha actual,
DETENERSE y reportar — no iterar a ciegas.

---

## FASE 4 — Menores (cierran la lista de la ronda 55%)

**4.1 — Boca, color/material** (geometría ya resuelta): el tono
rojo-marrón oscuro lee "herida". Ajustar `lip_mat`/`lip_mat_lower` hacia
rosa-tierra desaturado (dirección: más cerca del tono piel, menos
saturación — coherente con la paleta lavada del [[Art Bible]]). A/B de
2-3 candidatos en captura para Boris — es su llamada estética.

**4.2 — Warpaint, 3 estilos rotos** (`warpaint_atlas.gd _draw_pattern()`):
rework de Slash Crimson (roto), Tribal Tide (invisible — probablemente
trazo demasiado fino o fuera del área visible del atlas; revisar contra la
costura u=0 de [[Lecciones]]) y Jagged Crown (débil). Objetivo: 6 estilos
+ None utilizables. Validación visual con `warpaint_N_*.png` por estilo.
No bloqueante — puede diferirse si la ventana se alarga.

---

## Orden, dependencias y presupuesto de iteración

```
FASE 0 (pipeline/tinta)  ← bloqueante de TODA medición
  └→ re-baseline QA
FASE 1 (torso/hombros)   ← mayor apalancamiento; VoBo de Boris al cierre
  └→ FASE 2 (manos)      ← independiente de F1 en código, pero después
       └→ FASE 3 (pelo)  ← requiere helper de loft nuevo
            └→ FASE 4 (boca/warpaint) ← menores, paralelizables
```

- Máx. 2 rondas de QA por fase sin reporte al orquestador.
- Checkpoint de Vault tras CADA fase ([[SCHEMA]] §6-7): [[Current-State]]
  (solo lo vigente), [[LOG]] (entrada por fase), [[Lecciones]] si se pagó
  una, commit descriptivo.
- Si una fase revela que la técnica no alcanza (como pasó con el ajuste de
  parámetros en 32→55%), se documenta el techo y se PARA — no se quema
  presupuesto en la 3ª variante de lo mismo.

## Criterio de éxito del PRD

- Fase 0: personaje con tinta idéntica al entorno en el banco +
  re-baseline medido.
- Fases 1-3: cada una debe SUBIR el % del QA imparcial vs. el re-baseline
  (no vs. el 55% viejo). El objetivo aspiracional de la ventana completa
  es cruzar el techo de ~55% que el tuning de parámetros no pudo — el
  número concreto lo fija Boris al ver el re-baseline de Fase 0.
- Regresión cero: todos los gates ALL_PASS en cada checkpoint.

## Pendiente de ratificación

**Este PRD está `propuesto` — requiere VoBo de Boris antes de ejecutar:**
(a) el orden de fases (0→1→2→3→4), (b) la decisión de Fase 0.3 (banding
LINEAR es cambio de look global), (c) el criterio de "medición primero,
SHOULDER_X solo si la lámina lo pide" de Fase 1.
