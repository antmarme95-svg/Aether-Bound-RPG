# Minado — "Sculpting an archetypal figure: Advanced 3D male" (Djordje Nagulov)

Fuente: copia personal del director. **No se transcribe texto ni se reproduce
imagen alguna.** Todo abajo es síntesis propia orientada a primitivas del rig.

## Mapa del capítulo

| Parte | Título | Páginas | Secciones | Peso para el rig |
|---|---|---|---|---|
| 01 | Head, neck, and face | 116–121 | 01–13 | Alto (pero ver "Vacíos") |
| 02 | Shoulders, arms, and hands | 122–127 | 01–13 | Medio-alto (hombros/cuello, mano) |
| 03 | Torso | 128–131 | 01–08 | Alto (doctrina de cajas + balance) |
| 04 | Legs, groin, and feet | 132–135 | 01–07 | Bajo hoy (frente futuro) |

Corte exacto: p116 abre Parte 01 (portadilla). p121 cierra con §13. p122
abre Parte 02 (portadilla). p128 abre Parte 03. p132 abre Parte 04. p135
cierra en §07 — el capítulo termina ahí.

**Corrección al vault:** el vault minó solo pp.116–121 y describe esa parte
como "13 secciones" — correcto. Pero afirma implícitamente que ahí estaba
todo lo de cabeza/cuello. Las 14 páginas restantes (122–135) NO son sobre
cabeza; son hombros/brazos/manos, torso y piernas/pies. **El único material
adicional sobre cuello en el capítulo está en Parte 02 §07 (p124)** — y ese
sí es nuevo y directamente útil.

---

## Hallazgos nuevos

### 1. El cuello no es un cilindro: es dos columnas diagonales + un manto trapecial (p117 §03, §04; p118 §05)

El autor describe el cuello por sus tres masas rectoras y por cómo cambia en
cada extremo de rotación: las dos columnas del esternocleidomastoideo (ECM),
el trapecio que baja del cráneo a los hombros, y la piel que se pliega. Datos
concretos que el vault no tiene:

- Al **girar** la cabeza, el ECM del lado hacia el que giras queda **casi
  vertical y sobresaliendo**, y el del lado opuesto **desaparece por completo**
  bajo pliegues de piel. No es simétrico.
- Al **mirar arriba**, la piel del frente del cuello se estira delgada y se
  vuelve **casi vertical**; la porción del trapecio que se ancla a la base del
  cráneo prácticamente desaparece tras la piel amontonada; por detrás solo
  quedan unos pocos pliegues entre cráneo y trapecio.
- Al **mirar abajo**, el trapecio se tensa y se aplana contra las vértebras, y
  **el mentón casi toca las clavículas**; las mitades inferiores de los ECM se
  esconden; **la línea de mandíbula queda obscurecida** por pliegues.
- El **punto de rotación** de la cabeza está en la base del cráneo,
  **justo debajo de las orejas** (p117 §03) — no en el centro de la cabeza.

**Traducción al rig:**
- El cuello deja de ser un `CylinderMesh` único. Mínimo: un cilindro-núcleo
  ligeramente **inclinado hacia adelante** (no vertical) + **dos elipsoides
  delgados en diagonal** (ECM) desde detrás de la oreja hacia el hueco
  supraesternal, cruzándose en V. Esas dos diagonales son lo que hace que un
  cuello lea como cuello y no como poste.
- **El pivote de rotación de la cabeza va a la altura del lóbulo de la oreja,
  no en el centro del cráneo.** Cambio de una línea en el rig, efecto grande:
  hoy la cabeza gira "flotando".
- Al rotar la cabeza por código, `visible`/escala de los dos ECM debe ser
  **asimétrica en función del ángulo** (el del lado hacia el que gira, más
  grueso; el contrario, se apaga). Barato y muy legible.
- Personajes: **los tres**, pero es LA reparación del defecto "no hay cuello".
  Valen se lleva el cuello largo (más recorrido del cilindro-núcleo, ECM más
  visibles por menos grasa).

### 2. Las clavículas rotan ~45° al encoger hombros y "prácticamente esconden el cuello" (p124 §07)

Nuevo y numérico. Al elevar los hombros, las clavículas rotan hasta unos
**45 grados**, levantando todo el tejido; las laderas superiores del trapecio
se comprimen contra el cuello formando **pliegues profundos bajo el cráneo**;
el pecho no se estira, la masa **cuelga de las clavículas**. Complemento del
§05 (p124): al protraer los hombros las clavículas **sobresalen rotando por
encima de la horizontal**, con hoyuelos arriba y abajo del hueso.

**Traducción al rig:** esto es literalmente la receta del enano. El look
"hombros que se tragan el cuello" no se logra acortando el cuello: se logra
**rotando el par de clavículas hacia arriba (hasta ~45°) y subiendo la masa
del trapecio hasta comerse el tercio inferior del cuello**, dejando el cuello
con la misma longitud interna. Parámetro sugerido: `clavicleTilt` (0° humano,
~30–45° enano, ~0–10° elfo) desacoplado de `neckLength`.
**Personaje: Darro, directo.**

### 3. Las clavículas son masa visible con hoyuelos, no una arista (p124 §05, p128 §01)

El libro trata clavícula y borde inferior de la caja torácica como
**landmarks óseos que asoman a través del tejido** y cambian de prominencia
con la pose. En el rig la costura cuello-hombro hoy es un chaflán; el libro
pide **dos cilindros delgados en S suave, cada uno con una depresión encima y
otra debajo**. Esa depresión es lo que separa visualmente cuello de pecho.
**Personaje: los tres; es el arreglo del "bloque bajo la cabeza".**

### 4. Doctrina explícita de cajas: dos cajas rígidas y un resorte (p128 §01, p129 §02)

El texto ordena visualizar el torso como **un tubo con dos cajas grandes
metidas dentro** (caja torácica y pelvis); el resto del tejido se comprime y
expande encima, pero **las cajas permanecen inviolables**. Y para flexión:
pensarlo como **dos masas sólidas unidas por un resorte** (la zona lumbar),
dejando **intacta la región alta de la columna y las caderas** — mover esas
zonas produce distorsión falsa.

**Traducción al rig:** validación fuerte y explícita de la regla del vault
"caja para planos, esfera solo para bola-y-cuenco". Concreta: el torso debe
ser **`BoxMesh` caja torácica + `BoxMesh` pelvis + un tramo intermedio
deformable**, nunca un solo cilindro escalado. Cualquier animación de
inclinación de torso solo debe tocar el tramo intermedio.
**Personaje: los tres. Es la base de la silueta trapezoidal de Darro** — el
trapecio enano sale de una caja torácica más ancha y más corta, no de
hombros más grandes.

### 5. La caja torácica es de forma **ovalada/de huevo**, no cilíndrica (p123 §04, p130 §04)

Mencionado dos veces: cuando las masas grandes se levantan, "la forma oval de
la caja torácica se discierne más claramente"; y al flexionar de lado, "su
forma tipo huevo se hace más distinta" en el lado extendido.
**Traducción:** la caja torácica en sección transversal es una **elipse más
ancha que profunda**, y se **estrecha hacia arriba**. En el rig: `BoxMesh` con
escala X > Z y un chaflán superior, no un cubo. Enano: elipse aún más ancha.

### 6. La curvatura de la columna **se cierra hacia el cuello** (p129 §03)

Cita textual breve, atribuida a Nagulov: la curvatura de la espalda
"isn't uniform like a parenthesis". Se hace **más pronunciada hacia el
cuello**. **Traducción:** si el rig alinea segmentos de torso por un arco
constante, está mal. El gradiente de inclinación entre segmentos debe crecer
hacia arriba. Esto también es lo que da la **cabeza ligeramente adelantada**
que un cuello creíble necesita.
**Personaje: los tres; Darro más marcado.**

### 7. La mano descansa sobre una bola imaginaria y **medio pulgar es palma** (p126 §10)

Dos datos duros y accionables:
- La mano **no es un rectángulo plano**: curva en todos los ejes. Modelo
  mental: **apoyada sobre una pelota grande**.
- **Casi la mitad del pulgar es en realidad parte de la palma** — colocar bien
  esa mitad es lo que decide si la mano se siente natural.
- En reposo los dedos están **ligeramente curvados y cada uno con curvatura
  distinta**; dedos rectos y paralelos = error.
- El nudillo de los dos últimos dedos es móvil → la **línea de nudillos
  describe un arco pronunciado**, no una recta.

**Traducción al rig:** la palma debe ser un `BoxMesh` con **curvatura cóncava
por escala no uniforme y los metacarpianos abanicados sobre una esfera
virtual**; el pulgar arranca **a media palma**, no en el borde. La rotación de
reposo de cada falange debe llevar **jitter determinista por dedo**, no un
valor común. Esto ataca directamente el look "guante rígido".
**Personaje: los tres. Darro: arco de nudillos más corto y ancho.**

### 8. El puño es **oblongo, no cuadrado** (p127 §12)

Explícito: tendemos a pensar los puños como bloques cuadrados, pero desde casi
cualquier ángulo son **alargados**. Traducción: si el rig tiene pose de puño,
la caja debe ser más larga que ancha en el eje dedo→muñeca.

### 9. Muñeca: menos de 90° lateral, poco más de 180° arriba/abajo (p126 §11)

Números duros de rango de movimiento, útiles para clamps de IK/animación
procedural. Ver tabla.

### 10. Hombro: los primeros 30° no mueven la escápula; después, ratio 2:1 (p123 §02)

El vault menciona "ritmo escapulohumeral" y lo descarta por no aplicar. **Pero
el número sí aplica**: si el rig alguna vez rota brazos por código, la regla
es *0–30°: solo el húmero; >30°: el húmero rota el doble que la escápula.*
Es una fórmula implementable en tres líneas, no una noción de escultura.

### 11. Al girar la cabeza, los ojos giran con ella (p117 fig.03); al mirar arriba, las cejas suben (p119 §08)

El vault registra "no levantar la órbita ósea". Lo nuevo es el **acoplamiento
positivo**: la mirada acompaña la rotación de cabeza automáticamente, y no
levantar las cejas al mirar arriba produce una expresión de **ceño deliberado**
(útil si se quiere un Darro adusto: cabeza levemente baja + cejas quietas).
**Traducción:** parámetro `gazeFollow` acoplado a la rotación de la cabeza; y
`browLift` acoplado al pitch de la cabeza, con ganancia por personaje.

### 12. La punta de la nariz casi no se mueve; las aletas sí (p120 fig.11)

Dato de deformación limpio: **la punta de la nariz es prácticamente rígida**;
las aletas nasales son móviles. Traducción: si se anima gesto, la nariz se
parenta a la máscara facial como pieza fija y solo las aletas escalan. Ahorra
trabajo y evita el look de goma.

### 13. La mandíbula gira alrededor de un pivote adelante de la oreja, bajo el arco cigomático (p121 fig.12)

El vault ya lo tiene, pero lo etiqueta §12; **el dato ancla el arco cigomático
como landmark estructural**, y es la pista de construcción más útil del
capítulo para el eje enano↔elfo: el **arco cigomático es el puente hueso
pómulo→oreja**, y el pivote de la mandíbula cuelga de él. Un rostro construido
por masas necesita ese puente como pieza propia (cilindro delgado
pómulo→oreja) — hoy el rig no lo tiene, y su ausencia es parte de por qué la
mandíbula "flota como cubo suelto".

### 14. El párpado inferior debe tener **grosor suficiente para atrapar luz** en su borde interno (p117 §02)

Ya parcialmente en el vault, pero el criterio operativo es nuevo y medible:
**el borde debe formar un arco iluminado**. Traducción: el párpado no es un
plano — es un **toroide/anillo achatado** rodeando la esfera ocular, con
espesor visible. Contra el defecto "ojos como barras negras planas": la
esfera del ojo debe **sobresalir** del anillo palpebral, y el anillo debe ser
un aro con grosor, no una tira.

### 15. La córnea abulta: el ojo **no es esférico** y su silueta cambia al mirar de lado (p119 §08)

El vault lo tiene. Lo nuevo es el efecto medible: al rotar de lado, el ojo se
ve **ligeramente más grande del lado de la pupila y se afila en la esquina
opuesta**. Traducción: `SphereMesh` del globo + un **casquete esférico
adicional de radio menor** (córnea) desplazado hacia adelante. Dos primitivas,
no una. Esto también le da al ojo un highlight que rompe el look plano.

### 16. Fórmulas de balance: línea de plomada cabeza–caderas–pie de carga (p131 §08)

Regla verificable por código: **debe poder trazarse una recta vertical que
pase por la cabeza, las caderas y el pie que soporta el peso**. Si no pasa,
la figura lee como cayéndose. Traducción: **test automatizable** para las
poses de idle del rig. Y complementaria: **líneas rectas y paralelas dan
rigidez mortal** a una figura — el gesto global debe abstraerse a una
**S larga**. Aplicable a la pose de reposo de Roen/Valen; Darro puede
permitirse más verticalidad como rasgo.

### 17. Contrapposto: caderas y hombros inclinan en sentidos OPUESTOS (p130 §06)

Además: la pierna del lado de la cadera baja suele estar **medio paso
adelante y ligeramente flexionada**. Traducción directa a la pose de reposo:
`hipRoll = +k`, `shoulderRoll = -k`, con `k` pequeño. Tres líneas, gran
ganancia de vida. **Personaje: Roen y Valen; Darro con `k` menor.**

---

## Contradice al vault

**Ninguna contradicción dura.** Dos matices:

1. El vault (§"Brazos y antebrazos") descarta la Parte 02 entera:
   *"la mayor parte de 'Shoulders, arms, and hands' (Advanced 3D male Part 02)
   es sobre POSADO dinámico … no aplica a `character_rig.gd`"*.
   Es **parcialmente falso**: la Parte 02 contiene §07 (p124), que es el mejor
   material del libro sobre **cómo el hombro se come el cuello** — el defecto
   #1 del rig hoy — y §10–13 (pp.126–127) sobre estructura estática de la
   mano (bola imaginaria, mitad del pulgar en la palma, arco de nudillos).
   Ese descarte hizo que el vault se perdiera los hallazgos 2, 3, 7 y 8.

2. El vault dice del cuello, citando el otro capítulo: *"el cuello se apoya en
   ángulo contra el cráneo, con los dos tendones del ECM cruzando en diagonal
   opuesta"*. Este capítulo **no lo contradice pero lo precisa**: la asimetría
   por rotación (hallazgo 1) implica que un modelo estático simétrico de los
   dos ECM es correcto solo en reposo frontal.

---

## Ya cubierto (no re-minar)

- Los huesos del cráneo no se mueven; error de novato levantar la órbita (p118 §06).
- Mitad superior de la cabeza definida por el cráneo aun en gente corpulenta (p118 §06).
- Globo ocular como pieza separada; párpado superior hace casi todo el cierre (p117 §02, p119 §09).
- Pivote de mandíbula delante de la oreja bajo el arco cigomático (p121 fig.12).
- Orejas suben ligeramente al sonreír (p120 fig.10) — sigue siendo la única mención de oreja.
- Pliegue nasolabial permanente desde los 30s; pliegues perpendiculares al músculo (p118 §07).
- Braquiorradial gira del exterior del codo a la base del pulgar (p125 fig.09).
- Epicóndilos alineados con el codo con brazo recto; forman triángulo al flexionar (p125 §08).
- Trocánter mayor como landmark de cadera (p132 §01, p134 §04).
- Piel: pliegues donde el tejido está flojo (transversal a todo el capítulo).

---

## Números duros

Todo lo explícitamente numérico del capítulo. **Es poco — ver Vacíos.**

| Medida | Valor | Página | Uso en el rig |
|---|---|---|---|
| Rotación de clavícula al encoger hombros | hasta **~45°** | p124 §07 | `clavicleTilt` — receta del enano |
| Rotación de clavícula al protraer hombros | **más allá de la horizontal** (sin cifra) | p124 §05 | límite superior de `clavicleProtract` |
| Escápula inmóvil en el arco inicial del brazo | primeros **~30°** | p123 §02 | clamp de rig de brazo |
| Ratio escapulohumeral pasados 30° | **2:1** (húmero : escápula) | p123 §02 | fórmula de rotación de brazo |
| Rango lateral de muñeca | **< 90°** total | p126 §11 | clamp de IK de muñeca |
| Rango flexión/extensión de muñeca | **algo más de 180°** total | p126 §11 | clamp de IK de muñeca |
| Proporción de pulgar que es palma | **~1/2** | p126 §10 | origen del pulgar a media palma |
| Aparición del pliegue nasolabial permanente | **~30 años** | p118 §07 | envejecimiento de NPCs |
| Alcance de arrugas de sonrisa | hasta **media distancia a la oreja** | p120 | máscara de arrugas |
| Ángulo de pierna analizado (poses) | **90°** y **140°** | p133 §02–03 | ROM de cadera |
| Ángulo umbral de "articulaciones complejas" | **>100°** de rotación | p131 §07 | umbral para corrección de volumen |
| Pivote de rotación de la cabeza | base del cráneo, **bajo las orejas** | p117 §03 | posición del pivote (no fracción) |
| Pivote de la mandíbula | delante de la oreja, bajo el arco cigomático | p121 fig.12 | posición del pivote (no fracción) |
| Ball-and-socket de la cadera | **ligeramente arriba** del trocánter mayor | p132 §01 | offset del pivote de pierna |
| Línea de balance | recta vertical por **cabeza–caderas–pie de carga** | p131 §08 | test automatizable de pose |

---

## Vacíos — lo que el capítulo NO contesta

Esto es lo más importante del reporte, porque el encargo pedía fracciones de
la altura de la cabeza y **el capítulo no da ni una**.

1. **Cero proporciones faciales en fracciones de altura de cabeza.** Ni ancho
   de mandíbula, ni altura del mentón, ni posición del pómulo, ni longitud de
   nariz, ni separación ocular, ni altura de la línea de ojos. Las únicas
   proporciones faciales del libro están en el capítulo anterior
   ("3D male — Part 01 | Basic form" §10–11), ya minado. **Este capítulo es de
   posado y expresión, no de proporción.** Si el rig necesita números de cara,
   no salen de aquí.

2. **Nada sobre mandíbula ancha vs. fina como eje anatómico.** El libro no
   compara fenotipos. Lo único cercano es el señalamiento (del otro capítulo)
   de que la mandíbula masculina tiene cambios de plano más marcados. **El eje
   enano↔elfo no tiene respaldo numérico en este libro.** Lo más útil que sí
   aporta es estructural, no métrico: el arco cigomático como puente
   pómulo→oreja y el pivote mandibular colgando de él (hallazgo 13) — una
   mandíbula "ancha" es un arco cigomático más ancho y más bajo, no un cubo
   más grande. Pero eso es inferencia mía, no del libro.

3. **Nada de proporción de cuello:** ni longitud, ni diámetro, ni relación
   con el ancho de la cabeza. Solo descripción de masas y de deformación.
   El "cuello largo" de Valen no tiene número aquí.

4. **Nada de estructura de oreja.** Confirmado por segunda vez: el libro no
   tiene sección de oreja. Buscar en otra fuente.

5. **Nada de pelo.** Todos los sujetos son calvos, deliberadamente. El defecto
   "pelo como casco duro" no se resuelve con este capítulo.

6. **Nada de rangos raciales / no humanos.** El libro es estrictamente
   humano-idealizado. Enano 4.5 cabezas y elfo 8 cabezas están fuera de su
   alcance; no valida ni invalida esas proporciones.

7. **Nada de conteo de cabezas.** Ni una sola vez se menciona la altura total
   en cabezas en las 20 páginas.

8. **Nada sobre ojos almendrados / tilt ocular.** Solo mecánica del globo.
