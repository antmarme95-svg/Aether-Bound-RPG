# Minado — "Sculpting an archetypal figure: 3D male" (Nagulov), pp.92-115

Fuente: copia personal del director, NUNCA copiada al repo. Todo abajo es
síntesis propia; cero transcripción, cero descripción reconstructiva de imagen.
Cotejado contra `Aether Bound/10-Knowledge/Principios de Anatomía 3D.md`.

El capítulo son 3 partes: **Part 01 Basic form** (pp.94-101, 20 secciones),
**Part 02 Muscles** (pp.102-109, 20 secciones), **Part 03 Skin** (pp.110-115,
8 secciones). La pasada previa del vault minó §06-11 y §14-15 de la Part 01 y
casi nada de Part 02/03 — ahí está el grueso de lo nuevo.

---

## Hallazgos nuevos

### A. Orden de construcción (el orden de código que faltaba)

**A1 — El orden real del capítulo es torso-primero, y es explícito y numerado**
(pp.95-100, §03→§20). Secuencia literal del proceso: (1) torso desde una caja;
(2) caja torácica + pelvis dentro de esa caja; (3) extrusión del cuello hacia
arriba desde el tope del torso; (4) landmarks óseos del torso, deliberadamente
**exagerados** en esta etapa; (5) músculo primario del torso; (6) brazos;
(7) piernas; (8) cabeza; (9) refinar cabeza; (10) manos; (11) pies;
(12) pasadas de overview por región; (13) **chequeo final de proporciones y
re-escalado de piezas**.
→ Rig: es literalmente el orden de las llamadas de `_build()`. Lo importante
para nosotros es lo que hoy no se cumple: **el cuello se construye en el paso 3,
antes de la cabeza y antes de los brazos**, no como pieza de relleno al final.
→ Pega a los tres, es el esqueleto del código.

**A2 — Los landmarks se exageran primero y se atenúan después** (p.95 §04,
p.102 intro: la escultura tiene "calidad écorché" intencional a mitad de
proceso). El detalle se atempera en pasadas posteriores, nunca al revés.
→ Rig: da licencia explícita para un parámetro global tipo `landmark_gain` que
arranque alto durante el tuning visual y se baje al final, en vez de buscar el
valor final de una.
→ Darro (silueta que necesita landmarks legibles a baja escala).

**A3 — Chequeo de proporciones al final, moviendo/escalando piezas enteras**
(p.100 §20, p.115 §08). El autor descubre que sus brazos quedaron largos, las
rodillas altas y la cabeza grande, y lo arregla escalando componentes, no
re-esculpiendo. Textual sobre por qué es barato: la escultura sigue en partes
separadas.
→ Rig: esto es exactamente el modelo procedural. Justifica exponer escalas por
componente (`head_scale`, `arm_len`, `knee_y`) como paso final independiente
del bloqueo. Y confirma que la cabeza es la pieza que uno tiende a hacer
demasiado grande.
→ Valen (8 cabezas es justo el ideal contra el que el autor corrige).

**A4 — "Rotar y ajustar constantemente: lo que se ve bien desde un ángulo deja
de verse bien a 30° de rotación"** (p.97 §08). Advertencia dura y específica
con número.
→ Rig: el QA de render no puede ser una sola vista frontal contra lámina.
Mínimo front / 30° / perfil por iteración.

---

### B. Torso, caja torácica y pelvis (defecto #1)

**B1 — El bloque de partida del torso es una CAJA, no un cilindro** (p.95 §03).
La razón dada es que la caja aporta **lados definidos** que mantienen ordenados
los muchos cambios de plano del cuerpo; las esquinas se rebajan de inmediato.
→ Rig: el volumen madre del torso debe ser un `BoxMesh` achatado en Z con
ancho ≠ profundidad, no una esfera/cilindro. Esto ataca directo el "torso bola":
una bola no tiene lados, por lo tanto no puede tener un frente ancho y un
costado angosto.
→ Roen primero, los tres después.

**B2 — La cresta ilíaca es un CUENCO en el que se sienta el abdomen** (p.95 §04)
y el borde inferior de la caja torácica marca el **tope** del abdomen. Es decir
el abdomen es una masa propia, alojada entre dos bordes óseos.
→ Rig: tercera masa entre tórax y pelvis, con radio menor que ambos por
construcción — la "cintura" deja de ser un lerp y pasa a ser un componente con
tope y piso definidos por los otros dos.

**B3 — La forma triangular del torso masculino la produce el LATISSIMUS DORSI,
no el hueso ni la caja torácica** (p.96 §05). Los dorsales son "enormes" y
envuelven buena parte del torso antes de desaparecer hacia arriba dentro de la
axila (p.105 §07).
→ Rig: el V-taper no se consigue estirando el tórax en X. Se consigue con **una
masa dorsal añadida** que nace ancha arriba (bajo la axila) y converge a la
cintura, envolviendo el tórax por los flancos. Esta es la pieza que hoy falta y
que hace que el torso lea como bola: no hay nada que tape los flancos.
→ Roen y Darro (Darro exagerado: es lo que produce el trapecio).

**B4 — Los pectorales cuelgan de las clavículas, drapean sobre la caja torácica
y se meten POR DEBAJO de los deltoides** (p.96 §05). Forma general: pentágono
(p.103 §03). Se dividen en tres grupos según dónde se anclan al esqueleto —
superior sobre las clavículas, medio al esternón, inferior fino al cartílago —
y **los tres convergen y se retuercen bajo la axila**. Advertencia: no
sobre-modelar las divisiones o el pecho lee permanentemente tenso. Los pezones
apuntan ligeramente hacia afuera, no al frente.
→ Rig: el pecho es una placa pentagonal montada SOBRE el tórax y METIDA bajo el
deltoides — no un abultamiento del propio tórax. El orden de solape importa:
pecho por debajo de hombro.

**B5 — Los oblicuos desbordan por encima del borde de la cresta ilíaca**
(p.105 §07) y son los músculos más prominentes del costado del torso.
→ Rig: la transición cintura→pelvis no es un taper limpio; hay una masa que
monta sobre el borde pélvico. Nuevamente: solape, no blend.

**B6 — En el bloqueo, el surco de la columna se talla profundo** (p.95 §04) y
más adelante se flanquea con las dos columnas gruesas del erector spinae
(p.100 §19). En mujeres el ángulo es más suave por menos músculo.
→ Rig: la espalda necesita canal central + dos cilindros verticales paralelos
a él. Bajo Sobel, el canal es lo que separa las mitades.

**B7 — El abdomen es el primer lugar donde romper la simetría** (p.104 §06):
los cuadrados del six-pack están notoriamente desalineados en la mayoría de la
gente, y las divisiones horizontales varían de paralelas a radiadas.
→ Rig: si alguna vez se tallan abdominales, hay que sembrar jitter por fila.

---

### C. Cintura escapular, hombro y unión brazo-torso (defecto #2 y #3)

**C1 — El pasaje clave del capítulo entero para nuestro bug** (p.103 §04): los
hombros deben resolverse bien "no sólo para el torso, sino para **enganchar los
brazos correctamente**" — los brazos **se encajan por debajo** de los
deltoides, y los músculos del pecho y de la espalda hacen lo mismo. Y una regla
diagnóstica textual: si las formas no calzan, **hay un problema estructural**,
no cosmético.
→ Rig: el deltoides debe ser la pieza PADRE que cubre el extremo proximal del
cilindro del brazo, del pectoral y del dorsal. Hoy el brazo nace afuera y la
hombrera flota; la topología correcta es: brazo entra dentro del deltoides, el
deltoides monta sobre el acromion, el acromion es parte del torso.
→ Los tres, pero es el fix crítico de Darro (hombros que se tragan el cuello).

**C2 — Números de anclaje del deltoides** (p.103 §04): el hombro envuelve el
acromion, descrito como una placa ósea **rectangular y plana**. Al frente, el
deltoides ocupa el **último tercio de la clavícula**; atrás se ancla a la
escápula. El deltoides se une a la escápula por un **tendón**, razón por la
cual esa zona lee más plana justo sobre el hueso.
→ Rig: `SHOULDER_X` deja de ser un número libre — el centro del deltoides cae
en el tercio distal de la clavícula. La cara posterior del deltoides es plana
(caja), no esférica. Un ball joint puro nunca dará esa faceta plana: ahí está
la mitad del problema del hombro de 3 DOF.

**C3 — El hueco triangular de la clavícula** (p.103 §04): hay un espacio vacío
donde el pecho y el hombro se encuentran, y ese vacío produce un **hueco
triangular** característico en la clavícula. No es un artefacto: es un rasgo
que debe existir.
→ Rig: la costura pecho-hombro debe dejar una depresión real (escalón de
profundidad → el Sobel la entinta). Si hoy se cierra con blend, se pierde el
único marcador que dice "el brazo está pegado al torso".

**C4 — Cada escápula ocupa aproximadamente UN TERCIO del ancho de la espalda**
(p.95 §04) — número duro que el vault no tenía.
→ Rig: dos placas de ancho = 1/3 del ancho torácico cada una, dejando ~1/3 al
canal central. Se ubican en el bloqueo, antes que cualquier músculo.

**C5 — Escápula y cresta ilíaca son los dos puntos de anclaje de casi toda la
espalda** (p.105 §08). Los romboides sólo asoman por los bordes del trapecio; el
teres major sale del extremo de la escápula y se hunde bajo la axila. En gente
musculosa la escápula no se ve como placa sino que se define por los **surcos
entre músculos** que la rodean.
→ Rig: la escápula no necesita ser una pieza visible. Necesita que las piezas
vecinas dejen surcos alrededor de su contorno. Para cel-shading esto es mejor
noticia que modelar el hueso.

**C6 — El trapecio se extiende POR ENCIMA de las escápulas, se sienta sobre los
hombros y se afina hacia el cuello** (p.96 §05).
→ Rig: masa puente hombro→cuello, con taper hacia arriba. Es la pieza que
convierte "cabeza sobre un bloque" en "cuello que nace de los hombros". Para
Darro se exagera hasta tragarse el cuello; para Valen se adelgaza casi a nada.

---

### D. Cuello (defecto #4)

**D1 — El cuello se EXTRUYE hacia arriba desde el tope del torso, y al hacerlo
aparece la curva-S perezosa de la columna** (p.95 §03). Es el paso 3 del
proceso, dentro del bloqueo del torso, antes de la cabeza.
→ Rig: el cuello es un componente del TORSO, no de la cabeza. Y no es vertical:
nace inclinado hacia adelante y la cabeza se apoya sobre él con contra-
inclinación. Un cilindro vertical entre dos piezas nunca va a leer como cuello.

**D2 — Anatomía del ECM, con un error común nombrado** (p.104 §05): se ancla en
un solo punto del cráneo **detrás de la oreja** y se **ramifica en dos** hacia
abajo. Una rama va a la clavícula; la principal se convierte en tendón y se
hunde en el **hoyuelo entre las clavículas** — y el libro señala explícitamente
que el error frecuente es llevarla a los extremos claviculares. El trapecio
cierra la parte de atrás.
→ Rig: dos tirantes finos desde detrás de la oreja convergiendo al centro de la
muesca yugular + trapecio detrás = el cuello queda cerrado por delante y por
detrás, y aparece la muesca. Es geometría barata y de altísimo retorno.

**D3 — La manzana de Adán es mucho más prominente en hombres** (p.99 §16,
p.104 §05).
→ Rig: pieza chica frontal en el cuello. Marcador de género/raza barato: alta
en Darro, apenas insinuada en Valen.

**D4 — El cuello es un caso de "casi todo invisible en reposo"** (p.104 §05):
mucha estructura debajo, casi nada en superficie.
→ Rig: no tallar tendones. Sólo ECM + trapecio + laringe.

---

### E. Cabeza y cara (números nuevos)

**E1 — El punto más alto del cráneo está aproximadamente a 2/3 del camino hacia
atrás, y ahí también es el más ancho** (p.99 §16). Error común nombrado: hacer
el cráneo demasiado redondo — hay cambios de ángulo sutiles pero definidos de
frente y de perfil. La línea temporal marca los bordes de la frente. Hay un
bultito distintivo en la base del cráneo (occipital).
→ Rig: la esfera craneal necesita desplazar su máximo a 2/3 posteriores y
achatarse por los lados en la línea temporal. Directamente atacable con una
esfera escalada + offset, sin geometría nueva.

**E2 — Proporciones faciales relativas** (p.108 §17): la nariz ocupa
**alrededor de 1/3 de la cara en vertical**; los labios son tan anchos como los
**centros de los ojos**; las orejas se extienden **desde la esquina del ojo
hasta la base de la nariz**. Tip de verificación: mirar la escultura **desde
abajo** para chequear curvatura de frente y si los labios envuelven los dientes.
→ Rig: tres restricciones duras que hoy no están parametrizadas. La de la oreja
es la más barata: `ear_top = eye_y`, `ear_bottom = nose_base_y`.

**E3 — Rasgos masculinos de la zona frontal** (p.108 §18): la zona de la ceja es
más rugosa en hombres, con **glabela prominente**, y los ojos se ubican **más
hundidos y más cerca de la ceja**. La boca tiene dos nódulos prominentes en las
comisuras y otro bajo el labio inferior; debe leer carnosa, no tallada. El
filtrum es más largo en hombres.
→ Rig: `browRidge` y profundidad de ojo son parámetros de sexo/raza, no sólo de
individuo. Encaja con la "frente pesada" enana ya especificada en el vault y
sin implementar.

**E4 — SÍ hay una sección dedicada a la oreja** (p.109 §19): el hélix es la
espiral grande que describe toda la oreja y fluye hacia la concavidad central;
el antihélix se pega al hélix, ocupa la mayor parte del interior y tiene forma
de **"Y" curva**; el trago es una pequeña **placa** de cartílago que tapa el
orificio; ambos terminan abajo en el lóbulo carnoso. Mucha gente tiene un bulto
en el **tercio superior** del hélix, y eso es lo que da carácter a la oreja.
→ Rig: la oreja no es una esfera. Es anillo exterior (toro/loft) + "Y" interior
+ placa (caja chica) + lóbulo. Y el bulto del tercio superior es un parámetro de
personaje, candidato natural para diferenciar la oreja élfica de Valen más allá
de alargarla.

---

### F. Extremidades — datos nuevos con número

**F1 — Las piernas ocupan la MITAD de la altura total** (p.96, pie de fig.08),
señalado como zona que los principiantes descuidan; en la misma figura el autor
marca su propia rodilla como "demasiado baja" y la corrige.
→ Rig: `leg_len = 0.5 * height` como invariante, y `knee_y` como parámetro
separado y sospechoso por default. Para Darro (4.5 cabezas) esta regla es lo
primero que se rompe deliberadamente — el enano tiene piernas por debajo del
50%; conviene expresarlo como desviación explícita de la regla, no como número
suelto.

**F2 — El pulgar se angula ~40° respecto al resto de la mano, y su primer
nudillo llega aproximadamente a la articulación inferior del índice**
(p.107 §15). Número duro que el vault no tenía (el vault tiene la regla de
Zambelli sobre falanges, que es otra).
→ Rig: `thumb_yaw = 40°`, `thumb_reach = index_MCP`.

**F3 — Puntas y nudillos describen ARCOS, nunca líneas paralelas; y la mano
vista de frente tiene una curva suave general** (p.107 §15). Extiende la regla
de convergencia que el vault ya tiene: no es sólo que los dedos convergen, es
que **las líneas de puntas y de nudillos son arcos**.
→ Rig: dos arcos como curvas de control, no dos rectas con offsets.

**F4 — Manos y pies deben colocarse TEMPRANO aunque se detallen tarde**
(p.98 §12, §14): un stand-in de mano ayuda a entender la muñeca y a juzgar
proporciones globales; lo mismo el pie para juzgar la pierna. Error común
explícito: **hacer la mano demasiado pequeña**.
→ Rig: proxies de mano/pie desde el primer bloqueo. Relevante para Darro, cuyo
canon pide manos enormes: el libro dice que el sesgo natural es al revés.

**F5 — Asimetrías verticales con dirección explícita** (p.106 §12): la cabeza
externa del gastrocnemio se sienta **más alta** que la interna; en los tobillos
es al **revés**, el interno más alto. Y (p.107 §13) la cabeza lateral del
tríceps se sienta más alta que la medial y la larga.
→ Rig: tres pares donde el offset vertical izquierda/derecha del par es un
número con signo conocido. Barato, y mata el look de "cilindros simétricos".

**F6 — La tibialis anterior toma la silueta del lado externo de la pantorrilla,
no el hueso** (p.106 §12). Contraintuitivo y nombrado como tal.
→ Rig: el perfil externo de la pantorrilla lo define una masa muscular
desplazada, no el eje del cilindro.

**F7 — El brazo superior es simple: bíceps al frente, tríceps atrás, y punto**
(p.100 §17). El antebrazo, en cambio, se descompone en tres: extensores afuera,
flexores adentro, y el braquiorradial que envuelve el radio y **trepa bastante
hacia el brazo superior** (p.107 §14). La ulna conecta codo y muñeca y termina
en el proceso estiloides; **la ulna misma no es del todo recta**.
→ Rig: antebrazo = 3 masas con una que invade el brazo superior (explica por
qué el codo lee como articulación y no como junta). Bíceps casi recto de perfil,
curvándose sólo cerca del extremo (p.107 §13).

**F8 — El pie** (p.108 §16): el meñique fluye a la planta **casi sin cambio de
ángulo**; los tres dedos medios comparten apariencia y sólo varían en tamaño; el
**segundo dedo suele ser el más largo**; la forma más grande del pie es el talón,
que se afina hacia el tendón de Aquiles.
→ Rig: dedos del pie = un prefab escalado ×3 + dos casos especiales (gordo,
meñique). El talón es la primitiva dominante, no la planta.

---

### G. Reglas de estilo con impacto en cel-shading

**G1 — "La naturaleza aborrece las líneas paralelas": prácticamente ninguna
línea del cuerpo corre recta ni paralela a otra por un tramo largo; pensar en
formas en S y curvas contrastantes** (p.112 §03). El vault tiene esta regla
**sólo para pelo**. El capítulo la enuncia para el cuerpo entero, y agrega el
corolario: **espaciados uniformes** entre pliegues/surcos son un error clásico.
→ Rig: aplica a costillas, abdominales, mechones, correas de armadura, dedos.
Cualquier repetición procedural necesita jitter de espaciado y de ángulo.

**G2 — Line weight / variación de nitidez** (p.112 §03): la razón dada de que
la escultura leyera rígida es la **uniformidad del detalle** — cada forma
recibió la misma atención. En la realidad la nitidez varía mucho incluso dentro
de una misma zona: algunos surcos empiezan profundos y se hacen someros; una
forma puede leer dura en un punto y blanda en otro (la rodilla es el ejemplo
dado).
→ Rig: bajo Sobel esto se traduce a **profundidad variable de la costura a lo
largo de la costura**. Una costura de profundidad constante da una línea de
grosor constante = look de dibujo técnico. Es probablemente el hallazgo más
transferible de la Part 03 entera a nuestro pipeline.

**G3 — Alternar zonas planas con zonas detalladas** (p.111 §02) es lo que
vende la escultura; el brazo se cita como ejemplo natural de eso.
→ Rig: presupuesto de detalle desigual por región, deliberado.

**G4 — La grasa importa incluso en cuerpos atléticos** (p.112 §04, p.106 §10):
advertencia doble de no vaciar de grasa el glúteo ni la zona sobre la rótula.
Un físico sin grasa lee antinatural aunque la anatomía sea correcta. La grasa
tiende a suavizar y a esconder músculo.
→ Rig: Darro "build más liviano" no significa definición seca; significa masa
menor con superficie igual de blanda.

**G5 — Chequear formas moviendo la LUZ** (p.114 §07, p.115): esculpir con una
sola luz esconde defectos por mucho tiempo; también sirve subir la
especularidad, porque las superficies brillantes leen mucho mejor que las mates.
→ Rig: el QA de render debe incluir al menos una pasada con luz rotada y otra
con material brillante, no sólo el material cel final.

**G6 — Retopologizar / reposar antes de detallar para evitar que las partes se
FUSIONEN** (p.102 §01). Aunque es específico de ZBrush, el motivo es nuestro
problema exacto.
→ Rig: separación mínima entre masas vecinas como invariante verificable.

---

## Contradice al vault

1. **Primitiva de arranque del torso.** Vault, línea 27: "Cilindro → … y la
   caja torácica en su forma más simple ('bullet' o 'birdcage': cilindro
   redondeado, **no caja recta**)". El capítulo (p.95 §03) arranca el torso
   **desde una caja**, justificándolo por los lados definidos, y sólo después
   rebaja las esquinas para llegar al huevo torácico. No es contradicción de
   forma final (el huevo sigue siendo el destino) sino de **método y de orden**:
   el vault prohíbe la caja donde el libro la prescribe como punto de partida.
   Para un rig procedural, donde el "rebajado" no existe, la resolución práctica
   es: **caja escalada como volumen madre (X≠Z), huevo como acabado**, no
   cilindro de revolución — un cilindro no puede dar frente ancho y costado
   angosto, que es exactamente el defecto "torso bola".

2. **Mandíbula masculina.** Vault, línea 283-284: "**La mandíbula masculina es
   más angular, con cambios de plano más marcados que la femenina** — coherente
   con la elección ya hecha en código de esfera+ángulo goníaco". El capítulo
   (p.108 §17) advierte lo contrario en la práctica: la línea de la mandíbula es
   **bastante suave**, y un **error común es hacerla demasiado prominente o
   angular**. Ambas frases salen del mismo autor en el mismo capítulo (§10 vs
   §17), así que la lectura correcta no es "el vault se equivocó" sino que el
   vault se quedó con la mitad de la regla: *más angular que la femenina, pero
   la línea sigue siendo suave*. **Esto pega directo al defecto reportado de
   "mandíbula = cubo suelto"**: el cubo es la sobre-corrección exacta que el
   libro nombra.

3. **Oreja.** Vault, líneas 325-332: "**Oreja — única mención encontrada,
   tangencial:** el libro NO tiene una sección dedicada a proporción/estructura
   de oreja… para proporción/estructura de oreja en reposo, este libro no aporta
   nada más allá del principio general esfera-vs-caja". **Falso.** p.109 §19
   "Constructing the ear" es una sección completa con hélix / antihélix en "Y" /
   trago como placa / lóbulo, más el bulto del tercio superior. Y p.108 §17 da
   la proporción que faltaba: la oreja va del **rabillo del ojo a la base de la
   nariz**. La conclusión del vault de que la oreja es "masa redondeada tipo
   bola-cuenco → esfera" queda desmentida por su propia fuente.

4. **Alcance del anti-paralelismo.** El vault lo trata como regla de pelo
   (líneas 154-157, 199-201). p.112 §03 lo enuncia como regla del cuerpo
   entero. No es contradicción, es una sub-generalización que conviene corregir
   en el doc.

---

## Ya cubierto

- Caja torácica 2/3 del torso / pelvis 1/3 en caja inclinada hacia atrás (p.95) — igual que el vault, línea 48-51.
- Clavícula en "S" (p.95 §04) — ya está, línea 80.
- Deltoides que cubre el brazo superior y lo hace ver corto (p.99 §17) — ya está, línea 392.
- Bloqueo de brazos gestual, quiebre de codo, epicóndilo medial alineado con el codo (p.96 §06) — ya está, líneas 385-395.
- Sartorio como cinturón, glúteo como frijol, trocánter invisible salvo contrapposto, curva-S de la pierna de perfil (p.97 §08-09) — ya está, líneas 350-359.
- Pie ≈ largo del antebrazo; primer metatarsiano como vara; dedos con ángulo agudo salvo el gordo; bulto del meñique (pp.98-99 §14-15) — ya está, líneas 361-369.
- Cráneo como huevo/caja de lado con la cara colgando; cuello temprano; ECM en diagonal opuesta (p.97 §10) — ya está, líneas 275-284.
- Ojos a la mitad de la cara, separados por un ancho de ojo, oreja a media cabeza de perfil, frente como arreglo complejo de planos, boca al final (p.97 §11) — ya está, líneas 286-295.
- Dedos con planos, no cilindros lisos; palma como caja; no hacer los dedos rectos (p.98 §12-13) — ya está, líneas 100-137.
- Pliegues permanentes en codo, rodilla, muñeca, ingle/axila (p.111 §02) — ya está, líneas 404-415.
- 7ª cervical como landmark de la base del cuello (p.100 §19) — ya está, línea 76.
- Romper la simetría / cara asimétrica (p.114 §06) — ya está como "ruido para este proyecto", línea 456.
- ASIS, xifoides, borde de la 10ª costilla, ángulo inferior de la escápula (p.95 §04) — ya está, líneas 73-77.

---

## Números duros

Toda proporción, fracción o medida que el capítulo da **explícitamente**.

| # | Medida | Valor | Página / § | Uso en el rig |
|---|---|---|---|---|
| 1 | Caja torácica dentro del torso | 2/3 de la altura del torso | p.95 §03 | ya en vault |
| 2 | Pelvis dentro del torso | 1/3 inferior | p.95 §03 | ya en vault |
| 3 | Ancho de cada escápula | ≈1/3 del ancho de la espalda | p.95 §04 | **nuevo** — deja ~1/3 al canal central |
| 4 | Anclaje frontal del deltoides sobre la clavícula | último **1/3** distal | p.103 §04 | **nuevo** — fija `SHOULDER_X` |
| 5 | Piernas respecto a la altura total | **1/2** | p.96 fig.08 | **nuevo** — invariante; Darro se desvía por debajo |
| 6 | Ideal heroico de altura | **8 cabezas** | p.100 §20 | Valen exactamente; Roen 7.5 |
| 7 | Punto más alto (y más ancho) del cráneo | ≈**2/3** hacia atrás | p.99 §16 | **nuevo** — offset de la esfera craneal |
| 8 | Nariz en vertical | ≈**1/3** de la cara | p.108 §17 | **nuevo** |
| 9 | Ancho de los labios | = distancia entre los **centros de los ojos** | p.108 §17 | **nuevo** |
| 10 | Extensión vertical de la oreja | del **rabillo del ojo** a la **base de la nariz** | p.108 §17 | **nuevo** — `ear_top`/`ear_bottom` |
| 11 | Ángulo del pulgar | ≈**40°** respecto al resto de la mano | p.107 §15 | **nuevo** |
| 12 | Alcance del primer nudillo del pulgar | ≈ articulación inferior del **índice** | p.107 §15 | **nuevo** |
| 13 | Rotación mínima de chequeo | **30°** (a 30° se cae lo que se veía bien) | p.97 §08 | **nuevo** — protocolo de QA de render |
| 14 | Ojos en la cara | a **media** altura de la cara | p.97 §11 | ya en vault |
| 15 | Separación de ojos | **un ancho de ojo** | p.97 §11 | ya en vault |
| 16 | Oreja de perfil | a **media** cabeza | p.97 §11 | ya en vault |
| 17 | Pie | ≈ largo del **antebrazo** | p.98 §14 | ya en vault |
| 18 | Grupos del pectoral | **3** (clavicular / esternal / cartilaginoso) | p.103 §03 | **nuevo** |
| 19 | Componentes del antebrazo | **3** (extensores / flexores / braquiorradial) | p.107 §14 | **nuevo** |
| 20 | Ramas del ECM | **2** desde un único anclaje craneal | p.104 §05 | **nuevo** |
| 21 | Interdigitaciones visibles del serrato | **3** | p.105 §07 | menor |
| 22 | Dedo del pie más largo | el **segundo**, habitualmente | p.108 §16 | **nuevo** |
| 23 | Cabeza lateral del gastrocnemio | **más alta** que la medial | p.106 §12 | **nuevo** (signo, no magnitud) |
| 24 | Maléolo interno | **más alto** que el externo | p.106 §12 | **nuevo** (signo) |
| 25 | Cabeza lateral del tríceps | **más alta** que medial y larga | p.107 §13 | **nuevo** (signo) |

*(Nota: los conteos de polígonos y decimaciones que aparecen en pp.111 y 115 son
específicos de ZBrush/3ds Max y no se transfieren; se omiten a propósito.)*

---

## Vacíos

Preguntas del encargo que este capítulo **no** contesta. No se inventaron
números para taparlas.

1. **Ancho del pecho en cabezas.** El capítulo no da NINGUNA medida horizontal
   absoluta: ni ancho de hombros, ni ancho de pecho, ni ancho de cadera, ni
   ratio hombro:cadera. Todo el V-taper se describe cualitativamente ("los
   dorsales dan la forma triangular"). El defecto #1 —"el torso lee más ancho
   que los hombros"— **no se puede cerrar con números de este capítulo**; hay
   que medirlo en la lámina canónica, como ya estaba planeado. El capítulo de
   proporciones que precede a éste (pp.<92) es el candidato obvio para esos
   números y no estaba en el lote.
2. **Altura a la que cae el punto más ancho del tronco.** No se da. Sólo el dato
   análogo para el cráneo (2/3 hacia atrás).
3. **Largo del cuello.** Ninguna medida — ni en cabezas, ni en fracción de
   altura, ni en ángulo de inclinación. Se dice que se extruye y que se apoya en
   ángulo contra el cráneo, sin número. Crítico para Valen (cuello largo) y
   Darro (cuello tragado): esos valores hay que sacarlos de la lámina.
4. **Proporciones no humanas.** Cero contenido sobre enanos, elfos o cualquier
   desviación estilizada. Todo asume la figura masculina humana atlética. Las
   traducciones a Darro y Valen de arriba son inferencias mías, no del libro.
5. **Ancho de hombros del enano / caída de hombros del elfo.** Ídem, nada.
6. **Cinemática y DOF.** El capítulo es de escultura estática en T-pose. No dice
   nada sobre articulación, ROM ni grados de libertad — no aporta a la duda
   abierta de Toño sobre DOF ni al modelo de hombro de 3 DOF. La única señal
   indirecta es C2: la cara posterior plana del deltoides sobre el acromion es
   incompatible con un ball joint puro.
7. **Ángulo de inclinación de la pelvis.** Se dice "ligero ángulo hacia atrás"
   (p.95 §03) sin grados.
8. **Profundidad (eje Z) de cualquier masa.** El capítulo trabaja frente/perfil
   descriptivamente; no da ninguna relación ancho:profundidad, ni para el tórax
   ni para la pelvis ni para la cabeza. Para un rig de primitivas esto es una
   ausencia grande: sabemos que la caja debe tener X≠Z, no cuánto.
9. **Umbral de "se funde vs. borde duro".** El libro trabaja en malla continua
   con blending manual; no da ninguna regla objetiva de cuándo dos masas deben
   mantener costura visible y cuándo fundirse. Lo más cercano es C3 (el hueco
   triangular de la clavícula debe existir) y G2 (la nitidez debe variar). El
   criterio operativo sigue siendo nuestro, el del Sobel.
