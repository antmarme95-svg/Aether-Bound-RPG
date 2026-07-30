# AUDITORÍA DE CÓDIGO — AETHER BOUND (2026-07-12, rama `feat/c6-anatomy-rework`)

> **Fuente RAW, depositada verbatim (2026-07-12).** Auditor: subagente Fable
> imparcial, modo solo-lectura (gates corridos para verificar, cero
> mutaciones), encargo del director en el punto de decisión pre-rework. Par de
> este reporte: [[QA-Auditoria-Output-vs-RAW-2026-07-12]]. No se edita.

---

**Veredicto global: base SÓLIDA con deuda de sesión acotada. CERO hallazgos
CRITICAL. Los dos gates corren ALL_PASS. La deuda real está en: andamiaje de
sesión sin limpiar, docstrings del peinado 11 que ya mienten, y una
inconsistencia doctrinal vieja (class_name cruzado) que la lección prohíbe
pero el núcleo usa por todas partes.**

---

## 4. GATES (lo verifiqué corriendo, resultados exactos)

| Gate | Resultado | Tiempo | Detalle |
|---|---|---|---|
| `test_core.gd` headless | **ALL_PASS** (36 PASS) | 1.03 s | Warning esperado de `Config.class_mult` con origin 'unknown' (es parte del test). Warnings de ObjectDB leaks al salir — ruido preexistente, no de esta sesión. |
| `autotest_biomech.gd` windowed | **ALL_PASS** (10 PASS) | 9.1 s | locomotion 0 violaciones ROM, fases windup→active→recovery, clamps de codo/rodilla/hombro correctos, violaciones registradas. |
| `tmp_anatomy.gd` (banco, corrida extra para evidencia visual) | Termina solo (hold=false OK) | 6.1 s | Medidas: estatura 1.883 m, **7.77 cabezas** (canon impreso: 7.5), **hombros 2.72 cabezas** (canon impreso: ~2), pierna 49.7%. |

Notas de entorno: no había editor de Godot corriendo (cero riesgo
Beckett/8770). Epic/EA/Steam SÍ estaban corriendo y **no los maté** (modo
auditoría) — aun así todo corrió al instante, la contención de la lección no
se manifestó hoy. No corrí `autotest_slice` (biomech ya cubría el pedido).

---

## 1. SALUD DE `hair_library.gd` (peinado 11, rework de hoy)

**El código del rework es coherente — no hay lógica muerta ni ramas
contradictorias dentro de la función.** El diff reemplazó limpio la capa vieja
de 7 cintas por el lóbulo `crown_drape` + 9 cintas cortas. Los helpers
`_ribbon`/`_s_spine` están **sanos**: contrato de ejes documentado en ambos
docstrings (lección M10-r4 aplicada). Estilos 0–10 y barbas **intactos** (el
diff solo toca prince_curtain; git log lo confirma).

**Pero el estado es visualmente INTERMEDIO** (corrí el banco y miré
`anatomy_face_34.png` / `anatomy_face_back.png`): el lóbulo corona lee como
casquete/bollo liso con frontera tonal visible desde atrás, y las cintas
cuelgan como tablones rígidos separados con huecos entre sí (lectura
"medusa"), varias en un tono gris-azulado ajeno al castaño.

Deuda concreta:

- **[HIGH] Docstring del estilo 11 ya miente** — `hair_library.gd:407-418`
  dice "7 flequillo/coronilla + 8 laterales + 6 sueltos = 22 mechones". El
  código real: 9 corona + 8 laterales + **9** sueltos = **26**. El comentario
  de la capa externa (`:536-539`) dice "(6)" con 9 entradas en `loose_defs`
  (`:540-551`). La lección M10-r4 es explícita sobre costuras documentadas; la
  siguiente ronda va a leer esto y autorar mal encima.
- **[MEDIUM] Anillo de anclas desalineado del lóbulo rotado** — `crown_drape`
  rota `-0.30` en X (`:465`) pero los anchors (`:493`) y las normales (`:494`)
  se calculan sobre el marco SIN rotar de `crown_c`. Además la "normal" es
  radial-esférica, no la normal real del elipsoide achatado (0.51 en Y).
  Verifiqué numéricamente que raíz y ancla quedan DENTRO del elipsoide (valor
  de forma ~0.4–0.56 < 1). Candidato directo al look de tablones.
- **[MEDIUM] Two-tone roto por el patrón hair_tint** — `lighter` se duplica al
  construir con `lightened(color de paleta)` (`:471-477`), pero
  `characters.gd:62` y `tmp_anatomy.gd:68` re-tiñen SOLO `hair_mat` DESPUÉS:
  1/3 de los mechones (`mi % 3 == 1`) conserva lightened(chestnut `#5a3a24`)
  en vez de lightened(`#8a6b48`). Hoy el desvío es sutil (dos cafés); los
  mechones **gris-azulados** de las capturas NO quedan explicados por esto —
  dejo la observación abierta para la ronda visual (hipótesis: caras traseras
  de cintas edge-on con rim, o material sin re-teñir).
- **[LOW]** Header del archivo (`:1`) dice "10 hair builders" y `build_hair`
  docstring "(0-9)" — hay 12. `_hair_drake_dreads` (índice 9) quedó definido
  tras prince_curtain sin línea en blanco ni comentario "# 9 —" (`:571-572`).
- **[LOW]** Factor mágico de solape `seg_len * 1.16` en `_ribbon` (`:155`) sin
  comentario.
- **[MEDIUM/LOW]** `_beard_stubble` (`:587-608`) usa `StandardMaterial3D` con
  `TRANSPARENCY_ALPHA` → pase transparente → **invisible al Sobel del post**
  (la misma física de la lección del toon). Si un personaje con stubble entra
  a una escena con post Melancolía, la barba desaparece de la tinta. Además
  `shell_mat` (`:589`) es variable muerta.

---

## 2. ANDAMIAJE TEMPORAL (qué es basura de sesión vs. qué queda)

**Basura de sesión (limpiar al cerrar la ventana):**
- **[HIGH]** `project.godot:38` —
  `run/main_run_args="--autotest=res://tests/tmp_anatomy.gd"`: **F5 en el
  editor lanza el banco de anatomía, no el juego**. Editor-only (no afecta
  exports/CLI), pero es exactamente el tipo de estado que se olvida. Revertir
  al cerrar C6. *(Nota del orquestador: revertido en Fase 0, commit 42d169e.)*
- `godot/tests/tmp_anatomy_boot.tscn` + `tmp_anatomy_launcher.gd` (+ su
  `.uid`) — andamiaje Beckett, untracked. El launcher es correcto (add_child
  diferido a /root, espejo de debug.gd). Borrar, o versionar conscientemente
  si el flujo Beckett→banco se queda.
- `beckett/hold_anatomy_bench=false` (`project.godot:29`) + su lectura en
  `tmp_anatomy.gd:159` — un test del juego leyendo un setting con namespace de
  addon de editor. Funciona y el default es sano (false → quit normal);
  acoplamiento sesión-específico a documentar o retirar.

**Queda mientras Beckett esté instalado (correcto, con aviso):**
- Autoload `BeckettRuntime` (`project.godot:23`) — corre en **cada** partida
  windowed (marca TCP a 8771 cada 2 s si no hay editor; diseño del addon dice
  impacto cero, el código lo respalda). **Debe salir de cualquier build de
  release.** `effort_schema`/`dock_revealed` son auto-escritos por el addon,
  OK.
- **[MEDIUM]** `.uid`: **60 untracked vs 69 tracked** — media biblioteca de
  uids se generó esta sesión y quedó sin versionar. Godot recomienda
  versionarlos junto al script. El estado mixto es lo peor de ambos mundos (el
  uid del autoload Beckett sí está tracked, ese riesgo está cubierto).
  Decidir: commitear los 60 o ignorarlos por patrón.

**Sondas `tmp_*.gd` (15 + banco):** `tmp_ally`, `tmp_dagna`×3,
`tmp_duel_pair`, `tmp_guard`, `tmp_pound`, `tmp_pressure`, `tmp_reactions`,
`tmp_spawnflag`, `tmp_springboard`×2, `tmp_step_ab`, `tmp_step_probe`,
`tmp_timefeel`, `tmp_vignette` — todas de PRDs ya cerrados (006/007):
cumplieron su función, son candidatas a archivar/borrar en lote.
`tmp_anatomy.gd` es el único **vivo** (ventana C6).

---

## 3. RESPETO A LECCIONES.MD

- **[MEDIUM] `class_name` cruzado: la lección y el código núcleo se
  contradicen sistemáticamente.** La lección dice "nunca, siempre const
  preload". El núcleo legado usa globals por todas partes: `HairLibrary`
  referenciado por nombre global en `character_rig.gd:1489,1502`;
  `CharacterRig`, `ToonMaterials`, `PhenotypeData`, `PaletteData` como globals
  en decenas de sitios (game_director, escenas, autotests). Los archivos
  POST-lección (`rig_biomech.gd:8`, `character_signature.gd:8`) declaran
  "never class_name" y se cargan con preload… pero `character_signature.gd:72+`
  llama a `ToonMaterials` global — ni los nuevos son puros. **No hay race
  activa** (ambos gates pasan, headless y windowed), así que es deuda
  latente/doctrinal: o se re-scopea la lección (aplica solo a scripts
  preloadeados en corridas `--script`) o se planifica la migración. Lo que no
  debería quedarse es la ambigüedad.
- **Shaders: PASS limpio.** `toon_opaque` y `toon_golden` sin escritura de
  ALPHA (post-safe, comentado el porqué); `melancolia_post.gdshader:141`
  escribe `ALPHA = 1.0` (exactamente lo que exige la lección de quads de
  post); `toon.gdshader`/`toon_foliage`/`chrono_field` escriben ALPHA **a
  sabiendas** y documentado. El rig usa `toon_mat_opaque` desde C6.
- **abs/min/max Variant con `:=`: PASS** en código propio. Única aparición:
  `addons/beckett/tools/run_tools.gd:165` (`var start := max(0, ...)`) —
  código de terceros.
- **Texturas runtime, relojes de tiempo real, espera >POSE_STEP antes de
  captura**: `tmp_anatomy.gd` cumple las tres (`_wait` acumula delta real,
  settle 0.25 s).

---

## 5. DEUDA TÉCNICA GENERAL

- **[MEDIUM]** `character_rig.gd` = **2,418 líneas**: construcción +
  materiales + armadura de origen + VFX de 3 arquetipos + animación
  (+`_process` de ~430 líneas) + constraints, todo en un archivo. Funciona y
  está gateado, pero cada ronda de review lo engorda; los VFX de arquetipo
  (`_update_vanguard_vfx`, `_update_strategist_vfx`, ~500 líneas juntas) son
  el corte natural.
- **[MEDIUM]** Desync datos↔librería: `phenotype_data.gd:4-7` lista 10
  peinados (0-9) — los estilos 10 y 11 **no existen para la UI de creación**;
  `WARPAINTS` lista 6 (0-5) y el banco usa `warpaint=6` (scout marks, existe
  en el atlas pero no en el pick list). Si es intencional (estilos de
  personajes nombrados), no está escrito en ningún lado.
- **[LOW]** Vestigios de outline: `_add_outline_pass`/`_apply_outline_to_children`
  son stubs `pass` (`character_rig.gd:754-758`) con call sites que siguen
  pasando `hair_color` y `0.025`.
- **[LOW]** En `tmp_anatomy.gd`: `_strip_to_sobel` es código muerto (solo se
  llama a sí mismo, `:226-251`, quedó obsoleto por C6a); `i % 1 == 0` siempre
  true en `_build_ruler:283` (el peldaño corto nunca ocurre); el comentario
  `:62` "(M10-r3: 150 mechones)" está desactualizado (son 26 ribbons).
- **[Observación]** El banco imprime desviaciones del canon que nadie gatea:
  7.77 cabezas vs 7.5, hombros 2.72 vs ~2. Es informativo por diseño, pero la
  cifra de hombros es 36% sobre el canon que el propio banco declara —
  decisión estética del director, no mía; solo señalo que el número está
  impreso y sin dueño.

## Prioridad sugerida
1. Revertir `main_run_args` + decidir destino de boot/launcher (basura de
   sesión, cambia el F5).
2. Corregir los docstrings del estilo 11 ANTES de la siguiente ronda de pelo
   (mienten en conteos y capas) + revisar la desalineación
   anillo-de-anclas/lóbulo rotado.
3. Política `.uid` (60 untracked — commitear o ignorar, no mixto).
4. Re-scopear o pagar la lección de `class_name`.
5. Desync PhenotypeData/HairLibrary/Warpaints + two-tone vs hair_tint.
6. Barrido de sondas `tmp_*` cerradas y stubs de outline.

**Lo que no pude verificar:** la causa exacta de los mechones gris-azulados
(requiere ronda visual dedicada); `autotest_slice` (no corrido); y el
comportamiento de Beckett con editor vivo (no había editor corriendo). No
edité ningún archivo ni maté ningún proceso; los únicos escritos fueron
artefactos en `godot/test_out/` (gitignored) y logs en mi scratchpad.
