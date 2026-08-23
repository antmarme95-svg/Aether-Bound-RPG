---
status: BORRADOR — propuesta, pendiente de validación del director
source: "Respuesta al bloque 'Preguntas/Dudas Toño a Claude' de [[Principios de Anatomía 3D]] (DOF). Insumos: las notas de DOF del director · lectura directa de `godot/character/rig_biomech.gd` y `character_rig.gd` (rama feat/dagna-rig, 2026-08-21) · el minado del cap. 7 del libro de anatomía (ritmo escapulohumeral con números)."
updated: 2026-08-21
---

# Grados de Libertad (DOF) del rig — documentación agnóstica de motor

> Contesta la pregunta que el director dejó abierta en
> [[Principios de Anatomía 3D]] §Preguntas/Dudas. **Agnóstico de motor a
> propósito:** describe articulaciones, ejes, rangos y **acoplamientos**, sin
> nombrar una sola API de Godot. Lo que aquí se decide sobrevive a un cambio
> de motor; lo que vive en `rig_biomech.gd` no.

## La tesis, antes de las tablas

**El conteo de DOF no es una meta, es un diagnóstico.** La propia nota del
director lo dice: un juego nunca usa los 21 DOF reales de una mano, y más DOF
significa infinitas soluciones de IK y más costo. Así que la pregunta correcta
**no** es "¿cuántos DOF nos faltan?" sino, por cada DOF ausente:

> **¿su ausencia produce un defecto que se ve?**

Con ese filtro, de los ~150 DOF que la anatomía enumera, **12** merecen
construirse y el resto no. Y los 12 no están repartidos: **6 son la cintura
escapular**, que es exactamente donde el rig falla hoy a la vista.

## Inventario real del rig (medido, no estimado)

Leído de `rig_biomech.gd` §ROM y de las llamadas a `clamp_node` en
`character_rig.gd:3890-3908`. Un eje cuenta como DOF si su rango no es cero.

| Articulación | Ejes con rango | DOF | ×N | Total |
|---|---|---|---|---|
| `hips_root` (pelvis) | x, y, z | 3 | 1 | 3 |
| `spine` (lumbar) | x, y, z | 3 | 1 | 3 |
| `spine_upper` (torácico) | x, y, z | 3 | 1 | 3 |
| `head` | x, y, z | 3 | 1 | 3 |
| `shoulder` | x, y, z | 3 | 2 | 6 |
| `elbow` | x (bisagra) | 1 | 2 | 2 |
| `hip_leg` | x, y, z | 3 | 2 | 6 |
| `knee` | x (bisagra) | 1 | 2 | 2 |
| `ankle` | x, z | 2 | 2 | 4 |
| | | | | **32** |

## Contraste con la anatomía, por región

| Región | Anatómico (notas del director) | Rig | Veredicto |
|---|---|---|---|
| **Miembro inferior** (por lado, con pelvis) | 9 | **9** | ✅ **Completo.** El eje z del tobillo ya modela la subastragalina (inversión/eversión). No falta nada. |
| **Miembro superior** (por lado) | 10 | **4** | ❌ Faltan 6: escápula 3, pronosupinación 1, muñeca 2. |
| **Columna** | 72 | 6 (+3 de `head` como proxy cervical) | ⚠️ Deliberadamente reducido. Correcto — ver abajo. |
| **Mano** (por lado) | 21 | **0** | ⚠️ Correcto por ahora. |

El miembro inferior estando completo no es casualidad: es el que ya pasó por
playtest y por el frente de foot IK. **Lo que se mide, se completa.**

## Lo que falta y NO hay que construir

- **Columna vertebral segmento a segmento (72 DOF).** La propia nota del
  director da el argumento: la amplitud por vértebra es de 2° a 15°. Dos
  segmentos con acoplamiento correcto rinden más que veinticuatro sin él.
  **Lo que sí falta en la columna no es un DOF, es un parámetro no
  rotacional** — ver §Hallazgo del libro.
- **Dedos de la mano (21 por mano).** Un DOF de abrir/cerrar, y solo el día
  que un Pivote aparezca en primer plano sosteniendo algo. Ni antes ni más.
- **Un cuarto segmento de columna / cervical propio.** El pivote de la cabeza
  está mal puesto, que es un problema distinto y más barato — ver abajo.

## Lo que falta y SÍ hay que construir — 12 DOF

Ordenados por daño visible actual.

### 1. Complejo escapulotorácico — +3 por lado (6)

**El único DOF ausente que ya está produciendo un defecto reportado.** Las
hombreras-compuerta de Dagna flotan fuera del brazo y los brazos se despegan
del torso. Causa: el hombro es un ball joint de 3 DOF anclado a un punto fijo;
sin escápula, el eje del brazo **no se mueve nunca**.

Estado en el código: existe un `acromion` (`character_rig.gd:776-780`) pero es
**una caja decorativa parenteada al torácico en posición fija** — silueta, no
cinemática. Las clavículas se eliminaron por leer como placas de armadura
(`:513`). O sea: la pieza está dibujada y no articulada.

Ejes: elevación/depresión · protracción/retracción · báscula.

### 2. Roll del antebrazo (pronosupinación) — +1 por lado (2)

El más barato de los tres y con retorno inmediato en un juego con armas: sin
pronosupinación **no se puede sostener creíblemente un arma a dos manos**, y
el elenco entero las lleva. No es una articulación nueva: es habilitar el eje
de giro longitudinal sobre el nodo de antebrazo que ya existe.

Nota del minado del cap. 7: **sin acoplar el roll del húmero, la abducción se
traba anatómicamente a 90°** — o sea que este DOF también desbloquea rango en
el hombro.

### 3. Muñeca — +2 por lado (4)

Hoy la mano cuelga rígida del antebrazo. Es el mismo tipo de defecto que
tenía el pie antes del foot IK (la bota colgaba rígida del nodo de rodilla,
ver el comentario de `ankle` en `rig_biomech.gd`), y se resolvió igual de
barato. Ejes: flexión/extensión · desviación radial/cubital.

**Total: 32 → 44 DOF.**

## El hallazgo que cambia el modelo, y no es un DOF

`rig_biomech.gd` trata **cada eje como independiente**: `clamp_node` recorta
x, y, z por separado contra una tabla de rangos. La anatomía no funciona así —
funciona por **cadenas acopladas**. El rig no tiene *ningún* acoplamiento.

Tres acoplamientos con evidencia, listos para escribirse:

1. **Ritmo escapulohumeral** (minado cap. 7, con números): de 0° a 30° de
   abducción la escápula no se mueve; a partir de ahí aporta 1° por cada 2°
   del húmero, con techo de ~75° de elevación.
   `escapula = clamp((abducción − 30) / 2, 0, 75)`.
   Y con el brazo arriba **el acromion cambia de orientación**: la hombrera no
   solo sube, gira su cara. Eso es el defecto de la hombrera flotante,
   contestado con una fórmula.
2. **Asimetría lumbar/torácico** (cap. 7): en extensión extrema el lumbar se
   acorta ~30% y el torácico ~1%, por la rigidez de la caja torácica.
   **Esto no es un DOF: es una escala longitudinal.** El torácico debe ser
   rígido en su eje largo y toda la escala vivir en el lumbar. El rig hoy
   modela la diferencia solo en rango de rotación (el torácico es ~60% del
   lumbar) y no tiene nada de escala. Es el parámetro más barato de la lista.
3. **Acumulación de torsión**: la torsión se suma desde la pelvis — el
   torácico carga la suya más la del lumbar. Hoy son independientes.

**Recomendación de método:** la tabla de ROM se queda como está (define el
espacio legal), y se le agrega **una tabla de acoplamientos** que define el
espacio *anatómicamente probable* dentro de él. Son dos conceptos distintos y
hoy solo existe el primero.

## Corrección barata, aparte de todo lo anterior

El pivote de rotación de la cabeza está en `HEAD_Y`, en el centro del cráneo.
El minado del cap. 5 dice que **el pivote real va bajo las orejas**. No es un
DOF nuevo ni una articulación nueva: es mover un número. Probablemente la
mejor relación arreglo/costo de todo el documento.

## Qué queda por decidir (director)

1. ¿Se ratifica este recorte — 12 DOF nuevos y ni uno más?
2. ¿Los acoplamientos entran como tabla propia junto al ROM, o como código
   en el constructor?
3. ¿Dónde vive esta página: sección de [[Principios de Anatomía 3D]], o
   página propia de `10-Knowledge/`? (Es tecnología de personaje, no
   anatomía minada de un libro — se inclina a página propia.)
