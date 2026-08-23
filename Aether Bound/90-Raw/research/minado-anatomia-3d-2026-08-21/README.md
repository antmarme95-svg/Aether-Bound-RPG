---
status: raw
updated: 2026-08-21
---

# Minado del libro de anatomía 3D — barrido 2026-08-21

**Qué es esto:** los reportes crudos de 10 subagentes que barrieron, capítulo
por capítulo, *Anatomy for 3D Artists* (3dtotal) contra las necesidades del
rig procedural. Encargados por Boris como **prep técnico** antes de construir
a **Roen (humano 7.5 cabezas), Darro (enano 4.5) y Valen (elfo 8)** — tres
personajes elegidos justamente porque cubren las tres razas y por lo tanto
**validan** [[Principios de Anatomía 3D]] en vez de solo estresarlo.

**Estado: CRUDO.** Nada de acá es canon. Es material de insumo para decidir
qué asciende a [[Principios de Anatomía 3D]] — que sigue en `propuesto` — y
esa decisión es del director. No citar estos archivos como fuente de canon.

## Disciplina de derechos de autor

El libro es **copia personal de Boris y no está ni estará en el repo**. Los
7 encargos llevaron la misma regla explícita: reportar **principios en
síntesis propia**, prohibido transcribir texto, prohibido reproducir o
describir imágenes de forma reconstruible, máximo una cita corta atribuida
por reporte. **Las medidas numéricas sí se reportan completas** — un número
es un hecho, no expresión protegida.

## Los archivos

| Archivo | Capítulo | Libro | Qué se le pidió |
|---|---|---|---|
| `cap01-2D-male.md` | Drawing an archetypal figure — 2D male | pp.18–42 | Extraer **números** de proporción |
| `cap02-2D-female.md` | Drawing an archetypal figure — 2D female | pp.43–65 | Números + **diferencial** contra el masculino |
| `cap04-3D-male.md` | Sculpting an archetypal figure — 3D male | pp.92–115 | Orden de construcción, torso, cintura escapular |
| `cap05-advanced-3D-male.md` | Advanced 3D male (Nagulov) | pp.116–135 | Cabeza por masas, cuello, mandíbula ancha vs. fina |
| `cap06-3D-female.md` | Sculpting an archetypal figure — 3D female | pp.136–159 | Qué cambia y qué NO entre sexos = qué es slider y qué constante |
| `cap07-advanced-3D-female.md` | Advanced 3D female (Anger) | pp.160–181 | Deformación en pose; el omóplato al levantar el brazo |
| `cap08-male-bodybuilder.md` | Master projects — Male bodybuilder | pp.182–207 | Variación por físico; el trapecio de Darro |
| `cap09-curvy-female.md` | Master projects — Curvy female | pp.208–225 | Dónde se deposita el volumen = cómo debe portarse el slider de peso |
| `cap10-slim-female.md` | Master projects — Slim female | pp.226–249 | Landmarks que emergen sin masa; el cuello. Referencia de **Valen** |
| `cap11-advanced-topology.md` | Advanced topology (Peteuil) | pp.250–259 | **Traducción** a loft procedural, no resumen |
| `DOF-propuesta.md` | — | — | **No es minado.** Borrador propio que contesta la pregunta de DOF del director; pendiente de dónde vive |

**Pendiente de barrer:** solo el cap 12 (*3D reference gallery*, pp.260–281) —
esculturas de 7 artistas con los grupos musculares etiquetados; sirve de
calibración, no de fuente de reglas. El cap 3 (*2D reference gallery*) se
descartó: son bocetos sin texto.

## Los tres hallazgos que justificaron el barrido

1. **Convergencia sobre la causa raíz del "torso bola".** Los caps 4, 5 y 6,
   leídos por agentes ciegos entre sí, llegan a lo mismo: el torso arranca de
   una **caja** (X≠Z), no de un cilindro de revolución; la caja torácica va
   **más angosta arriba**; y el V-taper lo produce el *latissimus dorsi* como
   masa añadida, no el tórax. Corolario de arquitectura: **el ancho de hombro
   no debe ser un parámetro** — se deriva del ancho de la caja torácica.
2. **El ritmo escapulohumeral, cifrado** (cap 7): de 0° a 30° de abducción la
   escápula no se mueve; luego aporta 1° por cada 2° del húmero, con techo de
   ~75°. Es la respuesta a las hombreras flotantes, y de paso convierte los
   +3 DOF escapulares de teoría a fórmula.
3. **La asimetría lumbar/torácico** (cap 7): en extensión el lumbar se acorta
   ~30% y el torácico ~1%. **No es un DOF: es una escala longitudinal**, y el
   rig no tiene ninguna.
4. **El esqueleto es invariante — dicho explícitamente, y confirmado tres
   veces** (caps 6, 8 y 10): mismos huesos, misma estructura y mismas
   proporciones entre figura promedio, bodybuilder y delgada. **Regla de
   arquitectura: los sliders mueven radios y rellenos, jamás posiciones de
   junta.** Corolario del cap 8: muñecas y tobillos conservan el tamaño de la
   figura promedio aunque todo lo demás crezca — es el **contraste**, no el
   engrosamiento uniforme, lo que hace leer la masa. El rig hoy escala
   extremidades enteras por un multiplicador, que es justo el error.
5. **El "hombros que se tragan el cuello" del enano es masa añadida, no
   proporción distinta** — y hay **tres fuentes independientes**: rotación de
   clavícula hasta ~45° (cap 5), caja torácica más ancha y corta (cap 6), y el
   trapecio que al crecer se parte en dos masas y la superior invade el ángulo
   del cuello (cap 8). **El cuello no se acorta: se tapa.** Darro puede
   compartir esqueleto con Roen y Valen.
6. **El slider de peso está mal concebido** (cap 9): el peso tiene **dos**
   efectos independientes — sube volumen por zona **y baja la amplitud del
   relieve de los landmarks**. El rig solo hace lo primero, y por eso lee
   *inflado* en vez de *graso*. Excepción a respetar: trapecio y escápula
   siguen legibles en figura llena. Y la cadera es prominente incluso en
   cuerpo pasado de peso: **es parámetro de identidad, no producto del peso** —
   fusionarlos es otra vía al torso-bola.

## Los hallazgos negativos, que también son resultado

- **El libro no trae medidas horizontales. CERRADO como hallazgo.** Apareció
  una sola en 10 capítulos: ancho de hombros = 2 alturas de cabeza. Faltan
  pecho, cintura, cadera, la **razón hombro/cadera**, largo de cuello,
  grosores y **toda profundidad en Z**. Es estructural: el libro enseña un
  sistema **vertical**, de contar cabezas. Seis agentes la buscaron por
  separado —incluidos los tres *Master projects*, que eran los candidatos más
  probables— y ninguno la encontró. **Ya no es un vacío de barrido: es una
  propiedad del libro.** Los anchos hay que **medirlos en píxeles sobre las
  láminas ratificadas de `90-Raw/concept/`** — medición del proyecto, no cita,
  con la ventaja de que mide nuestras razas y no la figura académica.
- **El conteo de cabezas del libro no es estable, ni siquiera dentro del
  libro.** Los capítulos 2D usan 8; el de *curvy female* usa 7; el de *slim
  female* **rechaza explícitamente el sistema de cabezas** y mide con calibre
  contra una foto de referencia. Conclusión práctica: **el 7.5 del humano del
  proyecto no sale de este libro** — sale de los briefs de concept art, es
  decisión del director, y conviene que quede escrito antes de que alguien lo
  "corrija" creyendo que arregla algo. Toda vertical tomada del libro se
  reescala o se ancla a un landmark.
- **El cap 11 rinde poco**: 5 principios geométricos, cero números, y no
  contesta el patrón de aristas de la unión brazo-torso. Para eso hace falta
  otra fuente — topología de personajes de juego, no este libro.

## Correcciones a [[Principios de Anatomía 3D]] que salieron del barrido

Cinco, todas sobre defectos vivos del rig:

1. Primitiva de arranque del torso: el doc dice cilindro redondeado; el libro
   dice caja.
2. Mandíbula masculina: el doc se quedó con media regla. El mismo autor
   advierte que la línea de mandíbula es **suave** y que el error común es
   hacerla demasiado angular — que es, palabra por palabra, el "cubo suelto"
   que reportó el render de Dagna.
3. El doc afirma que el libro no tiene sección de oreja. **Sí la tiene**, en
   dos capítulos distintos, uno con la proporción.
4. La fracción 2/3–1/3 del torso no sale de este libro y no deja lugar al
   abdomen, que el cap 6 trata como masa propia.
5. El doc **descarta los capítulos Advanced** con el argumento de que el rig
   es estático. Premisa caducada: hoy son la fuente principal del frente de
   animación, y de ellos salieron los dos hallazgos cifrados de arriba.
