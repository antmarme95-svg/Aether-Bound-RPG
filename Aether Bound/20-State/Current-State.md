---
status: vivo
updated: 2026-08-17
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

## Estado general (2026-08-05)

**Worldbuilding narrativo:** las 9 fichas de Pivote + los 3 fijos + Speck +
Old Tobin Hale + toda la estructura política y geográfica están escritos.
Sprint QA cerrado (16ª). El vault ya soporta escribir guión.

**Canon de base que sigue vigente** (fijado en las rondas 3ª-6ª; historial en
[[LOG]] y [[Current-State-Historico]]): costo de F1 = colapso tecnológico, no
exterminio · una sola fuente viva por personaje · Speck durmió 550 años ·
Bound Five formado en Acto 1 · topología "rueda, no malla" · **Iven es
excepción intencional** de la fila Deber Institucional (ningún QA debe
reportarla). Los 5 finales visuales, completos y ratificados.

### ✅ Regla de idioma establecida (decisión de Boris, 2026-07-30)

**El guión y todo el contenido de front-end (diálogos, líneas canónicas, UI,
textos in-game) se escribe en inglés de acá en adelante.** El vault sigue en
español. Registrado en `CLAUDE.md` regla 9 y en `Nomenclatura.md`.
**Pendiente:** varios beats de diálogo ya escritos (los del Reckoning en
`Geografía y Ciudades.md`, entre otros) están en español, de antes de esta
decisión — necesitan pasada de traducción cuando se aborde el guión completo.
No bloquea nada mientras tanto.

### Rondas 7ª-16ª — cerradas (detalle completo en [[LOG]])

Decisiones de canon y arquitectura resueltas ahí: gate F1/F2a con mensajero,
cráter centralizado en [[El Cráter — Matriz de Rutas]], 4 grados de agencia,
linter ampliado a 22 clases.

**Nota de método que sigue vigente (salió de la 16ª, confirmada en la 4ª
re-corrida):** los prompts de QA deben apuntar explícitamente a
`[[El Cráter — Matriz de Rutas]]` como fuente única. En la 16ª, no hacerlo
produjo 7 falsos positivos sobre 9; en la 4ª re-corrida, hacerlo produjo
**cero**.

Queda 1 hueco de canon genuino (quién mueve el dinero de Iven, cruza con
Maren) y menores sin cerrar (no bloquean).

### 🛠️ Herramientas del vault

```
python "Aether Bound/scripts/check_vault.py"    # peso de arranque
python "Aether Bound/scripts/check_canon.py"    # consistencia (22 clases)
```

`check_canon.py` — **22 clases** (12 base + 6 de la escena del cráter +
2 de la 11ª: `quiebre-lugar`, `superlativos`). Detalle de cada clase y su
origen: [[LOG]].

Exit 1 si hay críticos. Método: skill `canon-qa` / [[QA de Canon Loop]].
**Orden no negociable:** linter en 0 → subagentes en frío solo para juicio →
fixes **a la fuente** con re-grep → checkpoint → re-corrida.

**Regla nueva (2026-08-03):** si un QA encuentra un crítico de una clase que el
linter ya cubre, **el bug es del linter** — se agrega el chequeo, no se parcha
la línea.

Hook `.claude/settings.json` + `Aether Bound/scripts/hook_current_state.sh`:
corre `check_vault.py` automáticamente al editar este archivo — construido y
probado 2026-07-30.

### Nota de método

El cuello de botella no es el QA, es el **barrido**: los 8 críticos de la 4ª
re-corrida fueron todos fallas de propagación, no de escritura. Ver
[[Lecciones]] y [[QA de Canon Loop]].

Con el sprint y los links de fijos cerrados, el frente siguiente es
**guión y diálogos por actos** (ahora en inglés).

**Plan de abordaje con asignación de modelos por sprint:** `~/.claude/plans/haz-un-plan-de-dazzling-lemur.md`.

---

## ✅ ADR-003 CERRADO (2026-08-10) — hard reset ejecutado

**[[ADR-003 Reset de desarrollo y motor]] está cerrado y ratificado.**
`godot/` fue eliminado del árbol de trabajo (recuperable en el tag
`archive/prototipo`). El frente C (técnico) del Task-Board queda
**descongelado**.

**Lo que salió:** motor **GODOT** · vertical slice = [[Slice of Bond]]
recortado a 3 escenas con **Dagna**, greybox de entorno pero **no de
cuerpo** · PC únicamente para v1 · alcance de v1 diferido hasta medir el
costo real en horas de un Pivote · método: gauntlet-loop solo sobre
traversal, con [[Benchmark Biomecánico]] como estándar. Detalle y las 3
piezas pre-código (árbol de "¿y si no duele?", contador de horas, 3
playtesters — Diego/Santiago/Delmer) en el §Cierre del ADR.

> **Nota de la 5ª re-corrida:** [[Slice of Bond]] comprime la traición en
> un solo golpe al salir del mini-dungeon, y el canon nuevo pide dos
> tiempos. Como el pilar que el slice existe para probar **es** el Bond
> vacío, hay que decidir si el slice adopta los dos tiempos o se declara
> excepción explícita. Bloquea el diseño del slice, no el guión.

**Próximo código de producción:** el vertical slice, sobre Godot, según
ese cierre. Nada más está autorizado todavía — sigue sin sentido escribir
combate genérico o sistemas fuera del slice hasta que dé veredicto.

### 🧪 Spike comparativo Godot/Unity — condiciones emparejadas (2026-08-12)

**Dagna ya camina en Godot con animación real**, no solo traslación. Ciclo
retargeteado con la herramienta **stock** (`BoneMap` +
`SkeletonProfileHumanoid`), mismo criterio que el retargeting Mecanim del
lado Unity: cero solver escrito a mano. Fuente: el Walk in-place del pack
**DoubleL** (ExplosiveLLC descartado — su FBX de caminata no trae
esqueleto; Kevin Iglesias — rig Rigify como el nuestro, pero la versión
free no trae Walk).

Verificación repetible: `godot/tools/verify_and_capture.gd` corre la
escena, sigue a Dagna con cámara de costado, captura, y **mide la rotación
del muslo** — exit 1 si el hueso no se mueve. Hoy da 24° y ciclo alternado,
con los pies apoyados en la pendiente vía IK sobre el pose animado.

En el camino salieron **2 bugs de importación pre-existentes** que el spike
anterior tapaba (árbol duplicado al re-apropiar una instancia · pista de
escala ×100 dentro de la pose del FBX). Están en [[Lecciones]] §Godot 4.7
— leer antes de tocar importación de FBX otra vez.

**Moonwalk CERRADO — la causa raíz era otra, y Boris la reportó tres
veces.** El FBX del warrior está exportado **mirando a +Z** y Godot asume
−Z (`Basis.looking_at` apunta el −Z al objetivo), así que Dagna subía la
rampa **de espaldas** desde la primera versión. Se corrige girando el nodo
`Model` 180° al construir la escena — en un solo lugar; poner además
`use_model_front` en los `looking_at` la deja de espaldas igual.
Se revirtió también el cambio de clip: el correcto es el *forward*.

Queda además, y era real aunque no fuera la causa raíz, el ajuste de
**cadencia**: el clip in-place aporta 1.55 m/s de zancada propia, y la
cadencia se ata a la velocidad real cuadro a cuadro (resuelve solo el caso
de la pendiente, donde el avance efectivo cae). Verificado con la prueba
limpia —cuánto avanza el cuerpo por vuelta del clip contra lo que el clip
aporta—: **0% en régimen**.

**Lección de método, en [[Lecciones]] §Godot 4.7:** un mismo síntoma
("moonwalk") lo producen tres causas distintas, y la orientación invertida
**da vuelta el signo de toda medición sobre huesos** — llegué a "arreglar"
el clip en la dirección opuesta a la correcta mientras el número decía que
mejoraba.

**Comparador cuadro a cuadro Unity/Godot listo** (`godot/tools/frame_strip.gd`
+ `unity/Assets/_Spike/Editor/SpikeFrameStrip.cs`): mismo punto de la
rampa, mismos cuadros, misma cámara, y la fase inicial alineada por el
contacto del talón izquierdo **detectado midiendo el hueso**. Lo que la
lámina muestra: la diferencia grande **no es de motor, es de clip** — la
zancada de Starter Assets recorre 1.12 m y la de DoubleL 0.825 m. El
**retargeting** stock sí funciona en los dos; el **foot IK** stock no —
del lado Godot hubo que escribirlo (ver arriba).

**Comparativa de motores escrita** (pedido del director, 2026-08-12):
[[Comparativa de Motores — Godot vs Unity]] — pros/contras + FODA de los
dos, con cada afirmación marcada por origen (medido / hecho de plataforma
/ juicio). **No reabre la decisión.** El eje que más pesa resultó ser de
método: Godot se automatiza y se autoverifica desde CLI, Unity mucho
menos. El contraargumento más fuerte del otro lado son los 55 paquetes de
assets ya comprados, que ahí funcionan sin convertir.

### ✅ Foot IK RESUELTO con solver propio — cumple el Benchmark (2026-08-12)

**El `TwoBoneIK3D` de fábrica no produce salida en Godot 4.7.1.** Probado
en escena mínima aislada (esqueleto de 3 huesos hecho a mano, malla pesada
100% al hueso punta, juez = el render) con **9 variantes de
configuración**: las 9 dan 0 píxeles, contra una variante de **CONTROL**
—sin IK, rotando el hueso raíz a mano— que da 2.127. Repro versionado en
`godot/tools/min_ik_repro.gd`. No es nuestro rig.

**Se escribió el solver a mano**: `godot/scripts/two_bone_ik.gd`
(`SpikeTwoBoneIK`), ley de cosenos analítica, sin iteraciones. Implementado
como `SkeletonModifier3D` propio — el framework de modifiers sí funciona,
lo que no funciona es la clase `TwoBoneIK3D`; y usarlo garantiza el orden
correcto respecto del AnimationMixer. En el mismo banco mínimo da **2.730
píxeles**.

**Resultado contra el estándar del [[Benchmark Biomecánico]]** (§v2, fila
de HZD: *"foot IK contra el terreno cada frame — pies creíbles en
terreno"*; y canon de Sable, raíz continua):

| Métrica | Sin IK | **Con solver propio** | Estándar |
|---|---|---|---|
| Raíz continua | — | ✅ desvío 7.8% | Sable: continua |
| Penetración, plano | −0.213 m | **−0.004 m** | ~0 |
| Penetración, rampa 21.8° | −0.323 m | **+0.006 m** | ~0 |
| Plano → rampa | −0.110 m | **+0.010 m** | 0 |

**El pie queda a ±6 mm del suelo en los dos terrenos**, y se apoya
igual de bien en pendiente que en plano — que es exactamente lo que pide
la fila de HZD. **El Benchmark, en su criterio de foot IK, está
cumplido.**

**Calibración medida, no estimada:** `ankle_height_offset = 0.045`, hallado
barriendo valores con `tools/footik_benchmark.gd` hasta minimizar la
penetración. Corrige que el rest pose del rig, tras el retargeting con
`fix_silhouette`, no es una pose de pie apoyado y da una altura de tobillo
de 0.037 m en vez de los ~0.08 reales.

### ✅ Comparación de foot IK Godot vs Unity — CERRADA (2026-08-12)

Mismo protocolo y **los dos calibrados con el mismo criterio**:

| Métrica | **Godot** (solver propio) | **Unity** (`Animator IK`) |
|---|---|---|
| Penetración, plano | −0.004 m | +0.005 m |
| Penetración, rampa 21.8° | +0.005 m | +0.031 m |
| Plano → rampa | +0.009 m | +0.027 m |

(Línea base sin IK, para escala: −0.213 m en plano y −0.323 m en rampa.
Repetibilidad de una misma columna: ±1 mm.)

**Las dos columnas son confiables.** Hubo una falsa alarma sobre el
encuadre del instrumento de Unity: se volcaron **las 16 muestras con la
línea del suelo dibujada encima** y el encuadre está bien — vista lateral,
personaje derecho, pies sobre la línea. La alarma salió de mirar **una sola
miniatura de una fase con los dos pies en el aire**.

**Se probó el error de coseno y la medición lo rechazó** (+0.031 →
+0.055 m al desplazar a lo largo de la normal). Revertido. El motivo: el
`footOffsetY` de Unity calibrado da 0.21 m, que **no es una altura de
tobillo** sino un factor que absorbe la geometría tobillo→punta de la
bota — y un fudge así no tiene dirección física que respetar.

**La diferencia en pendiente queda sin explicar** (script, clips o motor),
y **no alcanza para decir que un motor planta mejor el pie**. Lo que sí
está establecido: **los dos cumplen el estándar**.

**La diferencia real de motor** es de costo, no de calidad: en Unity el
foot IK viene funcionando; en Godot hay que escribirlo.

Detalle, salvedades y la métrica que se descartó por no ser comparable
(raíz continua, atada al timestep de cada motor):
[[Comparativa de Motores — Godot vs Unity]].

**Comparador cuadro a cuadro Unity/Godot listo** (`godot/tools/frame_strip.gd`
+ `unity/Assets/_Spike/Editor/SpikeFrameStrip.cs`): mismo punto de la
rampa, mismos cuadros, misma cámara, y la fase inicial alineada por el
contacto del talón izquierdo **detectado midiendo el hueso**. Lo que la
lámina muestra: la diferencia grande **no es de motor, es de clip** — la
zancada de Starter Assets recorre 1.12 m y la de DoubleL 0.825 m. El
**retargeting** stock sí funciona en los dos; el **foot IK** stock no —
del lado Godot hubo que escribirlo (ver arriba).

**Comparativa de motores escrita** (pedido del director, 2026-08-12):
[[Comparativa de Motores — Godot vs Unity]] — pros/contras + FODA de los
dos, con cada afirmación marcada por origen (medido / hecho de plataforma
/ juicio). **No reabre la decisión.** El eje que más pesa resultó ser de
método: Godot se automatiza y se autoverifica desde CLI, Unity mucho
menos. El contraargumento más fuerte del otro lado son los 55 paquetes de
assets ya comprados, que ahí funcionan sin convertir.

### ⛔ Foot IK: migrado a `TwoBoneIK3D`, y sigue sin producir salida (probado 2026-08-12)

**Hecho:** `SkeletonIK3D` (deprecado en 4.x) fue reemplazado por
**`TwoBoneIK3D`**, subclase stock de `SkeletonModifier3D` que Godot 4.7
trae de fábrica — junto con `FABRIK3D`, `CCDIK3D`, `SplineIK3D` y otras.
El objetivo del IK ahora es *suelo + altura del tobillo sobre la planta*
(medida del rig en reposo), no el punto del suelo: poner el tobillo en el
suelo entierra el pie entero.

**El instrumento ahora mide sobre el RENDER**, que es el único canal que
puede reflejar la salida de un `SkeletonModifier3D` (los getters de hueso
y `BoneAttachment3D` devuelven la pose anterior a los modifiers). Cámara
ortográfica con su "arriba" en la normal del terreno, se ocultan el otro
personaje, las mallas del suelo y **el hacha** (colgaba por debajo de los
pies y era ella la que marcaba el píxel más bajo).

**Resultado, con instrumento validado:**

| Métrica | Con IK | Sin IK | Estándar |
|---|---|---|---|
| Raíz continua | ✅ desvío 7.8% | — | Sable: continua |
| Penetración, plano | −0.213 m | −0.213 m | ~0 |
| Penetración, rampa 21.8° | −0.328 m | −0.323 m | ~0 |

**La validación que faltaba, hecha bien:** con la animación **congelada**
(`pause()` + `speed_scale = 0`), mover el objetivo del pie 45 cm da **0
píxeles de diferencia**. Y con el `AnimationPlayer` **detenido del todo**,
también 0 — así que tampoco es que el mixer le pise el resultado al
modifier.

**Conclusión: ni `SkeletonIK3D` ni `TwoBoneIK3D` producen salida en
nuestro montaje.** Lo que se ve en pantalla es la animación cruda con el
cuerpo apoyado por física.

**Lo que NO se sabe todavía:** por qué. Los bones resuelven (índices
válidos), el target resuelve, `active == true`, el esqueleto es el
correcto. Falta encontrar qué requisito del modifier no estamos
cumpliendo.

| Métrica | Medido | Estándar del Benchmark |
|---|---|---|
| Raíz continua | ✅ desvío 7.7% | Sable: raíz continua |
| Penetración del dedo (plano) | ❌ −0.132 m | ~0 |
| Penetración del dedo (rampa 21.8°) | ❌ −0.205 m | ~0 |
| Adaptación de la planta | ❌ 10.9° de 21.8° | ≈ ángulo del terreno |
| Aporte del IK | ❌ 1.4 mm | — |

**CAUSA ACOTADA (escena mínima, 2026-08-12): `TwoBoneIK3D` no produce
salida en Godot 4.7.1.** No es nuestro rig. Esqueleto de 3 huesos hecho a
mano, malla pesada 100% al hueso punta, juez = el render, **9 variantes de
configuración** (base · `reset()` · `use_virtual_end` · `extend_end_bone` ·
`mutable_bone_axes` off · configurado antes de entrar al árbol · con hueso
hijo en la punta · cadena colgando de un padre · pose reescrita cada
frame): **las 9 dan 0 píxeles**. La variante **CONTROL** —sin IK, rotando
el hueso raíz a mano— da **2.127 píxeles**, así que el instrumento es
válido y los ceros son reales. Repro: `godot/tools/min_ik_repro.gd`.

**Consecuencia para la comparativa de motores:** el foot IK de Godot **no
es "stock, cero código"** como decía [[Comparativa de Motores — Godot vs
Unity]]. Hay que escribir el solver de dos huesos a mano (unas 40 líneas
de trigonometría). Del lado Unity, `OnAnimatorIK` funciona. Esa fila de la
comparativa cambia de signo y es un dato real a favor de Unity.

**Lo que queda sin explicar:** por qué el modifier no aplica. Puede ser un
requisito no documentado o un bug de esta build.

**Descartado antes de llegar a la escena mínima:** Descartados con medición: la cadena de
huesos ES contigua padre-hijo · `active`/`influence`/esqueleto/target
correctos · el `AnimationPlayer` no le pisa el resultado (probado con el
mixer detenido) · el pole (estaba mal seteado, se corrigió, sigue igual).
Test decisivo: misma fase de animación, esqueleto actualizándose, objetivo
movido 50 cm → **0 píxeles**. El modifier se ejecuta y no hace nada.

**Sin descartar:** `IKModifier3D.reset()` tras configurar · configurar los
settings ANTES de entrar al árbol (es lo que exigía el `SkeletonIK3D`
viejo) · `use_virtual_end`/`extend_end_bone` · asignar por ruta de
propiedad en vez de por setter.

**Próximo paso recomendado:** escena mínima aislada (esqueleto de 3 huesos
a mano + `TwoBoneIK3D` + target) para decidir si el problema es la API o
nuestro rig. Si ahí tampoco anda, el camino barato es escribir el solver
de dos huesos a mano (unas 40 líneas) — y entonces el argumento de
"herramienta stock" del lado Godot deja de sostenerse igual, que es un
dato para la comparativa de motores.

**Bug propio pendiente, anotado en el código:** `_rest_ankle_height()` da
0.037 m cuando un tobillo real está a 0.08-0.10 m de la planta (lee el
rest pose, que tras `fix_silhouette` no es una pose de pie apoyado). Hoy
no cambia nada medible, pero hay que arreglarlo el día que el IK aplique.

Hasta que el IK produzca salida, la comparación contra Unity no se corre:
mediría animación cruda contra un IK que sí funciona, y le daría a Unity
una ventaja que no es del motor.

**Aviso de método para quien lea esto:** esta conclusión se dio vuelta
DOS veces en el mismo día por instrumentos mal validados. La versión
actual es la primera que se apoya en un test de efecto innegable con
todas las demás variables congeladas. Ver [[Lecciones]] §Godot 4.7.

**Sigue sin decidirse el veredicto Godot-vs-Unity.** Esta pasada solo
empareja las condiciones para que ese veredicto compare lo mismo de los
dos lados. Deuda anotada y no bloqueante: el clip es de una mano y Dagna
lleva hacha a dos manos (los brazos no cuadran, las piernas sí), y el foot
IK baja los pies sin ajustar la pelvis, así que en pendiente la deja algo
agachada. El jugador sigue idle en los dos motores.

---

## Hechos vigentes

- **Branch:** `master` (el hard reset se ejecutó y mergeó ahí, 2026-08-10).
  Los playtests viejos (`Start-Playtest-Greybox.bat` y demás lanzadores de
  `godot/`) fueron eliminados junto con el código que apuntaban.
- **Speck:** la última Warden cristalina superviviente, shapeshifteada como
  zorro. Narrativa + diseño visual 100% completo. Detalle en
  [[Current-State-Historico]].
- **Anatomía/rework (C6):** todo el trabajo de C6 (oreja élfica, nacimiento
  de oreja, etc.) vivía en el código Godot archivado — queda como
  conocimiento en [[Lecciones]] / [[Benchmark Biomecánico]] / [[Art Bible]],
  no como código vigente. Se reconstruye si el slice lo requiere.
- **Motor:** GODOT, re-confirmado (ADR-002 + cierre de ADR-003).

---

## Pendientes

> Boris también escribe acá directo (fuera de sesión con el asistente) —
> cualquier ítem nuevo bajo "Inmediato" o dentro de las listas de abajo
> se revisa juntos al arrancar la próxima sesión, se lea o no la marca
> de quién lo escribió.

### 🗓 Inmediato — próxima sesión

0. **⏳ RONDA 2 DE FIXES APLICADA (2026-08-17) — SIGUE SIN CERRAR.**
   La re-corrida en frío de los 2 subagentes **sí se ejecutó** sobre la ronda 1:
   congruencia semántica dio 0 críticos / 1 medio / 5 menores, dramaturgia dio
   **3 críticos / 4 medios / 3 menores**. Las 5 tandas de la ronda 2 están
   aplicadas y commiteadas; linter en **0 críticos / 0 medios**.

   Cerraron: (1) **residuos de "Valen ya lo sabía"** fuera de los sub-beats 2b —
   seis líneas señaladas más cuatro que aparecieron al barrer la clase (Maren,
   Sereth, Vekka §Dinámicas, y Nyael §Dinámicas); (2) **la escena Valen↔Nyael era
   imposible** (Nyael no está presente en el Acto 3) — reescrita como reacción a
   la nota del nicho; (3) **F2a-Bram no se había propagado a [[Los 5 Finales]]**;
   (4) cinco medios (causalidad del Reckoning de Bram, §La Rueda de Roen, corredor
   con las excepciones Bram/Nyael en las 3 fichas de fijos, epílogo F2a de Bram
   con motor propio, Aethelgard Watch); (5) seis menores.

   > ⛔ **EL SPRINT SIGUE SIN CERRAR — hace falta OTRA re-corrida en frío.**
   > La re-corrida que validó la ronda 1 encontró **3 críticos que la ronda
   > anterior no vio**, incluida una escena físicamente imposible que sobrevivió
   > cinco rondas. El patrón histórico es claro: cada re-corrida encuentra algo.
   > No cerrar sin una pasada nueva de 2 subagentes en frío, y **no la puede
   > correr quien aplicó estos fixes** (skill `canon-qa` §Anti-objetivos).
   > Es el primer trabajo de la próxima sesión de canon.

   Bloque histórico de la ronda 1, para contexto:

   **⏳ RE-CORRIDA DE QA DEL 08-13 — FIXES APLICADOS, VALIDACIÓN PENDIENTE.**
   Se corrieron 2 subagentes en frío (dramaturgia + congruencia semántica) sobre
   el bloque de propagación de "la traición tiene dos tiempos", y **las 7 tandas
   de fixes ya están aplicadas y commiteadas** (una por tanda; detalle completo en
   [[LOG]] §2026-08-13). Linter en **0 críticos / 0 medios**.

   Cerraron: (1) la ruptura de Bram movida a la sala del Fragmento en la Matriz,
   [[Los 9 Pivotes]] y el Reckoning; (2) **F2a existe en la ruta Bram** — decisión
   de Boris, mismo mecanismo de holder=agente que Nyael; (3) origen de Roen
   reescrito como Mistbound interior, sin bestias; (4) Darro — dos años de
   aprendizaje con Vekka, rechazo al tercero, versión única; (5) **Valen y Darro
   migrados al sub-beat 2b** con escena de cráter recortada a reacción contenida;
   (6) siete medios; (7) cuatro menores + bloque de aritmética canónica de Nyael.

   > *(Nota histórica: esa re-corrida ya se ejecutó — es la que produjo la ronda 2
   > de arriba. El pendiente vigente es la re-corrida **siguiente**.)*

1. **✅ ACTO 1 — GUIÓN COMPLETO (2026-08-12).** Detalle de cada decisión
   en [[LOG]] §2026-08-12. **Las 5 escenas escritas**, todas
   `provisional` y compartiendo una sola re-corrida de QA:
   [[Guion/Encuentro con Roen]] (tutorial) →
   [[Guion/Caminata y Taberna — Valen se suma]] (loc. 1) →
   [[Guion/Frontera — Camino al Nido]] (loc. 2, enseña el T1 de Valen) →
   [[Guion/El Nido — El Primero]] (loc. 3: Speck, el Pivote, la elección
   ilusoria, el primer God-Core, la primera palabra) →
   [[Guion/Waypost — Los Cinco]] (loc. 4: Darro, *Open Seam*, y el grupo
   se vuelve equipo — cierre del acto).
   **✅ El primer jefe también quedó cerrado:** **The Long Vigil**
   ([[Bestiario]] §The Long Vigil) — la última de las bestias guardianas
   que pusieron a Speck en la crisálida, 550 años de guardia con el
   propósito vaciado. **Su moveset es la caracterización:** no persigue,
   cede terreno y lo recupera, y todo se dispara por proximidad **a la
   crisálida**, no a sí misma. El jugador mata, en su primer jefe, a lo
   único que seguía cuidándola — y nadie en la ficción lo sabe.

   **Canon nuevo que salió en el camino, todo escrito a fuente:**
   **Voz del protagonista** ([[Voz Narrativa]], sección entera, canon:
   gradiente coming-of-age + 8 reglas + 3 anclajes + grados de voz por
   final) · **Waypost** en [[Geografía y Ciudades]] §K — bookend y sala
   de la formación, nombre no pronunciado · **beat de formación del
   equipo** (locación 4, fuente única) · **3 tabernas nombradas**
   ([[Nomenclatura]]).

   **⚠️ Abierto para vos, nada bloquea:**
   - **Ambigüedad en [[Geografía y Ciudades]] §M** — dice que Roen *"fue
     este puesto, en otra vida"* sobre Aethelgard Watch, y su ficha lo
     pone en la frontera Mistbound, que es tierra interior. El guión
     escribió lo que las dos lecturas soportan. Fix de una línea, en el
     sentido que elijas.
   - **Las tarjetas por Pivote del Acto 1 no están extraídas.** El Nido
     pide 4 slots por Pivote (llegada · combate · lectura de la duda ·
     reacción a Speck) — **los 4 ya existen en las 9 fichas**, en prosa y
     en español. Waypost pide 2 más, y **uno de ellos es nuevo**: la
     silla en la mesa (acotación muda, no línea) no existe en ninguna
     ficha. Trabajo de extracción + traducción (regla 9), no de diseño.
   - **Concept art:** The Long Vigil sería el primer boss del juego sin
     lámina — anotarlo cuando se abra el próximo batch.
   - **The Long Vigil deja una pregunta de diseño de combate abierta a
     propósito:** si se puede terminar la pelea **sin matarla**
     retirándose. Cruza con la elección ilusoria (dos "no puedo hacerlo"
     seguidos serían uno de más), así que **no se asumió**.

   **Del canon de voz sigue abierto:** cotejar la tabla de finales contra
   [[Los 5 Finales]] cuando se escriba ese guión (F4 y F2b son las de
   riesgo) y la decisión de **voice-over sí/no**, que no está tomada en
   ningún lado del vault.

   **Frente siguiente: el Acto 2** — La Rueda, el **Bautizo** (donde el
   jugador dice su primer nombre) y el **pico de voz en la oficina de Old
   Tobin Hale**.
2. **✅ BLOQUE DE PROPAGACIÓN — las 12 fichas: CERRADO (2026-08-12).**
   Detalle completo en [[LOG]] §2026-08-12. Las 4 tandas se cerraron con
   linter en **0 críticos** y commit por tanda:
   - **Tanda 1** — Maren, Torgan, Iven, Sereth.
   - **Tanda 2** — Bram, Lyris, Nyael (+ [[Geografía y Ciudades]] §3,
     variante Bram, que seguía ubicando su rechazo en el corredor).
   - **Tanda 3** — Vekka, Dagna.
   - **Tanda 4** — Roen, Valen, Darro (pasada de verificación: se recortó
     la re-narración del quiebre en Roen y se rompió la convergencia de
     fórmula de Valen).

   Cada ficha de Pivote tiene ahora **sub-beat 2b (la ruptura, sala del
   Fragmento)**, el **obstáculo firma del link perdido** en el ascenso, el
   **sub-beat 3 podado** a culminación sin sorpresa, el índice en **6
   sub-beats (1, 2, 2b, 3, 4, 5)**, y la línea canónica con ubicación
   declarada explícitamente. **La Cuña de Dagna también cerró**: el objeto
   firma pasó a la piedra del borde del cráter, en First Wound.

3. **Canon estructural vigente** (4ª y 5ª re-corrida, todo ya escrito en
   las fuentes — es lo que el bloque de arriba tiene que propagar):
   - **La traición tiene dos tiempos.** *Ruptura* en la **sala del
     Fragmento**, dentro del Archive (el Fragmento es el detonante) →
     el **ascenso** es la ventana del Bond vacío → *toma* en el último
     corredor, que es culminación, no sorpresa. **Ojo: se ubicó primero
     en Driftmarket y se movió el 08-12** — ahí chocaba con el
     Reckoning ("nadie confiesa"), con la trampa de Tobin, y con que en
     Lyris/Iven/Maren la orden llega dentro del Archive.
   - **Excepciones:** Bram declara y **no obedece** (su link nunca
     muere); Nyael **declara por ausencia** (no está en la sala del
     Fragmento) y conserva su superlativo.
   - La crisálida es **elección ilusoria** — no hay rama "destruida".
   - Roen **decide** renunciar en la frontera, **formaliza** en
     Rivermeet. En F3 **se va después** del clímax. En el bookend tiene
     **70-75**.
   - Entre gates solapados **gana F4** si sus 2 condiciones globales se
     cumplen.
   - El arco de Valen son **90 años**. El Acto 1 tiene **un** Momento de
     Persona. **Derribar al portador no mata a Speck** (habilita F1 en
     Nyael y Bram; el jugador nunca pone una mano sobre ella en F1).

4. **Medios y bajos sin tocar de la 5ª (~15).** Inventario completo en
   [[LOG]]. Los dos que más pesan son **pre-existentes, no de estas
   rondas**:
   - **`Vekka` usa la palabra "Warden" en Actos 1 y 2**, cuando
     [[El Mundo y la Muda]] dice que el término no existe públicamente
     hasta el Archive en Acto 3 — y siendo enana no tiene vía canónica
     a él.
   - **✅ La Primera Cuña de Dagna — reubicada (2026-08-12)**, ver punto 2.
     Sigue abierto: [[The Tether]] no contiene la "regla T3" que
     [[Los 9 Links del Pivote]] le atribuye — falta verificar esa cita.
5. **Dos decisiones de diseño abiertas** (no son de QA; las dos bloquean
   la ratificación de [[Los 3 Links de los Fijos]]):
   - Ninguno de los 3 T3 de los fijos tiene **escena firma** propia
     (solo Roen tiene objeto firma, el escudo) — [[The Tether]] promete
     ambos para todo T3.
   - El caso **"rol duplicado"** vive en T1 para Roen y en T2 para Valen
     y Darro, sin razón declarada, y solo en Roen *sustituye* el sabor
     base en vez de sumarse.
6. **Reglas de tráfico mientras tanto:** linter (`check_canon.py`) antes
   de cada checkpoint, siempre. **Y al citar una sección, cerrar el `§`
   antes de seguir la frase** — el linter parsea lo que sigue como parte
   del nombre; costó 5 críticos propios entre la 4ª y la 5ª.
7. **Concept art:** §12.1 (V1 del key-art-poster) sigue sin correr — es
   el único brief pendiente de la sección 12.
7. **✅ Consejo corrido (2026-08-10) → [[ADR-003 Reset de desarrollo y
   motor]] tiene BORRADOR DE CIERRE, pendiente de tu firma.** Salió:
   hard reset SÍ · **Godot** (no se reabre hasta que el slice dé
   veredicto) · slice = [[Slice of Bond]] recortado a **3 escenas** con
   Dagna, greybox de entorno pero **no de cuerpo** (la biomecánica es el
   canal por el que viaja la pérdida — es el punto de tu premisa que el
   consejo casi tira junto con los tatuajes) · PC únicamente · alcance
   de v1 diferido hasta medir el costo real en horas de un Pivote.
   Transcript en `90-Raw/council-2026-08-10-motor-y-fases.md`.
   **Corrección al consejo:** propuso "Dagna o Roen" para el slice —
   malformado, **Roen es fijo y no traiciona**, no puede sostener la
   coda del Bond vacío. Dagna gana por defecto.
   **Falta para firmar:** (a) los 3 playtesters con nombre y fecha
   (Boris los tiene definidos, hay que registrarlos en §C del cierre);
   (b) 30 min de lectura para confirmar que Dagna sigue siendo el mejor
   de los **9 Pivotes** post-rework; (c) tu VoBo al recorte de 3
   escenas.

8. **✅ Segundo consejo corrido (2026-08-13)** sobre
   [[Veredicto de Motor y Lectura del Proyecto]]. Transcript en
   `90-Raw/council-2026-08-13-veredicto-motor-y-alcance.md`. Salió:
   **Godot ratificado y congelado** (cero re-evaluaciones de motor hasta
   que exista un slice jugable) · **playtest antes que guión, 5 de 5** ·
   **no defender el 3 como final**: construir Dagna sola end-to-end,
   cronometrada, con link de 1 tier, y que el número de horas decida si
   v1 son 3, 2 o 1 · **Bram queda**, porque al ser la ruta que se
   desbloquea es lo último que se construye y por lo tanto cortable a
   costo cero hasta el final.
   **✅ PROTOCOLO DE PLAYTEST ESCRITO (2026-08-13)** →
   [[Protocolo-de-Playtest]]. **Son dos**, en orden: **A** (test gris del
   Bond — cápsula, cornisa, 5 min con el botón y 5 sin él, sin arte ni
   diálogo) y **B** (sesión completa del slice, registro separado por eje
   gameplay/visual/narrativa + recuerdo a 7 días). Cada uno con guión
   minuto a minuto, redacción literal de lo que se dice y lo que **no**,
   disciplina de silencio, hojas de registro y mapeo de cada pregunta al
   árbol de fallos del ADR. Los 4 instrumentos acordados están dentro
   (botón en la cornisa · inputs por minuto · recuerdo a 7 días · frase
   al amigo), y los 4 riesgos del consejo tienen pregunta o registro
   propio.

   ✅ **§0 — el criterio de muerte está FIRMADO (Boris, 2026-08-13),**
   y se firmó **antes de que existiera la escena gris** — o sea antes de
   que hubiera un solo dato que pudiera contaminarlo, que es la única
   forma de que el criterio valga. A partir de acá, mover cualquiera de
   estos números es un commit con fecha y autor, y el impulso de moverlos
   se anota en el [[LOG]] aunque no se ejecute (§6).
   Firmado: 🟢 **P ≥ 3 pulsaciones y T ≥ 20 s** en 2 de 3 testers ·
   🟡 P = 2 o divergencia (rama INSTRUMENTO, no concluye) · 🔴 P ≤ 1 en
   2 de 3. **Condición de validez previa:** si el tester usó el botón
   menos de **2 veces/minuto** cuando lo tenía, la fase sin él **no se
   interpreta** — es la objeción del Outsider vuelta gate (un poder que
   nunca fue divertido no duele al desaparecer).
   **Y la regla que más importa, ya escrita:** un 🔴 en el test gris
   **NO puede falsear el pilar** — un cubo sin vínculo mide un reflejo
   motor, no duelo. Solo habilita conclusiones de ejecución mecánica.
   Un 🟢 tampoco prueba el pilar: es permiso para gastar en B.
   **Lo que falta ya no es el criterio, es el build.**

   **✅ Hook de telemetría IMPLEMENTADO y verificado (2026-08-13).** Era
   la dependencia que bloqueaba la métrica primaria. 6 archivos en
   `godot/`: `scripts/telemetry.gd` (grabador, un CSV por sesión con
   flush por línea), `scripts/ledge_zone.gd` (el volumen de la cornisa),
   `scripts/bond_driver.gd` (el botón y el corte del minuto 5 **en
   silencio**), `tools/telemetry_analysis.gd` (deriva P/T/U y clasifica),
   `tools/telemetry_report.gd` (informe + veredicto) y
   `tools/test_telemetry.gd` (**50 verificaciones, ALL_PASS**).
   ```
   godot --headless --path godot --script res://tools/test_telemetry.gd
   godot --headless --path godot --script res://tools/telemetry_report.gd -- --dir=user://telemetry
   ```
   Los umbrales viven como constantes en `telemetry_analysis.gd` y **no**
   se pueden pasar por línea de comandos: moverlos es un commit con fecha
   y autor, que es lo que §6 pide.

   **✅ ESCENA GRIS construida y verificada (2026-08-13).**
   `godot/scenes/gray_test.tscn`, generada por `tools/build_gray_scene.gd`,
   con `tools/test_gray_scene.gd` (**18 verificaciones, ALL_PASS**).
   Arena de 44×44, mesa central a **2.4 m**, y sobre la mesa una torre de
   dos peldaños a **4.6 m** y **7.0 m**. La cápsula **no tiene salto
   propio**; el botón da 7.5 m/s (ápice 2.87 m) y solo responde con los
   pies en el suelo. El test camina contra la mesa **desde 8 direcciones**
   con física real: altura máxima **0.00 m** — no hay vía sin botón.
   Se corre con `godot --path godot -- --tester=Diego`; F10 corta por
   fallo técnico y F11 por incomodidad del tester.
   **La torre está ARRIBA de la mesa y no al lado**: desde el suelo una
   mesa de 2.4 m se lee como un muro, y dos bloques parados encima son lo
   más barato que dice "esto es una superficie". De paso, toda la
   verticalidad queda del otro lado del botón — al minuto 5 no se pierde
   una cornisa, se pierde el piso de arriba entero.

   **⬜ Lo que ahora bloquea, y son dos cosas chicas:**
   (a) **congelar el build y anotar el hash** en §0.5 — última casilla
   abierta de §0; (b) **una pasada de feel con vos en la máquina**:
   velocidad, sensibilidad de cámara y altura del salto están puestas por
   número y nadie las jugó. Si el control se siente mal, un 🔴 sería de
   ejecución y el test habría costado tres sesiones para decir eso.

   **Riesgos abiertos que nadie había nombrado** (los 3 primeros ya con
   instrumento en el protocolo): el gancho es una ausencia y **no se
   captura en un GIF** — lo miden las preguntas 13 y 14 · el golpe de la
   pérdida es **50% audio**, y mientras el build esté mudo **está
   prohibido concluir la rama DISEÑO** · la objeción del Outsider al
   desbloqueo de Bram la mide la pregunta 12, con redacción neutra · el
   acoplamiento 1:1 Pivote↔build raza×rol sigue sin instrumento porque
   no es de playtest: desacoplarlo cambia toda la aritmética.

**Resumen de la 17ª ronda de QA (2026-08-10)** (detalle completo en
[[LOG]]): 13 críticos entre 2 subagentes en frío sobre todo el
`provisional` acumulado — corregidos a la fuente: dónde/cuándo se suma
Valen (taberna, ciudad natal), rol duplicado de Roen ("doble ancla" +
bajado a T1), excepción de manada de los 3 Hollowed, reubicación de
"El Encuentro" en las fichas draft de Roen/Valen (Zephyr, no The
Wilds), remate Strategist restaurado a distancia, escudo de Roen
quitado de la escena del tutorial, y 3 fixes menores de residuos.
Pendiente re-corrida antes de ratificar (ver punto 2 arriba).

### ✅ Medios de la 4ª — cerrados (2026-08-11, 2ª tanda)

4 decisiones más de Boris, ya escritas: **Roen en el bookend tiene 70-75**
(los cierres mandan, "thirty years" ×4) · **los 2 años de espera de Darro
van dentro de las edades 30-33** (sale a los 33, la cadena 33→38→63 y la
edad ~63 quedan intactas) · **el Acto 1 tiene un solo Momento de Persona**,
el del nido · **derribar al portador no mata a Speck** — la sobrecarga
necesita que la fuerza entre por su cuerpo, así que F1 es jugable en las
rutas Nyael y Bram con la regla de escritura "el jugador nunca pone una
mano sobre Speck en F1".

También cerrados: la entrada **Valen + Dagna** (la matriz 3 fijos × 9
Pivotes quedó completa) · Torgan y Dagna con ritos duplicados en dos POIs ·
Lyris tomando prestado el beat de "Deber Institucional" en F2a · el arnés
de Vekka condicionado a la variante viva · el beat de duelo de Maren ·
Encuentro con Roen "el link no cambia por rol" vs. "split por rol" ·
Sereth citando F1 dentro de la ficción de F3 · "sub-acto 1B" · los tres
flashes colapsados en dos · la nota cruda de `Nomenclatura`.

**Sigue abierto, es decisión de diseño, no de QA:** el caso "rol duplicado"
vive en **T1 para Roen y en T2 para Valen y Darro**, sin razón declarada — y
solo en Roen *sustituye* el sabor base en vez de sumarse. Si "la intimidad
es el árbol" ([[The Tether]]), una variante fijada en la pantalla de
creación de personaje no debería vivir en el árbol. Revisar junto con la
pregunta abierta de las escenas firma de T3 (punto 3 de arriba).

### Pendientes menores, sin bloquear nada
- ✅ **CERRADO (2026-08-17).** Excepción del Bond invertido de Bram: la ficha
  de Bram ya la anotaba bien (§sub-beat 2b, citando la fuente única); el hueco
  real era solo la fila **Mobile Foundry** de `Los 9 Links del Pivote`, que ya
  quedó anotada. Fuente única sigue siendo `Bond y el Bond Vacío` §La excepción
  de Bram.
- Orejas de Speck en las 5 láminas de finales: forma de zorro simple, no la
  forma de pétalos establecida en canon. Refinamiento visual futuro.
- Traducción pendiente de los beats de diálogo ya escritos en español (ver
  arriba, regla de idioma).
- `.claude/worktrees/quirky-wiles-afa8a0/` — worktree real de git (rama
  `claude/strange-galileo-243fc7`, 62MB) con vault viejo adentro. No se tocó;
  revisar si hace falta.

### ✅ Bestiario/Flora/Villanos menores — cerrado (2026-08-04)

3 archivos nuevos ([[Bestiario]], [[Flora y Ecosistemas]],
[[Villanos Menores]]) llenando el hueco de mundo abierto — detalle
completo en [[LOG]]. **Concept art del batch: 9/9 cerrado (2026-08-06).**
Los 3 re-rolls de texto (Leviathan v2, Wyrm v2, Borran v3) ratificados
sin cambios de canon. Mirror Stalker cerró distinto: tras 3 intentos sin
lograr la superficie de espejo literal, Boris aceptó la v3 (autómata de
cristal/vidrio) como pivote de diseño — [[Bestiario]] §The Mirror
Stalker ya actualizado. Mistbound Frontier sigue sin flora/fauna propia
(no bloquea).

### Worldbuilding — abierto
- **El Último Reino humano pre-Regencias:** construir backwards qué fue,
  cuándo cayó y cómo cuadra con 550 años de Regencias. El reclamo de House
  Marrow es leyenda deliberadamente no verificable — **no bloquea nada**,
  pero si se quiere hacer canon hay que escribirlo.
- Culturas por raza — ceremonias, idioma, costumbres (Aether-Born/Iron-Blooded/Restless)
- Lore de civilización Warden pre-caída
- Estrategia militar de los 3 reinos en el clímax
- The First Wound (ficha lore completa), Sunken Archive (ficha lore)
- Cabeza de the Academy of Sages (baja prioridad)

### Narrativa / guión (próximo frente real — en inglés)
- **✅ Bookend de Roen viejo — cerrado.** [[Voz Narrativa]] +
  [[Guion/Apertura — Roen Viejo]] + [[Guion/Cierres — Roen Viejo]], los 3
  `ratificado`. Sin narrador durante el juego; único bookend.
- **✅ Encuentro con Roen — estructura + guión escritos.**
  [[Geografía y Ciudades]] fija la secuencia (title card a mitad del
  tramo solo → emboscada de 3 Hollowed → Roen interviene → *Second
  Catch* variable por rol, no raza). [[Guion/Encuentro con Roen]] la
  escribe, `status: provisional` (toca *Second Catch*, pendiente QA del
  domingo).
- **✅ Armamento Base ratificado — 12 celdas + 9 Pivotes sin
  colisiones.** [[Armamento Base — Matriz Raza x Rol]]: arma/verbo/
  mecánica por celda, ventana de input del remate, equipamiento de
  Roen/Darro/Valen, escudo de Roen reconciliado. Barrido contra los
  Pivotes cerró 2 colisiones (Torgan, Lyris). Implementación
  (hitbox/timing/peso) sin verificar todavía — no bloquea.
- Guión completo por actos (GDD §1.2 tiene estructura, no hay diálogos)
- Momentos de Persona de Speck; diálogos del Bautizo (Darro la nombra)
- Los 5 Finales — scripting de diálogos/cinemática; estado post-final
  jugable; variantes C3 vivo/muerto
- Traducción de los beats de diálogo existentes en español (Reckoning, etc.)

### Concept art pendiente
- **✅ Tutorial de Zephyr completo — 5/5 ratificadas.** [[Briefs de
  Concept Art]] §15 (entorno ×3 skins) + §16 (emboscada/Roen) + §17
  (re-roll de Lyris, bumeranes). Todas copiadas a `90-Raw/concept/`.
  Notas menores no bloqueantes anotadas en el brief de cada una (§15-17).
- **✅ King Borran — ya cerrado (§9b-v3, ratificado 2026-08-06).**
  `king-borran-v3.png` en `90-Raw/concept/`. Flag viejo limpiado de esta
  lista — estaba mal listado como pendiente.
- **Driftmarket y Rivermeet daylight: ya resueltos**, flags viejos
  limpiados de esta lista (Driftmarket ratificado desde 2026-07-27 en
  §11.1; Rivermeet daylight ya estaba 🟡 aprobado, no bloqueaba nada).
- **✅ key-art-poster V2 — ratificado retroactivamente (2026-08-07).**
  [[Briefs de Concept Art]] §12.2, `marketing_key-art-poster-v2.png`
  (generado 2026-07-28, hallado sin evaluar), copiado a
  `90-Raw/concept/`. Nota menor no bloqueante: mismo ícono de destello
  de NB2 ya trackeado desde §15.4. §12.1 (V1) sigue sin correr.
- Sin tocar esta sesión: revisar las 4 escenas de traición (¿legacy o
  canon?); set de combos sin doc; QA de las 4 variantes de The Wilds;
  videos Higgsfield (bloqueo ffmpeg); POIs sueltos cuando aparezcan en
  el guión.

### Mapa del mundo
`Aether Bound universe.png` = referencia interna imperfecta (texto corrupto
en etiquetas). Plan: documentar por escrito a medida que avanza el
worldbuilding → al cerrar el frente, escribir spec exhaustiva. Ver cabecera de
[[Briefs de Mapa del Mundo]].

**POSPUESTO (post-lore):** trailer formal, cutscenes cinemáticas, banda sonora.

---

**Historial completo:** [[LOG]] y [[Current-State-Historico]].
