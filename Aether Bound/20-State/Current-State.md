---
status: vivo
updated: 2026-08-11
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

## Estado general (2026-08-05)

**Worldbuilding narrativo:** las 9 fichas de Pivote + los 3 fijos + Speck +
Old Tobin Hale + toda la estructura política y geográfica están escritos.
Sprint QA cerrado (16ª). El vault ya soporta escribir guión.

**Sprint QA de reparación — rondas 3ª a 6ª cerradas.** Historial completo en
[[LOG]] y [[Current-State-Historico]]. Canon que quedó fijado ahí y sigue
vigente: costo de F1 = colapso tecnológico (no exterminio); una sola fuente
viva por personaje; Speck durmió 550 años en crisálida; Bound Five formado en
Acto 1; topología "rueda, no malla"; **Iven es excepción intencional** de la
fila Deber Institucional (registrada en `Los 5 Finales §matriz` — ningún QA
debe reportarla). Los 5 finales visuales están completos y ratificados.

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

**Lo que salió del consejo + el cierre:** motor **GODOT** (ADR-002 vuelve
a plena vigencia) · vertical slice = [[Slice of Bond]] recortado a 3
escenas con **Dagna**, greybox de entorno pero **no de cuerpo** (rig con
biomecánica y game feel correctos) · PC únicamente para v1 · alcance de
v1 diferido hasta medir el costo real en horas de un Pivote · método:
gauntlet-loop solo sobre traversal, con [[Benchmark Biomecánico]] como
estándar. Detalle completo y las 3 piezas pre-código (árbol de "¿y si no
duele?", contador de horas, 3 playtesters — Diego/Santiago/Delmer, con
protocolo de sesión) en el §Cierre del ADR.

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
2. **5ª re-corrida de QA — empezar por acá.** La **4ª corrió el
   2026-08-11**: 8 críticos (4+4), todos corregidos a la fuente con
   re-grep, más ~14 medios. **Sigue sin cerrar** — el criterio es 0
   críticos en ambos subagentes. Detalle completo en [[LOG]].

   **6 decisiones de canon tomadas en esa ronda, ya escritas:** la
   decisión de la crisálida es **elección ilusoria** (no hay rama
   "destruida"); Roen **decide** renunciar en la frontera y lo
   **formaliza** en Rivermeet; en F3 Roen **se va después** del clímax;
   la traición del Pivote ahora tiene **dos tiempos** (ruptura en
   Driftmarket → tramo jugable con el link muerto → toma en el corredor),
   que es lo que le da ventana al beat del Bond vacío; entre gates
   solapados **gana F4** si sus 2 condiciones globales están cumplidas; y
   el arco de Valen son **90 años**, no 200.

   El cambio 4 (traición en dos tiempos) es el más grande: tocó
   [[Estructura Dramática]], [[Geografía y Ciudades]] §ACTO 3 (sub-beat 0
   nuevo), [[Bond y el Bond Vacío]] y [[El Cráter — Matriz de Rutas]] §1.
   **La 5ª tiene que barrerlo específicamente** — es canon fresco y
   ninguna ficha de Pivote se revisó todavía contra él.
3. **Pregunta abierta:** ninguno de los 3 T3 de los fijos tiene "escena
   firma" propia (solo Roen tiene objeto firma, el escudo) —
   [[The Tether]] promete ambos para todo T3. Es decisión de diseño, no
   de QA — revisar antes de ratificar [[Los 3 Links de los Fijos]].
4. **Reglas de tráfico mientras tanto:** linter (`check_canon.py`) antes
   de cada checkpoint, siempre.
5. **Concept art:** §12.1 (V1 del key-art-poster) sigue sin correr — es
   el único brief pendiente de la sección 12.
6. **✅ Investigación de gauntlet-loop — hecha (2026-08-10).** No es una
   tercera vía de motor: es un método de producción (constructor +
   crítico en loop contra un estándar medible) ortogonal a Godot/Unity,
   aplicable sobre cualquiera de los dos. Ya disponible parcialmente vía
   skill `/loop`; candidato de estándar medible: [[Benchmark
   Biomecánico]]. Detalle completo en [[ADR-003 Reset de desarrollo y
   motor]] §Tercera vía.
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

### Abiertos de la 4ª re-corrida — medios sin cerrar

No bloquean el guión, pero la 5ª los va a volver a reportar si no se tocan:

- **Edad de Roen en el bookend:** ficha dice 45, [[Voz Narrativa]] dice
  60-70 "20-30 años después", y los cierres dicen "thirty years" ×4.
  45+30 = 75, fuera de banda. Decidir: bookend a 20-25 años, o banda a
  70-75.
- **Timeline de Darro:** los 2 años que espera tras el rechazo de Vekka no
  caben en la cadena 33→38→63. O sale a los 35, o los 2 años van dentro
  de las edades 30-33.
- **Momentos de Persona en el Acto 1:** [[La Rueda]] dice 2, [[Speck]]
  dice 1 (+1 ambiguo), [[Geografía y Ciudades]] dice 1. Importa porque el
  gate de F4 se calcula sobre los Momentos disponibles.
- **`Valen-Ficha` no tiene entrada para Dagna** — 8 de 9 Pivotes. Único
  hueco de la matriz 3 fijos × 9 Pivotes.
- **Torgan y Dagna con ritos duplicados en dos POIs:** el Juramento de
  Torgan aparece en Shrine of the First Hammer y en el altar de su clan
  menor; la renovación de votos de Dagna, en Shrine of the First Hammer y
  en Dagna's Clan Stone.
- **Nyael y Bram (holder = agente):** cumplir el gate de F1 exige combatir
  a quien sostiene a Speck junto a un core activo, que es la definición
  física de F2b ([[Speck]] §Capa 5). Las dos rutas donde F1 y F2b se tocan
  son las dos sin resolución escrita.
- **Lyris en F2a** ejecuta el beat de la fila "Deber Institucional"
  (asciende por mecánica institucional) además del suyo, sin estar
  declarada como excepción — la única declarada es Iven.
- **Rol duplicado en tiers distintos:** T1 para Roen, T2 para Valen y
  Darro, sin razón declarada.
- **Nota de trabajo cruda dentro de `Nomenclatura` (ratificado):**
  "Preguntas/Dudas Toño a Claude" — resolver o mover al Task-Board.

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
