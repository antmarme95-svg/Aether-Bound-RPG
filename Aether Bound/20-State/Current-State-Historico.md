---
status: archivo
updated: 2026-07-16
---

# Current State — Histórico

> **Archivo, NO punto de entrada de sesión** (eso es [[Current-State]]).
> Higiene de contexto aplicada 2026-07-16 (skill "project-context" de
> Boris): `Current-State.md` se recortó a solo el presente (arranque de la
> próxima sesión + hechos vigentes); todo el relato histórico que vivía ahí
> —sesión por sesión, desde el reseteo del 2026-07-04— se movió aquí
> VERBATIM (copia exacta, sin editar contenido) para no perder nada.
> El registro append-only autoritativo sigue siendo [[LOG]]; este archivo
> es un respaldo de lectura cómoda del relato largo que antes vivía en
> Current-State, no una fuente nueva de verdad.

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

- **➡️ ARRANQUE DE LA PRÓXIMA SESIÓN (2026-07-16, actualizado tras análisis
  técnico + QA visual pedido por Boris — LEER ANTES DE TOCAR GEOMETRÍA):**
  Boris pidió un análisis con 2 subagentes (técnico: lee shaders/pipeline;
  QA visual: mira renders vs láminas RAW y vs benchmarks de estilo, sin
  código) para resolver si el techo de ~50-55% es del MOTOR o de
  ejecución, y si convendría pivotar de "Melancolía Gráfica" (acuarela +
  línea Sobel) a un estilo tipo Ghibli. **Veredicto de ambos, convergente:
  NO es el motor, y NO pivotar a Ghibli.** El pipeline de 4 capas del
  [[Art Bible]] está completo y sano en `melancolia_post.gdshader`
  (Forward+ soporta bien `hint_screen_texture`/depth) — la prueba es que
  el ENTORNO del propio juego (`wilds_start.png`, `combat.png`,
  `city.png`: árboles, cielo, colinas) YA logra el look de tinta +
  acuarela objetivo. Ghibli sería barato de probar (uniforms) pero
  quitaría la línea Sobel que hoy DISFRAZA la crudeza de las primitivas
  procedurales del personaje — expondría el maniquí, no lo arreglaría.
  **HALLAZGO NUEVO Y ACCIONABLE (prioridad #0, antes que SHOULDER_X):**
  el QA visual detectó que el PERSONAJE en los renders `anatomy_*.png`
  (banco `tmp_anatomy.gd`) **no muestra línea de tinta ni acuarela** —
  se lee piel con specular tipo PBR/plástico genérico — mientras el
  entorno, en el mismo pipeline, sí la muestra. El tratamiento visual
  funciona, solo no está llegando al rig del personaje en ese banco
  específico (posible desconexión entre `attach_post`/`PipelineConfig` y
  la escena de `tmp_anatomy.gd`, o `ink_fade_dist`/parámetros que apagan
  la tinta a la distancia de esas capturas — ver hallazgos B/D del
  subagente técnico: `golden_scene.gd:97-99,115` diverge de
  `pipeline_config.gd:11,15`). **Investigar y arreglar esto ANTES de
  seguir puliendo geometría** — el % de fidelidad reportado (32→55%)
  puede estar midiendo capturas que nunca tuvieron el tratamiento
  completo aplicado, lo cual invalida parcialmente la comparación contra
  la lámina. Segundo hallazgo del QA visual, sin investigar aún: los
  renders `wilds_start/combat/city` muestran un rig de personaje
  DISTINTO y mucho más primitivo (cápsulas sin cara, tipo bloqueo) que
  los renders `anatomy_*` — confirmar si eso es un placeholder de
  gameplay intencional (esperando integrar el rig nuevo) o una
  regresión/desincronización real entre bancos.
  **HALLAZGO #0.5 (mismo día, 2026-07-16, tras pedido de Boris de conocer
  a fondo la herramienta):** verificación en código (grep directo)
  confirmó que los 5 recursos de [[Propuesta-Recursos-de-Modelado]]
  (ratificados 2026-07-12) **siguen SIN ejecutar** — cero `SurfaceTool`/
  `Curve3D`/triplanar en `character_rig.gd`, y `toon_ramp.tres` sigue en
  `interpolation_mode=CONSTANT` (causa exacta del banding duro). Catálogo
  completo con prioridad de uso en [[Catálogo Técnico Godot]] (nueva
  página). **Esto cambia el punto 2 de abajo: el pelo NO necesita un 4º
  intento con cajas/conos — necesita el loft (`Curve3D`+`SurfaceTool`)
  ya ratificado hace 4 días y nunca aplicado.** Quick win adicional
  identificado: probar `interpolation_mode=LINEAR` en `toon_ramp.tres`
  (cambio de una línea) antes de cualquier otra cosa de shading.
  **HALLAZGO #0.6 (mismo día, 2026-07-16): nuevo recurso de conocimiento
  minado, listo para usarse en el punto 1.** Boris consiguió el libro
  "Anatomy for 3D Artists" y se minó completo (157 páginas, 5 subagentes,
  disciplina de copyright respetada) en [[Principios de Anatomía 3D]]
  (`10-Knowledge/`). Da una hipótesis CONCRETA para `SHOULDER_X`: bloquear
  el torso en 3 masas (caja torácica 2/3 + cintura deformable + pelvis
  1/3, no un cilindro continuo) con la cintura escapular
  (clavícula+escápula+acromion) como bloque separado y articulado sobre
  la caja torácica — no una continuación lisa del hombro al brazo.
  También trae solución concreta para el punto 2 (manos: sistema de
  mitades sucesivas + dedos que curvan convergiendo al medio, nunca
  rectos) y contexto útil para el punto 2 de pelo (bloquear masa completa
  ANTES que mechones individuales, variar tamaño/ángulo entre mechones
  vecinos — ver nota de fricción con el Sobel en la página, no aplicar
  ciego lo de "transiciones suaves"). **Usar esta página junto con medir
  la lámina en píxeles, no en vez de — el libro da lógica estructural
  transferible, la lámina sigue siendo la autoridad de proporción real.**
  **Después de resolver los puntos #0, #0.5 y #0.6, sigue el orden de
  impacto de la ronda 55% (sin cambios respecto al cierre 2026-07-14):**
  1. **✅ AUTORIZADO por Boris (2026-07-14, verbal en chat de cierre):
     reabrir `SHOULDER_X`/proporciones base del hombro.** El QA de la
     ronda 55% volvió a marcar la silueta general como "maniquí de
     tienda, sin cintura ni trapecio real" — el mayor punto de
     apalancamiento ahora, más que cara/manos. Contexto para quien
     ejecute: `SHOULDER_X` (hoy 0.21, `character_rig.gd`) fue calibrado
     en una sesión previa midiendo la lámina en píxeles (biacromial
     ~2.05 cabezas) — no es arbitrario, y una review vieja ya lo dejó
     fosilizado mal una vez (pidió "+10-15% más ancho", terminó +30%
     contradiciendo la lámina "narrow sloped shoulders" — ver
     [[Lecciones]], "ante conflicto con una review, auditar contra la
     lámina"). **Antes de tocar el número: medir la lámina en píxeles de
     nuevo** (mismo método que la vez anterior) para confirmar si el
     problema es realmente de ancho de hombro/cintura o de otra cosa
     (definición de superficie, vestuario que llega en Fase 4, etc.) —
     no cambiar el pivote a ciegas solo porque el QA lo nombró.
  2. **Pelo — mechones siguen fundidos en 2-3 lóbulos**, no leen como
     hebras individuales pese a la reconstrucción completa de
     `_hair_frontier_crop`. Necesita otra pasada de geometría (quizás
     tercer intento con una técnica distinta a boxes/conos semi-hundidos).
  3. **Costura/parche visible cuello-hombro** (hallazgo nuevo de la
     ronda 55%, NO investigado — puede ser un gap de geometría no
     soldada en la unión torso/cabeza/collar).
  4. **Boca — tono rojo-marrón oscuro lee "herida"**, no labios; la
     geometría (Opción A, fusión) ya está resuelta, falta solo color/
     material.
  5. **Warpaint — 3 estilos rotos** (Slash Crimson, Tribal Tide invisible,
     Jagged Crown) esperando rework de `warpaint_atlas.gd _draw_pattern()`
     — no bloqueante, Boris ya tiene 4 opciones viables (3 buenas + None).
  **Nada bloqueado — el punto 1 ya tiene luz verde, arranca directo la
  próxima sesión.** Barba sigue fuera del default (nota abierta desde
  Fase C, sin cambios). UI de creación de personaje (elegir warpaint/
  pelo/etc.) = Fase 4, sin tocar en esta ventana.
- **SESIÓN 2026-07-14 (noche, warpaint personalizable) — bug real
  corregido, 3 estilos reales curados.** Boris aclaró que
  "personalizable" exige estilos REALMENTE distintos con buena pinta, no
  solo exponer el slider. Se encontró la causa: la "V" geométrica se
  dibujaba para cualquier `warpaint_idx>0`, tapando los 5 patrones del
  atlas — corregido (exclusiva de idx==6). `WARPAINTS` ganó su 7ª
  entrada ("Scout Marks"). Evaluación visual de los 6: **3 buenos
  (Hexbrand, Eye of Ash, Scout Marks) + None = 4 opciones** (cumple el
  mínimo pedido); **3 rotos/débiles (Slash Crimson, Tribal Tide
  —invisible, confirmado—, Jagged Crown)** quedan como rework de atlas
  pendiente, fuera de esta sesión. Detalle en
  [[PRD-Warpaint-Personalizable]]. UI de elección = Fase 4 (sin tocar).
- **SESIÓN 2026-07-14 (noche, geometría nueva ejecutada) — 49% → 55%.**
  Los 4 puntos del [[PRD-Geometria-Nueva-Pelo-Torso-Manos-Boca]]
  ejecutados en código: torso sin masa elevada de abdomen (objetivo
  logrado, confirmado por QA), manos con quiebre de ángulo real en el
  nudillo, pelo reconstruido con concha recortada (nuca/orejas expuestas
  — confirmado) pero mechones aún fundidos en lóbulos (no logrado del
  todo), boca fusionada en una sola masa (estructura lograda, color/tono
  pendiente). QA de regresión completo ALL_PASS. **El propio QA de esta
  ronda ubica el mayor punto de apalancamiento para la próxima sesión en
  la SILUETA GENERAL del torso/hombros** ("maniquí de tienda", sin
  cintura ni trapecio real) — más que cualquier detalle de cara/manos, y
  toca `SHOULDER_X`/proporciones, un punto que varios PRDs anteriores
  vienen dejando como decisión explícita de Boris. Detalle completo en
  [[LOG]]. **Progreso total de la ventana: 32%→42%→45%→49%→55%.**
- **SESIÓN 2026-07-14 (noche, ratificación) — Boris aprueba geometría
  nueva de pelo/torso/manos sin cambios; boca = Opción A (fusión en una
  sola masa); warpaint queda como está (bilateral) — "mientras quede
  bien" — y se confirma como REQUISITO NUEVO que debe ser
  personalizable por el jugador en la creación de personaje (dato ya
  soportado, falta la UI de Fase 4).** Arranca ejecución en código.
- **SESIÓN 2026-07-14 (noche, planeación) — propuesta de geometría nueva
  para pelo/torso/manos/boca, esperando ratificación de Boris.** Con el
  techo de ajuste de parámetros confirmado (~50-55%), el orquestador miró
  DIRECTO ambas láminas con zoom (no delegó a un QA intermediario) y
  encontró que la construcción actual de las 4 áreas resuelve el problema
  equivocado: pelo necesita nuca/laterales casi rapados + flequillo de
  pocos mechones GRANDES (no una concha con 31 chicos); torso necesita
  el abdomen CASI PLANO (`abs_plate` como masa elevada sobra — los
  "oblicuos" de la ficha son literalmente 1-2 líneas de trazo); manos
  necesitan dedos CASI JUNTOS con quiebre de ángulo real en el nudillo
  (no más separación ni esferas-bulto); boca queda como decisión de
  Boris entre 2 direcciones (sin referencia directa en pose neutra).
  **Hallazgo colateral:** las dos láminas dibujan el warpaint distinto
  (asimétrico en la de cara vs. bilateral en la de torso, ya
  implementada) — contradicción que solo Boris puede resolver. Propuesta
  completa en [[PRD-Geometria-Nueva-Pelo-Torso-Manos-Boca]]. **Código sin
  tocar — pendiente ratificación antes de ejecutar.**
- **SESIÓN 2026-07-14 (noche, ronda 3) — boca/warpaint/brazalete: 45% →
  49%.** Boca: la línea de comisura (agrandada en rondas viejas para
  competir con la barba, ya fuera del default) se achicó/recedió y los
  labios ganaron masa propia. Warpaint: reconstruido bilateral y diagonal
  tras verificar la lámina DIRECTAMENTE (el orquestador la leyó en
  pantalla) — el patrón real es una "V" simétrica desde ambas sienes al
  puente de la nariz, no 2 trazos de un solo lado como había transcrito
  el QA de la ronda del 32%. Brazalete verde del bíceps retirado (no
  existe en la lámina; ahí hay un brazal de cuero, vestuario aparte).
  **El propio QA de esta ronda ubica el techo de la técnica en ~50-55%**
  mientras 4 bloqueadores sigan sin geometría nueva: torso "plancha" a
  distancia media, pelo-casco (2 intentos de tuning geométrico ya
  fallaron, necesita rediseño), manos "tabla", boca sin volumen real de
  labios. Recordatorio (no nuevo): la barba sigue fuera del default,
  nota abierta desde Fase C. **No tocado a propósito:** los `pec`
  (masas del pecho) que un QA anterior leyó como "ojos" — geometría con
  historial de debate específico orquestador↔QA, no se toca sin más
  contexto de Boris. Detalle completo en [[LOG]].
- **SESIÓN 2026-07-14 (noche, ronda 2) — pauldron fantasma RESUELTO, pelo
  mejora parcial: 42% → 45%.** El pauldron fantasma tenía causa raíz real
  (no solo de banco): las venas de mana se parentean a `arms[1]` DESPUÉS
  del pauldron en `_build()`, rompiendo el hack "último hijo" que también
  usaba `_apply_build()` en producción (escalado Vanguard) — pauldron
  ahora tiene nombre y se busca por `find_child()`. El pelo NO se resolvió
  de raíz: se probaron 3 variantes de geometría (protrusión/sink) que o
  reabrían el defecto histórico de "dientes en la silueta frontal" o no
  cambiaban nada visible; quedó solo un contraste tonal de 3 tonos que el
  propio QA confirma que no alcanza — **el problema es de silueta/
  geometría, no de color; necesita una sesión dedicada, posiblemente con
  propuesta visual antes de codear**. Hallazgos NUEVOS de este corte:
  boca lee como agujero geométrico (antes tapado por la barba), y dos
  masas del pecho (`pec`) leen como "ojos" en el torso — no reportado en
  rondas anteriores. Detalle completo en [[LOG]].
- **SESIÓN 2026-07-14 (noche, cierre) — QA visual imparcial de cierre:
  32% → 42%.** Mismo protocolo que la ronda anterior (subagente sin
  contexto de código, renders frescos post-13-puntos contra ambas
  láminas RAW). Mejora real pero moderada (+10 puntos). **CRITICAL sin
  resolver:** el pelo (punto 2) cambió de estilo en código pero el QA
  sigue leyéndolo como casco/gorro sólido sin textura de mechones — el
  swap de índice NO resolvió el hallazgo #1 de la ronda del 32%.
  **Hallazgo NUEVO (no es parte del PRD, no tocado esta sesión):** un
  pauldron fantasma (rectángulo gris/azul) flota sobre el hombro derecho
  en todos los renders — `tmp_anatomy.gd:75` lo intenta ocultar con un
  hack frágil (buscar el ÚLTIMO hijo de `arm_r`) que dejó de funcionar;
  verificado visualmente por el orquestador. Detalle completo de los 10
  hallazgos (CRITICAL→LOW) en [[LOG]]. **Decisión pendiente de Boris:**
  ¿segunda ronda de fixes (pelo real con mechones + pauldron fantasma
  primero, los más baratos) o aceptar 42% como checkpoint de este PRD y
  pasar a Fase D con las notas abiertas?**
- **SESIÓN 2026-07-14 (noche, continuación) — los 13 puntos del
  [[PRD-Rework-Fenotipo-Humano-Cuerpo-Completo]] EJECUTADOS EN CÓDIGO.**
  Orden por dependencia tal como quedó ratificado: venas cian/arcaneMod →
  pelo (Frontier Crop) → torso/hombros → orejas (pasivo) → manos → warpaint
  → boca → nariz/cejas → piel (investigado) → abdomen → columna (riesgo
  alto). QA completo (`test_core`/`autotest_biomech`/`test_combat`/
  `autotest_slice`/`autotest_ui`) ALL_PASS en cada checkpoint, incluyendo
  ANTES y DESPUÉS del cambio de columna. Detalle punto por punto en
  [[LOG]]. **Dos correcciones sobre el propio PRD, encontradas ejecutando:**
  (a) el "índice inválido" de warpaint (6) en realidad es un patrón vacío
  A PROPÓSITO en el atlas — usar un índice 1-5 pintaba un patrón legacy
  encima de los trazos nuevos; revertido a 6. (b) la asignación estática de
  `upper_spine.rotation.x` que pedía el PRD se hubiera borrado sola en
  <150ms de idle (hay un lerp de "follow del torácico" que corre cada
  frame fuera de strike) — implementada como offset del target del lerp
  en su lugar, para que la curva sobreviva en reposo real. **Nota abierta
  sin resolver: la métrica "cabezas" del banco bajó 7.49→7.13 tras el
  cambio de columna** — sospecha de artefacto de medición AABB sobre
  cráneo inclinado (no confirmado), a verificar antes del VoBo. **Pendiente
  para la próxima sesión: correr un nuevo QA visual imparcial (mismo
  protocolo del ~32%, sin contexto de código) contra ambas láminas para
  medir el % de fidelidad resultante, y VoBo de Boris antes de dar este
  PRD por cerrado y pasar a Fase D (pelo real + barba revisada).**
- **SESIÓN 2026-07-14 (noche) — Boris NO había ratificado el cierre de Fase
  C (75% cara) y pidió, antes de seguir a Fase D, un QA imparcial de CUERPO
  COMPLETO contra las láminas RAW.** Veredicto: **~32% de fidelidad
  global** — el 75% facial no se sostiene con pelo/torso/manos/hombros
  incluidos (pelo con estilo de banco equivocado — "11 Prince Curtain" en
  vez del canon "10 Frontier Crop"; torso con trapecios-caja que dejan
  costura; manos con dedos casi fundidos; bug real de venas cian por orden
  de ejecución de `accent`/`arcaneMod`). **Se ejecutó el proceso que Boris
  pidió para dejar de iterar a ciegas:** QA visual (Fable, sin código) →
  subagente técnico (lee `character_rig.gd`/`hair_library.gd`/
  `palette_data.gd`/`phenotype_data.gd`, traduce cada hallazgo a
  archivo/línea/valor, detecta 2 falsos positivos: el "mentón bloque" era
  boca mal interpretada, el "brazalete gris" era el bug de venas + warpaint
  de brazo ya conocido, no gear fantasma) → Fable ratifica la traducción
  (corrige 2 valores propuestos: columna -0.05→-0.09 rad, cejas necesitan
  arco no solo adelgazar). Plan de 13 puntos con orden por dependencia
  (venas→hombros→pelo→orejas→torso→warpaint→boca→nariz/cejas/manos→
  piel→abdomen→columna, el único de riesgo alto por tocar pivotes de
  combate) asentado en
  [[PRD-Rework-Fenotipo-Humano-Cuerpo-Completo]]. **Código sin tocar
  todavía — próxima sesión: ejecutar el plan en el orden indicado,
  empezando por el bug de venas (punto 1, limpia el ruido visual para
  todo lo demás).**
- **Milestone:** **Fase 1 CERRADA ✅ (2026-07-09)** — combate mínimo + Dagna aliada +
  Seismic Springboard T1 del vertical slice **"Slice of Bond"** (Humano Duelist ×
  Dagna), Gate 1 aprobado por el director. **EN CURSO: ventana C6/C4 (rework
  anatómico + pase de poses, branch `feat/c6-anatomy-rework`)** → luego Fase 2
  del [[Plan-de-Produccion]].
- **SESIÓN 2026-07-13 (tarde) — cintura cerrada + Fase C ABIERTA:**
  **(1) VoBo del director** al outfit frontier (turnarounds r2). **(2) Hueco
  de cintura del cuerpo DESNUDO CERRADO** (`de347d3`, delegado a subagente
  Sonnet, verificado por el orquestador): el auditor tenía razón — había
  **15.2 cm de vacío** entre `abs_plate` (mundo y=1.172) y `pelvis` (y=1.02),
  se veía el fondo a través del torso; se agregó una malla `waist` (cilindro
  de piel hijo de `spine`, top_radius=0.11 = radio base del torso → costura
  cero copiando `torso.scale` x/z, overlap real 5 cm). Banco reusable
  `tmp_waist_check.gd`. QA `test_core`+`autotest_biomech` ALL_PASS.
  **Nota abierta (preexistente, NO tocada): sliver de axila brazo-torso**
  (gap lateral, visible en cuerpo desnudo sin mangas). **(3) Fase C cara
  ABIERTA con LUZ VERDE del director** a la propuesta por masas fundidas
  (esquema anclado a `fenotipo-humano-v1.png`, anti-anime/ligne claire).
  Orden de masas aprobado: (1) cráneo+mandíbula fundida → (2) pómulos altos
  → (3) ojos almendra → (4) nariz cuña integrada → (5) boca por geometría →
  (6) **barba corta** (el rasgo que más falta: el fenotipo humano canónico
  está en `beard=0` lampiño; la lámina pide stubble) → (7) orejas → (8)
  warpaint 1 franja limpia. Hallazgo: existe `HairLibrary.build_beard()`
  (estilos 0-3) pero el stubble usa overlay translúcido (pitfall del toon
  ALPHA) → irá como MASA opaca semi-hundida. Pelo (crop) = Fase D aparte.
- **Fase C p4 ✅ (2026-07-14): nariz cuña integrada.** El prisma de 4 caras
  vivía flotando SOBRE el plano facial (cap plano sin overlap → costura
  visible, "pegada" al cráneo). Mismo truco de fusión que mandíbula/pómulo:
  la raíz (puente, arriba) se encoge casi a un punto (top_radius≈0) y se
  HUNDE ~1.6 cm dentro del cráneo (overlap real, sin cap visible); la punta
  (abajo, bot_radius mayor) sí proyecta ~8-9 mm fuera del cráneo. Se
  agregaron ALAS (dos bultos chicos semi-hundidos a cada lado de la punta)
  que el M9-r3 pedía ("abre a base/alas") y nunca se habían construido —
  funden la base de la cuña con mejilla/mandíbula. `character_rig.gd`.
  QA: `test_core` + `autotest_biomech` ALL_PASS, 7.49 cabezas estable,
  capturas en `godot/test_out/anatomy_face*.png`. **Pendiente inmediato:
  p5 boca por geometría.**
- **Fase C — masas de cara (histórico p1-p3, 2026-07-13):**
  **(p1) Mandíbula fundida** ✅ (`c12da0a`, director: "me convence muchísimo") —
  esfera escalada que penetra el cráneo (overlap real), mata las costuras de
  caja del r5, mentón suave; recalibrado a 7.49 cabezas. **(p2) Pómulos altos**
  ✅ con 1 ronda de fix (`eb1ecab` + `23f03d7`) — plano malar elongado
  semi-hundido; feedback del director ("los pusiste a un lado de los ojos"):
  el pómulo quedaba a la misma altura que el ojo, se bajó (y=-0.012 base,
  rango del slider tope en y=0.0, nunca cruza la altura del ojo 0.022) y
  ahora lee bajo el ángulo externo del ojo. **Nota abierta del director:**
  "no me terminan de convencer" — decisión conjunta de NO seguir iterando a
  ciegas: revisar en un VoBo de CARA COMPLETA tras barba (más contexto para
  juzgar una masa sutil). **(p3) Ojos almendra** ✅ (`ea3f5bb`) — mata el
  ojo-platillo del r5: esclerótica más chica/aplastada, iris+pupila crecen
  para llenar el alto del ojo (poco blanco visible), ceja crece y baja para
  SOLAPAR de verdad el tope del ojo (párpado real, no separado) → lee
  entrecerrado/calmado. Rango de `eyeShape` intacto (personalización de
  jugador, extremo alto = anime a propósito). **(p4) Nariz cuña integrada**
  ✅ (ver bullet arriba) — raíz hundida en el cráneo + alas de conexión.
  **Fase C COMPLETA (8/8, 2026-07-14) — las 8 masas ejecutadas de corrido,
  ajuste fino pendiente con Boris:** (p5) **boca por geometría** — las 3
  cajas planas (pupil_mat negro simulando un trazo) se reemplazan por labio
  superior + inferior (masas cilíndricas en `lip_mat` nuevo, tono rosa
  cálido, el inferior más carnoso) que se hunden en la mandíbula (mismo
  overlap real); la línea oscura queda solo como comisura interior/sombra.
  (p6) **barba corta** — `HairLibrary._beard_stubble()` reescrito: de shell
  translúcido (pitfall ALPHA del toon) a DOS masas opacas semi-hundidas
  (bigote + mentón/mandíbula) con gap real donde vive la boca, color
  oscurecido 35% vs. el pelo; default del slider `beard` sube de 0 (Clean)
  a 1 (Stubble) — el fenotipo humano canónico ya no vive lampiño.
  **Nota para el ajuste fino: en perfil el mentón lee como una bola algo
  marcada, no tan sutil como "sombra de 3 días" — candidato a achicar/
  aplanar más.** (p7) **orejas** — se agregó un lóbulo (bulto chico
  colgando bajo el pabellón existente, mismo truco de fusión) que faltaba
  para el quiebre lóbulo/pabellón del resto de la cara. (p8) **warpaint 1
  franja limpia** — de DOS marcas asimétricas (frente + mejilla, "Scout
  Marks" de M9-r2) a UNA sola franja sobre el pómulo izquierdo, alineada al
  eje diagonal del plano malar de p2. **Bug de regresión encontrado y
  corregido en el mismo paso:** la franja (z=0.106, sin tocar desde M9-r2)
  quedaba enterrada dentro de la masa `cheek` nueva de la Fase C p2 (el
  pómulo semi-hundido la sepultó) — invisible en render; subida a z=0.128
  para que asome sobre el pómulo. QA de los 8 pasos: `test_core` +
  `autotest_biomech` + `test_combat` + `autotest_slice` + `autotest_ui`
  ALL_PASS, 7.49 cabezas estable en todos. **Pendiente: VoBo de cara
  completa con Boris — ajuste fino (nota abierta de pómulos "no me
  terminan de convencer" + nota nueva de barba/mentón) → luego Fase D
  pelo.**
- **Fase C — AJUSTE FINO post-QA ✅ (2026-07-14, mismo día).** Boris pidió
  QA imparcial vs. lámina (`fenotipo-humano-v1.png`, subagente sin contexto
  previo): veredicto **≈30-35% de fidelidad, "totalmente alejada"** —
  Boris ratificó el veredicto del QA por encima de mi objeción inicial
  (yo veía labios/barba en mis capturas; él, mirando la lámina de nuevo,
  confirmó que faltaba barba COMPLETA de mandíbula, no un mentón aislado).
  Se le pidió al QA un plan de acción ejecutable (no solo diagnóstico) y
  se ejecutó en el orden que propuso:
  **(1) Silueta craneal:** `jaw_mesh` era una esfera única de curvatura
  uniforme → sin ningún quiebre óseo detectable por el Sobel. Se agregó
  masa de "ángulo goníaco" (bulto chico hundido por overlap real a cada
  lado, altura de la oreja) para introducir el quiebre vertical→horizontal
  de la mandíbula sin reintroducir costuras.
  **(2) Boca/labios:** labio sup/inf estaban casi tangentes en Y (gap
  0.013) y a la misma Z → sin escalón de profundidad, el Sobel no
  distinguía las dos masas (leía "bloque"). Gap Y casi al doble
  (-0.066/-0.090) + escalón Z real (superior protruye más, inferior se
  hunde) → línea de comisura detectable.
  **(3) Pómulos:** el eje Z de escala (0.46) los aplastaba tanto que "no
  leían desde ningún ángulo" (QA). Subido a 0.64 + menos hundimiento en el
  plano facial (z base 0.110→0.114).
  **(4) Ojos/arrugas:** las "arrugas" que el QA detectó NO eran piel — era
  el Sobel apilando el borde del pómulo + el de la ceja a solo ~3.4cm del
  ojo. Rango Y del pómulo bajado otros 0.008 (más lejos del ojo) + brow
  con menos invasión/alto (0.041→0.038, 0.013→0.011).
  **(5) Barba (prioridad de Boris):** de 2 esferas aisladas (bigote +
  mentón, leía "perilla") a una CADENA de 11 masas con overlap real ~2x
  entre centros (mismo truco que jaw/cheek — el Sobel entinta solo el
  contorno exterior de la cadena completa, no cada bulto), recorriendo
  TODA la mandíbula de patilla a patilla. 2 iteraciones de posición: r6d
  (subida, corrigió que colgaba visualmente sobre el cuello — el jaw se
  funde muy suave con el cuello, sin quiebre que ancle la barba más abajo)
  y r6e (overlap ~2x, corrigió que leía "collar de cuentas" en vez de
  sombra continua). Oscurecido bajado 35%→20% (sombreado tenue, no barba
  sólida).
  **(6) Warpaint:** proporción 4:1→10:1 (ancho 0.075, alto 0.007 — ya no
  "curita"); color `PAINT_COLORS[4]` ("wyld green") desaturado de
  `#4dff9d` (mint saturado, leía "curita fosforescente") a `#6b7f4a`
  (verde apagado/terroso) — cambio en `palette_data.gd`, array separado de
  `HAIR_COLORS` (no afecta pelo/otros usos de "wyld green"). z de la
  franja subido otra vez (0.128→0.140): el pómulo agrandado en el paso 3
  volvió a enterrarla.
  Archivos: `character_rig.gd`, `hair_library.gd`, `palette_data.gd`. QA:
  `test_core` + `autotest_biomech` + `test_combat` + `autotest_slice` +
  `autotest_ui` ALL_PASS, 7.49 cabezas estable. **Pendiente: VoBo de Boris
  de esta ronda de ajuste fino (¿re-correr QA vs. lámina, o suficiente
  para cerrar Fase C y pasar a Fase D pelo?).**
- **Fase C — [[QA Loop]] hasta 75% de fidelidad ✅ (2026-07-14, mismo día,
  cierra el PRD [[PRD-Fase-C-Ajuste-Facial]]).** Boris pidió correr el loop
  QA↔PRD hasta ~80% o el techo real de la técnica. Progreso medido:
  30-35% → 40-45% → 50-55%(...) → 62-65% (el agente QA perdió su hilo,
  reemplazado por uno nuevo sin contexto que discrepó fuerte con lo que el
  orquestador y Boris veían a simple vista — arrancó un desempate) → 55%
  (recalibrado a la baja con evidencia real leyendo el código) → 58% → 61%
  → 69% → **75% final**, confirmado por el mismo agente de desempate.
  Se resolvieron con múltiples iteraciones en vivo: **boca** (6 rondas —
  bloque→agujero por sobre-corrección→escalón real con caras frontales
  distintas + tono diferenciado por labio, `lip_mat`/`lip_mat_lower`);
  **barba** (reemplazo completo: de esferas dispersas a bloque sólido
  configurable por `density`, 5 iteraciones de forma hasta 3 cajas
  escalonadas + remate redondeado, siguiendo la conicidad real del jaw);
  **ojos** (el iris desbordaba la esclerótica entera —margen NEGATIVO,
  confirmado contra refs. de Link/Zelda BotW/TotK que Boris aportó— +
  luego los ojos estaban muy separados, hueco ~2.4x el ancho de un ojo,
  corregido a ~1x); **pómulos/mentón** (esfera→caja, mismo principio en
  ambos); **nariz** (arista al frente → cara plana al frente, mismo
  principio que resolvió la boca); **warpaint** (color bajado 3 veces).
  **Lección nueva para [[Lecciones]]:** una esfera NUNCA da un plano/borde
  anguloso en este vocabulario — usar cajas para cualquier rasgo que la
  lámina muestre como plano definido. QA de regresión completo ALL_PASS en
  cada ronda, 7.49 cabezas estable. **Techo real del 75%: pelo/orejas
  placeholder de Fase D** — subir más requiere completar esa fase primero.
  **Referencias nuevas en el Vault:** `research/quality-benchmarks/`
  ampliada con Link/Zelda (BotW/TotK, fenotipo base para el elfo de
  C6b/C6c) y capturas de Sable/Hinterberg. **Pendiente: VoBo final de
  Boris sobre el 75% antes de dar Fase C por definitivamente cerrada y
  pasar a Fase D pelo.**
- **Barba QUITADA del default (2026-07-14, veredicto directo de Boris:
  "no me gusta nada").** Pese al 75% técnico y la confirmación del
  desempate ("coherente con el lenguaje del resto de la cara"), el
  director la rechazó al ver el resultado final — se prioriza su criterio
  visual directo por sobre el % de QA. `phenotype_data.gd`: default de
  `beard` vuelve de 1 (Stubble) a 0 (Clean). El sistema de barba
  (`_beard_stubble`, `beardDensity`) NO se borra, queda disponible para
  personalización del jugador. QA de regresión ALL_PASS. Fenotipo humano
  canónico vuelve a lampiño.
- **Mentón corregido + Fase C cara CERRADA (2026-07-14).** Con la barba
  fuera, un QA final enfocado solo en labios+mentón detectó lo que la
  barba había estado tapando: `chin_boss` proyectaba ~4.7cm MENOS que
  `lip_lower` (la boca quedaba como el punto más adelantado de esa zona,
  al revés de la lámina). Fix en 2 pasadas: la primera se pasó (mandíbula
  protuberante/bulldog, detectado en captura), la segunda calibró un punto
  intermedio — confirmado: mentón como masa definida y separada, sin
  sobremordida, con pliegue mentolabial natural. Labios sin cambios (ya
  resueltos). QA de regresión ALL_PASS. **Con esto, la ventana de ajuste
  facial de la Fase C queda CERRADA — arranca Fase D (orejas + pelo por
  masas, propuestas antes de codear).** **Mapeado para Fase D: REVISAR LA
  BARBA de nuevo** — Boris la rechazó ("no me gusta nada") pese a estar
  técnicamente resuelta (75% de fidelidad, confirmada por el QA Loop); el
  sistema (`_beard_stubble`, `beardDensity` en `hair_library.gd`/
  `phenotype_data.gd`) sigue en el código pero fuera del default. Cuando
  se aborde el pelo real en Fase D, retomar la barba como parte del mismo
  frente visual (probablemente comparta decisiones de estilo/silueta con
  el pelo) en vez de dejarla huérfana — no asumir que "no me gusta" cierra
  el tema para siempre, es una nota abierta a re-visitar con más contexto.
- **🔨 REWORK GRÁFICO INTEGRAL 2026-07-12/13 (Fases A→B→anatomía→outfit, 8
  commits pusheados 42d169e→1794b1a, dirigido en vivo por Boris con QA
  imparcial Fable):** el día empezó con dos auditorías imparciales (código:
  base sólida cero critical; arte: ~55% fidelidad global — ambas archivadas
  verbatim en `90-Raw/reviews/QA-Auditoria-*-2026-07-12.md`) y cerró con:
  **(A) Shaders** ✅ VoBo colores del director: sombra acuarela (shadow_floor
  por preset en `melancolia_post` — muere la banda negra que se comía el
  dawn) + cristal de peligro ROJO unshaded (constante del Art Bible; el
  unshaded además reveló las facetas del clúster). **(B) Cuerpo** ✅ "mucho
  mejor" del director tras 3+2 rondas: uniones FUNDIDAS (muere el maniquí
  con costuras), musculatura de brazos (bíceps/tríceps/brachioradialis
  patrón gemelo, aplastados a pedido), y el fix RAÍZ del QA dirigido: el
  esqueleto del hombro estaba 30% más ancho y 13 cm más alto que la lámina
  (fósil del "+12%" de la review v0.1 que CONTRADECÍA el "narrow sloped
  shoulders" del concept) — SHOULDER_X 0.262→0.21, SHOULDER_Y 0.29→0.26,
  regla de oro: la silueta cuello→muñeca solo DESCIENDE
  (`90-Raw/reviews/QA-Auditoria-Tronco-Superior-2026-07-13.md`).
  **(C) Anatomía de torso** ✅ (debate formal orquestador↔QA, 3 veredictos
  ratificados por Boris): pecs elipsoides (mueren las cajas-peto), placa
  abdominal única sin six-pack, clavícula-cápsula, cuello +15% (~0.55
  cabezas; el 0.8 de la lámina es parte ilusión del cowl), piernas ya
  cumplían. Rúbrica nueva: [[Benchmark-Musculatura-Torso]] (borrador) con
  la lámina **`fenotipo-humano-torso-v1.png`** (Nano Banana, depositada por
  Boris) como autoridad #1 SOLO de superficie del torso (alcance acotado —
  NO identidad). **(D) Outfit "frontier"** ✅: jerkin panza-de-olla + strap +
  belt salen del cuerpo base a `character/character_outfit.gd` (faja
  envuelta fiel a la lámina + pouches); jugador/enemigos/guardias/reclutador
  vestidos in-game, banco de anatomía desnudo (constraint de Boris: outfits
  sin playera con músculos definidos). **(D2) Outfit CONFIGURABLE POR PIEZAS**
  ✅ (`305eac1`, feedback de Boris: "nada hardcodeado — faja y bandolera
  deben ser personalizables"): catálogo `_PIECES` (waist_wrap/diagonal_belt/
  hip_belt), `build(rig, [ids])` monta una lista arbitraria, `remove_piece`/
  `remove_all` para toggle en caliente, `PRESETS.frontier` = solo una lista
  predefinida; los call sites usan `build_frontier` (alias del preset). La
  UI de personalización (pestaña OUTFIT en creación) llega en Fase 4 — la
  API ya la soporta. **(D3) Faja: hueco ombligo-a-cadera CERRADO** ✅
  (`ea985f1`, feedback de Boris): la faja de 3 bandas dejaba ~4.5 cm de piel
  sobre el pantalón → 5 bandas solapadas bajando hasta el belt con radio
  creciente (sigue la cadera; se acerca al faldón de la lámina). Gates
  completos ALL_PASS (core/biomech/combat/slice/springboard). **Pendientes
  de VoBo: turnaround del torso desnudo + outfit frontier**
  (`test_out/rounds/anatomia-torso/` y `outfit-frontier/`). **⚠️ PENDIENTE
  dejado a propósito (retomar): verificar la CONTINUIDAD DE CINTURA DEL
  CUERPO DESNUDO** (torso→pelvis; el auditor advirtió que el jerkin tapaba
  un posible hueco de anatomía — para outfits sin playera debe estar
  cerrado en el cuerpo base, no solo bajo la faja). Nota menor: el belt
  quedó parcial bajo la faja (subirlo si Boris quiere el cinturón sobre el
  fajín). **DECISIÓN GRANDE de Boris (2026-07-13): VoBos viejos
  RECHAZADOS (r5 cabeza, cowl) — rework integral en curso; el peinado
  príncipe de hebras/cintas se DESECHÓ por completo** (~8 rondas fallidas;
  causa raíz: cuerdas rectas sobre domo convexo) — **Fase D pelo: masas de
  silueta "tipo animé aunque la cara sea anti-Genshin" (sus palabras),
  propuestas ANTES de codear.** Cola: Fase C cara → Fase D pelo →
  movimientos (crouch/walk/sprint/sprint-jump/jump, minar orientation
  warping de AMSG — solo tercera persona).
- **M10-r5/r6 ✅ CÓDIGO + QA (2026-07-12) [SUPERSEDED — el estilo 11 se
  desecha, ver bullet de arriba]: peinado "príncipe" DESBLOQUEADO,
  reconstruido y en punto de review.** Secuencia de la sesión:
  (a) **Cuelgue del banco RESUELTO — era contención, no código** (lección
  confirmada en [[Lecciones]]): matando Epic/EA/Steam, `tmp_anatomy` corre en
  7 s y `test_core` en 0.4 s ALL_PASS. (b) **El banco desbloqueado reveló el
  bug real del r4:** `_s_spine` generaba la espina con Y NEGATIVA mientras
  `_ribbon` mapea la espina sobre `mbasis.y` = flow root→tip → los 21
  mechones crecían OPUESTOS a su flow (las capas de caída apuntaban al cielo
  como astas). Fix de una línea + lección nueva del contrato de ejes entre
  helpers. (c) **r5 (ejecutor Sonnet, 4 rondas):** capa 1 barre atrás
  abrazando la concha (flow (0,0.24,-0.85)), enmarque a ±0.85 (cara
  despejada), +3 mechones de nuca (24 total). (d) **r6 (orquestador, fix
  estructural):** la concha sola era un crop — dos lóbulos nuevos de la misma
  técnica: masa OCCIPITAL (nuca llena, sin parches de piel, orejas
  flanqueando) + banda de FLEQUILLO frontal (hairline visible de frente; la
  v1 quedó enterrada a z=0.82R con el frontal del cráneo en 0.97R — margen
  real aplicado, emerge ~10 mm). Capturas por ronda:
  `godot/test_out/rounds/m10-r5/` (estado del ejecutor) y `m10-r6/` (final).
  QA: test_core + autotest_slice ALL_PASS. **Pendiente: VoBo del director del
  turnaround r6.** Observaciones honestas para su ojo: (i) la cúpula lee algo
  "piel" bajo luz dawn — cercanía tonal castaño-claro↔piel en la banda de luz
  del cel; lo ataca el gradiente raíz→punta de C8 (Sesión 4 del plan), no la
  geometría; (ii) los planos de sombra de algunos mechones leen gris-frío
  (sombras del post) — misma vía C8.
- **📦 Evaluación de plugins ✅ COMPLETA (2026-07-11, 13 zips + Chickensoft +
  Beckett MCP — sesión de research, sin tocar código):** veredicto completo en
  `90-Raw/research/Plugin-Evaluation-2026-07-11.md`. Lo accionable:
  (1) **Dialogue Manager 3.10.1 se ADOPTA cuando abra la Fase 2** (PRD-009 —
  único hueco real; NO instalarlo durante la ventana C6/C4). (2) **AMSG =
  referencia de lógica para C2 y C4**: detección de mantle (3 raycasts +
  shapecast, portable a nuestra física analítica) y PoseWarping
  (orientation/stride/slope, taxonomía de estados) — rutas exactas en el doc.
  (3) Shaders minables de HTerrain/ProtonScatter para montaña/foliage/agua de
  Fase 2/4. (4) Cross-check articular para C6b: tabla ROM de Humanizer +
  skeleton_config.json (53 huesos) + lista humanoide VRM; **semilla nueva:
  vista-esqueleto de debug en `tmp_anatomy.gd`** (dibujar articulaciones+ROM
  de `rig_biomech.gd`). (5) FancyControls = juice de HUD Fase 4 (UI, NO
  facial). (6) **Beckett MCP (tooling): spike de 1 sesión propuesto** cuando
  el banco corra limpio — MCP embebido en el editor que deja al agente VER el
  juego corriendo; decisión del director. (7) **godot-vrm CORREGIDO
  (re-bajado v2.5.7, fork AzPepoze/V-Sekai, Godot 4.3+ nativo con binarios
  incluidos Win/Linux/macOS)** — el zip viejo era rama Godot 3 obsoleta;
  MToon (12 `.gdshader`, shading en `mtoon_common.gdshaderinc`) queda
  minable como referencia de toon shading vs. `toon_opaque` (su outline por
  casco invertido se ignora — ya lo resolvimos con Sobel). Descartados:
  LimboAI (compilar), GodotSteam (zip vacío), Chickensoft (C#), skeleleton-2d
  GPLv3 (solo mirar). Semillas de modelado: expresiones faciales por estado
  (Fase 3–4) + spike nodo `Decal`. El cabello NO cambia de técnica: el ribbon
  del M10-r4 es el método canónico. **Benchmark de calidad (mismo día):** 3
  capturas del avatar VRM "AliciaSolid" reubicadas a
  `90-Raw/research/quality-benchmarks/` (NO en `concept/` canon — estilo
  anime, anti-referencia explícita del Art Bible). 3 lecciones transferibles
  extraídas: textura pintada/degradada > color plano, banding cel más suave
  (comparar vs MToon), degradado raíz→punta en pelo.
- **Ventana C6/C4 ABIERTA (2026-07-10).** Decisiones del director: pies IK
  DIFERIDOS (el greybox es plano; pagan en terreno, Fase 2+); **el rework se
  maneja ÚNICAMENTE en estilo Sobel** — "línea de tinta nítida de cerca;
  grisácea a media distancia; ausente en el horizonte" (la regla de Línea del
  [[Art Bible]] hecha canon del rig). Plan: C6a humano 7.5 cabezas → C6b
  enano/elfo + ROM → C6c cabeza/cara → C4a poses por gait → C4b canal airborne
  → playtest del director.
- **C6a ✅ CÓDIGO (2026-07-10): cuerpo humano canónico bajo línea Sobel.**
  (a) **Sin outline propio:** el rig ya no fabrica casco invertido (helpers
  no-op); materiales del rig/pelo/signature → `toon_opaque.gdshader` nuevo
  (toon.gdshader menos la escritura de ALPHA — pase opaco, visible al
  depth/screen del post; con textura y emission, así el warpaint y el metal
  caliente sobreviven). Factories `ToonMaterials.toon_mat_opaque[_textured]`.
  (b) **Proporciones canónicas** (lámina fenotipo-humano-v1): tabla
  PROPORTIONS en `character_rig.gd` — **7.57 cabezas medidas** (antes 6.38
  anime), hombros 2.39 cabezas, pierna 47.9%, estatura 1.93 m. Cabeza = pivote
  escalado ×0.84 (cara/pelo/goggles bajan JUNTOS — hair_library y warpaint
  intactos); pecho ancho/plano + cintura recogida (V-taper en _apply_build);
  hombros a la línea 1.55 y ±0.245 (el deltoide NACE del pecho — fuera el
  hueco lego); cuello real; manos +12%; pies con proyección. Jerarquía de
  nodos y biomecánica INTACTAS (hip-first, columna 2 seg, ROM: autotest_biomech
  0 violaciones). (c) **Fix de bug pre-existente:** `_build_origin_features`
  caía a ironblooded como ELSE con cualquier origin desconocido (armadura de
  forja fantasma en el banco); rama explícita ahora. (d) **Banco
  `tests/tmp_anatomy.gd`:** golden scene + post 4 capas, medidas numéricas
  (cabezas/hombros/pierna) + regla de cabezas en escena + capturas cerca/media/
  lejos y frente/perfil — la regla Sobel verificada (tinta fina en close-up,
  figura sin línea en el horizonte). QA completo: test_core/combat/locomotion/
  ads + autotest_biomech/combat/slice/ui/springboard ALL_PASS. **Pendiente:
  VoBo del director de las capturas. Dagna queda visualmente desfasada hasta
  C6b (sus piezas firma se posicionan para el cuerpo viejo — se re-monta sobre
  el cuerpo enano real).**
- **C6a-r2 ✅ CÓDIGO (2026-07-10, feedback del director: "que los cuerpos dejen
  de componerse de puros círculos").** Los volúmenes pasan de cápsulas/esferas-
  globo a masas que ESTRECHAN como la lámina (`CylinderMesh` cónico): tronco =
  taper continuo pecho ancho→cintura (hombros cuadrados, el jerkin retoma el
  mismo radio); brazo = deltoide→codo→muñeca fina + **mano de MITÓN** (caja con
  curl, no esfera); pierna = muslo masivo→rodilla, pantorrilla→tobillo; bota
  con puntera (el pie tiene dirección); cuello con taper desde el trapecio.
  Las únicas esferas que quedan son articulaciones (deltoide/codo/rodilla) y
  el cráneo (C6c). Pauldron re-asentado al deltoide nuevo. Medidas estables
  (7.58 cabezas) y QA visual completo ALL_PASS de nuevo. Capturas en
  `godot/test_out/anatomy_*.png`.
- **📋 Character Blockout Review v0.1 del director (2026-07-10) — ARCHIVADA
  en `90-Raw/reviews/Character-Blockout-Review-v0.1.md` (fuente raw,
  verbatim).** Veredicto: Needs Revision, ~60–65% de fidelidad al concept;
  los problemas son de proporciones/silueta/lenguaje visual, no técnicos.
  Norte artístico EXPLÍCITO: BotW / Hinterberg / Palia / Torchlight III —
  anatomía estilizada, NO anime, NO low-poly crudo; formas grandes y siluetas
  limpias. Es el checklist de aceptación de C6.
- **C6a-r4 ✅ CÓDIGO (2026-07-10): respuesta a la review v0.1.** Implementado:
  **CRITICAL 1** silueta atlética (hombros +12% → 0.66 m, pecho con volumen
  CHEST_X 1.16, cintura 0.90, pelvis más ancha que cintura = cambio
  tórax→pelvis legible) · **CRITICAL 2** cabeza menor (HEAD_SCALE 0.84; el
  culpable del read 6.5–7 era el PELO-bloque: +7 cm de AABB → aplastado hacia
  atrás suma solo +2 cm; lectura visual ahora ~7.4) · **CRITICAL 3** cuello
  largo (0.17) + línea de hombros más baja (SHOULDER_Y 0.29) · **CRITICAL 4**
  brazos con masa de atleta (deltoide 0.068, bíceps 0.062, antebrazo 0.054) ·
  **HIGH 5** pierna con cuádriceps/rodilla/GEMELO diferenciados (masa trasera
  nueva) · **HIGH 6** manos +18% (llegan a media pierna) · **HIGH 7** pies
  mayores (bota 0.11×0.09×0.21 + puntera) · **HIGH 8** planos anatómicos del
  torso (placa pectoral al ras — el plano lo lee el escalón cel, no la tinta
  Sobel — + clavículas) · **LOW 13** A-pose suave (splay 0.15) · **LOW 14**
  codo en reposo relajado (0.34) · **LOW 15** transición hombro-brazo fundida
  (deltoide mayor) · **MEDIUM 10 parcial** pelo aplastado/hacia atrás vía
  transform del hair_slot. Medidas: estatura 1.943, hombros 2.65 cabezas,
  pierna 48.9%. QA completo ALL_PASS. **Pendientes de la review:** MEDIUM 9
  (cara con personalidad — con el ojo del director), MEDIUM 10 completo
  (rediseño de peinados), MEDIUM 11–12 (capas de ropa + peso de accesorios —
  el director los difirió explícitamente junto con el detalle de pies),
  LOW 14 fino (postura relajada global). **VoBo pendiente de las capturas r4.**
- **C6a-r5 ✅ CÓDIGO (2026-07-10, feedback del director en dos rondas:
  "las manos no tienen dedos" → "hay tres masas, pulgar más dos").** Mano
  final: palma + **CUATRO dedos individuales delgados** (ranura ~3 mm entre
  cada uno — discontinuidad real de profundidad → **el Sobel entinta las
  separaciones** en close-up y a distancia se funden en una masa; la línea
  hace el trabajo, no la geometría) con **largos naturales** (medio > índice
  ≈ anular > meñique) + PULGAR hacia el cuerpo + curl progresivo palma→dedos.
  (La v1 con dos masas de dedos leía como garra — el director la tumbó.)
  **r5c (tuning en vivo, "funciona mejor"): dedos +20% de largo y pulgar
  ALINEADO a la dirección de los dedos (cuelga) con 30° de apertura. r5d
  (ref. anatómica del director — Cleveland Clinic, vista palmar): el pulgar
  nace de la eminencia TENAR, a media palma (nacimiento 50% más adentro).
  r5e: dedos 10% más delgados (sección 0.0108×0.038; el pulgar no).**
- **📋 Character Head/Bust Review v0.2 del director (2026-07-10) — ARCHIVADA
  en `90-Raw/reviews/Character-Head-Review-v0.2.md`.** Sobre las capturas de
  M9-r1. Veredicto: Needs Revision, fidelidad 4/10 / overall 5/10. Críticos:
  pelo (color/forma), pintura facial verde ausente. Altos: capas de vestuario
  (o documentar base modular), estructura facial (mandíbula ancha/amable),
  ojos-platillo. Medios: cuello overlong, orejas. **Checklist de M9/M10.**
- **M9-r2 + M10 ✅ CÓDIGO (2026-07-10): respuesta a la review v0.2.**
  (a) **CRITICAL 1 — pelo:** estilo NUEVO `frontier_crop` (índice 10 del
  hair_library: corto, lados recortados, volumen barrido arriba-atrás,
  hairline baja) en castaño claro (#8a6b48, patrón de tinte de Dagna); fuera
  la cuña y el rizo suelto; el hack de aplastar hair_slot REVERTIDO (cada
  estilo se autora a su cráneo — las trenzas de Dagna vuelven a su forma
  aprobada). (b) **CRITICAL 2 — pintura:** patrón warpaint 6 "Scout Marks"
  (asimétrico) + **banda de pintura en el bíceps izquierdo** (acompaña al
  warpaint, color de paleta); verde wyld + piel porcelana en el banco.
  **Hallazgo de pipeline:** la cara del cráneo vive en la COSTURA u=0 del
  atlas; los jaw-box/cheeks con material de atlas EMBARRABAN la pintura (UVs
  de primitiva sin control) → el atlas ahora vive SOLO en el cráneo (jaw/
  cheeks = skin plano); el banco vuelca `warpaint_atlas.png` para calibrar
  viendo. La diagonal de mejilla marca ✓; **la de FRENTE sigue oculta bajo
  el hairline — TODO puntual: debug de UV con retícula.** (c) **HIGH 4–5 —
  cara:** mandíbula +12% más ancha (registro amable, no joven), cara media
  más corta (skull y 1.03), boca ancha con sonrisa franca, mentón fundido,
  ojos −15% con apertura entrecerrada y menos esclerótica (fuera el
  ojo-platillo caricatura), cejas más bajas/RECTAS (rango de tilt acotado
  en apply_phenotype). (d) **M6–M7:** cuello 0.15 y más grueso (convergencia
  v0.1 "no existe" / v0.2 "overlong"), trapecio más fundido, orejas a la
  banda ceja-nariz y +15%. (e) **HIGH 3 — vestuario: DOCUMENTADO como
  base-body modular intencional** (el sistema signature de Dagna ES el
  sistema de equipamiento por capas; el director difirió la ropa a Fase 4 en
  la review v0.1 — la v0.2 acepta esta vía si se documenta). (f) **LOW 8:**
  el "prop" era el pauldron — oculto en el banco de anatomía. LOW 9 (piel
  cálida): parcialmente iluminación dawn del banco; A/B en luz neutra
  pendiente para el lock de textura (Fase 4). QA completo ALL_PASS.
- **📋 Review v0.5 del director (2026-07-10) → M9-r5 ✅ CÓDIGO + QA VERDE.**
  Archivada (`90-Raw/reviews/Character-Head-Review-v0.5.md`). Los 4
  bloqueantes: **(1)** quiff REDONDEADO-angular de esferas escaladas (curva
  superior asimétrica más alta al frente; fuera el birrete de cajas — y con
  él la cuña M6 y el hairline alto M7); **(2)** marcas restauradas a tamaño
  r3 como franjas rectas (frente ≈ ceja; mejilla cruzando el pómulo);
  **(3)** limpieza de rasgos atravesados — ojos conformados (−4 mm, esclerótica
  plana) y cejas pegadas al cráneo (flotaban 10 mm: eso era lo visible desde
  atrás, no normales invertidas); **(4)** orejas a la vertical media del
  cráneo, asoman flanqueando en la trasera. **PROCESO: capturas por ronda en
  `godot/test_out/rounds/rN/`** (diff visual anti-regresiones, exigencia del
  reviewer). QA biomech/combat/slice ALL_PASS. **Pendientes: VoBo del
  turnaround r5; ratificación EXPLÍCITA del cowl/base-body modular por el
  director (documentada 3× en PR; el reviewer la exige para cerrar).**
- **📋 Review v0.4 del director (2026-07-10) → M9-r4 ✅ CÓDIGO + QA VERDE.**
  Review archivada (`90-Raw/reviews/Character-Head-Review-v0.4.md`; overall
  6/10; 5 bloqueantes para aspirar a Approved). Respuesta: **(1) pelo
  reconstruido** — lección técnica: las cajas no abrazan esferas; la solución
  es la CONCHA elipsoide ajustada que se auto-recorta contra el cráneo
  (emerge ~7 mm arriba/atrás, se hunde en orejas/nuca baja → fade natural sin
  borde-repisa) + quiff/cresta de cajas hundidas como acentos; **la nuca del
  jugador ya lee corte corto, no casco**. **(2) orejas** visibles en perfil/
  espalda. **(3) cuello −30%** (0.10, base 0.075) — bloqueante promovido
  CERRADO. **(4) cowl** documentado 3ª vez (base-body modular; pendiente
  ratificación EXPLÍCITA del director). **(5) plano flotante** eliminado (era
  la cresta de la construcción vieja; quedan 2 esquinitas del quiff arriba,
  anotadas). **(M6)** ambas marcas como geometría recta (patrón 6 del atlas
  intencionalmente vacío — el _slash escalonaba). QA biomech/combat/slice
  ALL_PASS. **Pendiente: VoBo del turnaround r4; ratificación del cowl.**
- **📋 Review v0.3 del director (2026-07-10) → M9-r3 ✅ CÓDIGO + QA VERDE.**
  Review archivada (`90-Raw/reviews/Character-Head-Review-v0.3.md`; overall
  5.5/10, cierres verificados de ronda 1: pelo castaño, ojos on-model "no
  tocar más", piel, prop). r3 responde: **C1** quiff ANGULAR de cajas
  contenido (fuera el top knot; la visera frontal se levantó — ocultaba la
  marca) sobre el casquete probado del library (la coronilla quedaba calva en
  perfil). **C2** marcas BILATERALES en lados opuestos (concept): mejilla
  izquierda por atlas + frente derecha por GEOMETRÍA — el v del atlas se
  comprime no-linealmente hacia la ceja (debug de retícula) y la franja de
  frente por textura no es posicionable; dos bugs de entierro cazados y a
  Lecciones (anillo del bíceps < radio efectivo escalado; placa al ras =
  astilla que la tinta se come). **H3** cráneo compacto 0.82x + mandíbula
  0.138 dominante (trapecio invertido) + pómulos como quiebre. **H4**
  vestuario: base-body modular DOCUMENTADO (2ª vez; la review lo cierra si
  está en el PR — está en commit + Vault). **M5** nariz-prisma de 4 lados
  con arista al frente. **M6** orejas semi-elípticas verticales inclinadas.
  **M7** cuello 0.13 con base 0.068 al trapecio. **L8** boca +15%. **Gate
  biomech flaky ARREGLADO de raíz** (assert adversarial re-fuerza 6 frames;
  hitch de boot saturaba el settle → 4/4 verde). Banco con TURNAROUND de
  cabeza (frente/¾/perfil/espalda — exigencia de la review para aprobar).
  QA: biomech ×4 + combat/slice/ui + core ALL_PASS. **Pendiente: VoBo del
  director del turnaround r3.**
- **M9-r1 ✅ CÓDIGO (2026-07-10): la cara gana personalidad (review M9).**
  Mandíbula marcada + mentón, nariz fina, MEJILLAS ALTAS (pómulos bajo el
  ojo; rango del slider `cheek` subido en apply_phenotype), SONRISA ligera
  (3 segmentos de tinta, comisuras arriba), cejas finas café cálido, iris
  café en el banco (en juego = accent del origen), y **orejas por defecto
  en origin neutro** (los origins las reemplazan). Capturas:
  `anatomy_face.png` / `anatomy_face_34.png`. QA biomech/combat/slice
  ALL_PASS. **Ronda 2 con el ojo del director pendiente; M10 (peinado real)
  es la mitad faltante de la cabeza.** La
  palma sigue siendo el nodo `hand` (meta de montaje de arma y toggle del
  prótesis intactos). Captura del banco: `anatomy_hands.png`. QA:
  biomech/combat/slice ALL_PASS.
- **C6a-r3 + C6c ✅ CÓDIGO (2026-07-10, la comparación lado a lado del
  director contra fenotipo-humano-v1).** (a) **Hombros CAÍDOS** (lámina:
  narrow sloped shoulders): trapecios con masa del cuello al deltoide matan
  la repisa cuadrada; hombros −1 cm (SHOULDER_X 0.235) y pecho más fibroso
  (CHEST_X 1.07 / CHEST_Z 0.84) — el atleta de frontera es ENJUTO. (b)
  **C6c — la cabeza deja el chibi:** cráneo con forma (0.90/1.06/0.97, nuca),
  mandíbula estrecha + mentón, **nariz** (el perfil de la lámina por fin
  existe), ojos a escala humana (r 0.021 vs 0.034 del ojazo anime), ceja baja
  pegada al ojo; chin/nose en skin_mat (el warpaint atlas mapea raro en cajas
  chicas). HEAD_SCALE 0.84→0.87 → **7.49 cabezas medidas** (canon 7.5 exacto).
  (c) **Fix de gate flaky:** elbow release del strike −0.085→−0.082 — el pico
  del follow-through rozaba el ROM con margen 0.0003 rad y fallaba
  autotest_biomech según el alineado de frames (lección ampliada). QA: biomech
  ×5 + combat/slice/ui/springboard + test_core ALL_PASS. **Pendiente: VoBo del
  director. El vestuario de la lámina (capucha/vendas/faldón) = Fase 4.**
- **B15 ✅ (2026-07-06): benchmark observacional medido** — los 3 clips
  del director analizados frame a frame → [[Benchmark Biomecánico]] §v3.
  Números clave para el alcance 2: hit-stop 2f normal / 3f pesado
  (congelado global), reacción del golpeado al frame siguiente, combo
  sincopado (no uniforme), frontera de release 0.58 VALIDADA (contacto
  ≈60% del ciclo), estados de movilidad no bloqueantes (~0.1 s), y
  **Sable confirma nuestro canon 1:1: raíz continua + stepping solo en
  extremidades**. **B15b (misma tarde): el director grabó el tutorial
  COMPLETO de Sifu (28 clips) — los 3 faltantes quedaron medidos:**
  parry (hit-stop 3 f > 2 f del golpe normal, riposte ~0.3 s, stun
  ≥0.85 s), guard break (~1.0 s de stagger sin control), y el bloqueo
  cede terreno bajo golpes pesados (→ PushPullComponent). Ver
  [[Benchmark Biomecánico]] §B15b (consecuencias 6–8 para el alcance 2).
  Único faltante: mantle de Fortnite (irrelevante hasta C2).
  **B15d (misma tarde): el director grabó NUESTRA build y se midió con
  el mismo pipeline → [[Benchmark Biomecánico]] §B15d (AS IS vs TO BE).**
  Confirmado: 0 hit-stops en combate (esperado, alcance 4) y locomoción
  ya alineada con Sable (raíz continua + holds ~4–5 f). Hallazgos
  nuevos: la bestia reacciona solo con flash blanco (pose idéntica — sin
  reacción corporal) y el daño al jugador es un tinte de pantalla >1 s
  que tapa la lectura. Salvedad (cerrada a medias por B15e: kit activo
  confirmado; síncopa aún sin medir). Ampliado
  con el running jump: aire 42 f = analítica del código exacta (0.70 s,
  ~8 f más flotante que Fortnite), landing no bloqueante ✅, pero el
  rig NO tiene canal airborne — el salto no tiene pose (gait sin
  silueta, extiende B15c).
- **PRD-006 alcance 2 ✅ CÓDIGO (2026-07-06): kit Humano Duelist
  jugable.** Combo ×4 con buffer generoso y durs sincopadas (B15), RMB
  contextual = guardia/parry Roba (ventana estricta), momentum→daño
  capturado al arrancar el swing, ley sprint↔arma, lunge enemigo vía
  HitPayload+guardia (parry → bestia stunned ~2 s). La decisión de
  diseño quedó resuelta por ENRUTAMIENTO DE INPUT: `try_attack()` viejo
  intacto y solo llamado por autotests históricos (`autotest_slice`
  ALL_PASS). Decisiones documentadas en el PRD.
- **B15e ✅ (2026-07-06 noche): playtest dirigido del kit Duelist
  medido.** Veredicto del director: "los fundamentals existen, pero no
  es ni de cerca la experiencia de Sifu" — y los números lo localizan
  ([[Benchmark Biomecánico]] §B15e): 8 tintes rojos a pantalla completa
  en 11.4 s de pelea (el evento visual MÁS grande del clip; wash ~50 %
  del combate), jugador golpeado sin cambio de pose, bestia solo flash
  (kit confirmado activo), patrón resultante = trade-fest (tanquear es
  óptimo). Todo el feedback sigue siendo cromático; nada corporal ni
  temporal. Salvedad B15d cerrada a medias: la síncopa del combo sigue
  sin ser medible con ese encuadre + wash encima.
- **Fix del tinte de daño ✅ (2026-07-06, adelantado por B15e):** el
  wash plano (`ColorRect` alpha 0.55 full-rect en `hud.gd`) es ahora un
  vignette real de bordes (shader canvas_item radial, centro SIEMPRE a
  alpha 0) con decay en dos fases: fuerte ≤0.2 s + cola ≤0.3 s.
  Verificado con sonda visual `tests/tmp_vignette.gd` (frames t=0 /
  0.1 / 0.25 / 0.5 s) + `autotest_ui` y `autotest_slice` ALL_PASS.
  Con esto el próximo clip del director ya permite medir la síncopa.
- **PRD-006 alcance 3 ✅ CÓDIGO (2026-07-06 noche): reacciones
  corporales + par light/heavy.** (a) La bestia tiene `receive_strike()`:
  HitPayload → GuardComponent → flinch/stagger/posture break **animados
  en el cuerpo** (head snap, roll lateral, derrumbe con patas abiertas),
  FSM suspendida durante stagger/broken y ventana de castigo (daño
  ×1.5). (b) El jugador acusa el golpe con `rig.play_flinch()` (head
  snap a 60 fps + recoil de columna en el reloj de pose). (c)
  `enemy_humanoid.gd`: light (saber rápido, postura frágil, encadena) y
  heavy (maul, torre de Equilibrio, carga de 0.8–1.0 s) sobre el MISMO
  CharacterRig con el strike hip-first — el telegraph es la biomecánica.
  Parry Roba contra ellos → stun 2 s. QA: test_core/test_combat/
  autotest_slice/autotest_ui ALL_PASS; sondas visuales `tmp_reactions` y
  `tmp_duel_pair`. **Pendiente: playtest del director (feel).**
- **B15f (2026-07-06 noche): playtest del alcance 3 PARCIAL ✅** — en
  gameplay real: cero washes (daño = banda de borde, centro limpio) y
  la bestia acusa con el CUERPO (roll/postura baja legibles). Los 2
  asesinos de B15e resueltos y verificados. Sin salir en cámara: flinch
  del jugador, par light/heavy (el boot no llevó `--spawn=duelpair`) y
  síncopa. [[Benchmark Biomecánico]] §B15f.
- **B15g ✅ (2026-07-06 noche): Playtest Loop del alcance 3 CERRADO** —
  el par verificado en juego real (5/7): spawn por flag, siluetas por
  rol sin leer color, swing del maul legible en arco completo,
  reacciones/muertes corporales, vignette limpio. Pendientes de
  medición: parry vs humanoides y síncopa. **Hallazgo de feel: presión
  enemiga baja** (≈1 golpe/2–3 s se lee pasivo) → candidatos de tuning
  en [[Benchmark Biomecánico]] §B15g.
- **PRD-006 alcance 4 ✅ CÓDIGO (2026-07-07): canales 1–3 de la
  [[Game Feel Bible]] como sistema reutilizable.** Autoload `Feel` +
  lógica pura `combat/time_feel.gd` / `combat/trauma_shake.gd`
  (headless-testable, lista para PRD-007). Canal 1: hit-stop 2f/3f
  GLOBAL por masa de arma (números B15 medidos; ×1.5 golpe de muerte,
  50% al recibir, cap 1 por 100 ms), parry Roba = clang 3f (B15b) +
  dilation 0.2×0.35 s + sting de dos notas sintetizado (placeholder
  hasta B8). Canal 2: shake trauma² Perlin, decay 1.2/s, caps 0.25 m /
  2° / 0.6. Canal 3: combat framing (FOV +4°, lift, histéresis 2 s) +
  soft-aim cono 30° total. `HitPayload.weapon_mass` nuevo. QA:
  test_combat +22 asserts, sonda en juego real `tmp_timefeel` (clang
  3 f exactos, dilation 0.354 s), test_core/slice/ui ALL_PASS, FPS
  491/336. Decisiones en el PRD. **Pendiente: playtest del director
  (feel).** Esto cierra el B15e #1 (la mitad temporal contra Sifu).
- **Tuning de presión enemiga ✅ CÓDIGO (2026-07-07, B15g):** el par
  humanoide ya no se congela entre golpes. En `enemy_humanoid.gd`:
  recover del light 0.55→0.42 s, `chain_prob` data-driven (light 0.72,
  heavy 0.0), y **circle-strafe durante recover** (tangente + corrección
  radial al anillo de ataque; sentido que alterna). El heavy sigue lento
  pero ACECHA. Verificado por sonda `tmp_pressure` en juego real:
  `recover_path` del light ≈0 → 3.55 m, heavy 3.56 m; loop de golpes
  vivo (light 6 / heavy 5 strikes en 8 s). **Pendiente: playtest del
  director.**
- **PRD-006 alcance 5 ✅ CÓDIGO (2026-07-07): greybox + spawns
  parametrizables + `autotest_combat.gd` — CIERRA PRD-006 y abre el
  Gate 1.** Escena nueva `scenes/combat_arena.gd`: blockout barato (suelo
  plano + anillo de límite + postes de parallax) que implementa el
  contrato de escena completo (`get_height`/`clamp_position`/`get_bounds`/
  `player_spawn`/...). Parser `gameplay/spawn_spec.gd`: spec tolerante
  (`light,heavy`, `2light+1heavy`, `duelpair` alias, vacío→default).
  Estado FSM `ARENA` + `--skip=arena`; helper `_spawn_humanoids`
  COMPARTIDO con WILDS — el `--spawn=duelpair` viejo se generalizó (back-
  compat verificado por `tmp_spawnflag`). `tests/autotest_combat.gd`
  (windowed): verifica spawn parametrizado (2 kinds), parry Roba→stun,
  kill loop del kit Duelist real (ambos muertos en 940 frames) y muestra
  FPS. **FPS del greybox 177 → gate ≥60 holgado** (escena trivial;
  captura `test_out/combat_arena.png`). QA: test_core/slice/ui ALL_PASS,
  `tmp_spawnflag` PASS. Lección nueva: golpear a un enemigo `dying`
  reinicia su timer de muerte (dejar de pegarle al entrar en dying).
  **Pendiente: playtest del director del feel (alcances 4 + tuning).**
- **Playtest del director (clip 2026-07-08) → feedback del kit defensivo.**
  Notas: (1) RMB mantener no generaba guardia — sin pose ni cambio de
  feedback (el rojo salía igual al bloquear); (2) LMB/RMB-tap funcionan
  pero poco evidentes del lado del jugador (sobre todo el parry); (3) el
  "status gráfico" del enemigo no le encanta (→ tarea de arte aparte).
- **Capa 1 del fix ✅ CÓDIGO (2026-07-08): la guardia gana cuerpo +
  feedback propio.** (a) Rig: `set_guard(bool)` = pose de bloqueo
  sostenida (antebrazos cruzados al frente + arma arriba + brace),
  blend in/out, compone sobre el gait y bajo el strike; el flinch acusa
  el golpe SIN bajar la guardia. Dentro de ROM (constraint_report vacío).
  (b) Feedback: un golpe BLOQUEADO deja de pintar el vignette rojo —
  ahora destello ACERO (`COL_BLOCK`) + chispa de deflexión en el arma
  (`_spawn_guard_spark`); el rojo queda SOLO para daño limpio. Wiring:
  `stats.take_damage(..., blocked)` → payload al HUD; `_set_guard` llama
  `rig.set_guard`. Sonda visual `tests/tmp_guard.gd`. **Director aprobó
  ("mejoró mucho", 2026-07-08).**
- **Capa 2 del fix ✅ CÓDIGO (2026-07-08): el parry se ve del lado del
  jugador.** El parry Roba solo se leía por el stun del enemigo. Ahora:
  (a) Rig `play_parry()` = deflexión seca de TODO el cuerpo (arma batea
  arriba-afuera + off-arm en contrapeso + giro de torso lumbar/torácico
  + cabeza al acero robado), riposte ~0.3 s sobre la guardia, ROM limpio.
  (b) VFX `_spawn_parry_flash()` = pop emisivo cian + burst de chispas
  cian→oro al frente del arma (más brillante que el destello de bloqueo).
  Wiring en `receive_hit` (reacción `parried`). Verificado: pose legible
  en sonda (`guard_parry.png`), parry real end-to-end en autotest_combat.
  QA: test_core/combat/slice/ui ALL_PASS. **Fix de test:** el kill loop
  de autotest_combat se acotó por TIEMPO REAL (era por frames → falla a
  FPS alto).
- **Capa 3 del fix ✅ CÓDIGO (2026-07-08): legibilidad del swing (LMB).**
  El swing se leía poco del lado del jugador. SIN tocar la biomecánica
  ratificada del strike: `_spawn_swing_arc()` dibuja una estela de filo
  (crescent emisivo additivo con TAPER por vertex-color — borde de ataque
  brilla, cola se apaga) al ENTRAR la fase active (1×/golpe, detecta la
  transición). Se desvanece en ~0.16 s. Sonda `swing_arc.png` (slash
  diagonal legible). QA: test_core/combat/slice/ui ALL_PASS.
- **✅ PAQUETE DE FEEDBACK DEL KIT VALIDADO POR EL DIRECTOR (2026-07-08,
  en vivo).** Las 3 capas aprobadas: guardia con cuerpo + bloqueo acero
  (Capa 1, "mejoró mucho"), tell del parry (Capa 2) y estela del swing
  (Capa 3) — todas confirmadas en `Start-Playtest-Greybox.bat`. El kit
  Duelist queda cerrado a nivel feel. El status gráfico del enemigo sigue
  como tarea de arte aparte (chip/sesión propia).
- **PRD-007 alcance 0 ✅ CÓDIGO (2026-07-08): Dagna aliada spawnea y
  sigue.** `gameplay/ally_dagna.gd`: montada por el pipeline de personajes
  (`apply_to_rig("dagna")`) sobre los 4 componentes canónicos; **sigue**
  un slot al hombro IZQUIERDO del jugador (la cámara vive en el derecho),
  ground-snap + gait procedural. Boot flag nuevo **`--ally=dagna`** (spawn
  en ARENA, array `allies` separado de `enemies`, update en
  `_gameplay_update`). Sonda `tests/tmp_ally.gd`: spawn + follow (22 m
  recorridos, dist acotada ~2.6 m) + captura `ally_dagna_follow.png`
  (Dagna legible: trenzas/túnica/hombreras/martillo). QA: test_core/
  combat/slice/ui ALL_PASS.
- **PRD-007 alcance 1 ✅ CÓDIGO (2026-07-08): ground-pound de Dagna → zona
  de onda + VFX teal.** `ally_dagna.gd`: `ground_pound()` = secuencia
  plant→slam→recover; en el impacto (tras windup ~0.35 s) spawnea el VFX
  (burst teal + 2 anillos de choque expandiéndose, per la lámina) y emite
  `springboard:wave`. El director registra la onda en `springboard_waves`
  (zona {pos, radio 4.2, ventana 0.6 s} que consumirá el jugador en el
  alcance 2) y **empuja a los enemigos cercanos** (la onda ES un ataque;
  knockback por `push_pull`, sin daño aún). Triggers del pound: Bond
  (alcance 2) e IA (alcance 3) — aquí se dispara por sonda. `tmp_pound.gd`:
  onda registrada + knockback (1.6 m) + expiración + captura
  `pound_wave.png` (los anillos teal leen igual que la lámina). QA:
  test_core/combat/slice/ui + tmp_ally ALL_PASS.
- **PRD-007 alcance 2 ✅ CÓDIGO (2026-07-09): Seismic Springboard T1 —
  Bond=`R` + salto-en-onda → lanzamiento vertical.** `game_director`:
  `_check_key_r()` + `request_bond_pound()` piden el pound a Dagna en ARENA;
  el controlador comparte `springboard_waves` por referencia (patrón de
  `enemies`). `player_controller._wave_at()`: un salto DENTRO de una onda
  activa amplifica `vel_y` a `SPRINGBOARD_LAUNCH_VEL 17.0` → **~6.0 m** (7.3×
  el salto normal ~0.8 m). **Air control por la ley de leap del PRD-005:** el
  lanzamiento siembra `_air_vel` con el momentum horizontal actual + activa
  `_leaping` → conserva y dirige la inercia (corres→cargas; parado→recto).
  **Feel (GFB):** `Feel.springboard_launch()` (freeze pesado + trauma) + estela
  teal + tell de HUD `set_springboard_ready()` (cue "SALTA" pulsante en suelo
  dentro de la onda). Sonda `tests/tmp_springboard.gd` ALL_PASS (6.00 m con
  onda / 0.82 m sin / 4.67 m de air control + captura `springboard_launch.png`);
  regresión test_core + autotest_combat ALL_PASS. **Pendiente: playtest del
  director (feel) — "afinamos con playtest"** (altura/tecla/ventana a tunear).
- **PRD-007 alcance 2b ✅ CÓDIGO (2026-07-09): Seismic Springboard DIRIGIDO.**
  Capa de **colocación** sobre el reactivo: `RMB` (mantener) apunta un punto en el
  suelo (raycast cámara→suelo `cam.project_ray_*` + decal teal clampeado a
  `DESIGNATE_RANGE` 11 m; teal en rango, ámbar si se recorta al borde); `R` con el
  apuntado activo → `_issue_directed_pound()` ordena a Dagna **viajar** al punto
  (estado `traveling`, deja su slot de guardia = costo táctico) y golpear ahí; la
  onda nace MARCADA `directed` y el lanzamiento suma un empuje horizontal hacia el
  punto (`SPRINGBOARD_DIRECT_PUSH` 3 m/s) sobre el `_air_vel` del alcance 2.
  Cooldown de orden 4.5 s. **Los dos modos conviven:** `R` solo = reactivo (alcance
  2, intacto). **Decisión de control del director (2026-07-09): RMB pasó a apuntar
  y la guardia/parry se mudó al botón lateral TRASERO del mouse (`XBUTTON1`);**
  SPACE sigue siendo salto, el lateral delantero (`XBUTTON2`) queda libre. Archivos:
  `player_controller.gd`, `game_director.gd`, `ally_dagna.gd`. Sonda nueva
  `tmp_springboard_directed.gd` ALL_PASS (clamp 11.0 m, onda en punto err 0.45 m,
  Dagna viaja 5.9 m, arco dirigido **8.91 m vs 4.67 m** plano = +4.24 m, cooldown
  activo/decae) + captura `springboard_directed.png`; regresión tmp_springboard /
  autotest_combat / test_core / autotest_slice / autotest_ui ALL_PASS.
  **✅ PLAYTEST DEL DIRECTOR APROBADO (2026-07-09): "ambos se sienten muy bien,
  nada que ajustar".** Los dos modos (reactivo + dirigido) y el esquema de control
  nuevo (RMB apunta, guardia en `XBUTTON1`, SPACE salto) validados en vivo. Sin
  tuning: rango 11 m / cooldown 4.5 s / empuje 3 m/s quedan como están. Playtest
  Loop del 2b CERRADO.
- **PRD-007 alcance 3 ✅ CÓDIGO (2026-07-09): Dagna IA de combate mínima — pelea
  a tu lado.** Tres piezas (mínima pero real, sin companion AI rica): (1) **la onda
  HACE DAÑO** —`game_director._on_springboard_wave` aplica `POUND_DAMAGE` 30 con
  falloff (+knockback) a los 3 disparos del pound (Bond/dirigido/autónomo); salta
  enemigos `dying`. Cierra el "la onda ES un ataque" de los alcances 1–2. (2)
  **Pound AUTÓNOMO** —`ally_dagna._update_combat_ai()`: ≥1 enemigo en `POUND_SENSE`
  3.8 + cooldown `AI_POUND_CD` 7 s → golpea sola. (3) **Muralla-block + defensa
  propia** — sube guardia (`rig.set_guard`) con enemigo en `GUARD_BLOCK_RANGE` 2.6;
  `receive_hit()` acusa (flinch/bloqueo + knockback) pero **NUNCA cae** (piso
  `HEALTH_FLOOR`; decisión del director: su pérdida es coda del slice). **Aggro por
  CERCANÍA** (decisión del director: nearest, no tanque) —`_nearest_target()` +
  `enemy_humanoid.combat_target` → cada enemigo va por el más cercano entre jugador
  y Dagna. Archivos: `ally_dagna.gd`, `game_director.gd`, `enemy_humanoid.gd`. Sonda
  `tmp_dagna_combat.gd` ALL_PASS (nearest, retarget, pound autónomo → onda + daño
  40→24 HP, muralla arriba/abajo, bloqueo reduce daño, martilleo sin caer) +
  captura `dagna_combat.png`; regresión completa ALL_PASS.
  **✅ PLAYTEST DEL DIRECTOR APROBADO (2026-07-09): "funciona bien"** — Dagna pelea
  a tu lado sin robarte la pelea; sin tuning (30/7 s/3.8/2.6 quedan). Playtest Loop
  del alcance 3 CERRADO. **La mecánica de Dagna aliada queda COMPLETA; falta solo el
  Gate 1 (alcance 4).**
- **PRD-007 alcance 4 ✅ CÓDIGO (2026-07-09): Gate 1 — cornisa solo alcanzable vía
  Springboard.** Cierra la construcción de la Fase 1 (falta solo el playtest del
  director). (a) **La cornisa:** `combat_arena.gd` crece una meseta elevada
  (`LEDGE_H` 3.5 m; footprint x∈[-5,5] z∈[-8,2]) con **faro teal = objetivo**,
  delante del spawn y separada del arco de enemigos. Como la Y del jugador es
  analítica (`get_height`), la cornisa es un footprint que devuelve `LEDGE_H`.
  **Solo alcanzable vía Springboard:** salto normal medido **0.82 m** no llega;
  lanzamiento **6.01 m** sí. (b) **Cliff real (no trepable a pie):** step-block en
  `player_controller.update()` — una celda elevada a la que NO llegaste desde arriba
  (subida > `LEDGE_STEP_MAX` 0.5 m sobre la Y de inicio de frame) es un MURO
  (revierte el paso horizontal); aterrizar descendiendo sí entra. **Gateado por
  `scene.has_method("is_cliff_wall")` → cero efecto en The Wilds ni otras escenas.**
  Tuning de feel: el punto de lanzamiento del gate se alejó del borde (pista) para
  que el arco cruce el labio por encima en vez de raspar la cara del cliff. (c)
  **Gate permanente nuevo `tests/autotest_springboard.gd` ALL_PASS** (A–H:
  aliada+onda por Bond real, no-trepa-a-pie, salto normal <cornisa, Springboard-en-
  ventana → cornisa ALCANZADA a y=3.50 pico 6.01 en plena meseta z=-2.8, Dagna pelea
  sin caer HP 120→111, FPS 578) + captura `springboard_gate.png`. Regresión
  test_core/autotest_combat/tmp_springboard/tmp_springboard_directed/slice/ui
  ALL_PASS. **FPS ≥60 con margen enorme** (577–583 en autotest; +3 mallas estáticas
  sobre el greybox de 177 fps frío del alcance 5; el número definitivo se confirma
  en el playtest del director, la corrida fría natural).
- **Fix del corte del salto ✅ CÓDIGO (2026-07-09, feedback del director):** Boris
  probó el Gate 1 — "se siente bien pero al llegar a la altura de la cornisa como
  que se cortó el salto". Diagnóstico: NO era gráfico — el aterrizaje analítico
  atrapaba al jugador al ENTRAR al footprint subiendo (por debajo de la tapa) y
  mataba `vel_y`. Fix: (a) el suelo **solo atrapa descendiendo** (`vel_y ≤ 0` en el
  snap del `player_controller`) → el arco del Springboard completa hasta el ápice;
  (b) muro del cliff más firme (`LEDGE_STEP_MAX` 0.5→0.15) → solo entras a la meseta
  desde arriba, sin trepar raspando la cara. En llano no cambia nada (nunca subes
  hacia el suelo). Gate ampliado con **F2** (regresión permanente del corte: lanzarse
  pegado al cliff → pico 5.99 ≥ 5.0, antes ~3.3). QA: gate + test_core/locomotion +
  autotest_combat/slice/ui + tmp_springboard/tmp_springboard_directed ALL_PASS.
  **✅ RE-VERIFICADO POR EL DIRECTOR (2026-07-09): "se siente perfecto".** El arco
  del Springboard completa limpio a la cornisa. Playtest Loop del Gate 1 CERRADO.
- **🏁 FASE 1 CERRADA (2026-07-09).** Gate 1 aprobado: en el greybox peleas junto a
  Dagna y usas el Springboard T1 sobre su onda para alcanzar una cornisa imposible,
  ≥60 FPS. PRD-006 (combate mínimo) + PRD-007 (Dagna aliada + Seismic Springboard
  T1) completos en código Y validados en playtest. **Siguiente: la ventana C6
  (rework anatómico del cuerpo base) + pase de poses C4, RATIFICADA entre el Gate 1
  y la Fase 2** — no se disparó la cláusula de escape (los cuerpos no impidieron
  juzgar el feel). Luego, la Fase 2 del [[Plan-de-Produccion]].
- **Dagna gráfica en Godot ✅ (2026-07-07): pipeline lámina → config →
  rig PROBADO** (entregable extra pedido por el director para *liberar su
  diseño*). Sistema nuevo reutilizable: `godot/data/characters.gd`
  (configs de personajes nombrados: origin+clase+fenotipo+piezas firma)
  + `godot/character/character_signature.gd` (extras de lámina —
  túnica/hombreras/cuña de trenza/tatuajes de gremio/martillo — colgados
  aditivos sobre el rig, cero cambios al rig base). Dagna se lee
  inconfundible vs. `dagna-v1.png`; **la cuña de la trenza queda
  garantizada y legible en perfil** (la ficha lo exigía). Sonda de
  presentación `tests/tmp_dagna.gd` (frente/espalda/perfil/detalle,
  cámara nivelada). **Solo capa de LOOK** — el ROM/IK enano y su
  animación siguen diferidos (C4 + PRD-007). QA: test_core/autotest_slice
  ALL_PASS, tmp_dagna limpio. Ejecución creativa por subagente **Fable**;
  orquestación + fixes de fidelidad (mirada nivelada, cuña) por mí.
  **Nota: la sesión de Fable se cortó por límite de gasto mensual de la
  cuenta.** Demo adicional: `tmp_dagna_golden.gd` — Dagna bajo el pase
  Melancolía Gráfica en la golden scene (el registro del Art Bible SÍ
  aterriza en el rig; el greybox era la anti-referencia).
  **Veredicto del director (2026-07-07): identidad liberada, pero la
  ANATOMÍA está lejos de la lámina** — el cuerpo base hereda gráficos del
  prototipo pre-reset que ya estaban corruptos; debió hacerse rework
  completo. → **C6 (rework anatómico del cuerpo base)** en el Task-Board;
  **ventana RATIFICADA (2026-07-07): entre el Gate 1 y la Fase 2, junto
  al pase de poses C4** (cláusula de escape: se adelanta a PRD-007 si en
  el Gate 1 los cuerpos impiden juzgar el feel).
- **➡️ ARRANQUE DE LA PRÓXIMA SESIÓN:**
  0. **VENTANA C6/C4 EN CURSO (branch `feat/c6-anatomy-rework`).** Hecho
     (2026-07-10): **C6a r1–r3 + C6c** — humano canónico 7.49 cabezas bajo
     línea Sobel pura (sin casco invertido; `toon_opaque` post-safe),
     volúmenes cónicos de lámina (nada de círculos), hombros caídos con
     trapecios, cabeza sin chibi (cráneo con forma, mandíbula, nariz, ojos
     humanos). Banco: `tests/tmp_anatomy.gd` (medidas + capturas en
     `godot/test_out/anatomy_*.png`). **Primero: VoBo del director de las
     capturas r3** (las de la comparación las dio en vivo, la cara nueva aún
     no la aprueba). **Luego C6b:** enano trapezoide 4.5 cabezas + elfo 8
     esbelto sobre la tabla PROPORTIONS + ROM enano/elfo en `rig_biomech.gd`
     + **Dagna re-montada** (sus piezas firma HOY están desfasadas — apuntan
     al cuerpo viejo). Después C4a (poses por gait) + C4b (canal airborne) y
     playtest del director de la ventana completa. Pies IK DIFERIDOS.
  0a. **Decisiones que esperan al director (2026-07-12):** (i) VoBo del
     turnaround r5 de la CABEZA (M9) + ratificación explícita del
     cowl/base-body (pendientes desde M9-r5 — requieren que el director VEA
     las capturas); (ii) VoBo de la sección §7 "Cierre de sesión" añadida a
     [[SCHEMA]]; (iii) **VoBo del turnaround m10-r6 del peinado príncipe**
     (capturas en `godot/test_out/rounds/m10-r6/`, ver ítem M10-r5/r6).
     **✅ RATIFICADA (2026-07-12): [[Propuesta-Recursos-de-Modelado]]** (C8,
     Design Loop cerrado) — los 5 recursos, los 3 ajustes al plan de rework
     de la sesión paralela (gradientes+banding → su Sesión 4; Decal VS
     triplanar → su Sesión 5; nota de cinta continua → su Sesión 2) y el
     loft como mini-loop propio pre-C6b.
     **Plan de rework EN EJECUCIÓN (2026-07-12, esta sesión): Sesiones 0–2
     COMPLETADAS.** S0: tercera ronda de evaluación dirigida volcada al doc
     de plugins (cara sin plugin minable; cross-check ROM; orientation
     warping de PoseWarping → candidato C4, tercera persona exclusiva).
     S1: **Beckett MCP instalado** (`godot/addons/beckett/`, habilitado en
     project.godot, `.mcp.json` gitignoreado; servidor solo-localhost
     verificado) + cuelgue del banco RESUELTO (contención confirmada).
     S2: peinado príncipe reconstruido (ver ítem M10-r5/r6, VoBo pendiente).
     **Nota Beckett:** el editor aún NO se ha abierto con el plugin activo —
     el `.mcp.json` se auto-escribe al primer arranque del editor, y
     registrar el MCP en la sesión de Claude Code requiere sesión interactiva
     + aprobación del director. **Siguen: S3 (vista-esqueleto) y S4 (repaso
     completo + gradientes/banding C8) y S5 (Decal VS triplanar).**
  0b. **PRD-006 CERRADO ✅ + playtest VALIDADO (2026-07-08):** el kit Duelist
     cerrado a nivel feel. El greybox (`--skip=arena --spawn=<spec>`,
     `Start-Playtest-Greybox.bat`) queda como banco de combate permanente.
     **Ojo: el greybox NO corre el post Melancolía — ahí el rig se ve sin
     línea de tinta hasta que el banco de playtest gane el post (pendiente
     de decidir al cierre de la ventana C6/C4).**
  1. **PRD-007 (Dagna + Seismic Springboard T1) — spec RATIFICADO
     (2026-07-08):** [[PRD-007 Dagna aliada + Seismic Springboard T1]].
     Design Loop cerrado. **Alcances 0 ✅ (aliada sigue), 1 ✅ (ground-pound →
     onda + VFX teal) y 2 ✅ CÓDIGO + PLAYTEST APROBADO (2026-07-09):** el
     Springboard T1 (Bond=`R` + salto-en-onda → lanzamiento ~6 m con air
     control) funciona bien en vivo. Banco: `Start-Playtest-Greybox.bat` (ya
     trae `--ally=dagna`). **Alcance 2b — Springboard DIRIGIDO ✅ CÓDIGO
     (2026-07-09):** `RMB` apunta (raycast cámara→suelo, decal teal, rango 11 m) +
     `R` ordena → Dagna viaja al punto → pound ahí → esprintas y arcas (empuje
     hacia el punto sobre tu momentum); cooldown 4.5 s, Dagna deja su slot al
     viajar. Los dos modos conviven (reactivo + dirigido). Guardia/parry mudada a
     `XBUTTON1` (botón lateral trasero). Sonda `tmp_springboard_directed` ALL_PASS.
     **✅ PLAYTEST APROBADO (2026-07-09):** Playtest Loop del 2b CERRADO. **Alcance 3
     ✅ CÓDIGO (2026-07-09): Dagna IA de combate mínima** (onda con daño + pound
     autónomo + muralla-block/defensa propia sin caer + aggro por cercanía). Sonda
     `tmp_dagna_combat` ALL_PASS + **PLAYTEST APROBADO (2026-07-09): "funciona
     bien"** — Playtest Loop del 3 CERRADO, sin tuning. **Alcance 4 ✅ CÓDIGO
     (2026-07-09): Gate 1** — cornisa/meseta (`LEDGE_H` 3.5) con faro teal solo
     alcanzable vía Springboard (salto normal 0.82 m no llega; lanzamiento 6.01 m
     sí), cliff no trepable a pie (step-block en el controlador, gateado por
     escena), gate permanente `tests/autotest_springboard.gd` ALL_PASS + captura.
     **✅ PLAYTEST APROBADO (2026-07-09): "se siente perfecto"** (tras el fix del
     corte del salto — aterrizaje descend-only + muro firme). Playtest Loop del Gate 1
     CERRADO. **🏁 FASE 1 CERRADA.** La cláusula de escape C6 NO se disparó (los
     cuerpos no impidieron juzgar el feel). **SIGUIENTE: ventana C6 (rework anatómico
     del cuerpo base) + pase de poses C4** — RATIFICADA entre el Gate 1 y la Fase 2;
     luego la Fase 2 del [[Plan-de-Produccion]].
  1b. El **pipeline de personajes** (`characters.gd` + `signature.gd`) ya
     está listo para replicar con los otros 8 pivotes cuando toque
     (Fase 4 / concept art). Dagna es el molde.
  2. Tarea de arte aparte (chip/sesión propia): repasar el **status
     gráfico de las reacciones del enemigo** (flinch/stagger/broken), que
     al director no le convence.
  3. Backlog C4 (cuando toque el pase de poses): postura de columna
     por gait (B15c) + canal airborne del rig (B15d #6 — el salto hoy
     no tiene pose).
  4. **Metodología del pase visual RATIFICADA (2026-07-09)** para la Fase 4:
     playtests por capa acumulativos en The Wilds sobre `melancolia_post` (las
     4 capas ya implementadas — solo las usa la golden scene), **gate
     secuencial: cada capa se libera con VoBo del director antes de apilar la
     siguiente**, criterio = keyframes canónicos + FPS por capa. Detalle en
     [[Plan-de-Produccion]] §Fase 4. El PRD del pase visual nace ahí.
- **PRD-006 CERRADO ✅ en código** (Feature Loop; alcances 0–5). Falta
  solo el playtest del director del feel:
  - **Alcance 0 ✅** rig restringido (ROM + constraints) + strike
    hip-first, movilidad aprobada.
  - **Alcance 1 ✅** (2026-07-06): `godot/combat/` — CombatComponent /
    GuardComponent / EnergyComponent / PushPullComponent + HitPayload +
    `weapons.json`, instanciados NEUTROS en jugador y bestia; curvas
    trifásicas del strike (coil hold / release overshoot / settle con
    follow-through). QA: `test_combat` 41/41.
  - **Ronda de articulación ✅ APROBADA en vivo** (feedback "legos"):
    follow-through amortiguado por segmento + lag de cadena abierto +
    **columna en 2 segmentos** (lumbar+torácico, adelanto de C4). El
    melee vivo anima `play_strike` (fix: antes solo lo veían los
    autotests). Boot de prueba melee:
    `--origin=ironblooded --cls=warrior --skip=wilds`.
  - **Alcance 5 ✅ código** (2026-07-07): greybox `combat_arena.gd` +
    spawns parametrizables (`spawn_spec.gd`) + `autotest_combat.gd`.
    Siguiente hito: PRD-007 (Dagna + Springboard T1). Gate 1: pelear
    junto a Dagna en el greybox ≥60 FPS (greybox ya a 177 FPS).
- **Animación — canon fijado por A/B (2026-07-06, 3 rondas):** stepping
  EN 2s (12 Hz) SOLO en extremidades; cuerpo/raíz suaves a 60. Body pop
  descartado (mecanismo queda tras `body_pop_on_twos` OFF). Tecla T
  cicla los 3 modos in-game. [[Benchmark Biomecánico]] **RATIFICADO por
  el director (2026-07-06 noche)** — la condición se cumplió vía
  B15d–B15g: canon validado midiendo nuestra propia build + playtest.
- **Sesiones de arte (2026-07-04, todas cerradas):** fenotipos ✅ (B12) ·
  keyframes dawn/dusk ✅ + regla nocturna · Speck trilogía ✅ (B9 arte) ·
  golden scene ✅ (B11) · Dagna ✅ (B1 1/9).
- **Depósito de concept art del director (2026-07-08, en `90-Raw/concept/`,
  versionado):** 8 láminas nuevas en estilo Melancolía Gráfica. **4
  acoplamientos** (link moves, lee la co-dependencia al instante): *The
  Weaver's Net* (Humano Strategist + Nyael), *Skyhook* (Enano Vanguard +
  Lyris), *Arcane Ballistics* (Elfo Strategist + Torgan), *Mobile Foundry*
  (Enano Strategist + Bram) → referencia para [[Acoplamientos]] /
  [[Los 9 Links del Pivote]] / fichas de pivotes (B1). **4 beats
  narrativos:** *El Último Vínculo* (Dagna forja el guante, Speck al
  hombro) y *La traición ejecutada* (la Primera Cuña en el God-Core) →
  [[Estructura Dramática]] / [[Dagna]]; *Final 1 sacrificio silencioso* y
  *Final 4 aether renacido* → [[Los 4 Finales]]. Es REFERENCIA raw (no
  cierra los ítems de diseño B2/B6; los alimenta). +4 láminas del 07-07
  ya existentes se versionaron también (Seismic Springboard, Traición_
  Dagna, Fenotipos+Speck, El primer viso de la muda).
- **Branch actual:** `feat/c6-anatomy-rework` (ventana C6/C4; C6a hecho, sigue
  C6b). `master` quedó al cierre de la sesión 2026-07-09: PRD-007 alcances
  **2b, 3 y 4 —Gate 1— mergeados + playtest aprobado; 🏁 FASE 1 CERRADA**, más el fix
  del corte del salto del Gate 1. `autotest_combat.gd` y `autotest_springboard.gd`
  son gates permanentes. Lanzador de doble clic para el
  playtest en el greybox: `Start-Playtest-Greybox.bat` (raíz; la meseta del Gate 1
  ya vive en el greybox). Sondas temporales `tests/tmp_*.gd`
  (step, vignette, reactions, duel_pair, spawnflag, timefeel, pressure,
  dagna, guard, ally, pound, springboard, springboard_directed, dagna_combat)
  quedan hasta validar el pipeline / limpieza.
- **Motor: GODOT CONFIRMADO** (ADR-002).
- **Bloqueos:** ninguno.
- **Deuda técnica visible:** pies sin IK y ROM enano/elfo (C4 restante);
  mesh de bloques = etapa (pase visual en producción del slice).
- **Riesgos abiertos:** frame budget térmicamente frágil en la laptop RTX
  2060 (~58 fps warm); export a consolas requiere partner externo (Godot).

**Historial de estados:** ver [[LOG]].
