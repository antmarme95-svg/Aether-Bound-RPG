# Minado — "Drawing an archetypal figure: 2D female" (Anatomy for 3D Artists, 3dtotal)
Autor del capítulo: Chris Legaspi. Páginas impresas 43–65 (23 imágenes, todas leídas).
Síntesis propia; ninguna cita ni imagen reproducida.

> **Advertencia de cobertura:** el capítulo arranca en la p.42 (Part 01 | Proportions, secciones "01: …" que preceden a lo que aparece en p.43). **La p.42 NO está en el set entregado.** Todo el aparato numérico del capítulo vive en esa sección de proporciones, y lo único que sobrevive en el set es su cola (p.43). Es muy probable que las medidas faltantes estén en la página ausente. **Recomendación: conseguir p.042 y re-minar.**

## Tabla maestra de proporciones

| Medida | Valor | Unidad | Página | Texto o diagrama |
|---|---|---|---|---|
| Altura total de la figura | 8 | cabezas | 43 | texto + diagrama (fig.01c, cabezas apiladas con líneas guía) |
| Cabeza + torso (vértice → base de la pelvis / ingle) | 4 | cabezas | 43 | texto (fig.01b) |
| Piernas (base de la pelvis → planta del pie) | 4 | cabezas | 43 | texto (derivado explícito: "las últimas cuatro cabezas") |
| Base de la caja torácica | mitad del torso, midiendo desde el tope de los hombros | fracción de torso | 43 | texto |
| Centro horizontal de la cabeza (línea de los ojos) | 1/2 | de la altura de la cabeza | 43 | texto |
| Centro vertical de la cabeza (eje de la nariz) | 1/2 | del ancho de la cabeza | 43 | texto |
| Cara dividida en tercios iguales (línea del pelo, arco superciliar, base de la nariz, base del mentón) | 3 × 1/3 | de la cara | 43 | texto ("rule of thirds") |
| Costillas de la caja torácica | 12 | pares | 47 | texto |
| Vértebras de la columna | 33 | huesos | 47 | texto |
| Dientes | 32 | piezas | 49 | texto |
| Ángulo de la mandíbula (hacia la oreja) | ~90 | grados | 53 | texto ("casi ángulo recto") |
| Rango de movimiento del hombro (rótula) | 360 | grados | 58 | texto |
| Rango de movimiento de la cadera (rótula) | 360 | grados | 59 | texto |
| Músculos del cuerpo (referencia) | >600 | músculos | 54 | texto |
| Músculos de cabeza y cara | >40 | músculos | 56 | texto |

Nota: de la fig.01c (p.43) se puede leer que la figura ocupa exactamente ocho módulos de cabeza apilados con líneas guía horizontales; el libro **no rotula** en esa figura qué landmark cae en cada línea. Cualquier lectura de pezón/ombligo/entrepierna sobre esa figura sería interpolación mía → no se reporta.

## Diferencial numérico vs. la figura masculina

| Rasgo | Valor femenino | Valor masculino declarado | Página |
|---|---|---|---|
| Altura total | 8 cabezas | no declarado en este capítulo | 43 |
| Pecho / senos como diferencia sexual principal | cualitativo: grasa y tejido mamario sobre el pectoral, curva suave, no rígida ni puntiaguda | no declarado | 63 |
| Cresta ilíaca más visible en mujeres | cualitativo, sin cifra | no declarado | 50 |
| Ancho de caja torácica / ancho de hombro / inclinación pélvica | **ausente** | **ausente** | — |

**Hallazgo negativo duro:** este capítulo **no** pone cifras a la cadena causal "caja torácica menor → hombros más juntos". No la menciona siquiera. El único diferencial sexual que el capítulo enuncia es el pecho (p.63) y la visibilidad de la cresta ilíaca (p.50), ambos cualitativos.

## Proporciones idénticas (candidatas a constante en el código)

Todo lo siguiente se enuncia sin marca de sexo, es decir, como estructura común:

- Reparto 4 cabezas arriba / 4 cabezas abajo sobre un total de 8 (p.43). El **50/50 torso-piernas** es la constante estructural más fuerte del capítulo.
- La base de la caja torácica en la mitad del torso (p.43).
- Regla de tercios de la cara y ejes medios de la cabeza (p.43).
- Conteos óseos: 12 pares de costillas, 33 vértebras, 32 dientes, pelvis de 3 huesos fusionados (pp.47, 49).
- Articulaciones esféricas de hombro y cadera con 360° de rango (pp.58, 59).
- Cadena de segmentos declarada sin longitudes: brazo = húmero + (radio+cúbito) + mano; pierna = fémur + (tibia+peroné) + pie (p.47). Sirve como topología del rig, **no** como medida.

## Alturas de landmarks (eje vertical, de arriba abajo)

El capítulo enumera landmarks **anatómicos** (dónde el hueso toca la piel), no **métricos** (a qué altura caen). Ninguno lleva cota. Lista, con su página, para uso como puntos de rig:

| Landmark | Altura declarada | Página |
|---|---|---|
| Eminencia frontal | — | 52, 53 |
| Arco superciliar | — | 52, 53 |
| Hueso nasal | — | 52, 53 |
| Hueso cigomático (pómulo) | — | 52, 53 |
| Ángulo de la mandíbula | — | 52, 53 |
| Tubérculo mentoniano (mentón) | — | 52, 53 |
| 7ª vértebra cervical (C7, base del cuello) | — | 50 |
| Acromion / clavículas | — | 49, 50 |
| Escotadura supraesternal (yugular) | — | 49 |
| Esternón | — | 50 |
| Apófisis xifoides | — | 49 |
| Escápula: espina / ángulo inferior | — | 50 |
| 10ª costilla | — | 49, 50 |
| Cresta ilíaca (justo debajo del ombligo) | **relativo, sin cifra**: por debajo del ombligo; marca el fin del abdomen y el inicio de la cadera | 50 |
| Olécranon (codo) | — | 50 |
| Apófisis estiloides del cúbito / radio (muñeca) | — | 49, 53 |
| Trocánter mayor (cadera) | — | 51, 52 |
| Sacro y cóccix | — | 52 |
| Rótula | — | 51 |
| Cabeza del peroné | — | 51 |
| Cresta anterior de la tibia | — | 51 |
| Maléolo lateral / medial (tobillo) | — | 51, 52 |
| Calcáneo (talón) | — | 51 |
| Falanges distales | — | 49, 51 |

Único landmark con posición **relativa** declarada en todo el capítulo: la cresta ilíaca respecto al ombligo (p.50).

## Vacíos

Ausentes por completo en las 23 páginas leídas:

1. **Ancho de hombros** — en cabezas o en fracción de altura. Ausente.
2. **Ancho de caja torácica.** Ausente.
3. **Ancho de cintura.** Ausente.
4. **Ancho de cadera.** Ausente.
5. **Ancho de cabeza en términos absolutos** (solo se dice que su eje vertical la parte a la mitad). Ausente.
6. **Razón hombro/cadera.** Ausente. Es el vacío principal.
7. **Inclinación pélvica en grados.** Ausente.
8. **Altura del pezón, ombligo, entrepierna, rodilla, codo, muñeca, mentón, hueco supraesternal.** Todas ausentes como cota.
9. **Largo de cuello.** Ausente.
10. **Largos de segmento**: cabeza (como longitud absoluta), húmero, antebrazo, mano, muslo, pierna, pie. Todos ausentes.
11. **Diferencial masculino/femenino cifrado** (altura en cabezas del varón, ancho relativo de tórax). Ausente.
12. **Grosor / profundidad** de cualquier volumen. Ausente.

Causa probable de 1–11: la sección "Part 01 | Proportions" empieza en la p.42, que no está en el set. Este capítulo, tal como se entregó, es 1 página de proporciones (43) + gesto/construcción (44–45) + esqueleto (46–53) + músculos (54–61) + iluminación de la piel (62–65). Las tres últimas partes son puramente descriptivas y no cotan nada.
