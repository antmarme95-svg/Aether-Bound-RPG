---
status: vivo
updated: 2026-07-30
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

## Estado general (2026-07-30)

**Worldbuilding narrativo:** las 9 fichas de Pivote + los 3 fijos + Speck +
Old Tobin Hale + toda la estructura política y geográfica están escritos. El
vault soporta escribir guión en cuanto cierre el sprint QA (7ª re-corrida,
único pendiente).

**Sprint QA de reparación — 6 re-corridas procesadas.** Historial completo en
[[LOG]] y [[Current-State-Historico]]. Resumen de lo fijado por ronda:

- **3ª:** agencia de Speck en 3 grados; regla del Fragmento fuente única;
  gates de los 5 finales desambiguados; Isolde = reclamo de House Marrow;
  longevidad alineada; Goggles no retirables; Mudas ninguna completada en
  550 años.
- **4ª (18→17):** costo de F1 = colapso tecnológico, NO exterminio (F1 no es
  mejor que F4); gate de F4 = 2 condiciones; matriz de roles fija eliminada;
  `Geografía` = fuente primaria de ubicaciones. **12 epílogos F1 reescritos.**
- **5ª (15→13):** Speck durmió 550 años en crisálida (nunca estuvo despierta
  disfrazada); 4 fichas cortas archivadas (`Dagna/Darro/Roen/Valen.md` →
  `90-Raw/`, regla: una sola fuente viva por personaje); Bond vacío invertido
  en la celda de Bram; Vekka → Deber Institucional. **Los 5 finales visuales
  completos**, ratificados por Boris (nota abierta no bloqueante: orejas de
  zorro simple en vez de pétalos).
- **6ª (9→9, todos cerrados):** gate de F1 reescrito sin autocontradicción;
  Lyris F1/F3 alineadas a su sub-beat 5; Nyael/Bram F1 mencionan a su agente
  sustituto; premisa "sin reloj autónomo" bajada a la fuente real; Bound Five
  formado en Acto 1 (no Acto 2) propagado a `Geografía`/`Estructura
  Dramática`; topología "rueda, no malla" reforzada; Momento de Persona 7
  corregido a Acto 2. **Iven queda como excepción intencional** a la fila
  "Deber Institucional" (decisión de Boris, 2026-07-30) — es el único de los
  4 cuya institución le mintió activamente; registrado en `Los 5 Finales
  §matriz` para que ningún QA futuro lo reporte como crítico.

### ✅ Old Tobin Hale — ficha escrita (2026-07-30)

[[Old-Tobin-Hale-Ficha-Expandida-v1]]. Personaje de apoyo, sin arco de
traición: dispara el falso positivo del Reckoning y entrega the Wanderer's
Goggles. El extraño que le dejó los Goggles hace 40+ años queda
**deliberadamente sin resolver** (siembra a propósito, mismo patrón que The
Monolith). Indexado en `00-Index`.

### ✅ Regla de idioma establecida (decisión de Boris, 2026-07-30)

**El guión y todo el contenido de front-end (diálogos, líneas canónicas, UI,
textos in-game) se escribe en inglés de acá en adelante.** El vault sigue en
español. Registrado en `CLAUDE.md` regla 9 y en `Nomenclatura.md`.
**Pendiente:** varios beats de diálogo ya escritos (los del Reckoning en
`Geografía y Ciudades.md`, entre otros) están en español, de antes de esta
decisión — necesitan pasada de traducción cuando se aborde el guión completo.
No bloquea nada mientras tanto.

### 🔜 Pendiente para cerrar el sprint

**7ª re-corrida QA.** Criterio: 0 críticos.

### 🛠️ Herramientas del vault

```
python "Aether Bound/scripts/check_vault.py"    # peso de arranque
python "Aether Bound/scripts/check_canon.py"    # consistencia (12 clases)
```

`check_canon.py`: citas `§`, wikilinks, fuente única, aritmética de edades,
longevidad, género, reinos, cuadrantes, diálogo, **fichas duplicadas**,
**huérfanos de índice**. Exit 1 si hay críticos. Método: skill `canon-qa` /
[[QA de Canon Loop]]. **Orden no negociable:** linter en 0 → subagentes en
frío solo para juicio → fixes **a la fuente** con re-grep → checkpoint →
re-corrida.

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

### 🗓 Inmediato
- **7ª re-corrida QA** (ver arriba) — único criterio de cierre del sprint.
- **Pregunta de bonds de fijos** de `The Bound Five.md` — mecanismo de
  bonds/links propios para Roen, Darro y Valen a partir de raza/rol, para que
  los 9 vínculos sean protagonistas por igual. Toca `The Tether` y `Bond y el
  Bond Vacío`. Arranca al cerrar el QA.

### Pendientes menores, sin bloquear nada
- `Los 9 Links del Pivote`/ficha de Bram no anotan la excepción del Bond
  invertido (solo vive en `Bond y el Bond Vacío.md`).
- 3 epílogos F4 (Maren, Iven, Bram) cierran en alza sin friccionar con
  "agridulce, no triunfal"; Roen F4 sin la pasada de tono que sí recibieron
  Valen/Darro.
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
