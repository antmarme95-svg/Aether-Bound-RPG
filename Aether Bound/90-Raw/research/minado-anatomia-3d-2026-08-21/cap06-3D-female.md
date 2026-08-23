# Minado — "Sculpting an archetypal figure: 3D female" (Mario Anger, 3 partes, pp.136-159)

> Síntesis propia. No hay transcripción de texto ni reproducción de imágenes del
> libro. Copia personal del director; nada se copió al repo.

Contexto de lectura: el capítulo son 3 partes de un mismo autor — Part 01 Basic
form (136-145), Part 02 Muscles (146-151), Part 03 Body fat and skin (152-159).
El foco pedido (diferencial vs. el masculino) está concentrado en Part 01 §07,
§13-15 y en Part 03 §01-03. Part 02 es casi íntegramente catálogo muscular
neutro al sexo y aporta poco al diferencial, pero sí aporta lo de cuello.

---

## Diferencial vs. la construcción masculina

| Rasgo | Cómo cambia en la construcción femenina | Número / razón que da el libro | Pág. |
|---|---|---|---|
| Punto más ancho del cuerpo | Se **traslada de los hombros a las caderas**. En el masculino el ancho máximo es el hombro; aquí el ancho máximo es la cadera. | Cualitativo pero categórico: la cadera es el punto más ancho de la figura femenina. Es un **cambio de topología de la silueta**, no un ajuste de grado. | 141 (§14) |
| Separación de hombros | Menor que en el masculino. | **≈ 2 cabezas entre hombro y hombro**; el libro dice explícitamente que es menos que en el cuerpo masculino. | 141 (§14) |
| Causa de esa reducción | No es el hombro: es la **caja torácica más chica**. La cintura escapular hereda el ancho de la caja sobre la que se apoya. | Atribución causal explícita: hombros más juntos *por* la caja torácica menor. | 141 (§14) |
| Ancho de cadera | Sube por dos vías sumadas: hueso pélvico + **pad de grasa**. | El libro separa las dos contribuciones: "la grasa extra que cargan las mujeres también suma al ancho". Dos términos, no uno. | 141 (§14), 152 (§02) |
| Ángulo del brazo (carrying angle) | El antebrazo se **abre hacia afuera en el codo**, y el libro lo declara consecuencia directa de la relación hombro/cadera: hombros más apretados + caderas más anchas. | Sin grados. Es el único lugar del capítulo donde un ángulo se deriva *causalmente* de la proporción torso. | 139 (§07) |
| Altura de la cintura | La línea de cintura **empieza más arriba** que en el masculino. Efecto declarado: da la ilusión de caderas más altas. | Sin fracción. Es un desplazamiento en Y del estrangulamiento, no un cambio de radio. | 153 (§03) |
| Relieve muscular | Al cerrar Part 02, se **reducen y funden** los músculos ya colocados: silueta más suave, menos voluminosa. La estructura se coloca igual y luego se aplana. | Método explícito: colocar todo el músculo y *después* atenuarlo, no omitirlo. | 151 (§20) |
| Grasa como porcentaje | La grasa es un **porcentaje mayor de la masa total**; ablanda estructura y funde partes vecinas entre sí. | El libro dice directamente que las siluetas de hombre y mujer difieren *principalmente por distribución de grasa*, no por hueso. | 152 (§01) |
| Zonas de grasa que alteran silueta | Pechos, región pélvica/glútea (pads que funden cadera→pierna), pad abdominal, alrededor de rodilla. | El pad pélvico "difumina las indicaciones del músculo de abajo" y **suaviza la masa del glúteo por abajo**. | 152 (§02), 153 (§03) |
| Pechos | Media esfera, con perfil de **lágrima**; cuelgan por gravedad. No son piezas pegadas encima del pecho — el libro lo advierte expresamente. | Sin medida. La regla dura es la de gravedad y no-adherencia. | 141 (§13) |
| Venas | Casi **invisibles** en el cuerpo femenino; solo bajo luz especial. | Contraste directo con el tratamiento masculino. | 157 (§18) |
| Marca lumbo-sacra | En la mujer la superficie sobre el sacro forma un **rombo** con dos hoyuelos (espinas ilíacas posterosuperiores). | Marcado como rasgo femenino específico. | 144 (§20c) |

---

## Lo que NO cambia — candidatos a constante en el código

Esto es la parte de mayor valor para el rig: el capítulo femenino usa
**exactamente el mismo constructor** que el masculino, en el mismo orden, con
las mismas primitivas. Lo único que se reparametriza es lo de la tabla de
arriba.

1. **Los landmarks óseos no cambian nunca.** Declaración literal del libro
   (p.142 §16): son visibles en la superficie sin importar cuánto músculo o
   grasa haya, y **rodillas y codos permanecen siempre en su posición**
   mientras el resto del cuerpo engorda o adelgaza. Traducción directa: las
   posiciones de junta del rig deben ser **fijas por altura**, y los sliders de
   peso/arquetipo deben mover *radios y pads*, nunca posiciones de junta.
2. **El inventario de primitivas es idéntico:** columna = cilindro en S; caja
   torácica = cuboide suavizado; pelvis = cuboide suavizado; cintura escapular
   = caja ancha; abdomen = cubo suavizado; miembros = cilindros; manos = dos
   cajas rectangulares; pie = cuboide alargado→cuña. Ningún sexo agrega o quita
   una primitiva estructural. La única masa **añadida** es el par de medias
   esferas del pecho.
3. **El orden de construcción es idéntico** (ver sección de orden abajo).
4. **8 cabezas de altura, brazos 3 cabezas, piernas 4 cabezas** se presentan
   como el canon idealizado *del cuerpo*, no como cifra femenina. Estas tres
   son razones, no longitudes: sobreviven intactas al reescalado por raza
   (Roen 7.5, Darro 4.5, Valen 8).
5. **Toda la anatomía de Part 02** (deltoides en 3 cabezas, trapecio, dorsal,
   erectores, cuádriceps/isquios, gemelos, manos, cuello) se describe sin una
   sola nota de sexo. Es geometría constante.
6. **La regla de rotación relativa** (§07) es del cuerpo, no del sexo: los
   segmentos se rotan *alejándose unos de otros* para que la mirada fluya —
   muslo mira al frente arriba y gira hacia la línea media abajo; rodillas
   rotadas afuera-atrás; pantorrilla repite; mano rotada en sentido opuesto al
   antebrazo. **Ninguna extremidad sale del cuerpo en ángulo recto.**
7. **Doble esfera por articulación** (p.137): cada junta se marca con *dos*
   esferas porque ahí ocurre un cambio de plano que una sola no puede dar.

---

## Ángulo y curvatura — dónde el contorno cambia de dirección

El rig lee rígido porque hace conos rectos. El capítulo señala estos quiebres,
todos aplicables:

- **Columna como cilindro en S de perfil, casi recta de frente** (p.138 §05).
  El torso se construye *sobre* esa curva. La caja torácica y la pelvis se
  colocan siguiendo la línea de la columna, no apiladas en un eje vertical.
- **Rotación en oposición caja torácica ↔ pelvis** (p.138 §06): la pelvis va
  inclinada hacia adelante y rotada hacia atrás; la caja torácica se rota **en
  oposición** a la pelvis. Este contra-giro es lo que produce la torsión de
  cintura. Es un parámetro de rotación, no de radio — y hoy el rig no lo tiene.
- **Caja torácica más angosta ARRIBA** (p.138 §06). Este es el taper que falta:
  el defecto medido ("bola más ancha que los hombros") es exactamente lo
  contrario de lo prescrito. El torso se estrecha hacia arriba, y la cintura
  escapular se monta *encima* de ese estrechamiento.
- **Margen costal como cambio de ángulo mayor** (p.153 §05): el borde inferior
  de la caja torácica es un cambio de plano fuerte, no una transición. Y el
  recto abdominal genera **sus propios planos de borde** que lo separan del
  resto del vientre.
- **Oblicuo delgado arriba, cambia de plano más abajo, hacia la cresta ilíaca**
  (p.153 §05) — el taper del torso no es lineal: es delgado arriba, se quiebra
  y se ensancha hacia la pelvis.
- **Pad abdominal**: cuando está desarrollado crea una **línea horizontal y un
  cambio de plano justo bajo el ombligo** (p.153 §03). Candidato a un pad
  paramétrico por peso.
- **Los brazos no entran rectos a las manos: cambian de ángulo en el proceso
  estiloides** (p.153 §05).
- **Curva en S del contorno del brazo/pierna**: dorsal→tendón crea un pliegue
  (p.154 §06); el sartorio cruza el muslo en curva (p.148 §10).
- **Regla de método muy útil para el pipeline**: exagerar primero los bordes y
  atenuarlos después, nunca al revés (p.153 §04). Es el mismo principio que ya
  usa el proyecto para "empezar con caja y suavizar".

---

## Orden de construcción — comparado con el masculino

**No difiere.** Lo notable es otra cosa: el capítulo ofrece **dos métodos
alternativos**, y el segundo es el que le sirve al rig procedural.

- **Método A (§01-04)**: acumular esferas (torso → cabeza/miembros → pies/manos
  → ajustar volúmenes → fundir en malla). El autor mismo lo critica: al fundir
  todo en un objeto, **ya no se puede ajustar cada parte por separado**.
- **Método B (§05-15)**: partir de **ocho cuerpos rígidos independientes** —
  cabeza, pelvis, columna, caja torácica, dos brazos, dos piernas — y unirlos
  al final. El autor lo elige "para preservar flexibilidad".
  Este es literalmente el modelo del rig de Aether Bound, con nombre.

Secuencia del método B, verbatim en estructura:
1. columna (cilindro en S)
2. pelvis (cuboide suavizado, inclinado adelante, rotado atrás)
3. caja torácica (cuboide suavizado, angosto arriba, contra-rotado)
4. **cuello (cilindro que sigue la curva S)** — antes que hombros y brazos
5. cabeza (permitida a adelantarse del cuerpo por la S del cuello)
6. miembros (cilindros, nunca perpendiculares)
7. manos, pies
8. **cintura escapular** (caja ancha sobre la caja torácica)
9. **abdomen** (cubo suavizado que rellena el hueco caja↔pelvis)
10. refinar (pechos, orejas, nariz, dedos separados)
11. verificar proporción contra el canon de 8 cabezas
12. recién ahí fundir todo

Observación de peso: **la cintura escapular y el abdomen se colocan en los pasos
8 y 9, DESPUÉS de los brazos** — son la costura, no el punto de partida.

---

## Hallazgos nuevos (con traducción a primitiva / parámetro)

**Cuello — el defecto #1 del rig**

1. *El cuello entra en el paso 4, antes que hombros y brazos, y es un cilindro
   que sigue la curva S de la columna* (p.138 §06). Efecto declarado: permite
   que la cabeza se adelante levemente del cuerpo. → **Primitiva: cilindro
   inclinado, no vertical.** Un cuello vertical produce la postura de maniquí.
   El parámetro es el ángulo de adelantamiento, y es constante entre sexos.
2. *El perfil del cuello lo dan hioides y cartílago; su forma lateral la da el
   esternocleidomastoideo, que nace en DOS puntos — clavícula y esternón — y
   termina en el mastoides* (p.150 §18, p.151 §18). → dos cintas finas en
   diagonal opuesta desde la muesca yugular hacia detrás de la oreja. Es lo
   que convierte un cilindro en un cuello.
3. *Entre el SCM y el trapecio casi ningún músculo genera forma de superficie*
   (p.151 §18). → **No hay que rellenar esa zona.** El hueco entre la diagonal
   del trapecio y la del SCM es correcto y debe leerse como hueco.
4. *El trapecio se aplana al llegar a la 7ª cervical y expone ese hueso*
   (p.147 §03). → un bulto puntual en la base de nuca; y donde el trapecio toca
   la esquina superior de la escápula deja una **muesca redonda hundida**.

**Cintura escapular y unión brazo-torso (defecto #1 y #2)**

5. *La cintura escapular es una caja ancha con roles por cara: borde frontal =
   clavículas, bordes laterales = acromion, plano trasero = escápulas. Se
   sienta justo SOBRE la caja torácica y es lo que habilita el rango del
   brazo* (p.140 §10). → confirma el candidato ya anotado en el vault, ahora
   con las tres caras asignadas explícitamente. Es una **caja separada**, no un
   ensanchamiento del torso.
6. *La cintura escapular se puede partir por la mitad para mover cada hombro de
   forma independiente* (p.141 §13). → dos medias cajas espejadas, un
   `shoulder_offset` por lado.
7. *El acromion es una meseta pequeña de forma cuadrada en lo alto del hombro*
   (p.142 §18). → caja chata, ya alineado con Lecciones.
8. *La cabeza medial del deltoides se fija AL ACROMION; la posterior nace en la
   espina de la escápula; las tres cabezas insertan a media altura del húmero,
   y hay un pequeño hueco entre deltoides y pectoral* (p.147 §05a-05b). → el
   brazo se despega porque el deltoides hoy nace del cilindro del brazo. Debe
   nacer de la **caja de la cintura escapular** y bajar hasta media altura del
   húmero. El hueco deltopectoral es geometría deseable, no un error de unión.
9. *La escápula deja siempre una línea ósea desde lo alto del hombro bajando en
   ángulo leve hacia la columna, y su borde medial cae casi recto a cada lado
   de la columna* (p.142 §18). → dos cajas planas inclinadas en la espalda.
10. *El dorsal ancho nace en la cresta ilíaca y se inserta en el húmero casi en
    el mismo punto que el redondo mayor* (p.147 §03). → el "puente" cadera→brazo
    que hoy no existe y que explica por qué la axila lee como agujero.

**Torso**

11. *El abdomen es una masa propia, blanda, que se estira y comprime — cubo
    suavizado colocado en el hueco entre las dos masas rígidas* (p.140 §11).
    → tres masas, con la de en medio explícitamente **deformable**. El rig no
    debería taperar un cilindro: debería colocar un tercer volumen.
12. *La clavícula tiene forma de arco visto de frente, con las puntas subiendo
    hacia cada hombro, y curva en S vista desde arriba* (p.143 §19). El vault
    solo tenía la S. → la curvatura es **doble**: arco en el plano frontal,
    S en el plano transversal.
13. *Manubrio y cuerpo del esternón forman un ángulo visible*: el esternón cae
    más empinado al principio y luego se suaviza (p.143 §19, p.153 §05). → un
    quiebre puntual en el centro del pecho.

**Manos y pies (para cuando toque ese frente)**

14. *Falanges: en el DORSO el primer segmento es el más largo, el segundo mide
    aproximadamente **la mitad** del primero, y la punta es el más corto. En la
    PALMA los tres son casi iguales y el conjunto es algo más corto* (p.156
    §16). Número explícito y distinto del sistema de mitades sucesivas de
    Zambelli ya en el vault.
15. *Visto de lado, los dos primeros segmentos del dedo están más o menos en
    una línea; solo el último se desplaza hacia adentro* (p.156 §16). → la
    curvatura del dedo se concentra en la punta, no se reparte.
16. *La mano nace de DOS cajas rectangulares; una se parte en cuatro para los
    dedos; la palma se curva hacia abajo; el pulgar pivota en un eje distinto y
    más alto, sobre el costado* (p.139 §08).
17. *El pie apoya solo en talón, dedos y borde exterior; dos arcos —
    antero-posterior y latero-medial* (p.139 §09, p.150 §15). *Los cuatro dedos
    chicos parecen agarrar el piso; el gordo va casi plano* (p.157 §17).
    → coincide con y precisa lo que el vault tenía del capítulo masculino.

**Cara / cabeza**

18. *La línea temporal recorta la esfera del cráneo dándole un plano más angular
    a cada lado* (p.154 §07). *Tres planos de frente con ángulos ligeramente
    distintos.* *La cara se separa del costado con una línea del pómulo a la
    punta del mentón* (p.154 §07).
19. *La oreja se puede construir con tubos curvos: hélix como un tubo que nace
    a media oreja, sube al borde y rodea hasta el lóbulo; el antihélix es una
    segunda curva por dentro; trago y antitrago se enfrentan* (p.154 §09).
    → **el vault afirma que el libro no aporta estructura de oreja. Sí aporta,
    y aquí está.**
20. *Los bordes de los párpados son curvos, no líneas rectas; el superior se
    monta sobre el inferior y sobresale más del lado exterior* (p.154 §10).
21. *Labio inferior = dos segmentos que se encuentran al centro; superior =
    tres, con el arco de Cupido en medio; las comisuras se enrollan hacia
    adentro formando un triángulo* — y el libro marca esto como **más
    pronunciado en mujeres** (p.155 §12). Único rasgo facial con sesgo
    femenino explícito en todo el capítulo.

---

## Contradice al vault

1. **Caja torácica: cilindro/huevo vs. cuboide con taper hacia arriba.**
   `Principios de Anatomía 3D.md` línea ~26-27 dice: *"Cilindro → … y la caja
   torácica en su forma más simple ('bullet' o 'birdcage': cilindro redondeado,
   no caja recta)"*, y línea ~48-49 la describe como *"cilindro/huevo
   redondeado"*. Anger usa **cuboide suavizado, más angosto arriba y
   contra-rotado** (p.138 §06). No es una contradicción de estilo: un cilindro
   redondeado no tiene ni taper ni caras para contra-rotar, y esos dos son
   justamente los dos defectos medidos del rig. Recomiendo cambiar el vault a
   *cuboide suavizado con taper superior*.
2. **Proporción 2/3 - 1/3 del torso — no verificada, y probablemente
   incompleta.** El vault (línea ~48-51) fija *caja torácica 2/3 / pelvis 1/3*
   con la cintura viviendo "entre ambas". Este capítulo trata el **abdomen como
   una masa propia con volumen** (p.140 §11), no como el espacio residual entre
   dos. Si el abdomen tiene volumen propio, 2/3 + 1/3 no deja lugar para él.
   La fracción del vault no sale de este capítulo y debería re-verificarse
   contra su fuente original antes de usarse como número de código.
3. **"El libro NO tiene una sección dedicada a proporción/estructura de
   oreja"** (vault, línea ~325-332). Falso para este capítulo: p.154 §09 da una
   construcción de oreja por tubos curvos con hélix, antihélix, concha, trago y
   antitrago. La afirmación del vault debe acotarse a "el capítulo masculino no
   la tiene".
4. **Matiz sobre el hombro masculino.** El vault (línea ~58-59) contrasta
   *"hombro ancho vs. cadera más angosta"* como el rasgo masculino. Este
   capítulo aporta la causa mecánica que el vault no tenía: la diferencia de
   ancho de hombro **no está en el hombro, está en la caja torácica**. No es
   contradicción, es corrección de dónde vive el parámetro — si el rig
   parametriza `SHOULDER_X` directamente, está parametrizando el síntoma.

---

## Números duros

- Figura idealizada: **8 cabezas** de altura total.
- Brazo completo: **3 cabezas**. Pierna: **4 cabezas**.
- Separación hombro-a-hombro femenina: **≈ 2 cabezas** (declarada menor que la
  masculina; el libro no da la cifra masculina).
- Falanges, dorso de la mano: primer segmento el más largo; **segundo ≈ 1/2 del
  primero**; tercero el más corto.
- Falanges, palma: los tres **casi iguales**, conjunto algo más corto que el
  dorso.
- Dedos: **3 falanges**; pulgar y dedo gordo del pie: **2**.
- Pecho: **media esfera**, perfil de lágrima.
- Deltoides: **3 cabezas**, insertan a **media altura del húmero**.
- Recto abdominal: se ancla bajo el pectoral, **a la altura de las costillas 5 y
  6**; **8 secciones no simétricas**.
- Oblicuo externo: engancha el serrato en las costillas **8 y 9**.
- Tríceps: **3 cabezas**.
- Cuádriceps: **3 cabezas** visibles en superficie.
- Maleolo medial (tibia) **más alto** que el lateral (peroné).
- Iluminación de control: **2-3 luces**, principal la más fuerte.

**Lo que NO hay:** ninguna cifra de ancho de pelvis, ancho de caja torácica,
razón cadera/hombro, ni grado de inclinación pélvica. Todos los diferenciales de
masa del capítulo son cualitativos.

---

## Vacíos — lo que el capítulo no contesta

1. **Ninguna razón numérica hombro/cadera.** Se pidió "la pelvis es más ancha en
   razón X vs. Y masculino". El libro solo da la separación de hombros en
   cabezas (≈2) y afirma que la cadera es lo más ancho. **No hay ancho de
   cadera en cabezas ni razón entre ambos, ni para el femenino ni para el
   masculino.** Para tener el número habría que medirlo en píxeles sobre la
   lámina de proporción de p.159 — que es de un solo sexo, así que ni siquiera
   eso da el diferencial. Es medible cruzando p.159 contra la lámina equivalente
   del capítulo masculino.
2. **Ninguna cifra de inclinación pélvica.** Se dice "inclinada adelante y
   rotada atrás" y "la caja torácica rotada en oposición", sin grados ni
   dirección de referencia. Igual para el masculino.
3. **Ninguna cifra de ángulo de cintura.** Se dice que la cintura empieza más
   arriba, sin cuánto.
4. **El ángulo de acarreo del codo no viene en grados** — solo la relación
   causal.
5. **Nada sobre inclinación pélvica ni ancho por raza/edad/peso.** El capítulo
   construye un único arquetipo idealizado. Los sliders de raza (enano 4.5
   cabezas) no tienen apoyo aquí: 4.5 cabezas contradice el canon de 8 y el
   libro no ofrece regla de reescalado no uniforme.
6. **Nada sobre cómo cambia la cintura escapular con el sexo.** La caja se
   construye igual; la única variable insinuada es que hereda el ancho de la
   caja torácica.
7. **Nada sobre grosor/largo de cuello por sexo.**
8. **El capítulo no cuantifica el pad de grasa.** Ubica los pads (pecho, pelvis,
   abdomen, rodilla, palmas, plantas) pero sin espesor ni radio.
