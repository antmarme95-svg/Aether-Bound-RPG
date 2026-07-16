---
status: propuesto
source: "Minado 2026-07-16 de 'Anatomy for 3D Artists — The Essential Guide for CG Professionals' (Chris Legaspi, Laura Braga, Djordje Nagulov, Mario Anger, César Zambelli, Daniel Peteuil; 3dtotal Publishing) — copia personal de Boris, NUNCA copiada al repo. 5 subagentes leyeron las 157 páginas (renderizadas a JPEG vía mutool/MuPDF) y reportaron principios en su propia síntesis, sin transcribir texto ni reproducir imágenes. Esta página es una segunda pasada de síntesis + cruce contra el código y las Lecciones del proyecto. **Ampliada 2026-07-16 (misma sesión, más tarde):** la primera pasada NO cubrió cabeza/cara — Boris señaló los capítulos exactos ('Sculpting an archetypal figure — 3D male — Part 01 | Basic form', secciones 10-11, pp.96-97; y 'Sculpting an archetypal figure — Advanced 3D male — Part 01 | Head, neck, and face' por Djordje Nagulov, pp.116-121) y se re-abrió el PDF (mutool, sin outline — se ubicó el rango renderizando muestras y leyendo cabeceras de capítulo) para minar esas 6 páginas específicas, agregadas como sección nueva abajo."
updated: 2026-07-16
---

# Principios de Anatomía 3D — minados para el pipeline procedural

> No es un resumen del libro — es la traducción de su lógica de construcción al
> vocabulario de primitivas que ya usa `character_rig.gd`
> (`CylinderMesh`/`BoxMesh`/`SphereMesh`, sin malla esculpida, sin `Skeleton3D`).
> Confirma y extiende [[Lecciones]] ("una esfera nunca da un plano/borde
> anguloso — usar caja"), y alimenta directo la ejecución pendiente del loft
> en [[Propuesta-Recursos-de-Modelado]] y las prioridades abiertas de
> [[PRD-Rework-Fenotipo-Humano-Cuerpo-Completo]].

## Principio general: qué primitiva para qué masa

El libro es explícito y consistente en las 157 páginas sobre una regla que el
proyecto ya venía descubriendo a mano, ronda por ronda:

- **Esfera** → solo articulaciones reales tipo bola-y-cuenco (hombro, cadera,
  a veces codo/rodilla) y masas genuinamente redondeadas (mejilla llena,
  glúteo). Nunca para un plano óseo.
- **Cilindro** → segmentos rígidos entre articulaciones (brazo, antebrazo,
  muslo, pantorrilla) y la caja torácica en su forma más simple ("bullet" o
  "birdcage": cilindro redondeado, no caja recta).
- **Caja** → cualquier zona con un plano o borde definido: pelvis, palma de
  la mano, dedos (sí, dedos — ver abajo), acromion, pómulo bajo luz dura. La
  caja "captura la naturaleza rígida" donde la hay; se suaviza después, nunca
  se empieza redondo para luego "encontrar" el plano.

**Confirmación cruzada, no solo transferencia:** el libro describe el pómulo
bajo luz de alto contraste como *"box-like"* y el acromion como *"una
superficie plana"* — exactamente el vocabulario de [[Lecciones]] ("si la
lámina muestra un plano definido, la primitiva correcta es caja, no esfera").
No es una técnica nueva que reemplaza la del proyecto; es la misma técnica,
confirmada por una fuente independiente, con más superficies del cuerpo
donde aplica de lo que se había probado hasta ahora.

## Torso y hombros (prioridad #1 — insumo directo para reabrir `SHOULDER_X`)

Este es el bloque con más señal del libro, y converge desde 4 de los 5
tramos leídos en el mismo diagnóstico:

**El torso se bloquea como 3 masas independientes, nunca como un cilindro
continuo con un solo taper.** Proporción de referencia: caja torácica
(cilindro/huevo redondeado) ocupa **2/3** de la altura del torso, pelvis
(caja rígida, inclinada levemente hacia atrás) ocupa el **1/3** inferior, y
entre ambas vive la cintura — el único tramo que se comprime/estira, con un
volumen real más angosto y deformable, NO una curva estética aplicada sobre
un cilindro. El "maniquí sin cintura ni trapecio real" que reporta el QA es
consistente con tratar el torso como una sola forma continua en vez de estas
3 masas con quiebre real entre ellas.

**Advertencia explícita para el cuerpo masculino:** el torso masculino NO
lleva quiebre de cintura tipo reloj de arena (eso es exageración femenina).
El contraste que sí debe leer con fuerza es **hombro ancho vs. cadera más
angosta + trapecio prominente en la base del cuello** — no una cintura
estrecha. Si se "corrige" el maniquí angostando la cintura al estilo
femenino, se contradice la lámina y el propio libro.

**La cintura escapular (clavícula + escápula + acromion) es un bloque
separado, articulado sobre la caja torácica — no una continuación lisa del
torso.** Se puede modelar como su propia caja ancha (borde frontal =
clavículas, borde lateral = acromion, cara trasera = omóplatos) que se monta
encima de la caja torácica. Esto es el candidato más concreto para
`SHOULDER_X`: en vez de un solo cilindro de hombro degradándose hacia el
brazo, el hombro necesita **2-3 masas superpuestas con costura visible entre
ellas** (deltoides + trapecio + hueco de axila/dorsal ancho), no un blend
suave.

**Landmarks óseos a tratar como quiebres/planos (candidatos a caja):**
acromion, muesca yugular (hueco base del cuello), proceso xifoides (punta
inferior del esternón), borde de la 10ª costilla, ángulo inferior de la
escápula (se ve como "cuchilla" al levantar el brazo), 7ª vértebra cervical
(bulto base del cuello).

**Reglas duras repetidas varias veces, con valor de checklist anti-error:**
- La clavícula **siempre** tiene forma de "S" — nunca recta. Señalado dos
  veces como el error de principiante más común.
- La caja torácica **nunca** se modela plana — siempre envuelve el torso con
  curvatura, aunque se use un cilindro simplificado.
- Deltoides/bíceps/tríceps deben leer como que **emergen unos de bajo
  otros** (nacen escondidos bajo el borde vecino), no como piezas pegadas
  una junto a otra — esto es lo que hace que el hombro lea como masa
  continua real en vez de "tubo con esfera pegada".
- Ritmo escapulohumeral 1:2 — al levantar el brazo, primero rota solo el
  húmero (0°-30°), luego la escápula se suma en proporción 1° por cada 2°
  del húmero. Mecánicamente es la razón de que un hombro sin ese "segundo
  estadio" (sin escápula/trapecio propios) lea plano — no aplica directo a
  una pose estática, pero confirma por qué el hombro necesita masa de
  trapecio SEPARADA del deltoides, no solo un cilindro más ancho.
- Bloquear primero la silueta general (triángulo invertido: hombros anchos,
  cintura angosta, torso musculoso) ANTES que cualquier detalle de músculo
  individual — el orden de trabajo importa tanto como la geometría.

## Manos (prioridad #2)

Hallazgo más accionable de todo el libro para el síntoma "dedos leen tabla
plana, sin quiebre de nudillo real":

**Sistema de proporción por mitades sucesivas** (César Zambelli): la palma
se trata como un cuadrado cuyo lado = largo del dedo medio. Para ubicar
nudillos en cualquier dedo: se divide el dedo a la mitad (primer nudillo),
esa mitad otra vez a la mitad (segundo nudillo), y esa mitad otra vez a la
mitad (inicio de la uña). Índice y anular terminan a la altura del inicio de
la uña del medio; el meñique termina en el último nudillo del anular; el
pulgar (que solo tiene 2 falanges, no 3) termina a la mitad de la primera
falange del índice.

**Los dedos NUNCA son rectos ni se insertan en la palma en línea recta.**
Los 4 dedos curvan levemente convergiendo hacia el medio — si se traza la
curva de cada uno, las 4 líneas convergen en un punto imaginario. El libro
es explícito: "dedos perfectamente rectos hacen que la mano se vea de
plástico". Esta es probablemente la causa raíz más directa y barata de
arreglar del síntoma reportado: no es solo el quiebre del nudillo, es la
AUSENCIA de curva de convergencia entre dedos.

**El nudillo es la cabeza del metacarpiano/falange asomando** — una
protuberancia PUNTUAL (candidata a esfera/cápsula pequeña propia), no una
curva continua tallada en el mismo cilindro del dedo. El patrón correcto del
dorso es protuberancia→canal(tendón)→protuberancia, repetido por dedo — no
una plancha uniforme. Asimetría intencional: el segundo nudillo del índice
sobresale un poco más que los demás al cerrar el puño — no todos los
nudillos están alineados a la misma altura.

**La palma como forma base:** caja ahusada (tapered box) agrupando
palma+dedos como una sola masa direccional — evita la "tabla plana" al
darle un volumen base con dirección antes de subdividir en dedos. En reposo,
la palma tiene una concavidad activa (tendones/músculos la abovedan), no es
plana ni siquiera relajada.

**Facetar, no redondear:** los dedos parecen cilíndricos a primera vista
pero tienen planos definidos en cada falange — mismo principio de "romper
la redondez con facetas" que ya resolvió mandíbula/pómulo, aplicado ahora a
falanges individuales.

## Pelo (prioridad #3)

Señal más clara para el síntoma "mechones se funden en 2-3 lóbulos" (3er
intento fallido con cajas/conos):

**Orden de trabajo: masa completa primero, mechones individuales AL FINAL.**
El método descrito (repetido en dos tramos distintos del libro) es: bloquear
el volumen general del peinado como una sola forma sólida, ignorando
mechones individuales — silueta antes que detalle. Los mechones finos son
la ÚLTIMA capa que se agrega, no la primera. Si la construcción actual
empieza directo con piezas individuales (cajas/conos por mechón) sin una
masa base de silueta ya resuelta, es consistente con el resultado de
"lóbulos fundidos": faltan pasadas intermedias de subdivisión progresiva.

**Regla anti-paralelismo, repetida como advertencia dura:** mechones con
tamaño/ángulo/espaciado uniforme entre sí se leen como bloque artificial. Se
necesita variación deliberada de tamaño y ángulo entre mechones VECINOS, más
un puñado de mechones "rebeldes" que rompan el patrón general — sin eso, el
ojo agrupa mechones parecidos en una sola masa (exactamente "2-3 lóbulos").

**Nota de fricción a resolver, no a copiar ciego:** el libro recomienda
transiciones SUAVES entre secciones de pelo (para escultura orgánica
sombreada). Aether Bound no depende de sombreado orgánico para leer
separación — depende de la línea de tinta Sobel, que solo dibuja un
contorno donde hay un escalón de profundidad REAL entre masas (ver
[[Lecciones]]: "un escalón de profundidad solo existe si las caras
frontales terminan en Z distinto"). La traducción correcta NO es "suavizar
hasta que no haya costura" — es variar tamaño/ángulo/profundidad real
mechón a mechón para que el Sobel entinte cada uno como un trazo distinto,
en vez de mechones idénticos y parejos que el Sobel también agrupa en un
solo contorno grande.

## Cabeza, cuello y cara (minado 2026-07-16, segunda pasada — insumo directo para la Fase 5 propuesta)

A diferencia de torso/manos/pelo, este bloque sale de dos capítulos
puntuales que Boris identificó por nombre y que la primera pasada no había
localizado: "3D male — Part 01 | Basic form" §10-11 (bloqueo general de
cabeza) y "Advanced 3D male — Part 01 | Head, neck, and face" (capítulo
completo, 13 secciones, dedicado a cabeza/cuello/expresiones). El libro SÍ
tiene contenido facial — la primera pasada simplemente no llegó a esas
páginas porque no era la prioridad de esa sesión.

**Bloqueo general del cráneo (§10, "Shaping the head"):** el cráneo se
visualiza como un huevo/caja alargada apoyada de lado, con la cara colgando
del lado puntiagudo. Es importante meter el cuello temprano en el proceso —
informa el resto de la estructura de la cabeza: el cuello se apoya en
ángulo contra el cráneo, con los dos "tendones" del esternocleidomastoideo
cruzando en diagonal opuesta entre sí. La cara se resuelve con planos
frontal/lateral + un indicio de mandíbula. **La mandíbula masculina es más
angular, con cambios de plano más marcados que la femenina** — coherente
con la elección ya hecha en código de esfera+ángulo goníaco en vez de una
esfera lisa.

**Proporción y orden de refinamiento (§11, "Refining the head"):** la línea
horizontal de los ojos va aproximadamente a la mitad de la cara — error
común: ponerlos demasiado alto. Los ojos se separan por aproximadamente el
ancho de un ojo (coincide con la corrección ya aplicada en
`character_rig.gd`: `side*0.052`→`side*0.036`). El pómulo desciende en
diagonal hasta la oreja, que en perfil se ubica a la mitad de la cabeza. La
frente es "un arreglo complejo de planos" que merece atención propia, no
solo una curva lisa. La boca se bloquea AL FINAL, después de ojos/nariz/
mandíbula — mismo principio de orden que ya se aplicó en pelo (masa/
landmarks generales antes que detalle).

**Principio de hueso vs. músculo (§06, "Bone visibility"):** la cara tiene
pocos músculos que definan forma — la mitad superior de la cabeza está
definida sobre todo por el hueso del cráneo, incluso en gente con más
grasa. En expresión neutra se ve la mayor parte de la órbita ocular y el
borde exterior del pómulo. **Error de principiante explícito citado por el
libro: "levantar el borde del hueco ocular junto con las cejas — los huesos
del cráneo no se mueven."** Esto es directamente aplicable a cualquier
slider de ceja/ojo en `character_rig.gd` (`eyeTilt`/`eyeShape`): la rotación
del grupo del ojo no debería sugerir que la órbita ósea se mueve, solo el
tejido blando (párpado/ceja) alrededor de ella.

**Ojo — mecánica del globo ocular (§02 "the face at rest", §08 "rotating the
eyes"):** el globo ocular se modela como pieza separada encajada en la
órbita, con el párpado superior plegándose bajo la ceja; conviene que el
párpado tenga grosor suficiente para que el borde interno atrape luz (no un
disco plano). El globo ocular es solo ligeramente más grande que el hueco
del párpado y, por el abultamiento de la córnea, no es perfectamente
esférico — esto afecta cómo se ve el ojo al girar. Al cerrar el ojo, el
párpado SUPERIOR hace casi todo el movimiento (el inferior casi no se
mueve) — relevante si en el futuro se anima parpadeo, no aplica a la
geometría estática actual.

**Mandíbula — pivote real (§12, "afraid and in pain"):** al abrir la
mandíbula, el pivote de rotación está delante de la oreja, bajo el arco
cigomático — dato concreto útil si el proyecto alguna vez anima apertura de
mandíbula (hoy `character_rig.gd` no lo hace, la mandíbula es geometría
fija).

**Oreja — única mención encontrada, tangencial:** el libro NO tiene una
sección dedicada a proporción/estructura de oreja. La única referencia
encontrada es de paso (§10 "happy and smiling": "las orejas también se
levantan un poco" al sonreír) — un dato de animación de expresión, no de
proporción base. **Para proporción/estructura de oreja en reposo, este
libro no aporta nada más allá del principio general esfera-vs-caja** (la
oreja es masa redondeada tipo articulación bola-cuenco → esfera, coherente
con la elección ya hecha en `_build_origin_features`).

**Nota de aplicabilidad — el capítulo es sobre EXPRESIONES, el rig es
ESTÁTICO:** buena parte de "Head, neck, and face" (§03-05, 09-13) describe
cómo cambian las masas al girar/inclinar la cabeza o gesticular (enojo,
miedo, sonrisa, beso) — no aplica directo a una malla facial fija sin
blendshapes. Lo transferible a Fase 5 es específicamente lo de arriba
(bloqueo §10-11, hueso-vs-músculo §06, mecánica de globo ocular §02/08) —
el resto queda como referencia para el día que el proyecto anime
expresiones faciales, no para esta fase.

## Piernas y pies (minado 2026-07-16, tercera pasada — completa el rework humano)

De "3D male — Part 01 | Basic form" §08-09 (piernas) y §14-15 (pies), no
minado en la primera pasada porque esa sesión priorizó torso/manos/pelo.

**Bloqueo de piernas (§08):** las piernas se arman igual que los brazos —
nota el "gesto ondulado" (no un tubo recto): el sartorius (la franja
distintiva del muslo) curva desde el frente de la cadera, alrededor del
muslo, hacia el interior de la rodilla. Las rodillas "solo se ponen como
bultos por ahora" en el bloqueo inicial — se refinan después. **Refinar
las piernas (§09):** el glúteo es sorprendentemente grande, se desliza por
debajo de la cresta ilíaca y se curva alrededor del trocánter mayor —
visualízalo como un frijol grande sentado en ángulo. El trocánter es un
landmark importante en el lateral de la cadera, básicamente invisible en
gente musculosa salvo en contrapposto. Hay una curva en S al ver la pierna
de perfil — importante para que la pantorrilla "entre" bien detrás del
muslo, en vez de ser dos cilindros apilados sin relación.

**Pies (§14-15):** dato de proporción rápido y verificable: **el pie mide
aproximadamente lo mismo que el antebrazo** (útil como regla de escala
cruzada si el rig necesita re-chequear proporciones). El hueso del dedo
gordo (primer metatarsiano) da la "vara" principal de la que sale el resto
del pie. Los dedos se bloquean con el ángulo agudo hacia abajo en el primer
nudillo — EXCEPTO el dedo gordo, que apunta recto (no cae en ángulo como
los otros 4). En el borde exterior del pie, el extensor digitorum brevis
es uno de los pocos músculos superficiales visibles; hay un bulto chico en
el borde exterior de la planta donde termina el hueso del meñique.

**Aplicabilidad al rig actual:** `character_rig.gd` no tiene pies/piernas
articulados con el mismo nivel de detalle que manos/torso (deuda técnica
ya registrada en [[Current-State]]: "pies sin IK y ROM enano/elfo", frente
aparte de este PRD). Estos principios quedan como INSUMO para ese frente
futuro, no para ejecutar ahora — ninguna fase actual del PRD toca piernas/
pies.

## Brazos y antebrazos (minado 2026-07-16, tercera pasada)

De "3D male — Part 01 | Basic form" §06-07 (brazos), §17 (arm overview) y
"Advanced 3D male — Part 02 | Shoulders, arms, and hands" (dinámica de
pose, aplicabilidad limitada — ver nota abajo).

**Bloqueo de brazos (§06-07):** trazos rápidos y gestuales para los
miembros. Ojo con el ligero quiebre en el codo visto de frente — el brazo
extendido NUNCA está perfectamente recto (más pronunciado en mujeres). Una
vez dibujado el tubo básico, se le da forma moviendo/inflando las formas.
Agregar un toque de bíceps e implicar el cambio de plano donde el
braquiorradial curva alrededor del hueso; el bulto chico en el interior
del codo es el epicóndilo medial — epicóndilo y codo quedan alineados
cuando el brazo está recto. **"El brazo superior aparece mucho más corto
que el antebrazo porque gran parte de su largo lo cubre el deltoides"**
(§17) — dato de proporción aparente útil si el rig necesita revisar por
qué un brazo "se ve" corto/largo en cámara aunque las medidas sean
correctas.

**Nota de aplicabilidad — la mayor parte de "Shoulders, arms, and hands"
(Advanced 3D male Part 02) es sobre POSADO dinámico** (brazo a 30°/90°/
180°, supinación/pronación, ritmo escapulohumeral) — no aplica a
`character_rig.gd`, que arma primitivas rígidas sin deformación muscular
por pose. Queda como referencia para el día que el proyecto anime
deformación de brazo, no para esta fase.

## Piel y pliegues — nota breve (Part 03 | Skin, aplicabilidad indirecta)

"3D male — Part 03 | Skin" describe cómo simular grasa/piel sobre músculo
ya bloqueado: los pliegues permanentes (codo, atrás de la rodilla, interior
de la muñeca, ingle/axila) vienen de dónde la piel está más floja vs. más
pegada al hueso. **Esto es escultura de detalle en malla continua — no se
traduce directo al vocabulario de primitivas de Aether Bound** (no hay
"piel" separada del hueso en `CylinderMesh`/`BoxMesh`/`SphereMesh`). Lo
único transferible es conceptual: los pliegues de la Fase 1 (costura
cuello-hombro) y cualquier futuro pliegue de codo/rodilla deben pensarse
como "dónde la piel está floja" (una masa semi-hundida adicional), no como
seguir tirando de la geometría rígida existente.

## Cabeza y ojos — brecha real detectada: rango racial no implementado

**Hallazgo cruzando código contra diseño ratificado (2026-07-16, mismo
día):** [[Fenotipos y Creación de Personaje]] (ratificado 2026-07-04) dice
explícitamente que `mandíbula`, `pómulos` y `tilt/forma de ojos` son
**"rango racial: mismo slider, rangos distintos"** — igual que `heightRange`
(que SÍ está implementado por origen en `origins_data.gd:24,56,88`). Pero
`character_rig.gd:1906-1947` (`jaw`, `cheek`, `eyeTilt`, `eyeShape`) usa el
MISMO `_lerp(min, max, v)` para cualquier `_origin_id` — no hay branch por
raza. Esto es una brecha real, no una hipótesis: el código no cumple
todavía la especificación ya ratificada de fenotipo. La tabla de
[[Fenotipos y Creación de Personaje]] da los extremos deseados por raza:
- **Elfo (aetherborn):** "mandíbula fina" (extremo bajo de `jaw` como base
  racial, no el punto medio 0.5 actual), "ojos grandes, tilt alto"
  (`eyeShape`/`eyeTilt` sesgados hacia sus extremos altos), "pómulos altos"
  (coherente con el rango ya implementado, sin sesgo adicional necesario).
- **Enano (ironblooded):** "mandíbula ancha" (extremo alto de `jaw`),
  "frente pesada", "nariz con historia" — la nariz no tiene slider hoy
  (geometría fija en `_build()`); si se quiere una nariz "con historia" por
  raza, hace falta agregar un parámetro nuevo (ej. `noseBump`), no reusar
  uno existente.
- **Humano:** "máxima variación individual" — el rango completo actual
  (0.0-1.0 sin sesgo) es correcto tal cual para esta raza, es la
  referencia neutral contra la que las otras dos se desvían.

**Esto es exactamente "el work del elfo y el enano" que falta para un
rework completo de cara:** la oreja YA es race-specific (`_build_origin_features`,
4 ramas), pero mandíbula/ojos NO lo son todavía — el rework de Fase 5 no
está completo si solo ajusta la forma base (humano) sin agregar el sesgo
racial que el propio diseño ya ratificó y el código nunca implementó.

## Nota de estilo — qué extraer y qué NO copiar literal

El libro está escrito para escultura realista/semi-realista en ZBrush con
malla continua y objetivo fotorreal o superhéroe musculoso — no es el
target de Aether Bound (BotW/Hinterberg/Palia/Torchlight, anti-anime,
anti-realismo PBR, ver [[Art Bible]]). Lo que se extrae es la LÓGICA
ESTRUCTURAL (qué landmarks importan, qué primitiva por zona, en qué orden se
bloquea), no el nivel de detalle realista ni proporciones de físico
fisicoculturista. Cuando el libro insiste en "romper la simetría perfecta"
o en músculos individuales muy definidos, eso es ruido para este proyecto —
la fidelidad que se busca es de SILUETA estilizada, no de anatomía médica
completa.

## Pendiente de aplicar

Estos principios están listos para informar la próxima sesión de código,
pero **nada de esto se ha tocado en `character_rig.gd` todavía** — es
conocimiento compilado, no una ejecución. El orden natural de aplicación
sigue el mismo que ya está en [[Current-State]]: primero medir la lámina en
píxeles para `SHOULDER_X` (ya autorizado), usando el bloqueo de 3-masas +
cintura escapular separada de aquí como hipótesis concreta a probar; luego
manos (sistema de mitades sucesivas + curva de convergencia); luego pelo
(masa completa primero, variación mechón-a-mechón) cuando se retome esa
geometría con el loft de [[Propuesta-Recursos-de-Modelado]].
