---
status: vivo
updated: 2026-08-12
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

En el camino salieron **3 bugs de importación pre-existentes** que el spike
anterior tapaba (árbol duplicado al re-apropiar una instancia · pista de
escala ×100 dentro de la pose del FBX · rig del pack mirando al revés →
moonwalk, que **detectó Boris a ojo**). Los tres están en [[Lecciones]]
§Godot 4.7 — leer antes de tocar importación de FBX otra vez.

**Moonwalk cerrado (2ª pasada del mismo día).** Boris lo siguió viendo en
la corrida viva después del cambio de clip, y tenía razón: eran **dos
problemas distintos con el mismo síntoma**. El primero era de dirección
(clip espejado, ya resuelto). El segundo es de **velocidad**: el clip
in-place aporta 1.22 m/s de zancada y el driver la trasladaba a 1.5 m/s
— 23% de patinada en plano, y del otro signo en la rampa. Arreglado
atando la cadencia a la velocidad real cuadro a cuadro
(`companion_walk.gd`). Medido con una prueba limpia — cuánto avanza el
cuerpo por vuelta del clip contra lo que el clip aporta: **de +23% a
+0%** en régimen.

**Comparador cuadro a cuadro Unity/Godot listo** (`godot/tools/frame_strip.gd`
+ `unity/Assets/_Spike/Editor/SpikeFrameStrip.cs`): mismo punto de la
rampa, mismos cuadros, misma cámara, y la fase inicial alineada por el
contacto del talón izquierdo **detectado midiendo el hueso**. Lo que la
lámina muestra: la diferencia grande **no es de motor, es de clip** — la
zancada de Starter Assets recorre 1.12 m y la de DoubleL 0.65 m. Lo
comparable de motor a motor (retargeting stock + foot IK stock) funciona
en los dos.

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

1. **✅ Guión: siguiente escena — ESCRITA (2026-08-12).**
   [[Guion/Caminata y Taberna — Valen se suma]]: caminata silenciosa
   Roen+jugador hasta la ciudad natal + taberna donde se suma Valen
   ([[Geografía y Ciudades]] §Beats Narrativos, locación 1). Sigue
   directo de [[Guion/Encuentro con Roen]]. Linter en 0 críticos,
   indexada. `status: provisional` — comparte re-corrida con
   `Encuentro con Roen` (los dos tocan links de fijos que siguen
   provisionales).
   **✅ Las 3 decisiones abiertas — cerradas por Boris el mismo día
   (2026-08-12), las 3 escritas a fuente:**
   - **Roen y Valen no se conocían.** El guión queda firme.
   - **✅ Voz del protagonista — decisión nueva, la de más alcance del
     día.** No es silent protagonist clásico: **arranca mudo y gana voz
     acto a acto** (elemento coming-of-age). Fuente única y gradiente
     completo en [[Voz Narrativa]] §Voz del protagonista — Acto 1 mudo ·
     Acto 2 primeras palabras (candidata: **"Speck"**, el nombre que le
     puso Darro) · Acto 3 líneas completas · **vuelve al silencio en el
     Bond Vacío**, que es donde el arco se paga (el silencio deja de ser
     el default y pasa a ser pérdida) · el cráter es la única vez que
     habla **eligiendo**. Las escenas ya escritas no cambian.
   - **✅ Tabernas nombradas:** **The Braided Oar** (Rivermeet) ·
     **The Last Ladle** (Emberdeep) · **Underfall** (The Stillspire) —
     [[Nomenclatura]] §Tabernas de la ciudad natal.
   **Lo único que quedó abierto de este bloque:** si la taberna del
   bookend ([[Guion/Apertura — Roen Viejo]]) es The Braided Oar. No se
   asume por defecto — el Roen viejo contando la historia en la mesa
   donde el grupo se formó es una decisión con peso, y es tuya.
   **Siguiente escena natural:** locación 2 (frontera hacia El Nido, ya
   con grupo de tres), que es donde toca enseñar el T1 de Valen **y
   donde hay que colocar la primera palabra del jugador**.
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
- `Los 9 Links del Pivote`/ficha de Bram no anotan la excepción del Bond
  invertido (solo vive en `Bond y el Bond Vacío.md`).
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
