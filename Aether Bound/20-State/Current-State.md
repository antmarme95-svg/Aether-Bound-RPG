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
vault soporta escribir guión en cuanto cierre el sprint QA (16ª re-corrida,
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

Cráter centralizado en [[El Cráter — Matriz de Rutas]] (fuente única).
Rondas 11ª-15ª (2026-08-03/04): 4 decisiones de diseño resueltas + 30
críticos de propagación/superlativo, todos cerrados en la fuente —
detalle completo en [[LOG]]. Patrón recurrente: datos triplicados sin
fuente única (resuelto, "Superlativo Consolidado" en `Los 9 Pivotes`) y
superlativos de exclusividad colisionando entre Pivotes, no solo fijos.

**Mejora estructural al linter (15ª, sugerida por el propio QA):**
`check_superlativos` solo vigilaba a los 3 fijos y solo detectaba un
personaje repitiéndose a sí mismo. Ahora cubre los 9 Pivotes + detecta
colisiones **entre dos personajes distintos** reclamando la misma
exclusividad "de elenco" (el bug estructural detrás de 3 de los últimos
4 críticos). 22 clases en total.

Queda 1 hueco de canon genuino (quién mueve el dinero de Iven, cruza con
Maren) y menores sin cerrar (no bloquean).

**Falta lanzar la 16ª re-corrida** — a ver si el linter bajó el volumen.

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

1. **16ª re-corrida QA** — criterio de cierre: 0 críticos de 2 subagentes
   Opus en frío. Rondas 12ª-15ª (2026-08-04): 6+4+10+10 críticos, todos
   cerrados en la fuente ([[LOG]]); la 15ª además amplió
   `check_superlativos` — esta ronda muestra si bajó el volumen.
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

### ✅ Bestiario/Flora/Villanos menores — cerrado (2026-08-04)

Hueco identificado por Boris: el vault no tenía criaturas, flora,
ecosistemas ni villanos de mundo abierto con nombre propio (los 4 bosses
que ya existían en Geografía nunca tuvieron ficha). Sesión de diseño
completa — 3 archivos nuevos:

- [[Bestiario]] — eje de salud del Aether (Sano/Ambiental/Corrupto/
  Aberración) aplicado a toda la fauna dispersa; ficha para los 4 bosses
  ya nombrados + 3 nuevos que completan los 5 dungeons formales (Hollow
  Warden, Drowned Choir, Cascade Warden). God's Throne queda sin boss
  nombrado a propósito — no compite con el peso de The First Wound.
- [[Flora y Ecosistemas]] — mismo eje aplicado a plantas; incluye el
  **Jacaranda de Rivermeet** (pedido de Boris) y sistematiza la Hoja de
  Maelys ya existente en la ficha de Dagna.
- [[Villanos Menores]] — decisión de Boris: **sin jefe final** de mundo
  abierto (no hace falta, el antagonismo real es institucional/personal).
  2 capas: facciones de las 3 razas ya establecidas (Compañías Impagas
  humanas, Sin Nombre enanos, No Licenciados élficos — cada una anclada a
  canon político ya escrito) + 2 razas nuevas **no sapientes** nacidas de
  la corrupción del Aether (Vaciados = ex-personas mutadas, espejo oscuro
  de Speck; Motas = enjambre menor, alivio cómico). Ninguna es 4ª
  civilización — no contradice [[Las Tres Razas]].

Se agregaron 2 líneas de reacción de mundo abierto (Bram y Torgan, ver
sus fichas) y se asignaron los 3 bosses nuevos a sus dungeons en
`Geografía y Ciudades`. `check_canon.py` 0 críticos tras el barrido.

**Concept art del Bestiario — 7/9 ratificados (2026-08-04):** los 9 briefs
de [[Briefs de Concept Art]] (sección "13 — Bestiario") se corrieron en NB2. **Burning Shepherd,
Hollow Warden, Drowned Choir, Cascade Warden, The Hollowed, The Chaff**
ratificados y en `90-Raw/concept/`. **Crowned Leviathan** y **Aether
Wyrm** archivados pero pendientes de re-roll (traen texto/etiquetas
incrustadas, violan la regla estándar §10). **Mirror Stalker rechazado**
— se leyó como gólem de piedra, no vendió el concepto de reflejo/vidrio;
no está en el vault, pendiente de re-roll real en la próxima corrida.

**Pendiente de esta sesión:** Mistbound Frontier sigue sin flora/fauna
propia (anotado en [[Flora y Ecosistemas]], no bloquea). Falta meter esta
pasada al loop de QA — mañana.

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
