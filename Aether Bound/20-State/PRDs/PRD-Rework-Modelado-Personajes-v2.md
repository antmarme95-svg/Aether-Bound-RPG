---
status: propuesto
source: "Compilado 2026-07-16 por el orquestador a pedido de Boris: cruce de [[Current-State]] (hallazgos #0/#0.5/#0.6 + orden de impacto de la ronda 55%), [[Principios de Anatomía 3D]] (minado del libro), [[Catálogo Técnico Godot]] (verificación de campo de recursos sin ejecutar), [[Propuesta-Recursos-de-Modelado]] (ratificada 2026-07-12) y [[Lecciones]]. Anclas de código verificadas por grep directo el mismo día."
updated: 2026-07-16
---

> **NOTA DE ESTADO (2026-07-17):** la **Fase 1 (torso/hombros)** y la
> **Fase 2 (manos)** quedan **SUPERSEDED** por
> [[PRD-Reescritura-Escultura-Rig-v1]] (fases **R2** y **R3**
> respectivamente) — dos QA imparciales consecutivos (rostro 35%,
> torso ~40%) confirmaron el techo del ajuste de parámetros y se aprobó
> la reescritura por masas de la escultura. Las **Fases 3 (pelo/loft)**
> y **4 (boca/warpaint)** siguen vigentes AQUÍ y se retoman después de
> la reescritura. El contenido de abajo se conserva íntegro como
> registro.

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

## FASE 0 — Pipeline de tinta en el banco de anatomía — ✅ EJECUTADA Y CERRADA (2026-07-16)

**Por qué primero (premisa original):** el QA visual (2026-07-16) detectó
que los renders `anatomy_*.png` NO muestran línea de tinta/acuarela
mientras el entorno del juego sí — si el banco no aplica el tratamiento
completo, todos los % de fidelidad medidos hasta ahora (32→55%) estarían
parcialmente contaminados.

**Resultado del diagnóstico 0.1 (solo lectura + verificación de píxel):**
**la premisa NO se sostuvo.** `_gs.attach_post(_cam)` SÍ se llama en
`tmp_anatomy.gd:115`; el material del rig SÍ es `toon_opaque` vía
`ToonMaterials.toon_mat_opaque()` → `PipelineConfig.apply_to()`
(`character_rig.gd:255`, `toon_materials.gd:50-56`) — correcto, no hay
desconexión. `ink_fade_dist=70` (`melancolia_post.gdshader:20`) da fade≈1
a las distancias de estas capturas (2-8m) — no apaga nada de cerca.
Inspección directa con zoom ×4 de `anatomy_close.png`/`anatomy_face.png`/
`anatomy_full_front.png` confirmó que la tinta Sobel SÍ entinta al
personaje (silueta, cejas, nariz, boca, mandíbula, pectorales) y que el
banding SÍ existe (fuerte en `anatomy_full_side.png`/`anatomy_face_back.png`).
**Causa real encontrada:** las capturas "de frente" ponían la cámara
EXACTAMENTE alineada con el eje del sol de "dawn" (`sun_azim_deg=190` ≈
eje +Z del personaje) → superficie uniformemente iluminada sin contraste
que mostrar (mismo shader que el perfil, que sí banding bien). La
divergencia `golden_scene.gd:98-99` (`ambient_lift=0.16`/`rim_strength=0.10`
hardcodeados para materiales propios de la escena) vs
`pipeline_config.gd:11,15` (`0.14`/`0.18`) es real pero cosmética/menor —
no afecta al personaje, que usa `PipelineConfig` correctamente.

**0.2 — Fix aplicado:** `tmp_anatomy.gd` — nuevo helper `_key_offset()`
que rota 15° alrededor de Y el offset de cámara en `_frame_close()`, el
shot frontal del turnaround de cabeza, y `_frame_full_front()` (misma
distancia, mismo zoom, solo rota el ángulo) — rompe la alineación
cámara-luz sin dejar de leer como vista de frente. Verificado: capturas
regeneradas muestran volumen/sombreado real (comparable al entorno) + los
5 gates de la regla de sesión (`test_core`, `autotest_biomech`,
`test_combat`, `autotest_slice`, `autotest_ui`) ALL_PASS.

**Conclusión:** el % de fidelidad medido hasta ahora (32→55%) **NO estaba
contaminado** por falta de tratamiento visual — esa hipótesis no se
sostuvo contra el píxel real. Fase 1 puede arrancar directo sin
re-baseline obligatorio.

**0.3 — Quick win de shading (A/B banding LINEAR) — QUEDA OPCIONAL, no
bloqueante.** `godot/rendering/toon_ramp.tres` tiene
`interpolation_mode = 1` (CONSTANT, 4 escalones duros). Si Boris quiere
probar `LINEAR` en A/B, sigue disponible como tarea aparte — no
condiciona el arranque de Fase 1.

**0.4 — Re-baseline: OPCIONAL.** Dado que la Fase 0 no encontró
contaminación real, un QA imparcial nuevo puede correr en paralelo a Fase
1 si Boris lo quiere, pero no es prerrequisito.

**0.5 — Aclarar el segundo hallazgo del QA: PENDIENTE, sin investigar.**
Confirmar si el rig de cápsulas sin cara en `wilds_start/combat/city` es
el rig real de gameplay o un placeholder — si el juego real usa otro rig,
anotar en [[Current-State]] como frente aparte (integración del rig
nuevo), NO resolverlo en este PRD.

---

## FASE 1 — Torso/hombros: bloqueo de 3 masas + cintura escapular — 🔄 EN CURSO (2026-07-16, primera pasada ejecutada)

**Progreso 1.1-1.3 ejecutado (2026-07-16):**
- **1.1 medido:** biacromial en `fenotipo-humano-torso-v1.png` (medición
  propia por muestreo de píxeles + cuadrícula de cabezas superpuesta,
  regla "7.5 heads tall" del lado izquierdo = 92.67px/cabeza) da **~2.05-
  2.08 cabezas** — coincide exacto con lo que el render ACTUAL ya produce
  (`hombros_w = 0.556 m, 2.08 cabezas`, verificado en banco). **Conclusión:
  SHOULDER_X=0.21 NO se toca** — la lámina no pide más ancho, confirma la
  hipótesis del libro de que el problema es de masas faltantes (trapecio),
  no de ancho de hombro. Vista de espalda de la misma lámina confirma un
  trapecio VISIBLE y real (fluye del cuello a cada hombro con definición
  muscular) — respalda directamente 1.3.
- **1.2 (parcial) — cintura deja de copiar el torso:** `waist` (`:485`,
  ahora en línea ajustada) baja su `top_radius` de 0.11 (idéntico al fondo
  del torso) a 0.095 — primer "pellizco" real entre caja torácica y
  cintura (antes leían como un solo cono continuo, confirmado en capturas
  frescas de perfil/frente). El factor elíptico sigue copiándose de
  `torso.scale` en `_apply_build` para que la proporción se mantenga en
  cualquier build. **Pendiente de esta fase:** la pelvis YA es una caja
  (`_box_mesh`, `:302`) — el libro asumía que no existía como masa propia,
  pero SÍ existe; no hace falta crearla, solo verificar que la transición
  cintura→pelvis lea bien (no evaluado a fondo todavía).
- **1.3 (parcial) — trapecio agrandado + clavícula partida en 2:** el
  trapecio YA EXISTÍA en código (esfera semi-hundida, `:502-508`, desde
  2026-07-13) — la premisa de este PRD de que "no existe" estaba
  desactualizada. El problema real (confirmado en captura de perfil
  ANTES del fix: cero bulto visible, curva lisa cuello→hombro) era que su
  escala Y (0.6) lo hacía demasiado chico/corto para leer como masa
  propia — subida a 1.5 (radio efectivo 0.06→0.15). Captura fresca DESPUÉS
  del fix confirma un bulto con contorno propio en perfil, donde antes no
  había nada. Clavícula (`:442-450`) partida en 2 cápsulas cortas con
  quiebre de Z (medial proa/lateral recesada) sugiriendo la curva en S del
  libro — visualmente sutil en las capturas actuales, no tan dramático
  como el fix de trapecio/cintura, candidato a revisar en el QA de cierre.
  Acromion como plano separado y "deltoide emergiendo del trapecio" (resto
  de 1.3) — **NO implementado todavía**, el brazo sigue montado directo en
  `±SHOULDER_X` sin bloque escapular propio como padre.
- **Gates:** `test_core`/`autotest_biomech`/`test_combat`/`autotest_slice`/
  `autotest_ui` ALL_PASS tras los 3 cambios.
- **1.4 (costura cuello-hombro):** no evaluada a fondo todavía — el
  trapecio agrandado probablemente ya ayuda (esa masa ES la transición),
  pendiente de confirmar con QA de cierre.

**Acromion + deltoide-bajo-trapecio ejecutado (2026-07-16, mismo día):**
- **Acromion agregado** (`_box_mesh` chico y chato, por lado, semi-hundido
  entre el borde exterior del trapecio y el tope del deltoide, rotado con
  la misma caída del trapecio) — principio esfera-vs-caja ya confirmado 3
  veces en Fase C (mentón/pómulo/barba).
- **Trapecio corrido** (centro `0.115→0.135`, Y `0.30→0.285`) para que se
  solape DIRECTO sobre el tope del deltoide, no solo comparta vecindad —
  antes quedaba demasiado medial y su borde apenas tocaba el hombro.
- **Verificación honesta contra captura fresca:** en PERFIL, el bulto de
  trapecio sigue leyéndose bien (confirmado con zoom). En FRENTE y 3/4, el
  acromion y el ajuste de overlap NO producen un quiebre claramente
  visible a estos ángulos de cámara — un plano en el "tope" del hombro se
  luce más desde arriba que desde encuadres horizontales; no se ve como
  defecto nuevo (nada roto/flotando), pero tampoco como una mejora
  dramática en estas vistas específicas. No se sobre-ajustó a ciegas más
  allá de este punto — queda para el QA de cierre decidir si hace falta
  otra pasada (ej. probar la caja del acromion más grande, o verificar
  desde un ángulo 3/4-alto) o si el resultado ya alcanza.
- Gates `test_core`/`autotest_biomech`/`test_combat`/`autotest_slice`/
  `autotest_ui` ALL_PASS.

**Corrección post-cierre (2026-07-16, mismo día): trapecio hipertrofiado.**
Boris revisó la captura de espalda del cierre y detectó que el trapecio
(escalado Y=1.5 en el paso anterior) leía como "tres cabezas" — un bulto
redondo del mismo porte que la cabeza, no una pendiente muscular. Error de
proceso admitido: se había escalado para "que se viera algo" tras
confirmar que la versión original (Y=0.6) era invisible, sin medir contra
la lámina (viola la regla 4: "la lámina es la autoridad de proporción").
Comparación directa contra `fenotipo-humano-torso-v1.png` (vista de
espalda): ahí el trapecio es una pendiente suave leída por sombreado, no
un bulto separado. Se generaron 3 variantes en paralelo — **A**
(1.2/0.85/0.6), **B** (1.0/0.7/0.55), **C** (1.5/0.55/0.6, más ancha —
resultó tan prominente como A pese a ser más corta en Y) — con captura de
espalda lado a lado. **Boris eligió B**, la que menos lee como bulto
separado (sigue habiendo un quiebre chico, aceptado: el estilo tinta+Sobel
necesita algo de quiebre real para entintar cualquier masa, confirmado en
Fase 0). Valor final en código: `trap.scale = Vector3(1.0, 0.7, 0.55)`.
Gates re-verificados ALL_PASS.

**QA imparcial CORRIDO (2026-07-16, mismo día — subagente Fable, protocolo
[[QA Loop]]): ~40% de fidelidad torso/hombros.**

Positivo confirmado por el QA: la hipertrofia del trapecio quedó
genuinamente resuelta (sin "tercera cabeza"); la proporción global
(~7.5 cabezas, figura esbelta) aguanta a distancia; el pipeline de
tinta/sombreado es fiel al estilo — el problema es de fusión anatómica,
no de shader.

**Hallazgos CRITICAL — investigados:**
1. Torso lee como "peto/cartón" (contorno de tinta interior completo).
2. "Costura cuello-hombro sin soldar" — bloque rectangular tipo cuello de
   camisa en la base del cuello (vista 3/4).

Investigación de campo (marcado de color pieza por pieza, una a la vez,
en `anatomy_face_34.png`): torso, cuello, trapecio, clavícula (×2),
acromion, pauldron, pec y deltoide — **los 8 descartados uno por uno**
(cambiar color/ocultar cada uno no afectó el defecto). **El objeto real
es `chin_boss`** (el mentón, `character_rig.gd` cerca de la nariz) —  en
el ángulo 3/4 se lee desconectado de la mandíbula, no es una pieza de
hombro/cuello en absoluto. Se probaron 3 variantes de overlap (profundidad
Z 0.055→0.075 + centro; alto Y 0.032→0.06 + centro) — **ninguna cerró la
desconexión visual**, pese a que el cálculo de solape 3D (corte elíptico
de `jaw_mesh` en ese punto) indicaba que debía funcionar. Dado que
`chin_boss` ya tiene 6+ rondas de calibración validadas de FRENTE contra
la lámina (documentadas en el propio código), **se decidió NO seguir
ajustando a ciegas** (Lección: no reabrir una pieza ya validada sin
evidencia clara de qué cambiar) — revertido a sus valores originales
(`_box_mesh(0.058, 0.032, 0.055, skin_mat)`, posición
`Vector3(0.0, -0.134, 0.0975)`). **Queda como hallazgo ABIERTO, sin
resolver, para decisión de Boris** — necesita una investigación dedicada
(quizás un ángulo de cámara distinto en el banco, o revisar si el defecto
es de lectura de silueta/Sobel en vez de overlap puro) antes de intentar
un 4º ajuste.

**CRITICAL 2 ("costura cuello-hombro"/"cuello de camisa de cartón") — CERRADO
(2026-07-17, protocolo [[QA Loop]]).** La investigación de campo de arriba
(2026-07-16) había identificado bien la pieza culpable (`chin_boss`) pero
diagnosticaba mal el hueco: no estaba entre `chin_boss` y `jaw_mesh` (esos
sí se tocan bien de frente, por eso 6+ rondas de calibración frontal nunca
lo vieron), sino entre `chin_boss` y `neck` — un cilindro completamente
aparte, hijo de `upper_spine` en vez de `head`, sin ninguna pieza que
continuara el saliente frontal del mentón hacia la superficie lisa del
cuello. Salto real de profundidad de varios cm, invisible en el render
completo a 1280×720 pero clarísimo en un recorte ampliado 3-4x de la zona
mentón/cuello (lección nueva: **antes de dar un hallazgo geométrico por
cerrado, hacer zoom a la unión exacta, no confiar en el render completo a
tamaño natural** — ver [[Lecciones]]). Fix de 2 partes en
`character_rig.gd` (~línea 1018-1031): `chin_boss` achicado (0.058×0.032×
0.055 → 0.045×0.014×0.030, preservando su punta frontal ya calibrada) +
`chin_bridge` (masa puente, mismo patrón que `jaw_angle`) agrandada y
estirada para llegar hasta la superficie real de `neck`, no solo hasta la
mitad del camino. Gates `test_core`/`autotest_biomech` re-verificados
ALL_PASS. QA imparcial (mismo subagente, protocolo de re-invocación del
[[QA Loop]]) confirmó **CERRADO** en las 4 vistas del turnaround, con
recortes ampliados de verificación — el bloque/hueco ya no aparece ni a
resolución completa ni en zoom 5-6x.

**Hallazgos nuevos, reportados por el mismo QA de cierre (no bloquean este
cierre, quedan para otra ronda):**
- Mentón/mandíbula siguen leyendo "blandos"/redondeados en vez de por
  masas angulares — la geometría ya suelda bien, pero no tiene la
  definición de plano que pide la lámina. Distinto del CRITICAL 1 (torso
  "peto/cartón") pero mismo espíritu — candidato a atacar junto con HIGH/
  MEDIUM de abajo.
- Seam/pliegue visible en la base del cuello donde se junta con el
  trapecio/hombro (vistas 3/4 y perfil) — fuera del scope de hoy (se pidió
  ignorar hombros/torso), pero puede ser el próximo punto de fricción
  visual cuando se ataquen los HIGH de hombros.
- Marca blanca en forma de corchete sobre el cuello, debajo del mentón —
  posible artefacto de UV o highlight sin ajustar; preexistente (no
  introducida por este fix), sin investigar todavía.

**Hallazgos HIGH — NO atacados todavía:**
- Hombros como esferas infladas en vista trasera ("hombreras de fútbol
  americano"), contradice "narrow sloped shoulders" de la lámina.
- El trapecio corregido (Fase 1.3, ya cerrada) ahora es ILEGIBLE en el
  sentido opuesto — transición abrupta cilindro→esfera, sin pendiente.
- Perfil sin profundidad de pecho ni curva lumbar — el torso de lado es
  una tabla plana.

**Hallazgos MEDIUM — NO atacados todavía:**
- Cintura se lee por una línea de tinta dibujada, no por la silueta real.
- Clavícula como 2 trazos flotantes, desconectados visualmente.

**Estado de la fase: EN CURSO, no cerrada.** CRITICAL 2 (cuello de camisa
de cartón) cerrado y verificado 2026-07-17. CRITICAL 1 (torso "peto/
cartón") y todos los HIGH/MEDIUM siguen sin atacar. Gates
`test_core`/`autotest_biomech` ALL_PASS con el estado actual del código.

**Pendiente antes de dar por cerrada la fase:** resolver (o decidir
diferir) CRITICAL 1 + los hallazgos HIGH/MEDIUM de arriba + los 3
hallazgos nuevos reportados por el QA de cierre del CRITICAL 2, nuevo QA
imparcial de re-medición de fidelidad global, y VoBo de Boris con capturas
frente/perfil/3-4/espalda.

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
