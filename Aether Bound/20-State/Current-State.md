---
status: vivo
updated: 2026-08-04
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

## Estado general (2026-07-30)

**Worldbuilding narrativo:** las 9 fichas de Pivote + los 3 fijos + Speck +
Old Tobin Hale + toda la estructura política y geográfica están escritos. El
vault soporta escribir guión en cuanto cierre el sprint QA (13ª re-corrida,
único pendiente — ver "Inmediato" abajo).

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

### 🔜 Pendiente para cerrar el sprint

**Rondas 7ª-10ª procesadas (2026-08-02/03).** Detalle completo en [[LOG]].
13 → ~9 → 7 → ~10 críticos: **el volumen no bajó en cinco rondas**, siempre por
el mismo mecanismo (un fix entra en la fuente y no baja a las fichas). Las
decisiones de canon que salieron de esas rondas — gate F1/F2a con mensajero,
orden "El Primero", bautizo a Acto 2, agencia a 4 grados, el Pivote siempre en
el borde — están todas aplicadas. En la 10ª **se cortó el ciclo de parches y se
hizo una sesión de diseño.**

### 🏗️ Fix de arquitectura — cerrado, 0 decisiones de diseño abiertas

La mecánica del cráter, copiada a mano en 13 archivos, se centralizó en
[[El Cráter — Matriz de Rutas]] (fuente única); `Los 5 Finales` y `Geografía
§ACTO 3` podados; 8 chequeos nuevos en el linter. Detalle completo, incluidas
las 4 decisiones de diseño ya resueltas (gate F4, homogeneización de los 7
ejes F4-muerta, sabor de F4 con el beat de duelo en las 9 rutas, y agencia
de Speck con el beat mínimo de "cedida" en `Speck.md §Capa 4`): [[LOG]].

**12ª re-corrida corrida (2026-08-04): 6 críticos, todos cerrados en la fuente.**
Detalle en [[LOG]]. Ninguno era propagación repetida — 5 eran superlativos de
exclusividad colisionando entre archivos y beats obligatorios faltantes
(Lyris F1/F2b, Iven F2b, Nyael F2a), 1 fue una decisión de diseño real
consultada a Boris (quién llora: Iven conserva la exclusividad, Dagna pasa
a "se le quiebra la voz"). También se cerró una porción grande de medios
(rango de pasos de la Matriz, puntero circular Speck/Los 5 Finales, eco
Bond de F3, línea canónica de Sereth, edad de Bram, geografía de Bram,
gates faltantes, doble grieta de Vekka). Quedan menores sin cerrar (no
bloquean). **Falta lanzar la 13ª re-corrida** para confirmar cierre.

### 🛠️ Herramientas del vault

```
python "Aether Bound/scripts/check_vault.py"    # peso de arranque
python "Aether Bound/scripts/check_canon.py"    # consistencia (20 clases)
```

`check_canon.py` — **20 clases**. Las 12 originales: citas `§`, wikilinks,
fuente única, aritmética de edades, longevidad, género, reinos, cuadrantes,
diálogo, fichas duplicadas, huérfanos de índice. Las **6 nuevas (2026-08-03)**
cubren la escena del cráter, que causó críticos en 4 rondas seguidas:
`crater-mensajero` (cada Pivote responde a su cadena, no al Council por
defecto), `crater-borde` (el Pivote nunca en el centro), `gate-f4` (prohibido
agregar condición de ruta), `premisas` (matar a Speck no sana nada; no hay
reloj autónomo), `crater-beats` (F3 exige soltar, F4 exige que el mensajero se
aparte), `quiebre-fijos` (los fijos narran su reacción, no el evento).
**+2 de la 11ª:** `quiebre-lugar` (la traición ocurre en el corredor, no en el
cráter — el chequeo anterior veía el QUÉ y no el DÓNDE) y `superlativos`
(un «única vez» de un fijo vale en un solo lugar del vault).
Verificados contra los errores reales de las rondas 10ª y 11ª: los cazan todos.

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

El cuello de botella no es el QA, es el **barrido**: fixes hechos en la línea
reportada y no en la clase completa causaron que críticos ya "cerrados"
reaparecieran en la ronda siguiente (pasó en la 4ª→5ª y otra vez en la
5ª→6ª). Ver [[Lecciones]] y [[QA de Canon Loop]].

Con el sprint cerrado, el frente siguiente es **guión y diálogos por actos**
(ahora en inglés), y se abre la pregunta de bonds de fijos (abajo).

**Plan de abordaje con asignación de modelos por sprint:** `~/.claude/plans/haz-un-plan-de-dazzling-lemur.md`.

---

## 🔴 BLOQUEO ACTIVO — no se toca código

**[[ADR-003 Reset de desarrollo y motor]] está ABIERTO** (2026-07-28). El
director planteó hard reset de código + revisión de la decisión de motor
(Godot → posiblemente Unity).

- ❌ No se escribe código de producción, ni en Godot ni en Unity. Frente C del
  Task-Board congelado.
- ✅ **Sigue desbloqueado:** worldbuilding, guión, concept art, mockups de UI,
  diseño de sistemas en papel.

**5 criterios a resolver, en orden:** (1) vertical slice mínimo → (2) target
de plataforma → (3) alcance v1 vs post-lanzamiento → (4) motor evaluado
contra el slice → (5) inventario de qué se conserva. Requiere sesión con el
director; no delegable.

**Nota clave:** el riesgo mayor no es el motor — es que el alcance narrativo
(9 Pivotes × 5 finales × 9 celdas) creció a escala de estudio mediano. Ningún
motor resuelve eso.

---

## Hechos vigentes

- **Branch:** `feat/c6-anatomy-rework`. Playtest: `Start-Playtest-Greybox.bat`.
  Gates: `autotest_combat.gd`, `autotest_springboard.gd`. **Congelados por
  ADR-003.**
- **Speck:** la última Warden cristalina superviviente, shapeshifteada como
  zorro. Narrativa + diseño visual 100% completo. Detalle en
  [[Current-State-Historico]].
- **Anatomía/rework (C6):** oreja élfica 75%, nacimiento de oreja 74/70/78%.
  Queda: ROM por raza (C4), pies sin IK.
- **Motor:** GODOT confirmado (ADR-002), en revisión por ADR-003.
- **Deuda técnica visible:** pies sin IK, ROM enano/elfo (C4 restante), mesh
  de bloques = etapa.
- **Riesgos abiertos:** frame budget frágil RTX 2060 (~58 fps warm); export a
  consolas requiere partner externo.

---

## Pendientes

### 🗓 Inmediato — arrancar acá mañana

1. **13ª re-corrida QA** — criterio de cierre del sprint: 0 críticos de 2
   subagentes Opus en frío. La 12ª (2026-08-04) encontró 6 críticos, todos
   cerrados en la fuente (detalle en [[LOG]]); esta ronda debería confirmar
   el cierre o encontrar lo que quedó.
2. **Pregunta de bonds de fijos** de `The Bound Five.md` — mecanismo de
   bonds/links propios para Roen, Darro y Valen a partir de raza/rol, para que
   los 9 vínculos sean protagonistas por igual. Toca `The Tether` y `Bond y el
   Bond Vacío`. Arranca al cerrar el sprint.

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
- Guión completo por actos (GDD §1.2 tiene estructura, no hay diálogos)
- Voz narrativa (¿narrador? ¿silent protagonist? ¿qué tan verbose?)
- Momentos de Persona de Speck; diálogos del Bautizo (Darro la nombra)
- Los 5 Finales — scripting de diálogos/cinemática; estado post-final
  jugable; variantes C3 vivo/muerto
- Traducción de los beats de diálogo existentes en español (Reckoning, etc.)

### Concept art pendiente
- Revisar las 4 escenas de traición (¿legacy o canon?); set de combos sin
  doc; QA de las 4 variantes de The Wilds; videos Higgsfield (bloqueo
  ffmpeg); King Borran 🟡; Rivermeet daylight 🟡; Driftmarket 🔴; key-art-poster
  🟡; POIs sueltos cuando aparezcan en el guión

### Mapa del mundo
`Aether Bound universe.png` = referencia interna imperfecta (texto corrupto
en etiquetas). Plan: documentar por escrito a medida que avanza el
worldbuilding → al cerrar el frente, escribir spec exhaustiva. Ver cabecera de
[[Briefs de Mapa del Mundo]].

**POSPUESTO (post-lore):** trailer formal, cutscenes cinemáticas, banda sonora.

---

**Historial completo:** [[LOG]] y [[Current-State-Historico]].
