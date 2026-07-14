---
status: código de los 13 puntos EJECUTADO (2026-07-14 noche) — pendiente QA visual de cierre + VoBo de Boris
source: "QA visual imparcial (subagente Fable, sin contexto previo, ~32% de fidelidad contra `fenotipo-humano-v1.png`/`fenotipo-humano-torso-v1.png`) + subagente técnico (lectura de `character_rig.gd`/`hair_library.gd`/`palette_data.gd`/`phenotype_data.gd`/`tmp_anatomy.gd`) + ratificación cruzada de Fable sobre el plan técnico — los tres coordinados por el orquestador"
updated: 2026-07-14
---

> **Nota de ejecución (2026-07-14 noche):** los 13 puntos están implementados
> y pasan QA de regresión completo. Detalle punto por punto, incluyendo 2
> correcciones encontradas sobre este mismo documento (índice de warpaint 6
> NO era inválido; la asignación estática de columna se hubiera borrado
> sola por el sistema de settle), en [[LOG]] y [[Current-State]]. Falta el
> QA visual de cierre (mismo protocolo del 32%) + VoBo de Boris antes de
> considerar la Definición de Terminado (abajo) satisfecha.

# PRD — Rework de fenotipo humano (cuerpo completo, post-cierre Fase C)

> Nota de numeración: igual que [[PRD-Fase-C-Ajuste-Facial]], este documento
> NO usa un número de la secuencia PRD-008+ (reservada en
> [[Plan-de-Produccion]] para gameplay futuro). Es un rework técnico/artístico
> dentro de la ventana C6, con alcance MÁS AMPLIO que el PRD anterior: cubre
> cuerpo completo (torso, hombros, manos, columna), no solo cara.

**Objetivo:** cerrar la brecha detectada por un QA visual imparcial corrido
sobre el estado "cerrado" de la Fase C (mentón corregido, barba fuera del
default, `f1ccec3`) — veredicto **~32% de fidelidad global** contra las dos
láminas RAW del fenotipo humano. A diferencia del [[PRD-Fase-C-Ajuste-Facial]]
(que solo miraba cara), esta ronda evaluó **cuerpo completo** (`anatomy_full_front.png`,
`anatomy_full_side.png`, `anatomy_close.png`, `anatomy_medium.png`,
`anatomy_hands.png` además de los 4 renders de cara) y encontró que el 75% de
fidelidad facial alcanzado por el [[QA Loop]] anterior **no se sostiene** cuando
se juzga el personaje completo: pelo, torso y manos siguen en territorio de
"maniquí técnico".

## Origen del proceso — por qué este PRD existe

Boris identificó una laguna de proceso recurrente: el feedback de arte
("la mandíbula se ve como bloque", "el pelo no se parece") no se traduce de
inmediato a un requerimiento técnico preciso (qué mesh, qué valor, cuánto
cambiar), y eso obliga a iterar muchas más rondas de las necesarias (ver el
historial de 8+ rondas del [[QA Loop]] anterior). Para romper el patrón, este
PRD se construyó con **tres roles separados que se corrigen entre sí antes de
tocar código**:

1. **QA visual (Fable, sin contexto de código)** — mide fidelidad contra la
   lámina, hallazgos priorizados CRITICAL→LOW.
2. **Técnico (lee `character_rig.gd` y afines)** — traduce cada hallazgo a
   archivo/línea/valor numérico concreto, y señala cuándo un hallazgo de
   arte es en realidad un **falso positivo de código** (ya resuelto) o un
   **bug de orden de ejecución** (no un problema de diseño).
3. **Ratificación cruzada** — el mismo QA (Fable) revisa la traducción
   técnica contra las imágenes de nuevo, confirma o corrige. Esto detectó 2
   errores reales en la primera pasada (ver abajo) ANTES de escribir una
   sola línea de código.

## Correcciones detectadas en el propio proceso de traducción (antes de implementar)

- **Falso positivo retirado:** el hallazgo original "mentón como bloque
  separado tipo títere" **no es un problema de `chin_boss`** — es la misma
  geometría de boca abierta (relleno negro plano) mal interpretada como
  mandíbula. `chin_boss`/`jaw_mesh` NO se tocan.
- **Diagnóstico de "marcas cian/brazalete gris" cerrado por completo:** no
  hay ningún nodo de gear/accesorio fantasma — el pauldron ya está oculto en
  el banco de pruebas (`tmp_anatomy.gd:75`). Lo que se ve es (a) un bug real
  de orden de ejecución en `apply_phenotype()` (el color `accent` se usa
  para pintar venas ANTES de que el bloque de tema del origin lo actualice)
  combinado con `arcaneMod` default en `0.25` (activa venas de mana que no
  deberían existir en el fenotipo humano base), y (b) el `_arm_stripe` verde
  ya identificado como parte del warpaint (bicep izquierdo).
- **Trapecio vs. ancho de hombro:** el hallazgo "hombros angostos" no se
  resuelve solo con el ángulo del trapecio — `SHOULDER_X`/`SHOULDER_Y`
  (`character_rig.gd:39-40`) ya están calibrados contra una medición de
  lámina de una sesión anterior (biacromial ~2.05 cabezas). El plan trata
  el ángulo del trapecio como el fix de menor riesgo a probar primero, y dejar
  la posible reapertura de `SHOULDER_X` como **decisión de Boris**, no como
  ejecución automática, si la silueta sigue leyendo angosta después.
- **Cejas y columna:** los valores iniciales propuestos por el técnico
  (cejas solo más delgadas, columna -0.05 rad) fueron señalados por Fable
  como insuficientes contra la lámina — ver valores corregidos abajo.

## Plan de ejecución — orden por dependencia (para minimizar retrabajo)

El criterio: primero lo que otros sistemas ANCLAN (pelo depende de
cráneo/hombros; warpaint depende de torso; manos dependen de brazo), y el
único cambio de riesgo alto sobre biomecánica queda al final con su propio
ciclo de QA.

### 🔴 CRITICAL

1. **Bug de orden `accent`/venas + `arcaneMod` default — venas cian
   contaminando cualquier render.** `character_rig.gd`: mover el bloque de
   actualización de `accent` por tema de origin (~L1957-1967) a ANTES del
   cálculo de `vein_mat.albedo_color` (~L1783). `phenotype_data.gd:18`:
   bajar default de `arcaneMod` de `0.25` a `0.0` para el fenotipo humano
   base (no pertenece al humano canónico — es una feature de "modificación
   arcana" opcional). **Primero en la cola**: cualquier render de
   verificación posterior queda limpio de ruido cian.
   - *Riesgo:* confirmar que nada más lee `accent` entre esas líneas.
   - *Verificación:* re-render `tests/tmp_anatomy.gd`, confirmar venas
     ocultas por default.

2. **Pelo — estilo equivocado en el banco de pruebas.** `tmp_anatomy.gd:62`:
   `pheno["hair"]` está en `11` (Prince Curtain, melena de 22 cintas —
   coincide con la lectura de Fable "pulpo de madera sobre un balón").
   Cambiar a **`10`** (Frontier Crop, el propio código lo etiqueta como el
   canon del fenotipo humano — quiff corto + laterales con fade).
   - *Riesgo:* ninguna dependencia de biomecánica (el pelo no colisiona con
     nada).
   - *Verificación obligatoria (no cerrar solo con el swap):* Fable advierte
     que si el estilo 10 resulta ser la misma lógica de cintas en versión
     corta, seguirá sin parecerse a "corte corto con volumen compacto" de
     la lámina — re-renderizar y comparar antes de dar el hallazgo por
     cerrado.

3. **Torso robótico/facetado — trapecios como cajas.** `character_rig.gd:475`:
   los trapecios son `BoxMesh(0.19, 0.09, 0.08)` rotados sobre el cilindro
   del torso — una caja de caras planas intersectando un cilindro siempre
   deja arista visible. Sustituir por el mismo patrón "esfera escalada
   semi-hundida" que ya funciona en pecs/deltoides: ej.
   `_sphere_mesh(0.10, skin_mat)` con `scale=Vector3(1.6, 0.6, 0.7)`,
   posición mantenida `Vector3(tside*0.115, 0.315, 0.0)`.
   - *Riesgo:* aislado de `_apply_build` (que solo escala
     torso/pelvis/waist). Re-medir silueta con el banco tras el cambio.

### 🟠 HIGH

4. **Hombros — ángulo del trapecio (primer paso, no definitivo).**
   `character_rig.gd:477`: `trap.rotation.z` de `±0.40` rad → **`±0.28` rad**
   (~16°). Ejecutar DESPUÉS del punto 1 (venas limpias) y ANTES del pelo
   (punto 5) porque el pelo se ancla a la silueta cráneo/hombro.
   - *Riesgo:* puede reabrir la costura pecho-hombro (calibrada
     específicamente para el ángulo actual, comentario `character_rig.gd`
     L528-533) — verificar visualmente el solape tras el cambio.
   - *Punto de decisión de Boris:* si tras este cambio + re-medición con la
     regla de cabezas del banco la silueta SIGUE leyendo angosta, la
     siguiente palanca es `SHOULDER_X` (hoy 0.21) — pero eso reabre un
     debate ya resuelto con datos de lámina en sesión previa. No tocar sin
     confirmación explícita.

5. **Orejas — verificación pasiva, no acción nueva.** La geometría ya
   existe (`character_rig.gd:2269-2300`, esfera + lóbulo). Ejecutar
   inmediatamente después del punto 2 (swap de pelo): si el estilo 10 libera
   la zona y las orejas aparecen, cerrado. Fable confirma que hoy están
   enterradas en TODOS los ángulos por la capa `nape` del estilo 11 — si
   con el estilo 10 el `shell` (`hair_library.gd` línea 328,
   `scale=(0.85,0.72,0.98)`) las sigue tapando, ajustar ese radio.

6. **Manos — dedos sin separación real ni nudillos.**
   `character_rig.gd:620-658`: gap actual entre dedos es de solo ~0.38mm
   (`f_off` = `[0.022, 0.0073, -0.0073, -0.022]`, prácticamente fundido pese
   a que el comentario histórico dice "~3mm"). Cambiar a
   `f_off = [0.025, 0.010, -0.010, -0.025]` (gap efectivo ~1.4mm limpio).
   Agregar esfera-nudillo pequeña (r≈0.006) semi-hundida en la base de cada
   dedo (mismo patrón de overlap real que codo/rodilla). Pulgar: de
   `_box_mesh` de sección uniforme a cápsula/cono para que no lea "ranura
   paralela".
   - *Riesgo:* verificar si `weapon_data.gd` o algún socket de arma depende
     de la geometría exacta del dedo (no confirmado en esta pasada).
   - *Verificación:* re-render `anatomy_hands.png`.

### 🟡 MEDIUM

7. **Warpaint — franja horizontal-diagonal → 2 trazos verticales (CONFIRMADO
   por Fable contra la lámina).** `character_rig.gd:1902-1927`: reemplazar
   `fm_cheek` (caja `0.075×0.007×0.006`, diagonal `z=0.45,y=-0.50`) por 2
   cajas delgadas verticales, ej. `_box_mesh(0.006, 0.045, 0.005, fm_mat)`,
   bajando desde el nacimiento del pelo/ceja (`brow`, `y=0.038,z=0.133`)
   hacia el pómulo — Fable confirma explícitamente: "dos trazos verticales
   que bajan desde el nacimiento del pelo cruzando ceja/sien izquierda hacia
   el pómulo, no diagonal ni horizontal".
   - Ejecutar DESPUÉS del punto 3 (torso/pómulo en forma final) para no
     reposicionar dos veces sobre un contorno que todavía va a cambiar.
   - También corregir en `tmp_anatomy.gd:64-65`: `pheno["warpaint"]=6` es un
     **índice inválido** (el array `WARPAINTS` solo llega a 5) — fijar a un
     valor válido y decidir si `_arm_stripe` (L1876-1894) se elimina del
     fenotipo humano base o se condiciona a un warpaint específico (Fable no
     confirma que la banda de brazo exista en la lámina).

8. **Boca — relleno/sombreado, NO posición (reencuadrado tras corrección de
   Fable).** El gap Y entre `lip_upper`/`lip_lower` ya es correcto (no es el
   hallazgo #5 original, que se retiró). El problema real es el
   relleno/material del interior de la boca (negro plano, lee como
   hueco/prótesis). Fix: usar un tono de labio oscurecido (`lip_mat`
   existente) en vez de negro plano en `mouth_seam`, o cerrar el gap Y si el
   hueco es demasiado grande a la escala de cámara del banco. Ejecutar
   DESPUÉS del punto 7 (comparten zona con warpaint facial, evitar
   confundir ajustes).

9. **Nariz — prisma muy ancho/duro en frontal.** `character_rig.gd:861-867`:
   `bot_r` de `0.026` → `0.019`; `radial_segments` de `4` (pirámide visible)
   → `6-8` (suaviza facetas sin perder el quiebre de tono frontal
   deliberado de la Ronda 8 anterior).
   - *Riesgo:* las "alas" hijas (`ala`, L874-879, `z=0.132`) dependen del
     ancho de la punta de la nariz (`z=0.139`) para fundirse — verificar que
     no queden flotando tras angostar la base.

10. **Cejas — fix rápido + posible segunda pasada.** `character_rig.gd:1091`:
    `BoxMesh(0.048,0.011,0.010)` → `(0.040,0.006,0.010)` como primer paso
    (bajo riesgo, mismo mesh). **Fable señala que esto no da arco real** —
    si tras el cambio Boris ve que sigue leyendo recta, la segunda pasada
    es una cadena de 2-3 cápsulas/esferas decrecientes (mismo patrón que
    `_braid` de `hair_library.gd`), aplicando la rotación de `eyeTilt`
    (`apply_phenotype` L1846) al nodo padre del grupo, no a una malla única.

11. **Piel — investigar antes de tocar (no es necesariamente el color base).**
    `skin_mat` base y `SKIN_TONES[0]="#ffd9b8"` ya son objetivamente
    cálidos/rosados — el "grisáceo apagado" que ve Fable probablemente viene
    del LUT del post (`melancolia_post.gdshader`) o de la luz "dawn" del
    banco, no del hex de piel. Aislar comentando temporalmente
    `_gs.attach_post` (`tmp_anatomy.gd:102`) para un frame de control. **Si
    el post lo confirma, no tocar sin aprobación explícita de Boris** — el
    LUT afecta TODO el juego, no solo este personaje. Si no, subir
    `ambient_lift` de `toon_opaque.gdshader:26` de `0.14` a `~0.20`.

### 🟢 LOW / riesgo alto — al final, aislado

12. **Abdomen — "óvalo sin correspondencia" en la lámina.**
    `character_rig.gd:430-444`: `abs_plate.scale.z` de `0.4` → **`0.30`**
    como primer paso; `scale.x` de `1.1` → `1.25` (borde más gradual contra
    el cilindro). Fable duda que `0.30` sea suficiente — **si el render
    sigue leyendo "óvalo" tras verificar, bajar a `~0.22`**, no insistir en
    0.30.
    - *Riesgo:* bajo, nodo aislado sin dependencias de animación.

13. **Perfil "en tabla" — columna sin curva dorsal. ÚLTIMO, riesgo alto.**
    No hay ninguna rotación de columna en `_build()` (`spine`/`upper_spine`
    son `Node3D` puros en posición Y). Agregar
    `upper_spine.rotation.x = -0.09 rad` (~5.2° — **subido de la propuesta
    técnica inicial de -0.05 por objeción directa de Fable**, que consideró
    ese valor imperceptible dado que el torso ya está construido como
    placas separadas) + `spine.position.z += 0.01`.
    - **Riesgo ALTO — el único de los 13 puntos que toca pivotes de
      combate.** `spine`/`upper_spine` son los mismos nodos que
      `rig_biomech.gd` (PRD-006) usa para los strikes hip-first. Cualquier
      rotación estática se SUMA a las rotaciones dinámicas de combate.
    - **Obligatorio:** correr `autotest_biomech.gd` y `autotest_combat.gd`
      ANTES y DESPUÉS de este cambio, no solo después.
    - Si `-0.09 rad` sigue sin dar curva perceptible en perfil, el problema
      de fondo puede ser el ensamblaje del torso por placas separadas (punto
      3), no solo el ángulo de columna — no seguir subiendo el ángulo a
      ciegas, re-evaluar con Boris.

## Anti-objetivos (fuera de esta ventana)

- **Sin rediseñar geometría desde cero** — cada punto es un ajuste de
  magnitud/parámetro o un swap de estilo ya existente en el código, no una
  propuesta nueva de forma (excepto el pelo, que reutiliza el estilo 10 ya
  construido).
- **Sin tocar el LUT del post** sin aprobación explícita (punto 11) — es
  global, no aislado a este personaje.
- **Sin reabrir `SHOULDER_X`/`SHOULDER_Y`** de forma automática (punto 4) —
  es punto de decisión de Boris si el fix de trapecio no basta.
- **Sin re-litigar mandíbula/pómulo/ojos ya cerrados por el [[QA Loop]]
  anterior** (75% de fidelidad facial) — este PRD ataca torso/pelo/manos/
  hombros/warpaint/nariz/cejas/columna, más el bug de venas y el relleno de
  boca; no reabre lo que el PRD anterior ya cerró.

## Definición de terminado (gate de QA)

Cierra cuando, tras ejecutar los 13 puntos en el orden indicado, un nuevo QA
visual (Fable, mismo protocolo: sin contexto de código, renders de cuerpo
completo + cara contra ambas láminas) confirma:

1. Pelo lee como corte corto, no melena de cintas — silueta reconocible
   contra la lámina a distancia media.
2. Torso sin costuras duras pecho/abdomen/hombro — lectura orgánica, no
   "coraza".
3. Sin marcas cian/neón visibles en ningún render por defecto.
4. Manos con dedos separados y nudillos legibles.
5. Warpaint en la posición/orientación de la lámina (vertical, ceja→pómulo).
6. Veredicto global sube de ~32% a un piso que Boris considere aceptable
   para pasar de lleno a Fase D (el número lo fija él viendo el resultado,
   no se fija aquí un target arbitrario — misma regla que el PRD anterior).
7. El punto 13 (columna) pasa `autotest_biomech` + `autotest_combat` sin
   regresión antes de considerarse parte del cierre.

Checkpoint obligatorio al cerrar: actualizar `00-Index.md`, `LOG.md` y
`Current-State.md` (regla 4 del repo).
