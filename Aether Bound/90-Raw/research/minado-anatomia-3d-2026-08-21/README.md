---
status: raw
updated: 2026-08-21
---

# Minado del libro de anatomía 3D — barrido 2026-08-21

**Qué es esto:** los reportes crudos de 7 subagentes que barrieron, capítulo
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
| `cap11-advanced-topology.md` | Advanced topology (Peteuil) | pp.250–259 | **Traducción** a loft procedural, no resumen |
| `DOF-propuesta.md` | — | — | **No es minado.** Borrador propio que contesta la pregunta de DOF del director; pendiente de dónde vive |

**Pendientes de barrer:** caps 8-10 (*Master projects*: bodybuilder, curvy,
slim — pp.182–249) y cap 12 (*3D reference gallery*, pp.260–281). El cap 3
(*2D reference gallery*) se descartó: son bocetos sin texto.

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

## Los hallazgos negativos, que también son resultado

- **El libro no trae medidas horizontales.** Apareció una sola: ancho de
  hombros = 2 alturas de cabeza. Faltan pecho, cintura, cadera, la razón
  hombro/cadera, largo de cuello, grosores y **toda profundidad en Z**. Es
  estructural: el libro enseña un sistema **vertical**, de contar cabezas.
  Confirmado por tres agentes por separado. Si los caps 8-10 tampoco los dan,
  hay que **medirlos en píxeles sobre las láminas ratificadas de
  `90-Raw/concept/`** — medición del proyecto, no cita.
- **El libro usa 8 cabezas; el proyecto usa 7.5 para el humano.** No son la
  misma escala: toda vertical tomada del libro se reescala por 0.9375 o se
  ancla a un landmark. **El 7.5 del proyecto no sale de este libro** — sale de
  los briefs de concept art, es decisión del director, y conviene que quede
  escrito antes de que alguien lo "corrija" a 8 creyendo que arregla algo.
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
