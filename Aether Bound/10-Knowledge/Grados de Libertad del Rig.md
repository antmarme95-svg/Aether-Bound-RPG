---
status: ratificado
source: "Contesta el bloque 'Preguntas/Dudas Toño a Claude' que quedó abierto dentro de [[Principios de Anatomía 3D]]. Insumos: las notas de DOF del director (complejo escapulotorácico, miembro inferior, columna, mano) · inventario MEDIDO sobre `godot/character/rig_biomech.gd` y las llamadas a `clamp_node` de `character_rig.gd:3890-3908` (rama `feat/dagna-rig`, 2026-08-21) · el barrido del libro de anatomía, que aportó el ritmo escapulohumeral cifrado (`90-Raw/research/minado-anatomia-3d-2026-08-21/`). RATIFICADO por el director 2026-08-21: el recorte de 12 DOF y esta página como fuente única del tema."
updated: 2026-08-21
---

# Grados de Libertad del Rig

> **Agnóstico de motor a propósito.** Describe articulaciones, ejes, rangos y
> **acoplamientos** sin nombrar una sola API de Godot. Lo que se decide acá
> sobrevive a un cambio de motor; lo que vive en `rig_biomech.gd` no.
>
> Fuente única del tema. [[Principios de Anatomía 3D]] es anatomía minada de
> un libro; esto es tecnología de personaje.

## La tesis

**El conteo de DOF no es una meta, es un diagnóstico.** Un juego nunca usa
los 21 DOF reales de una mano: más DOF significa infinitas soluciones de IK y
más costo. Así que la pregunta correcta **no** es "¿cuántos DOF faltan?" sino,
por cada DOF ausente:

> **¿su ausencia produce un defecto que se ve?**

Con ese filtro, de los ~150 DOF que la anatomía enumera, **12 se construyen y
el resto no**. Y no están repartidos: **6 son la cintura escapular**, que es
exactamente donde el rig falla a la vista.

## Inventario del rig — 32 DOF (medido, no estimado)

Un eje cuenta como DOF si su rango no es cero.

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

## Contraste con la anatomía

| Región | Anatómico | Rig | Veredicto |
|---|---|---|---|
| **Miembro inferior** (por lado, con pelvis) | 9 | **9** | ✅ **Completo.** El eje z del tobillo ya modela la subastragalina. |
| **Miembro superior** (por lado) | 10 | **4** | ❌ Faltan 6: escápula 3, pronosupinación 1, muñeca 2. |
| **Columna** | 72 | 6 (+3 de `head` como proxy cervical) | ⚠️ Reducido a propósito, y está bien. |
| **Mano** (por lado) | 21 | **0** | ⚠️ Correcto por ahora. |

Que el miembro inferior esté completo no es casualidad: es el que pasó por
playtest y por el frente de foot IK. **Lo que se mide, se completa.**

## Lo ratificado: 12 DOF nuevos, ni uno más

Por orden de daño visible.

### 1. Complejo escapulotorácico — +3 por lado (6 DOF)

**El único DOF ausente que ya produce un defecto reportado.** Las
hombreras-compuerta de Dagna flotan fuera del brazo y los brazos se despegan
del torso: sin escápula, el hombro es un ball joint anclado a un punto fijo y
**el eje del brazo no se mueve nunca**.

Estado actual: existe un `acromion` (`character_rig.gd:776`) pero es **una
caja decorativa en posición fija** — silueta, no cinemática. Las clavículas se
eliminaron por leer como placas de armadura (`:513`). La pieza está dibujada y
no articulada.

Ejes: elevación/depresión · protracción/retracción · báscula.

### 2. Roll del antebrazo (pronosupinación) — +1 por lado (2 DOF)

El más barato, y con retorno inmediato en un juego con armas: sin
pronosupinación **no se sostiene creíblemente un arma a dos manos**, y el
elenco entero las lleva. No es articulación nueva — es habilitar el giro
longitudinal sobre el nodo de antebrazo existente.

Efecto secundario documentado: **sin acoplar el roll del húmero, la abducción
se traba anatómicamente a 90°**. Este DOF también desbloquea rango en el
hombro.

### 3. Muñeca — +2 por lado (4 DOF)

Hoy la mano cuelga rígida del antebrazo — el mismo defecto que tenía la bota
antes del foot IK (colgaba rígida del nodo de rodilla, ver el comentario de
`ankle` en `rig_biomech.gd`). Se resuelve igual de barato.
Ejes: flexión/extensión · desviación radial/cubital.

**Total ratificado: 32 → 44 DOF.**

## Lo que explícitamente NO se construye

- **Columna vértebra a vértebra (72 DOF).** La amplitud por vértebra es de 2°
  a 15°. Dos segmentos con acoplamiento correcto rinden más que veinticuatro
  sin él. Lo que falta en la columna **no es un DOF** — ver abajo.
- **Dedos (21 por mano).** Un DOF de abrir/cerrar, y solo el día que un Pivote
  aparezca en primer plano sosteniendo algo.
- **Un cervical propio.** El problema real es que el pivote de la cabeza está
  mal puesto, que es más barato — ver §Correcciones.

## Acoplamientos: el modelo que falta

`rig_biomech.gd` trata **cada eje como independiente** — recorta x, y, z por
separado contra una tabla de rangos. La anatomía funciona por **cadenas
acopladas**, y el rig no tiene *ninguna*.

**Regla:** la tabla de ROM define el espacio **legal**; una tabla de
acoplamientos define el espacio **anatómicamente probable** dentro de él. Son
dos conceptos distintos y hoy solo existe el primero.

Tres acoplamientos con evidencia, listos para escribirse:

1. **Ritmo escapulohumeral.** De 0° a 30° de abducción la escápula no se
   mueve; de ahí en adelante aporta **1° por cada 2° del húmero**, con techo
   de ~75° de elevación:
   `escapula = clamp((abducción − 30) / 2, 0, 75)`.
   Y con el brazo arriba **el acromion cambia de orientación**: la hombrera no
   solo sube, gira su cara. Es el defecto de la hombrera flotante contestado
   con una fórmula.
2. **Asimetría lumbar/torácico.** En extensión extrema el lumbar se acorta
   ~30% y el torácico ~1%, por la rigidez de la caja torácica. **No es un DOF:
   es una escala longitudinal.** El torácico debe ser rígido en su eje largo y
   toda la escala vivir en el lumbar. Hoy el rig modela la diferencia solo en
   rango de rotación (el torácico es ~60% del lumbar) y no tiene nada de
   escala. **El parámetro más barato y de mayor retorno de esta página.**
3. **Acumulación de torsión.** La torsión se suma desde la pelvis: el torácico
   carga la suya más la del lumbar. Hoy son independientes.

## Correcciones baratas, aparte de los 12 DOF

- **El pivote de rotación de la cabeza va bajo las orejas**, no en el centro
  del cráneo (`HEAD_Y`). No es un DOF nuevo ni una articulación nueva: es
  mover un número. Probablemente la mejor relación arreglo/costo de todo el
  frente. **Ojo:** es distinto del pivote de *apertura de mandíbula*, que va
  delante de la oreja bajo el arco cigomático y ya está descrito en
  [[Principios de Anatomía 3D]].
- **Muñecas y tobillos conservan el tamaño de la figura promedio** aunque el
  resto del cuerpo crezca. Es el **contraste**, no el engrosamiento uniforme,
  lo que hace leer la masa. El rig hoy escala extremidades enteras por un
  multiplicador.

## Abierto (decisión de implementación, no bloquea)

¿Los acoplamientos entran como **tabla propia** junto al ROM, o como **código**
en el constructor? Se decide al escribirlos. La tabla es más auditable y más
fácil de portar a otro motor; el código es más directo para las leyes que
dependen del orden de construcción.
