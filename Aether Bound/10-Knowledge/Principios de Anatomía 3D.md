---
status: propuesto
source: "Minado 2026-07-16 de 'Anatomy for 3D Artists — The Essential Guide for CG Professionals' (Chris Legaspi, Laura Braga, Djordje Nagulov, Mario Anger, César Zambelli, Daniel Peteuil; 3dtotal Publishing) — copia personal de Boris, NUNCA copiada al repo. 5 subagentes leyeron las 157 páginas (renderizadas a JPEG vía mutool/MuPDF) y reportaron principios en su propia síntesis, sin transcribir texto ni reproducir imágenes. Esta página es una segunda pasada de síntesis + cruce contra el código y las Lecciones del proyecto."
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
