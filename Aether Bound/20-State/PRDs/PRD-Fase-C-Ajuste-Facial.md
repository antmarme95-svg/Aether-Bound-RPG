---
status: cerrado (pendiente VoBo final del director)
source: "QA visual Rondas 1-2 (30-35% → 40-45%, contra `fenotipo-humano-v1.png`) + [[QA Loop]] Rondas 3-8+desempate (50-55% → 75%) — subagente QA imparcial + subagente PRD, iterado con `character_rig.gd` / `hair_library.gd` / `palette_data.gd`"
updated: 2026-07-14
---

# PRD — Fase C: Ajuste Fino Facial (post-QA)

> Nota de numeración: este documento NO usa un número de la secuencia
> PRD-008+ — esos números están reservados en [[Plan-de-Produccion]] para
> contenido de gameplay futuro (Cinder Ascent, Tether, Cold Open, etc.). Este
> PRD es un rework técnico/artístico dentro de la ventana C6 (`character_rig.gd`
> / `hair_library.gd`), no un PRD de esa secuencia.

**Objetivo:** cerrar la brecha de fidelidad que dos rondas de QA visual
midieron contra la lámina canónica `fenotipo-humano-v1.png`
(Ronda 1: ~30-35% · Ronda 2: ~40-45%) para la cara del rig humano
(`godot/character/character_rig.gd`) y el vello facial
(`godot/character/hair_library.gd`). La Fase C ya construyó 8 pasos por masas
(mandíbula, pómulos, ojos, nariz, boca, barba, warpaint) + un ajuste fino
post-Ronda-1; este documento fija qué de eso quedó CERRADO por QA y qué sigue
ABIERTO con acciones concretas y accionables para la próxima ronda de código.

## Contexto — de dónde viene cada número

1. **Fase C (2026-07-13, luz verde del director, "propuesta por masas antes
   de codear"):** 8 pasos construidos sobre `character_rig.gd` —
   p1 mandíbula fundida, p2 pómulos como plano malar, p3 ojos almendra con
   párpado, p4 nariz cuña integrada, p5 boca por geometría (labio sup/inf +
   `mouth_seam`), p6 barba 9-esferas, p7 (ver Current-State), p8 warpaint como
   1 franja (`fm_cheek`). Ver `Current-State.md` para la bitácora completa.
2. **QA Ronda 1** (contra el cierre de Fase C, commit `0b6855a`): veredicto
   ~30-35%, "totalmente alejada". Motivó el **ajuste fino post-QA**
   (2026-07-14, commits `c12da0a`…`ea3f5bb`): ángulo goníaco en la mandíbula,
   pómulo con más Z, gap Y + escalón Z en labios, cadena de 11 esferas de
   patilla a patilla en la barba, franja de warpaint más fina + `PAINT_COLORS`
   desaturado en `godot/data/palette_data.gd`.
3. **QA Ronda 2** (contra ese ajuste fino): veredicto ~40-45% — subió, pero
   destapó **una regresión** (boca) y **un problema nuevo** (barba en
   "cuentas de collar"), además de confirmar que el fix de pómulos no tuvo
   efecto perceptible. Este PRD parte de ahí.

## Alcance — estado por rasgo (Ronda 1 → Ronda 2 → pendiente)

### ✅ CERRADO (QA confirma mejora real, no requiere más trabajo en esta ventana)

1. **Ojos / arrugas** (`eyes`/`brows`, `character_rig.gd` ~L891-939). El fix de
   Fase C p3 (esclerótica `white` más chica y aplastada, iris/pupila más
   grandes para leer almendra) resolvió el efecto "patas de gallo" que
   envejecía la cara en Ronda 1. Ronda 2: "mejoró notablemente"; queda una
   leve sombra bajo el ojo, aceptable. **Sin acción pendiente.**
2. **Cobertura de barba** (`_beard_stubble`, `hair_library.gd` L596-635). La
   cadena de 11 esferas de patilla a patilla (antes 2 bultos aislados: bigote
   + mentón) cumplió el pedido del director de "barba completa, no perilla".
   Ronda 2 confirma cobertura correcta — el problema que queda es de FORMA
   y COLOR, no de cobertura (ver pendientes abajo).
3. **Proporción del warpaint** (`fm_cheek`, `character_rig.gd` L1776-1780). El
   cambio de ~4:1 ("curita/parche cuadrado") a ~10:1 (ancho 0.075 / alto 0.007)
   resolvió el problema de proporción. Ronda 2: "mejoró en proporción" — queda
   pendiente solo el color (ver abajo).
4. **Silueta craneal/mandíbula (parcial)**. La masa `jaw_angle` agregada en el
   ajuste fino (dos esferas `Vector3(0.55, 0.35, 0.85)` en
   `Vector3(gside * 0.095, 0.00, 0.050)`, hundidas en `jaw_mesh` por overlap
   real) produjo el quiebre bajo la oreja que Ronda 1 pedía. **Parcial**: el
   mentón/frente de mandíbula sigue redondo (ver CRITICAL pendiente abajo) —
   no se cierra el rasgo completo, solo esta sub-pieza.

### 🔴 CRITICAL — pendiente, prioridad 1

5. **Boca — revertir la sobre-corrección del escalón Z (regresión de Ronda 2).**
   El fix de Fase C p5 + ajuste fino separó `lip_upper` (`character_rig.gd`
   L840-844, `position.y = -0.066`) de `lip_lower` (L846-850,
   `position.y = -0.090`) con `mouth_seam` (L836-839) en medio. El QA de
   Ronda 2 diagnostica: el gap Y (0.066 vs 0.090 = 0.024, casi el doble del
   valor pre-ajuste de 0.013) combinado con el escalón Z (`lip_upper.z=0.140`
   protruyendo, `lip_lower.z=0.132` hundido) **sobre-corrigió**: en vez de una
   sombra fina de comisura, ahora se ve un área oscura central tipo "O"/boca
   abierta gritando — más área negra visible que en Ronda 1.
   - **Acción concreta:** reducir el gap Y a un punto intermedio entre el
     valor pre-ajuste (0.013, "sin escalón, leía como bloque") y el actual
     (0.024, "leía como boca abierta") — probar ~0.016-0.018 primero. Si el
     gap reducido sigue sin leer bien, evaluar si el problema real es que
     `mouth_seam` (la caja negra en `pupil_mat`, L836-839, `size=(0.046,
     0.006, 0.006)`) es demasiado alta/ancha para el nuevo gap y necesita
     encogerse en vez de que los labios se acerquen.
   - **Verificación:** capturar en el ángulo de banco de cámara del QA;
     comparar contra la lámina, que muestra boca CERRADA seria, no un óvalo
     oscuro. Confirmar que `mouth_seam` sigue leyendo como comisura/sombra
     fina, no como "interior de la boca" visible.

6. **✅ RESUELTO (2026-07-14, feedback directo del director) — Barba
   rediseñada como dispersión 2D + densidad configurable.** El director
   pidió explícitamente: menos densa, más textura de "3 días", y — en su
   defecto/además — seguir la barba de `fenotipo-humano-torso-v1.png`
   (bigote + mandíbula + mentón, pareja pero sin treparse a la mejilla
   alta); y que quedara CONFIGURABLE. La fila 1D de esferas (r6b→r6e) no
   podía resolver ambos síntomas del QA (collar de cuentas O masa sólida
   oscura, según el overlap) porque cualquier fila con overlap suficiente
   para fundirse en un contorno único se ve pareja/sólida — lo opuesto a
   la textura ruidosa de un stubble real. **r6f (`hair_library.gd`
   `_beard_stubble`)**: dispersión 2D de motas chicas con jitter
   (`RandomNumberGenerator` semilla fija 1234 — determinista para
   capturas/QA reproducibles), acotada a bigote + banda baja de mandíbula/
   mentón (sin subir a la mejilla, siguiendo la lámina de torso); color
   fijo aclarado a `darkened(0.12)` (antes 0.20-0.35). **Configurable**:
   nuevo parámetro `density` (0..1) en `HairLibrary.build_beard(index, mat,
   density)` controla cantidad de motas (bigote 3→7, mandíbula 14→34) —
   expuesto como slider de fenotipo `beardDensity` (`phenotype_data.gd`,
   default 0.35, tab face/Hair & Beard) y enganchado en
   `character_rig.gd` (`apply_phenotype`, cache key `beard_k` incluye la
   densidad). QA visual del banco: ya no lee ni "collar de cuentas" ni
   "máscara sólida" — textura dispersa con piel visible entre motas,
   siguiendo el contorno bigote→mandíbula→mentón de la lámina de torso.
   Regresión completa (`test_core`+`autotest_biomech`+`test_combat`+
   `autotest_slice`+`autotest_ui`) ALL_PASS, 7.49 cabezas estable.
   **Pendiente de la Ronda 3**: confirmar con QA visual formal que esta
   textura efectivamente lee bien contra la lámina de rostro (no solo la
   de torso) — el ajuste se hizo por feedback directo del director, no se
   re-corrió el subagente QA todavía para esta forma específica.

### 🟠 HIGH — pendiente, prioridad 2

7. **Pómulos — diagnosticar por qué el fix no tuvo efecto perceptible.**
   `cheeks` (`character_rig.gd` L882-889): el ajuste fino subió la escala Z
   de 0.46 a 0.64 razonando que la protrusión insuficiente impedía que el
   Sobel entintara el borde. Ronda 2: "prácticamente igual que Ronda 1... no
   produjo cambio visible perceptible a la distancia de cámara del banco".
   Dos hipótesis a descartar en orden:
   - **(a) La magnitud sigue sin ser suficiente.** El radio base es 0.030 con
     escala `(1.0, 1.0, 0.64)` → protrusión efectiva ≈ 0.030×0.64 ≈ 0.0192 m,
     modesta contra un cráneo de radio 0.15. Probar subir Z a 0.80-0.90 y/o
     subir el radio base a 0.034-0.036 antes de tocar otra cosa.
   - **(b) El cambio no se está leyendo por causa externa** (iluminación del
     banco de captura, ángulo de cámara que no cruza el plano donde protruye
     el pómulo, o el material `skin_mat` compartido sin textura que aplana el
     shading en esa zona). Verificar con un render en el ángulo 3/4 de la
     lámina (no solo frontal) antes de seguir subiendo la magnitud a ciegas —
     el QA de Ronda 1 ya señaló que "no se lee desde ningún ángulo", lo que
     sugiere que el problema puede no ser solo de escala.
   - **Acción concreta:** aplicar (a) primero (es más barato — un solo
     número), volver a correr el QA visual, y solo si sigue sin leer,
     investigar (b).

### 🟡 MEDIUM — pendiente, prioridad 3

8. **Mentón/mandíbula central — sigue redondo/blando.** `jaw_mesh`
   (`character_rig.gd` L762-773, esfera `Vector3(0.78, 0.84, 0.94)`) resuelve
   el ancho general pero el frente del mentón (x≈0, la punta baja de la
   esfera en `y=-0.149` con la escala aplicada) no tiene el ángulo que pide
   la lámina — el `jaw_angle` del ajuste fino solo cubre la zona goníaca
   (junto a la oreja, `gside * 0.095`), no el mentón central.
   **Acción concreta:** evaluar una masa adicional pequeña, semi-hundida en
   `jaw_mesh` sobre el eje central (x=0, cerca de `y=-0.149`), con el mismo
   truco de "segundo radio distinto rompe la curvatura continua" que ya
   funcionó para el ángulo goníaco — pero sin invadir la boca (labios en
   `y=-0.066`/`-0.090`, hay margen). Coordinar con el fix de boca (punto 5)
   antes de tocar esta zona: ambos comparten geometría cercana.
9. **Warpaint — color sigue saturado pese al cambio de paleta.**
   `PAINT_COLORS[4]` en `godot/data/palette_data.gd` (L41) ya bajó de
   `#4dff9d` ("wyld green" compartido con `HAIR_COLORS`, leía "curita
   fosforescente") a `#6b7f4a` ("wyld green, warpaint, desaturado"). Ronda 2:
   "mejoró en proporción, pero el color sigue leyendo bastante saturado
   (verde menta-lima)".
   **Acción concreta:** bajar más la saturación/luminosidad de
   `PAINT_COLORS[4]` — probar un verde-oliva más terroso (menor canal G
   relativo a R/B, ej. en el rango `#5a6b42`-`#4f5c3a`) contrastado contra la
   lámina de referencia. Recordar que `fm_cheek` aplica además
   `.darkened(0.18)` sobre este color (`character_rig.gd` L1767) — el ajuste
   de paleta y el darken interactúan, verificar el resultado compuesto, no
   solo el valor crudo de `PAINT_COLORS`.

### 🟢 LOW — pendiente, fuera de esta ventana

10. **Orejas.** No evaluables en ninguna ronda — tapadas por el pelo
    placeholder del banco de QA, ajeno a este PRD. **Esperar Fase D** (pelo
    por masas).
11. **Nariz en frontal.** Sin cambios entre rondas (no era parte del plan de
    6 puntos de Ronda 1→2); el QA liga el aplanamiento frontal al fix
    pendiente de mentón/mandíbula (punto 8). **No abrir trabajo nuevo en
    `nose`/`ala` (`character_rig.gd` L791-818) hasta cerrar el punto 8** — re-
    evaluar la nariz en la siguiente ronda de QA después de ese fix, no antes.

## Anti-objetivos (alcance CERRADO)

- **Sin tocar orejas ni pelo real** — el pelo placeholder del banco de QA es
  de la Fase D (propuestas por masas antes de codear), no de este PRD.
- **Sin rehacer warpaint por textura** — el atlas (`WarpaintAtlas`,
  `skull.material_override`) queda intacto; el ajuste de color vive solo en
  `PAINT_COLORS` (`palette_data.gd`) y en el `darkened()` de `fm_cheek`.
- **Sin re-abrir mandíbula/pómulo/ojos/nariz/boca/barba/warpaint como
  problemas de PROPUESTA** — la propuesta por masas de Fase C ya tuvo luz
  verde del director; este PRD es **ajuste de magnitud/parámetro** sobre esa
  propuesta, no un rediseño de forma desde cero.
- **Sin cambiar la paleta de `HAIR_COLORS`** — el fix de `PAINT_COLORS[4]`
  (Ronda 1) ya separó los arrays a propósito para no afectar "wyld green" en
  pelo/veins/aether; el punto 9 sigue esa separación.
- **Sin nueva ronda de QA parcial** — cada punto CRITICAL/HIGH se corrige y
  se verifica junto con los demás antes de pedir la Ronda 3 completa (evita
  gastar ciclos de QA en fixes aislados que puedan interactuar, ej. boca +
  mentón central, punto 5 y 8).

## Definición de terminado (gate de QA — Ronda 3)

Este PRD cierra cuando una **Ronda 3 de QA visual** contra
`fenotipo-humano-v1.png`, corrida después de implementar los puntos 5-9,
confirma:

1. **Boca** lee como cerrada/seria (sin área oscura central tipo "O") —
   CRITICAL resuelto, no regresión nueva.
2. **Barba** funde en una sola masa de sombreado (sin contorno individual
   por esfera) y su color lee como stubble tenue, no barba sólida — CRITICAL
   resuelto.
3. **Pómulos** leen desde al menos un ángulo de cámara del banco (frontal o
   3/4) — HIGH resuelto o diagnóstico documentado de por qué no.
4. **Veredicto global de fidelidad sube** de ~40-45% (Ronda 2) a un piso
   razonable (el director fija el número al ver la Ronda 3; no se fija aquí
   un target arbitrario).
5. Mentón central y color de warpaint (MEDIUM) — mejora documentada, aunque
   no bloquean el cierre si CRITICAL+HIGH están resueltos y el director da
   VoBo parcial.

Checkpoint obligatorio al cerrar: actualizar `00-Index.md`, `LOG.md` y
`Current-State.md` con el resultado de la Ronda 3 (regla 4 del repo).

## CIERRE (2026-07-14) — 75% de fidelidad, todos los CRITICAL/HIGH resueltos

Este PRD se escribió después de la Ronda 2 (~40-45%); el trabajo real siguió
usando el [[QA Loop]] recién ratificado, con 8+ rondas adicionales de
código↔QA (2 agentes distintos: uno perdió su transcript a mitad de camino,
un agente de desempate lo reemplazó y terminó cerrando el resto). Progreso
medido completo: **30-35% → 40-45% → 50-55% → 53-56% → 60-63% → 62-65% (hilo
perdido) → 55% (desempate, recalibra a la baja con evidencia real) → 58% →
61% → 69% → 75% (final).**

**Lo que se cerró más allá de los 3 puntos originales de este documento:**

- **Boca**: 6 rondas — bloque (r1-4) → agujero/grito por sobre-corrección
  (r5) → escalón real con caras frontales distintas + tonos de material
  diferenciados por labio (`lip_mat` más oscuro arriba, `lip_mat_lower` más
  claro abajo) → **confirmado resuelto** por el desempate.
- **Barba**: reemplazo COMPLETO del vocabulario — de esferas dispersas
  (`_beard_stubble` original) a un bloque sólido continuo, con 5 iteraciones
  de forma (collar gigante por profundidad mal calculada → aro por ser más
  ancho que el jaw real a esa altura → bulto negro por ser esfera, cae en la
  banda oscura del toon → "ladrillo" de caja única sin conicidad → 3 cajas
  escalonadas + esfera de remate, siguiendo la conicidad real del jaw
  medida en 3 alturas). **Configurable** vía `density` (fenotipo
  `beardDensity`). Confirmado resuelto, "coherente con el lenguaje de masas
  del resto de la cara".
- **Ojos**: 2 fixes distintos — (a) el iris/pupila desbordaban la
  esclerótica entera (margen NEGATIVO, no solo "fino" como decía el
  comentario original de Fase C p3): agrandada `white`, achicados
  iris/pupila; (b) feedback directo del director: los ojos estaban muy
  separados (hueco entre esquinas internas ~2.4x el ancho de un ojo, contra
  la regla estándar de ~1x) — recogidos y agrandados, ceja movida junto.
  Ambos confirmados resueltos.
- **Pómulos**: de esfera a caja achatada (mismo principio que el mentón) —
  confirmado con mejora de carácter real (plano anguloso, no "cachete").
- **Mentón/mandíbula**: `chin_boss` (caja) + `jaw_angle` (ángulo goníaco)
  resolvieron el "óvalo sin quiebres" de Ronda 1.
- **Nariz**: causa raíz real no era magnitud — la cuña tenía una ARISTA al
  frente (dos caras iguales, luz simétrica, sin contraste); cambiada a CARA
  PLANA al frente (una cara iluminada + sombra lateral = quiebre de tono
  real). Misma lección que la boca, aplicada con éxito.
- **Warpaint**: color bajado 3 veces (`#4dff9d`→`#6b7f4a`→`#5a6b42`→
  `#4f5c3a`) hasta un verde oliva apagado.

**Lección transferible más importante de todo el loop** (candidata a
[[Lecciones]]): en el vocabulario de primitivas + Sobel de este proyecto,
**una esfera nunca da un borde/plano anguloso** (mentón, pómulo, y el primer
intento de barba lo confirmaron 3 veces independientes) — usar cajas para
cualquier rasgo que la lámina muestre como plano o borde definido, esferas
solo para masas genuinamente redondeadas (mejilla llena, articulaciones).
Segunda lección: **un "escalón" de geometría solo se lee si las CARAS
FRONTALES de las dos masas terminan en Z distinto** — mover el centro o el
radio sin verificar dónde cae la cara frontal (boca, Ronda 3-4) puede dejar
ambas caras coincidiendo exactamente, anulando el efecto por completo pese
a que los números "parecen" distintos.

**Pendiente fuera de este PRD**: orejas y pelo real quedan para Fase D (el
peinado placeholder de banco impide evaluarlos); el 75% es el techo
alcanzable para "cara con pelo/orejas placeholder" — subir más requiere
completar Fase D primero, no seguir iterando este PRD.

**Siguiente paso**: VoBo del director sobre el estado final (capturas en
`godot/test_out/anatomy_face*.png`) antes de dar la Fase C por
definitivamente cerrada y pasar a Fase D.

## ACTUALIZACIÓN (mismo día) — Boris rechaza la barba en el VoBo

Pese a que el QA Loop cerró la barba en estado "técnicamente sólido,
coherente con el resto de la cara" (69%→75%), el veredicto directo del
director al ver las capturas finales fue: **"no me gusta nada"**. Se quitó
del default (`phenotype_data.gd`: `beard` 1→0, vuelve a Clean/lampiño). El
sistema (`_beard_stubble`, `beardDensity`) queda intacto para
personalización del jugador, solo deja de ser el default del fenotipo
canónico. **Lección de proceso**: el % de un QA Loop es una señal de
convergencia técnica, no un sustituto del criterio del director — un rasgo
puede estar "resuelto" contra todos los checkpoints del loop (forma,
overlap, conicidad, color) y aun así no gustarle a quien manda. El [[QA
Loop]] ya documenta esto en su fase de Cierre ("el % informa la decisión,
no la reemplaza"); este es el caso real que lo confirma.
