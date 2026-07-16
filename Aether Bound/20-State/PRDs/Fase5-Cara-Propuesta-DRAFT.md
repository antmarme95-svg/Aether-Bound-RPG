---
status: borrador — DRAFT de trabajo, NO es el PRD oficial
source: "Propuesta compilada 2026-07-16 a pedido de Boris: cruce de [[Principios de Anatomía 3D]], [[Lecciones]], `character_rig.gd` (grep directo por línea) y las láminas RAW disponibles. NO fue commiteado ni fusionado al PRD-Rework-Modelado-Personajes-v2 — es material de discusión para que Boris decida si se agrega como Fase 5."
updated: 2026-07-16
---

# FASE 5 (propuesta) — Cara: mandíbula, ojos, nariz, mentón, orejas

> **Esto NO es empezar de cero.** La cara ya tuvo una fase de trabajo previa
> ("Fase C", cerrada 2026-07-14) que llevó la fidelidad de la cara de un
> punto bajo a **75%**, con dos decisiones explícitas de Boris ya en firme:
> la barba se QUITÓ del default (nota abierta, no se reabre aquí) y el
> mentón se corrigió en esa ronda. Esta Fase 5 es una PASADA NUEVA y
> dirigida sobre 5 partes específicas, aplicando el libro de anatomía 3D
> minado DESPUÉS del cierre de Fase C (2026-07-16) — conocimiento que Fase C
> no tuvo disponible.

## Aviso previo — CORREGIDO tras indicación de Boris (2026-07-16, mismo día)

**Corrección importante:** la primera versión de este borrador afirmaba que
el libro no cubre cabeza/cara. Eso fue un error de alcance de la primera
pasada de minado (5 subagentes, prioridades de esa sesión = torso/manos/
pelo), no una limitación real del libro. Boris señaló los capítulos exactos
— "Sculpting an archetypal figure — 3D male — Part 01 | Basic form" §10-11
(pp.96-97) y "Advanced 3D male — Part 01 | Head, neck, and face" (capítulo
completo, pp.116-121, Djordje Nagulov) — y se re-abrió el PDF (mutool
render + lectura directa) para minarlos. **Sección nueva agregada en
[[Principios de Anatomía 3D]] → "Cabeza, cuello y cara"** con lo
transferible: bloqueo general de cráneo/cara, principio hueso-vs-músculo
(las cejas/párpados se mueven, la órbita ósea NO), mecánica del globo
ocular, pivote de mandíbula, y proporción ojo-a-ojo/altura de oreja en
perfil. Las secciones 1/3/4 de abajo (mandíbula, nariz, ojos) ya se
actualizaron con este material. **Única pieza que el libro sigue sin cubrir
en absoluto: proporción/estructura de OREJA** — la única mención encontrada
es tangencial (las orejas suben un poco al sonreír, dato de animación de
expresión, no de proporción base). Para orejas, sigue aplicando solo el
principio general esfera-vs-caja + la lámina/reviews ya validadas.

Dado esto, el ancla de proporción real para esta fase sigue siendo, con más
peso que de costumbre, **la lámina** (regla 4 del PRD: "la lámina es la
autoridad de proporción; el libro es la autoridad de estructura") — y aquí
casi no hay libro, así que casi todo el peso cae en la lámina + el criterio
ya validado en las rondas QA de Fase C (ver comentarios de código citados
abajo, que son en sí mismos conocimiento de proporción "pagado" en esa
ronda).

## Lámina de referencia — hallazgo, no hay una dedicada a cara

Búsqueda en el repo (`Aether Bound/90-Raw/concept/`) encontró:
`fenotipo-humano-v1.png` (cuerpo completo), `fenotipo-humano-torso-v1.png`
(torso), y variantes de otros orígenes (elfo, enana/enano). **No existe una
lámina de cabeza/rostro en close-up dedicada.** Lo que sí existe y es
directamente utilizable es la serie `Character-Head-Review-v0.2` a `v0.5`
en `Aether Bound/90-Raw/reviews/` — reviews estructuradas de Boris con
turnarounds de la cabeza en 4 ángulos, que documentan decisiones de
proporción ya ratificadas (posición de oreja, tamaño ojo/iris, hairline,
etc.). **Pregunta abierta para Boris:** si esta fase necesita medir
proporciones en píxeles (mismo método que SHOULDER_X), ¿se mide sobre
`fenotipo-humano-v1.png` (la cabeza ahí es chica, poco detalle útil) o hace
falta pedir/generar una lámina de rostro en close-up nueva? Sin esa lámina,
esta fase se apoya en el criterio ya validado por las reviews v0.2-v0.5 y
el veredicto verbal de Boris en el cierre de Fase C, no en medición en
píxeles fresca.

## Sistema de fenotipo — qué NO romper

`apply_phenotype()` (`character_rig.gd`) expone sliders que esta fase debe
preservar como interfaz intacta, solo reajustando los RANGOS/bases que
manipulan, no la firma:
- `jaw` (~línea 1906-1911): escala `jaw_mesh` en X/Z alrededor de la base
  0.78/0.84/0.94 (Y fijo — fija el mentón al ras de la nariz).
- `eyeTilt`/`eyeShape` (~línea 1940-1947): rotación Z de `eye_group` +
  ceja, y `scale.y` del grupo del ojo.
- No hay slider propio de nariz, mentón u oreja hoy — son geometría fija
  en `_build()`. Si esta fase agrega alguno nuevo, debe seguir el mismo
  patrón (`p.get("nombre", default)` + rango `_lerp` acotado, nunca tocar
  Y/posición que ya está calibrada contra otra parte, ej. el mentón fijo
  contra la nariz).

---

## 1. Mandíbula (`jaw_mesh`, `character_rig.gd:838-849`, ángulo goníaco `:860-865`)

**Estado actual:** esfera escalada (0.78 × 0.84 × 0.94), hundida ~2 cm
dentro del cráneo (overlap real, Lección "overlap real para fundir masas").
Posición `(0.0, -0.048, 0.026)`. Además, 2 masas chicas de "ángulo goníaco"
(esferas escaladas 0.55×0.35×0.85, posición `±0.095, 0.00, 0.050`) que
rompen la curvatura continua de la esfera principal cerca de la oreja.

**Historial de QA ya pagado (leer ANTES de re-tocar):** el comentario en
código documenta que este ES YA el resultado de abandonar un diseño previo
de "prisma de 4 caras + caja de mentón apiladas" (M9-r5, generaba costura)
en favor de la esfera fundida + ángulo goníaco. Ronda de ajuste fino
post-QA (2026-07-14) ya corrigió el problema de "curvatura uniforme = blob
sin quiebre óseo" agregando el ángulo goníaco. **Riesgo de regresión
conocido: si esta fase reintroduce una caja recta para la mandíbula
completa, repite el error ya corregido (costura dura) que motivó el cambio
a esfera+ángulo.** Cualquier cambio debe respetar el overlap real y no
reabrir una costura vertical.

**Qué dice el libro, ahora con las páginas de cabeza minadas ([[Principios
de Anatomía 3D]] → "Cabeza, cuello y cara"):** confirma dos cosas
puntuales. (1) "La mandíbula masculina es más angular, con cambios de plano
más marcados que la femenina" (§10) — respalda directamente que el ángulo
goníaco actual (quiebre de curvatura cerca de la oreja) es la dirección
correcta, no un capricho de esta ronda. (2) El pómulo bajo luz dura es
"box-like" — el principio esfera-vs-caja ya aplicado (esfera chica con
radio distinto, no caja pura, dado que la rama mandibular SÍ curva) sigue
siendo el punto medio razonable. No hay proporción canónica de ángulo
goníaco en grados/mm en el libro — eso sigue siendo lámina + criterio de
Fase C.

**Lección de Godot aplicable:** "una esfera nunca da un plano/borde
anguloso — usar caja" ([[Lecciones]]) ya se aplicó una vez a mentón/pómulo;
el ángulo goníaco actual es una solución intermedia (esfera con radio
distinto, no caja) que SÍ funcionó según el comentario de ronda 2026-07-14.
No asumir que hace falta una caja ahí solo por la regla general — el
historial de código dice que la esfera-con-quiebre-de-radio ya resolvió el
"blob".

**Propuesta concreta:** no reabrir la forma base (esfera fundida +
ángulo goníaco) sin evidencia visual fresca de que sigue fallando — pedir
turnaround fresco primero. Si el QA de esta fase encuentra un defecto
puntual (ej. el ángulo goníaco no se lee en 3/4, o la transición
mandíbula→cuello sigue blanda), la corrección específica se decide con
captura en mano, no a priori. Medida final (cuánto ancho/definición) se
ancla contra la review v0.5 / veredicto verbal de Boris de Fase C, no
inventada.

**Riesgo de regresión:** ALTO si se reconstruye desde cero — esta pieza ya
pasó por ~4 iteraciones documentadas (prisma recto → esfera+ajustes 2-6 →
ángulo goníaco). Cambiar de familia de primitiva otra vez sin nueva
evidencia visual repite el patrón de "2 rondas sin cerrar, sospechar del
andamiaje" al revés — aquí el andamiaje YA se corrigió una vez.

---

## 2. Mentón (`chin_boss`, `character_rig.gd:867-900`)

**Estado actual:** caja (`_box_mesh(0.058, 0.032, 0.055, skin_mat)`),
posición `(0.0, -0.134, 0.0975)`, recesada dentro de `jaw_mesh` con
overlap real.

**Historial de QA ya pagado — el MÁS largo de las 5 partes.** El comentario
documenta 6+ rondas de ajuste fino:
1. Esfera (`chin_boss v1`) → leyó redonda/blanda.
2. Cambio a CAJA → corrigió el borde recto, pero con protrusión ~2cm dejó
   un canto/borde flotante (caja plana sobre superficie curva no-tangente
   SIEMPRE deja escalón visible si el overlap es insuficiente — más overlap
   necesario que con esfera).
3. Recesado 0.086→0.080 (protrusión ~1.3cm) — corrigió el canto.
4. Ensanchado 0.052→0.058 para mentón más definido.
5. Post-QA (barba quitada): la cara frontal del mentón (z≈0.098) quedaba
   ~4.7cm DETRÁS de la cara frontal del labio inferior (z≈0.145) — el
   mentón NUNCA competía visualmente con la boca, al revés de la lámina.
   Subido a z≈0.148 (primer intento) → se pasó de rosca, leyó "mandíbula
   protuberante/bulldog". Bajado a punto intermedio (z≈0.125).

**Riesgo de regresión: MÁXIMO de las 5 partes.** Esta es la pieza con más
iteraciones documentadas de todo el rework de cara. Cualquier cambio debe
partir explícitamente del punto intermedio ya calibrado (z≈0.125,
protrusión ~1.3cm, caja 0.058×0.032×0.055) y no repetir los 2 extremos ya
descartados (mentón hundido tras el labio, o mentón bulldog).

**Qué dice el principio general del libro:** confirma la elección de caja
("box-like" para planos/bordes definidos) — esto ya se aplicó
correctamente en la ronda 2 de arriba. Nada nuevo que aportar aquí más allá
de lo ya pagado.

**Propuesta concreta:** tratar el mentón como la pieza de MENOR prioridad
de cambio de esta fase, salvo que el QA fresco de Fase 5 (con la tinta ya
corregida por Fase 0 del PRD general) muestre un defecto puntual distinto
a los 2 ya descartados. Si Boris pide "más marcado", mover DESDE el punto
intermedio ya calibrado (z≈0.125) hacia el extremo alto (z≈0.148) en pasos
pequeños con captura en cada uno — no repetir el salto directo que ya causó
"bulldog".

---

## 3. Nariz (`nose`, `character_rig.gd:902-942`)

**Estado actual:** cilindro con `radial_segments=4` (prisma de 4 caras),
`_cylinder_mesh(0.0015, 0.019, 0.062, skin_mat)`, raíz casi puntual
(`top_r≈0.0015`) hundida en el cráneo, punta ancha (`bot_r=0.019`)
proyectando ~8-9mm fuera, `rotation.y=0.0` (cara plana al frente, NO arista
centrada).

**Historial de QA ya pagado:** 8 rondas documentadas. La más importante:
Ronda 8 cambió `rotation.y` de `PI/4` (arista centrada, 2 caras chicas
simétricas repartiendo la luz = poco contraste) a `0.0` (cara plana al
frente = quiebre de tono real cara-iluminada/lados-en-sombra). El comentario
es explícito: **"NO tocar `radial_segments` (4→6-8 propuesto en otro PRD)
— con N par >4 ningún múltiplo de `rotation.y` deja una cara centrada en
+Z, así que subir segmentos reintroduce el problema que Ronda 8 cerró."**
Esto es una restricción dura y ya escrita en el propio código — cualquier
propuesta de "suavizar" la nariz subiendo segmentos debe descartarse salvo
que alguien resuelva primero cómo mantener una cara centrada con N>4.

**Qué dice el principio general del libro:** confirma cilindro/prisma para
segmentos con planos — coherente con lo ya hecho (cuña de 4 caras, no
esfera).

**Lección de Godot aplicable:** el mismo patrón de overlap real
(raíz hundida ~1.6cm, Lección "overlap real para fundir masas") ya se
aplicó aquí para eliminar la costura base-nariz que existía en el diseño
previo ("prisma con cap plano flotando sobre la piel"). Cualquier rework
debe preservar ese hundimiento de raíz.

**Propuesta concreta:** de las 5 partes, la nariz es la que MENOS necesita
tocarse — 8 rondas ya la llevaron a un estado estable ("proyección Z de
nariz/mentón estables on-model", review v0.5, positivos). Si Boris quiere
cambios, el espacio de exploración seguro es: ángulo de `rotation.x`
(inclinación raíz-punta), tamaño de `bot_r` (ancho de la base/punta) y las
"alas" laterales (`:944+`, bultos semi-hundidos a los lados de la punta) —
NUNCA `radial_segments` ni `rotation.y` sin resolver primero la restricción
documentada arriba.

**Riesgo de regresión:** ALTO en `radial_segments`/`rotation.y`
específicamente (documentado en el propio código como ya resuelto tras 8
rondas); BAJO en ángulo/alas (espacio no explorado a fondo).

---

## 4. Ojos (`eye_group`, `character_rig.gd:1090-1149`; ceja `:1174-1177`;
sliders `eyeTilt`/`eyeShape` `:1940-1947`)

**Estado actual:** grupo por ojo con 4 piezas — `white` (esfera escalada
1.0×0.85×0.36, radio 0.017), `iris` (disco r=0.0102), `pupil` (disco
r=0.0048), `glint` (disco r=0.0022, offset para brillo). Posición del grupo
`(±0.036, 0.022, 0.126)`. Ceja: caja `0.040×0.006×0.010` en
`(±0.036, 0.038, 0.133)`, solapando el borde superior del ojo (overlap
real = párpado).

**Historial de QA ya pagado — el más iterado en proporción relativa:**
- Separación ojo-a-ojo: corregida de "botones flotando" (hueco 2.4× el
  ancho de un ojo) a la regla humana estándar (hueco ≈ 1 ancho de ojo),
  moviendo `side * 0.052` → `side * 0.036`.
- Proporción esclerótica/iris: corregida de "iris cubre 60% del blanco" a
  agrandar la esclerótica en Y (0.58→0.85) y achicar iris/pupila — Ronda 8
  descubrió que el margen "de blanco fino" documentado en una ronda previa
  en realidad era NEGATIVO (el iris desbordaba el blanco), confirmado por
  Boris contra referencias de Link/Zelda BotW/TotK.
- Párpado: el solape ceja-ojo se ajustó dos veces para no apilar una
  segunda línea de tinta muy cerca de la del pómulo (lectura de "arrugas"
  no deseada).

**Qué dice el libro, ahora con las páginas de cabeza minadas ([[Principios
de Anatomía 3D]] → "Cabeza, cuello y cara"):** confirma la regla "hueco
entre ojos = 1 ancho de ojo" — SÍ viene del libro (§11, "Refining the
head"), no es un canon externo sin fuente como se pensó en la primera
pasada de este borrador. Dos principios adicionales, directamente
aplicables al código:
- **Hueso vs. músculo (§06):** "error de principiante — levantar el borde
  del hueco ocular junto con las cejas; los huesos del cráneo no se
  mueven." Aplicado a `eyeTilt`/`eyeShape` (rotación Z de `eye_group` +
  ceja): el slider debe leer como movimiento de tejido blando (párpado/
  ceja), no como si la órbita ósea rotara — vale la pena una revisión visual
  de si el rango actual de los sliders sugiere esto último en los extremos.
- **Mecánica del globo (§02, §08):** el ojo se modela como pieza separada
  encajada en la órbita (ya se hace: `eye_group` con white/iris/pupil
  independientes) con el párpado suficientemente grueso para atrapar luz en
  el borde interno — coherente con la ceja actual como caja que solapa el
  borde superior.

**Lección de Godot aplicable:** overlap real (párpado sobre esclerótica) ya
resuelto; el margen entre iris/pupila/esclerótica requiere verificar
RADIOS reales, no solo posiciones (mismo espíritu que la Lección del
escalón Z: "no confiar en que los números se ven distintos" — aquí ya se
verificó explícitamente en Ronda 8, con números).

**Propuesta concreta:** los ojos están en el estado MÁS validado de las 5
partes ("ojos, cejas y proyección Z de nariz/mentón estables on-model",
review v0.5 positivos). Si el objetivo de Boris para Fase 5 es re-abrir
esto, la sugerencia es acotar el trabajo a: (a) verificar que
`eyeTilt`/`eyeShape` cubren un rango de fenotipos creíble sin romper la
proporción validada en los extremos del slider (hoy solo se validó en el
valor base 0.5); (b) considerar si la ceja necesita un arco real (el propio
código señala en un comentario de PRD previo: "esto NO da arco real; si
sigue leyendo recta, segunda pasada = cadena de 2-3 cápsulas/esferas
decrecientes" — pendiente, nunca ejecutado).

**Riesgo de regresión:** MEDIO-ALTO — esta es la pieza donde más rondas de
ajuste fino ya "cerraron" un problema (separación, proporción iris/blanco);
tocar sin evidencia visual fresca de defecto arriesga reabrir esas 2
correcciones.

---

## 5. Orejas (`_build_origin_features`, `character_rig.gd:2143-2391`)

**Hallazgo de investigación — NO es una inconsistencia, es un sistema por
origen ya intencional y documentado en el propio código:**

Existen 4 variantes de oreja, una por rama de un `match`/`if-elif-else`
sobre `origin.id`:
1. **`aetherborn`** (`:2184-2198`) — orejas élficas largas y puntiagudas:
   cono (`CylinderMesh` top_radius≈0, bottom_radius=0.026, height=0.14),
   muy rotado (`rotation.z = side * -1.95`).
2. **`miststalker`** (`:2200-2213`) — orejas bestiales: cono más corto y
   ancho (bottom_radius=0.045, height=0.11), material de pelaje
   (`hair_mat`), parte del paquete visual de esa raza (incluye cola, tufts
   de pelaje).
3. **`ironblooded`** (`:2269-2283`) — orejas compactas redondas: esfera
   (radius=0.032), simple, coherente con el resto del paquete visual de esa
   raza (glow de forja, armadura, chispas).
4. **`else` — origin neutro/desconocido** (`:2359-2390`, **esta es la oreja
   DEFAULT real** para cualquier humano base o id fuera del canon): esfera
   escalada semi-elíptica vertical (radius=0.030, `scale=(0.40, 1.28,
   0.75)`), posición `(±0.124, -0.010, -0.034)`, inclinada
   (`rotation.x=-0.15`), MÁS un lóbulo separado (esfera chica
   `scale=(0.55, 0.6, 0.55)`) colgando bajo el pabellón con overlap real
   ("FASE C paso 7: la masa única leía como botón plano sin forma").

**Conclusión de la investigación:** no hay inconsistencia real entre
bancos — son 4 diseños deliberados, uno por raza/origen (patrón ya
establecido para todo `_build_origin_features`: armadura, tinte de piel,
partículas, etc. cambian igual por origen). El comentario en el código
además documenta un bug YA CORREGIDO relacionado (`ironblooded` antes vivía
en el `else` y cualquier origin desconocido heredaba su armadura de forja
por accidente — corregido en C6a separando la rama explícita). **La oreja
"real por defecto" para el trabajo de Fase 5 es la rama `else` (oreja
neutra + lóbulo), que es la que usa cualquier personaje sin origen
especial asignado (el caso más común en banco de pruebas y probablemente
en la mayoría de personajes jugables humanos).**

**Historial de QA ya pagado (oreja neutra):** reposicionada de "adelantada
sobre la mejilla, lee piercing" (review v0.5, crítico 4) a la vertical
media del cráneo; forma corregida de "disco frontal, lee audífonos/botones"
a semi-elipse vertical con inclinación; lóbulo agregado en Fase C paso 7
para romper el "botón plano sin forma".

**Qué dice el principio general del libro:** la oreja es masa genuinamente
redondeada (pabellón) — el libro reserva la esfera para "articulaciones
bola-y-cuenco y masas redondeadas (mejilla llena, glúteo)", coherente con
usar esfera aquí en vez de caja. No hay contradicción con la elección
actual.

**Propuesta concreta:** de las 5 partes, la oreja neutra es la que menos
iteración visual documentada tiene comparada con mandíbula/mentón/ojos —
solo 2 correcciones (posición, luego forma+lóbulo). Es candidata razonable
para una pasada de PULIDO real en Fase 5: verificar en perfil y 3/4 que la
semi-elipse + lóbulo lee como pabellón con hélix/trago diferenciado (hoy es
2 masas, sin quiebre interno de cartílago) — aplicando el principio
esfera-vs-caja del libro a cualquier sub-detalle nuevo (ej. si se agrega un
trago o antihélix como plano, sería caja chica semi-hundida, no otra
esfera).

**Riesgo de regresión:** BAJO-MEDIO — 2 correcciones documentadas, menos
frágil que mentón/nariz/ojos, pero cualquier cambio de posición debe
re-verificar que no vuelve a "adelantarse" (crítico 4 de v0.5, ya
corregido una vez).

---

## Cierre de fase (propuesto, mismo formato que Fases 1-3 del PRD)

- Gates de regresión: `test_core` + `autotest_biomech` + `test_combat` +
  `autotest_slice` + `autotest_ui` ALL_PASS (regla de sesión #2 del PRD
  general).
- Captura fresca de cabeza en 4 ángulos (frente/perfil/3-4/espalda),
  MISMO protocolo que las reviews `Character-Head-Review-v0.X` previas,
  para permitir comparación directa contra el estado ya validado.
- QA visual imparcial contra el criterio ya establecido en Fase C (75%) —
  el objetivo de esta fase es SUBIR desde ese 75%, no repetir mediciones
  ya cerradas. Máx. 2 rondas sin reportar a Boris.
- **No tocar:** la barba (fuera del default por veredicto de Boris, nota
  abierta de Fase C — no se reabre aquí); el pelo (Fase 3, ya tiene su
  propio plan de loft); warpaint/UI de creación (Fase 4); biomecánica/ROM
  del rig.
- Dado que 3 de las 5 partes (mandíbula, mentón, nariz) ya tienen entre 4 y
  8 rondas de ajuste fino documentadas y estables, se recomienda que esta
  fase empiece por **ojos y orejas** (menos iteradas, más espacio de
  mejora real) y trate mandíbula/mentón/nariz como "verificar primero con
  captura fresca, tocar solo si el QA de Fase 5 encuentra un defecto
  concreto no descartado ya" — para no quemar presupuesto reabriendo
  problemas ya resueltos.

---

## Preguntas abiertas para Boris

1. **RESUELTO (2026-07-16, mismo día):** el libro sí cubre cabeza/cara —
   Boris indicó los capítulos exactos, ya minados y agregados a
   [[Principios de Anatomía 3D]] → "Cabeza, cuello y cara". Único vacío que
   permanece: el libro no tiene proporción/estructura de OREJA (solo una
   mención tangencial de animación de expresión). Para orejas sigue
   aplicando lámina + criterio de Fase C + principio esfera-vs-caja
   general.
2. **No existe una lámina de cabeza/rostro en close-up dedicada** en
   `90-Raw/concept/` — solo `fenotipo-humano-v1.png` (cuerpo completo, cara
   chica) y las reviews `Character-Head-Review-v0.2-v0.5` (turnarounds ya
   hechos, pero son capturas del propio rig en rondas previas, no arte
   concept de referencia). ¿Se pide/genera una lámina de rostro dedicada
   antes de arrancar, o esta fase se mide contra el veredicto verbal de
   Boris + las reviews ya existentes?
3. **Confirmado por investigación, no es ambigüedad real pero vale
   ratificar:** la oreja "default" es la rama `else` de
   `_build_origin_features` (`character_rig.gd:2359-2390`) — las otras 3
   (aetherborn, miststalker, ironblooded) son variantes de raza
   intencionales, no inconsistencia. ¿Esta fase debe tocar SOLO la oreja
   neutra, o también ajustar las 3 variantes de origen si el mismo defecto
   aplica a todas (ej. si se agrega detalle de hélix/trago, ¿se replica en
   las 4 ramas o solo en la default)?
4. **El sistema de sliders de fenotipo** (`jaw`, `eyeTilt`, `eyeShape`) hoy
   solo tiene rango validado en su valor base (0.5) — los extremos del
   rango nunca se verificaron visualmente contra la lámina en las rondas de
   Fase C. ¿Se agrega verificación de extremos de slider al criterio de
   cierre de esta fase, o queda fuera de alcance (geometría base, no
   sliders)?
5. **Mandíbula/mentón/nariz ya tienen 4-8 rondas de ajuste fino
   documentadas y "estables on-model"** según la última review disponible
   (v0.5). ¿Boris quiere que esta fase las toque de todos modos (por
   ejemplo si el 75% de Fase C dejó algo pendiente específico en esas 3
   partes que no quedó registrado en el código), o el foco real de Fase 5
   debe ser ojos/orejas (las 2 partes con menos iteración y más margen de
   mejora aparente)?
