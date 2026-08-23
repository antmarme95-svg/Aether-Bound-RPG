# Cap. 11 — Advanced topology / Retopologizing (D. Peteuil, *Anatomy for 3D Artists*, pp.250–259)

**Veredicto honesto de entrada.** Es un capítulo introductorio de 8 páginas útiles, escrito para
alguien que nunca retopologizó. Aporta **cinco principios geométricos duros** y nada más. No trae
conteos de loops, ni presupuestos de polígonos, ni un solo número fuera de una mención de
"subdivisión nivel 2". Casi la mitad del texto (secciones 12–17) es topología facial, irrelevante
para nuestro rig de primitivas. La pregunta cara del encargo — cómo se resuelve la unión
brazo-torso y cuello-torso — **el capítulo no la contesta**. La menciona como zona difícil y sigue.

Todo lo de abajo es síntesis propia; no se transcribe el libro.

## Traducción a loft procedural

### 1. El loop debe ser perpendicular al eje de flexión (§07, p.254)
- **Qué dice:** los edge loops deben quedar aproximadamente perpendiculares al eje sobre el que la
  articulación va a rotar. Lo señala como error frecuente incluso en profesionales.
- **Implicación para generar:** es *el* principio más accionable del capítulo y cae directo sobre
  el loft. La orientación de cada anillo de perfil no debe salir del `Curve3D` por defecto (el
  transporte paralelo de Godot orienta el anillo según la tangente de la curva). Cerca de una
  articulación hay que **forzar la normal del anillo al eje de rotación del hueso**, no a la
  tangente de la espina. En un codo o rodilla ambos coinciden en pose T; en el hombro y la cadera
  no coinciden y ahí es donde el loft ingenuo produce el colapso. Regla implementable: al emitir
  anillos dentro de un radio ε de un joint, `basis` del anillo = base del hueso, no la de la curva.

### 2. Densidad uniforme salvo en articulaciones (§08, p.254–255)
- **Qué dice:** apuntar a densidad de polígonos razonablemente uniforme, con las articulaciones
  como excepción explícita: ahí conviene más densidad, porque al flexionar la densidad local
  *cambia* — el lado externo se estira y el interno se comprime. Si el codo va justo de polígonos
  en reposo, doblado se queda sin forma.
- **Implicación:** el espaciado de anillos del loft no debe ser uniforme en longitud de arco. Se
  parametriza como densidad base constante (anillos por unidad de longitud, para que brazo y pierna
  se vean del mismo "grano") **más una gaussiana de anillos extra centrada en cada articulación**.
  El criterio de cuánta densidad extra: la suficiente para que, tras la flexión máxima prevista,
  la densidad *deformada* del lado comprimido siga siendo ≥ la densidad base. Ese es un criterio
  computable y es la traducción exacta de lo que el texto dice en prosa.

### 3. Loops pareados: uno define la cara externa, otro el pliegue interno (§04, p.253)
- **Qué dice:** para codos y rodillas conviene tener loops que definan la tapa (rótula / punta del
  codo) por un lado y loops que definan la fosa (corva / sangría del codo) por el otro. Así la
  forma se conserva al doblar.
- **Implicación:** esto es lo más cercano a un conteo que da el capítulo, y es un mínimo de
  **dos loops funcionalmente distintos por articulación de bisagra**, no uno solo. En un loft,
  como el anillo rodea todo el miembro, un mismo anillo es a la vez cara externa y fosa interna —
  así que el requisito se cumple con **anillos cuyo perfil no es circular**: radio mayor y más
  saliente del lado extensor, radio menor y hundido del lado flexor. O sea: el perfil del loft debe
  ser **asimétrico y orientado** cerca de las bisagras. Un perfil de radio escalar (círculo) no
  puede satisfacer este principio, lo cual es un requisito de diseño concreto para la API del loft.

### 4. Bucles que rodean grupos musculares completos (§06, p.254)
- **Qué dice:** el flujo debe delinear grupos musculares grandes que producen un pliegue marcado
  al moverse — nombra explícitamente **pectoral** y **glúteo**.
- **Implicación:** hay masas que no son "tramo de miembro" sino **anillos cerrados que no cruzan el
  eje del loft**. Un loft por espina no los genera solos. Para el pectoral esto significa que el
  torso no puede ser un solo loft vertical: necesita, o bien anillos con perfil de muchos lados
  donde se pueda desplazar el contorno pectoral, o bien un loop de contorno adicional insertado a
  mano en el generador. Es la vía por la que el rig podría acabar teniendo pecho legible sin
  esculpir. Es también el principio más caro de implementar de los cinco.

### 5. Loops rectos y suaves; los quiebres solo donde cambia la dirección de la forma (§03, §10, p.253, 255–256)
- **Qué dice:** "limpio" significa loops rectos y suaves; loops ondulados son un defecto, porque
  una malla que ni siquiera es suave en reposo no puede deformarse suavemente. Los cambios de
  dirección del flujo se concentran donde nace un apéndice o una extrusión, y los cambios más
  grandes están en **hombros y caderas** — precisamente por ser las mayores zonas de cambio de forma.
- **Implicación (doble):**
  (a) El loft ya gana esto gratis: los anillos salen ordenados por construcción. Es la ventaja
      estructural de generar en vez de reparar, y vale la pena decirlo — la clase entera de defecto
      "loop ondulado" desaparece.
  (b) Confirma dónde poner el esfuerzo: hombro y cadera son las transiciones caras, no el codo.

### 6. Polos / estrellas (§03 + §18, p.253, 259)
- **Qué dice:** define el cambio de dirección como un vértice que conecta más o menos de cuatro
  aristas, y los ubica cerca del origen de un apéndice o extrusión — el ejemplo que da es donde el
  cuello encuentra la cabeza. En §18 trata los triángulos como algo a eliminar cuando aparecen por
  accidente al editar, borrando o añadiendo una arista.
- **Implicación:** el capítulo **legitima el polo estructural** (inevitable donde nace un miembro) y
  condena solo el polo accidental. Traducido: los polos de las tapas del loft (manos, pies, coronilla)
  y los de las bifurcaciones torso→brazo y torso→cuello **no son un defecto**; son exactamente donde
  la teoría los espera. Lo que sí sería defecto es un polo a mitad de un tramo recto de brazo. Para
  el generador: prohibir polos fuera de tapas y bifurcaciones, y aceptarlos sin culpa dentro de ellas.

### 7. Quads vs triángulos (§11, p.256)
- **Qué dice:** el purismo de solo-quads es escolar; en juegos se triangula igual al renderizar.
  El valor real del quad es de *edición y predicción* — poder leer los loops y anticipar cómo se
  deformará.
- **Implicación:** para nosotros esto **desactiva una preocupación**. `SurfaceTool` emite triángulos
  y no hay que pelearse con eso. La estructura de quads conceptual (anillo × segmento) se conserva
  en la parametrización aunque la malla emitida sea triangular; eso es todo lo que hace falta.

## Mapa de loops por articulación

Aviso: **el capítulo no da conteos**. La columna "cuántos" es lo que se deduce de sus principios
(§04 exige loops de tapa + loops de fosa como mínimo), no una cifra del libro. Trátese como piso,
no como recomendación citada.

| Articulación | Dónde corren los loops (según §03–§07) | Cuántos (deducido) | Si faltan |
|---|---|---|---|
| Hombro | Zona de mayor cambio de dirección junto con la cadera; origen de apéndice → polo esperado | El capítulo no lo especifica; señala que es donde más esfuerzo hay que poner | Colapso severo; es el caso que el texto marca como más difícil |
| Codo | Un loop define la punta del codo, otro la sangría interna; perpendiculares al eje de flexión | ≥2 funcionalmente distintos + densidad extra local | Al doblar, el codo "se queda sin polígonos" y pierde la forma (dicho explícito, §08) |
| Muñeca | No la trata | — | — |
| Cadera | Junto al hombro, el mayor cambio de dirección del cuerpo | No especificado | Ídem hombro |
| Rodilla | Loops que definen la rótula por delante y la corva por detrás | ≥2 + densidad extra | Pierde la forma al flexionar |
| Tobillo | No lo trata | — | — |
| Cuello | Solo lo menciona como ejemplo de dónde vive un polo (unión cuello-cabeza) | No especificado | — |

## Unión brazo-torso y cuello-torso

**Esta es la sección donde el capítulo decepciona.** Lo único que ofrece:

- El hombro está identificado como una de las **dos** mayores zonas de cambio de dirección del
  cuerpo (junto con la cadera), por ser donde más cambia la forma anatómica (§03).
- Los cambios de dirección — vértices de valencia ≠ 4 — se agrupan **donde nace un apéndice o
  extrusión**; el caso nombrado es cuello↔cabeza (§03). Por extensión directa: torso↔brazo y
  torso↔cuello son bifurcaciones donde el polo es estructural y esperado.
- El flujo debe delinear el pectoral como grupo (§06), lo que implica que la transición
  torso→brazo pasa *alrededor* de la masa pectoral, no la atraviesa.
- Las imágenes muestran hombro y axila resueltos, pero el texto no explica el patrón, y describirlo
  a partir de la figura sería reproducir la lámina — no lo hago.

**Lo aprovechable para nuestro defecto real** (brazos despegados del torso): el capítulo confirma
que la unión es una **bifurcación de superficie continua con un polo en el origen del apéndice**,
no dos volúmenes que se intersectan. Eso valida la migración a loft y descarta seguir apilando
primitivas ahí. Pero **no da la receta del patrón de aristas**. Para eso hace falta otra fuente.

## Números duros

Prácticamente ninguno. Inventario completo:

- **Valencia 4** es la valencia normal; ≠4 marca cambio de dirección (§03). Único número estructural del capítulo.
- **Subdivisión nivel 2** como objetivo si se quiere una base más densa reproyectada sobre el sculpt (§19). No traducible a nuestro flujo.
- Sin conteo de loops por articulación. Sin presupuesto de polígonos. Sin proporción de densidad
  articulación:tramo recto — solo el criterio cualitativo "más en articulaciones, uniforme en el resto".

Si el proyecto necesita cifras (anillos por miembro, presupuesto de triángulos), este capítulo no
las da y hay que sacarlas de otro lado o fijarlas empíricamente en el motor.

## Lo que NO aplica

- **Todo el flujo de trabajo manual** (§01–§02, §19): esculpir denso → snapear malla nueva encima
  → reproyectar. Es el capítulo entero como procedimiento y no es nuestro pipeline.
- **§18 Refining** — borrar/añadir aristas a mano para eliminar triángulos accidentales. En un
  generador procedural los triángulos accidentales no existen: o el generador los emite
  sistemáticamente (y se arregla el generador) o no aparecen.
- **§12–§17, toda la topología facial** (ojos, boca, surco nasogeniano, ceño, frente): ~4 de las 8
  páginas útiles. Son loops para blendshapes de expresión facial. Nuestros personajes son de
  primitivas; no hay cara deformable. Descartable completo por ahora, con una reserva: si algún día
  hay expresión facial, el principio subyacente que se repite en las cinco secciones es único y
  simple — **el loop sigue el pliegue que la piel va a formar**, que es el mismo principio §06
  aplicado a escala pequeña.
- **§11 la discusión quads-vs-tris** es informativa, pero como decisión ya está resuelta para
  nosotros por `SurfaceTool`.

## Vacíos

Preguntas del encargo que el capítulo **no** contesta:

1. **Cuántos loops por articulación.** Cero cifras. Lo más concreto es "al menos uno de tapa y uno
   de fosa" en codo/rodilla, y eso es inferencia mía sobre §04.
2. **El patrón topológico de la unión brazo-torso.** La pregunta cara — sin respuesta textual.
3. **Cuello-torso.** Ni una línea. El cuello aparece solo como ejemplo de polo hacia la cabeza.
4. **Muñeca y tobillo.** No se tratan.
5. **Ratio de densidad** articulación vs. tramo recto. Cualitativo, nunca numérico.
6. **Presupuesto de polígonos** para juego. Fuera de alcance del capítulo.
7. **Cómo cierra una tapa** (mano, pie, coronilla) sin polo feo. No se aborda.
8. **Perfil no circular:** el principio §04 lo *exige* implícitamente, pero el capítulo no razona
   sobre secciones transversales — esa traducción es mía y hay que validarla en el motor.

Para los puntos 1–4 conviene una fuente de referencia de topología de personajes de juego
(character topology reference), no un capítulo introductorio de un libro de anatomía.
