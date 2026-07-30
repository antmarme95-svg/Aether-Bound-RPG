# AUDITORÍA DE FIDELIDAD ARTÍSTICA — Concept (RAW) vs Output (Godot)

> **Fuente RAW, depositada verbatim (2026-07-12).** Auditor: subagente Fable
> imparcial ("ni juez ni parte"), modo solo-lectura, encargo del director en el
> punto de decisión pre-rework. Par de este reporte:
> [[QA-Auditoria-Codigo-2026-07-12]]. No se edita.

---

He revisado la referencia (Art Bible, reviews v0.1–v0.5, keyframes canónicos,
concepts de fenotipos, Dagna, follaje, benchmark VRM) y he abierto imagen por
imagen el output actual (`godot/test_out/`: banco de anatomía m10-r7, Dagna en
pipeline viejo y golden, golden dawn/dusk con y sin post, biomas, clases y
montages legacy). Este es mi reporte completo como auditor externo.

> Auditor externo, solo lectura. 2026-07-12. Rúbrica: Art Bible ("Melancolía
> Gráfica"), reviews del director v0.1–v0.5, norte BotW/Hinterberg/Palia/
> Torchlight III. Pares comparados: `fenotipo-humano-v1.png` ↔ `anatomy_*.png`
> (ronda m10-r7, la vigente); `dagna-v1.png` ↔
> `dagna_front/profile/detail/golden_close.png`;
> `keyframe-wilds-dawn/dusk-v1.png` ↔ `golden_dawn/dusk.png`
> (+ `golden_dawn_raw.png`); `foliage-clumps-v1.png` ↔ canopies del golden;
> registro contra la regla de Línea/Sobel y paleta del Art Bible.

## Veredicto general

**Needs Revision — base desigual.** El **pipeline de render** (registro de
línea, perspectiva aérea, atardecer con filos teal) es lo más cercano al norte
y está a dos fixes de shader de ser una base construible. El **personaje
humano** está a mitad de transformación: proporciones ya corregidas, pero el
lenguaje "maniquí de madera con costuras" contradice frontalmente la regla de
siluetas limpias/formas grandes. **Dagna** está oficialmente desfasada (montada
sobre el cuerpo viejo, diferida a C6b) y hoy vive a ~30% del concept. Hay
además **una violación de regla intocable**: el cristal de peligro no es rojo
saturado en ninguna captura.

## % de fidelidad por dominio

| Dominio | Fidelidad | Tendencia |
|---|---|---|
| 1. Humano — cuerpo/proporciones/silueta | **~60%** | ↑ desde el 60–65% del blockout, pero por razones distintas: proporciones resueltas, lenguaje de superficie no |
| 2. Humano — cara/cabeza (sin castigar pelo WIP) | **~50%** | consistente con el 5/10 de la review v0.5 |
| 3. Dagna | **~30–35%** | estancada (diferida a C6b por decisión, no por accidente) |
| 4. Paisaje/atmósfera (golden vs keyframes) | **dawn ~50% · dusk ~65%** | el dusk es lo mejor del proyecto |
| 5. Follaje | **~65–70%** | el lenguaje del clump sí se tradujo |
| 6. Línea/registro Melancolía Gráfica | **~65%** | el gradiente Sobel funciona; la cuantización de sombra lo sabotea |
| **Global ponderado** | **~55%** | |

## CRITICAL

**C1. La masa de sombra aplasta la acuarela en TODA captura in-world.**
Concept (`keyframe-wilds-dawn-v1`): suelo luminoso, sombras suaves lavadas,
rayos de dios atravesando el claro. Output (`golden_dawn.png`,
`anatomy_far.png`, `anatomy_medium.png`): una banda casi negra e informe cubre
el tercio medio del encuadre y se come el terreno, con facetas poligonales
duras visibles dentro. La prueba de que es un problema de post y no de escena:
`golden_dawn_raw.png` (sin las 4 capas) es MÁS fiel al keyframe en luminosidad
que la versión procesada. La capa de cuantización cel está colapsando los
valores bajos a un solo escalón negro en vez de los "3–4 escalones fijos con
bordes jitter" del Art Bible. Es el defecto que más daña el norte y
probablemente el más barato de arreglar (rango/curva del quantizer).

**C2. "Peligro = ROJO saturado" — la constante intocable no se cumple.**
En ambos keyframes el cristal es rojo carmesí saturado con halo que tiñe el
follaje. En `golden_dawn.png` es un cono rosa salmón lavado; en
`golden_dusk.png` mejora (emisivo rosa-magenta) pero sigue sin ser rojo.
Además la forma es un cono liso: el concept es un clúster cristalino facetado.
El Art Bible marca esto como constante en ambos registros; hoy no se lee
"peligro", se lee "carpa rosa".

**C3. El cuerpo humano lee "maniquí articulado", no "personaje" — rompe la
regla de siluetas limpias.**
Concept (`fenotipo-humano-v1`): atleta 7.5 cabezas de formas grandes continuas,
línea que fluye cabeza-hombro. Output (`anatomy_close.png`,
`anatomy_hands.png`): costuras de junta esféricas visibles en hombros, codos,
abdomen, muñecas y rodillas, con huecos entre segmentos en muñecas y codos;
placa pectoral con seam horizontal duro. Bajo el Sobel, cada costura genera
línea interior — exactamente lo contrario de "formas grandes, siluetas muy
limpias" (Palia/BotW). Las proporciones sí están: la regla de cabezas en
escena confirma ~7.5, el cuello existe y los hombros ya no son estrechos. El
problema ya no es proporción, es lenguaje de superficie/unión.

## HIGH

**H4. La cara sigue siendo placeholder amable, no el personaje del concept.**
Concept: mandíbula marcada, pómulos altos, nariz fina, sonrisa ligera con
personalidad (review v0.1, issue 9 — sigue abierto). Output
(`anatomy_face.png` m10-r7): los ojos ya están on-model (iris/pupila legibles,
buen tamaño), pero la nariz es un prisma plano, la boca es una línea pintada
con sublínea gris-azul que lee raro a distancia, el mentón tiene placas con
seams visibles y la frente ocupa ~45% de la cara (hairline alta, issue
conocido de v0.5 que el quiff WIP deberá resolver). No castigo el pelo, pero
registro que hoy tapa las orejas en los 4 ángulos: imposible verificar el fix
del crítico 4 de v0.5 desde estas capturas.

**H5. Dagna está a dos generaciones del concept y sus capturas "canónicas"
viven en el look anti-referencia.**
Concept (`dagna-v1`): veterana compacta con trenzas, tatuajes geométricos en
antebrazos, cinturón de herramientas, pauldrons, silueta trapezoidal plantada.
Output golden (`dagna_golden_close.png`): torso-caja tipo refrigerador, ojos
de esclerótica mirando arriba (cómico, no veterana), sin tatuajes, sin
herramientas, trenzas apenas insinuadas como rollos laterales. Peor:
`dagna_front/profile/detail.png` están capturadas en la escena vieja de pasto
voxel verde caramelo — literalmente la anti-referencia "saturación Genshin"
del Art Bible. Current-State ya lo declara ("Dagna queda visualmente desfasada
hasta C6b"), así que no es negligencia — pero el % real hoy es ~30–35% y
cualquier contenido de aliada construido encima heredará el cuerpo viejo.

**H6. Las islas flotantes se degradaron a glifos.**
Concept: islas con masa, árboles encima y sombra atmosférica. Output (ambos
golden): contornos blancos en rombo, vacíos, que leen como cometas o
marcadores de UI. Es un elemento de identidad del mundo (La Rueda) reducido a
esquema.

## MEDIUM

**M7. Sin rayos de dios ni camino compositivo en dawn.** El keyframe dawn se
define por los shafts de luz y el sendero con figura diminuta; el golden no
tiene ninguno de los dos. La figura a escala sí está (bien), pero la
composición pierde su guía.

**M8. Manos-mitón por debajo del estándar ya marcado.** Review v0.1 issue 6
pedía manos con presencia; `anatomy_hands.png` muestra bloques con ranuras
talladas, más pequeños que el antebrazo y con hueco visible en la muñeca.

**M9. Artefactos de render en capturas de anatomía.** Trazos grises flotando
en el cielo (`anatomy_face_34.png`, `anatomy_hands.png`), tiras cyan planas
flotando sobre brazo/torso/pierna (¿marcas aether?) que leen como glitch, y la
regla de medición entrando a cuadro en `anatomy_face.png`. Para un banco de
pruebas es tolerable, pero contamina cualquier evaluación de silueta.

**M10. Facetado poligonal del terreno visible en primer plano.** Triángulos
duros en el pasto de `golden_dusk.png`/`anatomy_far.png` donde el concept pide
lavados continuos con grano.

## LOW

**L11. `test_out/` mezcla tres generaciones de look sin etiquetar.**
`biome_wilds.png`, `biome_smelting.png`, `class_*.png`, `montage_*.png` y
`dagna_front/profile.png` son del prototipo viejo (verde caramelo, ojos
saltones, void oscuro) conviviendo con el golden actual. Un auditor —o el
propio director en seis meses— puede medir contra material muerto sin saberlo.

**L12. Copas con planos de hoja despegados.** En los árboles-marco del golden
hay cards de follaje flotando separados de la masa (esquina superior izquierda
de `golden_dawn.png`).

## Qué ya está sólido (NO tocar)

- **El gradiente Sobel por profundidad funciona de verdad:** línea negra
  nítida en personaje y árboles-marco, agrisada a media distancia, ausente en
  colinas. Es LA regla del Art Bible y está implementada correctamente.
- **El dusk con filos teal** (`golden_dusk.png`): cielo violeta, siluetas de
  colinas con rim teal-neón, herencia Sable nocturna — es la captura más
  cercana al norte de todo el proyecto y valida la regla nocturna ratificada.
- **La perspectiva aérea por capas** (colinas pastel escalonadas hacia
  blanco-azul) en ambos goldens.
- **El lenguaje del clump de follaje:** contorno festoneado + squiggles
  interiores del concept sí se tradujeron a las copas.
- **Proporciones del humano nuevo:** 7.5 cabezas, cuello existente, hombros
  ensanchados — los CRITICAL 1–3 del blockout v0.1 están sustancialmente
  respondidos.
- **Ojos on-model** en la cara actual, y la consistencia de escala
  personaje-mundo.
- **Grano de papel** presente y discreto.

## Prioridad de retrabajo (de más lejos a menos lejos del norte)

1. **Dagna** (~30%) — pero está correctamente diferida; la prioridad real es
   no construir contenido de aliada hasta C6b.
2. **Cristal de peligro** — violación de constante; fix de material/forma,
   barato y de alto impacto simbólico.
3. **Cuantización de sombra** — un fix de shader que levanta TODAS las
   capturas in-world a la vez; el mayor ROI del proyecto.
4. **Costuras del maniquí humano** — decidir si el cuerpo desnudo debe leer
   limpio o si el vestuario modular (decisión ya documentada) las cubrirá; si
   es lo segundo, documentarlo y dejar de evaluar el cuerpo desnudo como
   entregable final.
5. **Cara** (issue 9 de v0.1, aún abierto) — junto con el quiff en curso.
6. **Islas flotantes, god rays, manos** — en ese orden.

## Juicio final

La pregunta de Boris es si la base aguanta construir algo memorable encima.
Mi lectura imparcial: **el pipeline de render sí — el personaje todavía no, y
Dagna claramente no.** El registro Melancolía Gráfica está demostrado en motor
(el dusk lo prueba); sus dos defectos graves (sombra aplastada, rojo de
peligro) son de shader, no estructurales, y arreglarlos sube todos los
dominios a la vez. El humano tiene los cimientos de proporción correctos por
primera vez, pero congelar la silueta actual —con costuras de maniquí y cara
placeholder— repetiría el error que la review v0.1 advirtió: todo lo que se
construya encima (rig, poses C4, vestuario, LODs) hereda la base. El orden del
plan vigente (cerrar C6 antes de Fase 2) es el correcto; lo que esta auditoría
añade es que **los dos fixes de pipeline (C1, C2) deberían entrar en la
ventana actual**, porque hoy ninguna captura puede ponerse honestamente al
lado de los keyframes sin que la sombra negra y el cristal rosa delaten la
distancia. Con esos dos resueltos, el proyecto tiene por primera vez un
"golden" que defiende el norte por sí solo.

**Fidelidad global: ~55%. Tendencia: ascendente y con dirección correcta —
pero aún no es base sólida en el dominio personaje.**
