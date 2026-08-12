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

1. **Guión: siguiente escena.** El tramo de caminata silenciosa hacia la
   ciudad natal, y la escena en la taberna donde se suma Valen
   ([[Geografía y Ciudades]] §Beats Narrativos, locación 1 — corregido
   2026-08-10, ver [[LOG]]). Sigue directo de
   [[Guion/Encuentro con Roen]].
2. **🔨 BLOQUE DE PROPAGACIÓN — las 12 fichas. Empezar por acá, y no
   mezclarlo con más QA.** Es el pendiente más grande del vault y la
   única razón por la que el sprint no cierra.

   **Qué pasó:** la 4ª y la 5ª re-corrida cambiaron canon estructural
   (ver punto siguiente) y ese canon **no está en ninguna de las 12
   fichas**. Los dos subagentes de la 5ª lo reportaron por separado,
   sin verse. No es un fix de línea: es escritura.

   **Qué hay que hacer, por ficha (9 Pivotes + Roen/Valen/Darro):**
   - Escribir la **ruptura** — el Pivote declara en la sala del
     Fragmento y el link muere ahí. **Nueve formas desiguales, no una
     plantilla** (decisión de Boris): una frase seca para Maren, quince
     líneas para Sereth, casi ninguna palabra para Vekka. El beat se
     define por su función, no por su formato.
   - **Reescribir las 9 escenas del corredor**, que hoy están escritas
     como la revelación (*"¿lo sabías TODO ESTE TIEMPO?"*, el shock de
     los tres fijos, "nadie lo nota"). Ahora el grupo lleva el ascenso
     entero sabiéndolo: sin sorpresa, sin música de giro.
   - **Colocar el obstáculo firma del link perdido durante el ascenso**
     — es la ventana del beat del Bond vacío, y hoy no existe en
     ninguna ficha. Sin esto el pilar 2 sigue sin pagarse.
   - Corregir el índice: cada ficha declara **5 sub-beats** y ahora son
     **6** — 1, 2, **2b**, 3, 4, 5.
   - **Migrar la línea canónica de traición** de cada Pivote: las 9
     están escritas para el corredor (ver la columna *Línea* de la matriz
     en [[Los 9 Pivotes]]).
     Decidir por ficha si migra a la ruptura o si el corredor la repite
     en frío.
   - Los 3 fijos: su coro de reacción está escrito para una revelación
     que ya no ocurre ahí. **Ojo con Valen** — sus reacciones en
     Maren/Sereth/Iven usan todas la misma estructura ("noté X, lo
     modelé, esperé estar equivocado"): es convergencia de tanda, hay
     que variarlas al tocarlas.

   **Método:** por tandas, con linter + commit por tanda. **La 6ª
   re-corrida va después del bloque, no antes** — correrla ahora es
   pagar tokens por hallazgos que ya están inventariados en [[LOG]].

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
   - **La Primera Cuña de Dagna** —el único pago mecánico del bond alto
     con el Pivote— está anclada a "la roca del nido", lugar por el que
     la traición ya no pasa, y ni la cuña ni el martillo heredado
     aparecen en su ficha. Además [[The Tether]] no contiene la "regla
     T3" que [[Los 9 Links del Pivote]] le atribuye.
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
