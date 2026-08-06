---
status: vivo
updated: 2026-08-07
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

### ✅ Sprint QA — cerrado (16ª re-corrida, 2026-08-05)

Rondas 7ª-15ª (2026-08-02/04): decisiones de canon y arquitectura resueltas
(gate F1/F2a con mensajero, cráter centralizado en [[El Cráter — Matriz de
Rutas]], 4 grados de agencia, linter ampliado a 22 clases). Detalle completo
en [[LOG]].

**16ª (2026-08-05):** linter 0 críticos → 2 subagentes en frío → **9
críticos reportados, 7 falsos positivos** (citaban mecánica del cráter que
`El Cráter — Matriz de Rutas` ya centralizó el 08-03 y que las fichas ya
citan bien — los subagentes no la encontraron). 2 críticos reales
corregidos en la fuente: `Valen-Ficha` tenía invertido quién lee la
inscripción Warden (es Valen por defecto, Sereth solo en su ruta) y
revelaba "God-Cores = Wardens" como hecho confirmado en Acto 2 en vez de
teoría sin probar hasta el Sunken Archive (Acto 3). + 3 residuos MEDIUM
("9 traiciones"→8, superlativo de Sereth en F4, línea vieja de Lyris).
**Nota de método para la 17ª:** los prompts de QA deben apuntar
explícitamente a `[[El Cráter — Matriz de Rutas]]` como fuente única —
evita el ruido que dominó esta ronda. Detalle en [[LOG]].

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

El cuello de botella no es el QA, es el **barrido**: fixes hechos en la línea
reportada y no en la clase completa causaron que críticos ya "cerrados"
reaparecieran en la ronda siguiente (pasó en la 4ª→5ª y otra vez en la
5ª→6ª). Ver [[Lecciones]] y [[QA de Canon Loop]].

Con el sprint y los links de fijos cerrados, el frente siguiente es
**guión y diálogos por actos** (ahora en inglés).

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

**Arranca el guión.** Diálogos/screenplay empiezan mañana (2026-08-07),
**sin ronda nueva de subagentes de QA** — decisión de Boris (2026-08-06)
para conservar presupuesto semanal hasta el domingo.

**Reglas de tráfico mientras tanto (obligatorias, no opcionales):**
1. El linter (`check_canon.py`, gratis) sigue corriendo antes de cada
   checkpoint como siempre — eso no se salta nunca.
2. Diálogo sobre terreno ya auditado en la 16ª (arcos, encuentros,
   traiciones, los 60 epílogos) se escribe con confianza, sin reserva.
3. Cualquier línea de guión que toque [[Los 3 Links de los Fijos]]
   (Second Catch, The Long Calculus, Open Seam) se trata como
   **provisional** — está bien escribirla, pero no se da por definitiva
   hasta el QA del domingo.
4. **Domingo:** una sola ronda de subagentes audita todo lo acumulado —
   el guión nuevo de la semana + los links de fijos que siguen en
   `status: provisional` — en vez de gastar dos corridas separadas.

**Resumen de lo cerrado el 2026-08-05/06** (detalle completo en [[LOG]]):
Sprint QA 16ª cerrado · [[Los 3 Links de los Fijos]] diseñados
(provisional, pendiente QA domingo) · resolución del botón Bond con 4
links vía council ([[Bond y el Bond Vacío]] §Resolución) · concept art
de los 3 links de fijos y del batch completo del Bestiario (9/9,
incluido el pivote de Mirror Stalker) ratificados.

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
- **✅ Bookend de Roen viejo — cerrado (2026-08-07).** [[Voz Narrativa]] +
  [[Guion/Apertura — Roen Viejo]] + [[Guion/Cierres — Roen Viejo]], los 3
  `ratificado`. Sin narrador durante el juego; único bookend — apertura
  neutra en taberna + 5 cierres variables por final (F1/F2a/F2b/F3/F4),
  formato conversación con un Barkeep fijo. Primer guión real del juego,
  escrito de punta a punta.
- **🗓 Próximo paso:** guión de actos (Acto 1, Encuentro).
- Guión completo por actos (GDD §1.2 tiene estructura, no hay diálogos)
- Momentos de Persona de Speck; diálogos del Bautizo (Darro la nombra)
- Los 5 Finales — scripting de diálogos/cinemática; estado post-final
  jugable; variantes C3 vivo/muerto
- Traducción de los beats de diálogo existentes en español (Reckoning, etc.)

### Concept art pendiente
- **King Borran → §9b-v3 escrito (2026-08-05)**, prosa corta estilo
  Kadrun, listo para correr — reemplaza el intento de re-roll anterior.
- **Driftmarket y Rivermeet daylight: ya resueltos**, flags viejos
  limpiados de esta lista (Driftmarket ratificado desde 2026-07-27 en
  §11.1; Rivermeet daylight ya estaba 🟡 aprobado, no bloqueaba nada).
- key-art-poster 🟡 — los 2 briefs (§12.1/12.2) están completos, listos
  para correr en NB2, nunca se ejecutaron todavía.
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
