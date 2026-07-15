---
status: propuesta — esperando ratificación de Boris (masas propuestas ANTES de codear, mismo protocolo que Fase D)
source: "Observación directa del orquestador sobre `fenotipo-humano-v1.png` (zoom cara/pelo frente+espalda) y `fenotipo-humano-torso-v1.png` (zoom mano/torso), no un QA intermediario — más 3 rondas de QA visual imparcial (32%→42%→45%→49%) que ubicaron el techo de la técnica actual en ~50-55% mientras estos 4 puntos sigan siendo parámetro y no geometría nueva"
updated: 2026-07-14
---

# PRD — Geometría nueva: pelo, torso, manos, boca

> Los 18 puntos de [[PRD-Rework-Fenotipo-Humano-Cuerpo-Completo]] (ejecutados
> en 3 rondas, 32%→49%) agotaron lo que un ajuste de parámetro puede dar. El
> QA de la ronda 3 lo dice explícito: el techo de la técnica actual ronda
> 50-55% mientras 4 áreas sigan con la MISMA construcción de masas que ya se
> intentó calibrar sin éxito. Este PRD no es un ajuste — es una propuesta de
> **construcción nueva** para cada una, a ratificar ANTES de tocar código
> (mismo protocolo que rompió el patrón de iterar a ciegas en la Fase C).

## Método

Para cada área: (1) qué falla en la construcción actual y por qué un
parámetro no lo arregla, (2) qué muestra la lámina REAL (observación directa
de píxeles, con zoom, no una descripción de segunda mano), (3) propuesta de
masas concreta en el vocabulario ya probado del proyecto (cajas para planos,
esferas para redondeado, semi-hundido con overlap real — ver [[Lecciones]]).

---

## 1. Pelo — de "casco" a corte real

**Por qué el parámetro no alcanza:** la construcción actual (`hair_library.gd
_hair_frontier_crop`) es UNA concha elipsoide grande que cubre casi todo el
cráneo + ~31 mechones-caja hundidos casi al ras de esa concha. Not importa
cuánto se suba el contraste de color (probado: 2 tonos → 3 tonos) o la
protrusión (probado y revertido 2 veces — reabre "dientes" en la silueta o no
cambia nada visible): mientras la SILUETA GENERAL sea una sola elipse
continua, va a leer "casco". El problema es de cuántas masas hay, no de qué
tan detalladas son sus superficies.

**Lo que muestra la lámina (zoom directo, `fenotipo-humano-v1.png`):**
- Nuca/laterales MUY cortos — casi expone piel, se ve la oreja completa y un
  triángulo de nuca desnuda bajando hasta el cuello. Nuestra concha actual
  tapa toda esa zona.
- Volumen concentrado ARRIBA (coronilla), con un remolino/cowlick visible
  (líneas radiales desde un punto).
- Al frente, el flequillo NO es una masa continua — son 4-5 mechones
  INDIVIDUALES con puntas visibles, de largos distintos, cayendo hacia la
  frente en direcciones ligeramente distintas (no todos paralelos).
- Degradado de tono sutil (más claro arriba/coronilla, más oscuro en la base).

**Propuesta de masas (a ratificar):**
1. **Base craneal RECORTADA agresivamente** — la concha actual se achica en
   altura Y (sube el borde inferior) para exponer nuca/sienes reales, no solo
   "fade" cosmético. Nueva regla: en la nuca y sobre la oreja, la concha debe
   terminar VISIBLEMENTE arriba de donde termina hoy (≈ 30-40% menos área
   cubierta en esas dos zonas).
2. **Masa de coronilla separada** (no fundida con la base) — una elipsoide
   chica y alta en el punto más alto del cráneo, con 2-3 cajas finas en
   abanico (el remolino) rotadas radialmente desde ese punto. Mismo truco que
   el "quiff" actual pero MÁS aislado silueta-mente de la base.
3. **Flequillo = 4-5 mechones INDIVIDUALES grandes**, no 9-31 chicos. Cada
   uno una cuña (caja o cono achatado) con punta real, largo/ángulo distinto
   por mechón (variación determinista, como ya se hace), protrusión real
   (no semi-hundido al 93-97% — más cerca de 70-80%, con gap de verdad entre
   mechones vecinos para que el Sobel trace cada uno por separado).
4. **Laterales/nuca:** en vez de mechones-caja densos, 3-4 masas MÁS
   GRANDES y MÁS SEPARADAS entre sí (gap real, no solo tono) — menos
   "textura", más "mechones que se distinguen a simple vista".

**Riesgo:** ninguna dependencia de biomecánica (ya confirmado en el PRD
anterior). Riesgo real es de tiempo/iteración — el peinado "príncipe" de
cintas se desechó tras 8 rondas fallidas; esta propuesta usa un vocabulario
distinto (masas separadas grandes, no cintas), pero exige verificación
visual en cada paso, no un solo intento.

---

## 2. Torso — de "placa" a superficie casi plana

**Por qué el parámetro no alcanza:** `abs_plate` es una masa que SOBRESALE
del cilindro del torso. El QA la lee como "pieza de armadura pegada" /
"placa geométrica" en TODAS las magnitudes probadas (0.4→0.30 de protrusión)
porque el problema no es cuánto sobresale — es que la lámina no tiene NADA
que sobresalga ahí.

**Lo que muestra la lámina (zoom directo, `fenotipo-humano-torso-v1.png`):**
el abdomen es prácticamente PLANO. Los "oblicuos" que pide la ficha técnica
("Lean obliques are suggests one or two") son literalmente **1-2 líneas
finas curvas**, sin ningún volumen que las acompañe — el dibujo las resuelve
con TRAZO, no con forma. El ombligo es una marca mínima. No hay six-pack, no
hay placa, no hay six-pack. También: los pectorales son curvas MUY suaves,
casi lineales, no bultos esféricos — confirma el hallazgo del QA de que los
`pec` actuales (esferas escaladas) leen como "ojos".

**Propuesta de masas (a ratificar):**
1. **`abs_plate` se ELIMINA como masa elevada.** El abdomen vuelve a ser la
   superficie del cilindro del torso, sin bulto agregado.
2. **Oblicuos por LÍNEA, no por volumen:** 1-2 cápsulas MUY finas y CASI
   sin protrusión (apenas 1-2mm, al límite de lo que el Sobel detecta como
   escalón) siguiendo la curva torso→cadera, en vez de una masa. Si el motor
   no lee una protrusión tan chica, alternativa: aceptar que esta línea
   específica no se pueda "en volumen" bajo esta técnica y dejarla solo
   sugerida por el degradado de luz del cel-shading (sin geometría nueva).
3. **`pec` reconsiderado:** aplanar bastante más la protrusión Z (probar
   0.5→0.30-0.35 de escala Z, en la misma familia que abs_plate) y/o
   alargar horizontalmente para que la curva se lea más como "línea de
   pectoral" que como "bulto redondo" — esto es geometría existente
   recalibrada, no nueva, pero el objetivo (aplanar hasta casi desaparecer,
   no "mejorar la esfera") es un cambio de dirección respecto a los intentos
   anteriores.

**Riesgo:** bajo — nodos aislados sin dependencia de animación/combate
(igual que el `abs_plate` original).

---

## 3. Manos — de "abanico de cartas" a mano cerrada

**Por qué el parámetro no alcanza:** ya se probó agrandar el gap entre dedos
(0.38mm→1.4mm) y agregar nudillos-esfera — el QA sigue leyendo "tablas
planas"/"abanico de cartas". El problema no es la separación, es que CADA
dedo es un solo prisma recto sin quiebre, y los nudillos-esfera leen como
verrugas en vez de una articulación real.

**Lo que muestra la lámina (zoom directo, mano sobre la cadera en
`fenotipo-humano-torso-v1.png`):**
- Los dedos están CASI JUNTOS (mucho menos gap del que tenemos hoy) —
  la separación visual la hace la LÍNEA de contorno, no el hueco físico.
- Cada dedo tiene un quiebre de ÁNGULO visible en el nudillo medio (no es
  recto de la base a la punta) — se nota un pliegue, no un bulto.
- El pulgar está CASI OCULTO/enroscado hacia la palma en esta pose (nace
  bajo, cerca de la muñeca, y se curva hacia adentro) — no es un apéndice
  separado y visible como el nuestro.

**Propuesta de masas (a ratificar):**
1. **Gap entre dedos RECORTADO** de vuelta a algo más chico (≈0.5-0.8mm
   efectivo) — contraintuitivo respecto al punto 6 original, pero la lámina
   confirma que la separación se lee por la LÍNEA, no por el hueco físico
   grande (mismo principio que ya funcionó en la mano r5 histórica, antes de
   esta ronda).
2. **Cada dedo pasa de 1 caja recta a 2 segmentos** (falange proximal +
   falange distal) con una pequeña rotación entre ambos en el punto del
   nudillo — mismo patrón que brazo→antebrazo (un quiebre de ángulo real,
   no un bulto agregado). Esto reemplaza la esfera-nudillo actual.
3. **Pulgar recalibrado:** nacimiento más bajo/cerca de la muñeca (ya está
   parcialmente ahí) pero con MÁS curl hacia la palma (rotación x más
   agresiva) para que lea "enroscado", no "separado flotando".

**Riesgo:** verificar de nuevo si algún socket de arma depende de la
geometría exacta del dedo (mismo caveat que el PRD anterior, nunca
confirmado en ninguna pasada).

---

## 4. Boca — de "parche" a línea con volumen mínimo

**Por qué el parámetro no alcanza:** ya se intentó (a) solo tono, (b)
tamaño/posición del escalón Z, (c) achicar la línea de comisura + engordar
labios — el QA sigue leyendo "rectángulo sólido"/"parche". El techo de este
enfoque (2 cilindros + 1 caja de comisura) parece agotado.

**Lo que muestra la lámina:** la única referencia de boca es la cara
sonriendo (`fenotipo-humano-v1.png`) — no directamente transferible a
nuestra expresión neutra/cerrada por defecto, pero confirma que los labios
de la lámina tienen MUY poco volumen propio (la boca se lee sobre todo por
la LÍNEA curva de la sonrisa + los dientes, no por masa de labio).

**Propuesta (a ratificar — necesita más criterio de diseño que las otras 3,
por falta de referencia directa en pose neutra):**
- **Opción A (reducir piezas):** volver a una boca de UNA sola masa
  (fusión labio sup+inf en un solo volumen con una LÍNEA de comisura fina
  tallada, no una caja separada) — menos piezas compitiendo, un solo
  contorno que el Sobel trace limpio.
- **Opción B (aceptar el límite):** la boca en reposo, bajo este
  vocabulario de primitivas, puede tener un techo más bajo que el resto de
  la cara — considerar una boca MÁS CHICA en general (todas las dimensiones
  recortadas ~20-30%) para que el error relativo sea menos visible, en vez
  de seguir iterando la forma.
- Esta es la única de las 4 donde recomiendo que Boris elija dirección antes
  de que se proponga una geometría específica — las otras 3 tienen lámina
  directa que dicta la forma; esta no.

---

## Nota fuera de alcance (encontrada mirando las láminas, no parte de este PRD)

**Discrepancia entre las dos láminas del warpaint:** `fenotipo-humano-v1.png`
(cara) muestra una marca ASIMÉTRICA de un solo lado (ceja izquierda→mejilla,
como leyó el QA original del 32%); `fenotipo-humano-torso-v1.png` (torso)
muestra una "V" SIMÉTRICA bilateral (como se implementó en la ronda 3, 45%→
49%). Son dos láminas Nano Banana distintas con el mismo elemento dibujado
diferente — no hay manera de que el código satisfaga ambas a la vez. Queda
como nota para Boris: ¿cuál lámina es la autoridad para warpaint, o es una
característica personalizable (el slider `warpaint` ya soporta variantes)?

## Definición de terminado

Este PRD cierra con la RATIFICACIÓN de Boris sobre las 4 direcciones (pelo,
torso, manos — más la elección de opción A/B en boca) — recién ahí se abre
la ejecución en código, con el mismo ciclo de QA visual imparcial que las
rondas anteriores para medir el movimiento real del %.
