---
status: vivo
updated: 2026-07-16
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

- **📋 VEHÍCULO DE EJECUCIÓN (2026-07-16):
  [[PRD-Rework-Modelado-Personajes-v2]]** — todo lo de abajo (hallazgos
  #0/#0.5/#0.6 + puntos 1-5) quedó traducido a instrucciones ejecutables
  para Sonnet en 5 fases con anclas de código, gates y reglas de sesión.
  **VoBo de Boris RECIBIDO en los 3 puntos (2026-07-16, mismo día):** orden
  de fases 0→4 aprobado, A/B de banding LINEAR (Fase 0.3) autorizado,
  criterio "medición manda" para `SHOULDER_X` (Fase 1.1) confirmado. **Fase
  0 ejecutada y cerrada (2026-07-16, mismo día) — ver hallazgo detallado
  abajo: el pipeline de tinta funcionaba bien, el problema real era el
  ángulo de cámara del banco, ya corregido y verificado (gates ALL_PASS).**
  Fase 0.3 (A/B banding LINEAR) y 0.4 (re-baseline QA) quedan como
  opcionales, no bloqueantes. **Fase 1 (torso/hombros) — primera pasada
  ejecutada (2026-07-16, mismo día):** 1.1 medido (biacromial ~2.05-2.08
  cabezas en la lámina, coincide exacto con el render actual —
  `SHOULDER_X` NO se toca, confirmado que el problema es de masas
  faltantes). Trapecio (ya existía en código, agrandado — antes invisible
  en perfil, ahora tiene contorno propio), cintura (ya no copia el radio
  exacto del torso — primer pellizco real) y clavícula (partida en 2 con
  quiebre de S, más sutil) actualizados. **Acromion + overlap trapecio-
  deltoide completados (mismo día, a pedido de Boris):** caja chata
  semi-hundida en el tope del hombro + trapecio corrido para solapar
  directo el deltoide. Verificación honesta: se lee bien en perfil, sutil
  en frente/3-4 (un plano de acromion se luce más visto desde arriba) —
  no rompió nada, tampoco es dramático en esos ángulos. Gates ALL_PASS.
  **Con esto, Fase 1.3 queda completa en su primera pasada. Pendiente
  antes de cerrar Fase 1:** QA imparcial + VoBo de Boris con capturas
  frente/perfil/3-4/espalda — ver [[PRD-Rework-Modelado-Personajes-v2]]
  Fase 1 para el detalle completo.
- **➕ FASE 5 PROPUESTA (cara: mandíbula/ojos/nariz/mentón/orejas), pedida
  por Boris el mismo día, posterior a la Fase 4 (boca):** borrador completo
  en [[Fase5-Cara-Propuesta-DRAFT]] (`20-State/PRDs/`, NO fusionado al PRD
  oficial todavía). Esto NO es reabrir la cara desde cero — la Fase C ya la
  cerró al 75% (2026-07-14); es una pasada dirigida a esas 5 partes con
  conocimiento nuevo. **Corrección importante ocurrida en esta misma
  sesión:** el primer borrador reportó que el libro de anatomía minado no
  cubre cabeza/cara — Boris señaló los capítulos exactos ("3D male Part 01"
  §10-11 + "Advanced 3D male Part 01 | Head, neck, and face", Djordje
  Nagulov) y se re-minaron esas 7 páginas del mismo PDF (localizado en
  `Downloads`, `mutool` ya instalado). Nueva sección "Cabeza, cuello y cara"
  agregada a [[Principios de Anatomía 3D]] — el hallazgo más aplicable es el
  principio hueso-vs-músculo (las cejas/párpados se mueven, la órbita ósea
  NO — relevante para los sliders `eyeTilt`/`eyeShape`). Único vacío real
  del libro: no cubre proporción/estructura de OREJA. Mandíbula/mentón/
  nariz ya tienen 4-8 rondas de ajuste fino documentadas y estables —
  recomendación del borrador: priorizar ojos/orejas en esta fase. **Las 6
  preguntas abiertas quedaron RESUELTAS por Boris (2026-07-16, mismo día):**
  se genera lámina de rostro nueva (brief 8 en [[Briefs de Concept Art]]);
  esta fase toca solo la oreja neutra; se verifican extremos de slider; las
  5 partes se revisan parejo (no solo ojos/orejas); el sesgo racial de
  mandíbula/ojos queda fuera, entra con el frente de elfo/enano. **Único
  paso pendiente antes de arrancar la medición de esta fase: generar y
  aprobar la lámina de rostro** (brief 8) contra los 5 ejes del [[Art
  Bible]] — todavía no se generó ninguna imagen.
- **➕ Minado ampliado + brecha racial detectada (2026-07-16, mismo día,
  pedido explícito de Boris de cubrir "el humano completo + el work del
  elfo y el enano"):** [[Principios de Anatomía 3D]] ganó 3 secciones más
  (Piernas y pies, Brazos y antebrazos, Piel y pliegues) — insumo para el
  frente de piernas/pies (deuda técnica ya conocida), no para ejecutar ya.
  **Hallazgo real con impacto directo en Fase 5:** `character_rig.gd:1906-
  1947` (`jaw`/`cheek`/`eyeTilt`/`eyeShape`) usa el MISMO rango para las 3
  razas, pese a que [[Fenotipos y Creación de Personaje]] (ratificado
  2026-07-04) ya declara esos 3 rasgos como "rango racial" — mismo
  tratamiento que `heightRange`, que sí es por-origen. La oreja SÍ cumple
  el diseño por raza (4 ramas ya existentes). Un subagente Fable (2
  reintentos por error 529 del servidor, 3er intento OK) incorporó esto al
  borrador con una propuesta de mecanismo concreta (§1/§4 de
  [[Fase5-Cara-Propuesta-DRAFT]]) y una pregunta abierta nueva (#6: ¿el
  sesgo racial entra en esta fase o es frente aparte?). **Hallazgo
  colateral, ya separado como tarea aparte (no bloquea nada de lo
  anterior):** `origins_data.gd` sigue tratando a Mist-Stalker como raza
  completa (Beast-Folk) pese a la decisión ratificada "Mistbound 100%
  humanos" — tarea C1 pendiente de [[Nomenclatura]].
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
  **FASE 0 EJECUTADA Y CERRADA (2026-07-16, mismo día) — el hallazgo de
  arriba resultó SOBREESTIMADO, no confirmado contra el píxel real.**
  Diagnóstico directo (Lección: "para geometría/forma específica, mirar
  el píxel gana") sobre `anatomy_close.png`/`anatomy_face.png`/
  `anatomy_full_front.png` con zoom ×4 mostró que la tinta Sobel SÍ
  entinta al personaje (silueta, cejas, nariz, boca, mandíbula,
  pectorales — comparable en peso al entorno) y que el banding SÍ existe
  (visible con fuerza en `anatomy_full_side.png`/`anatomy_face_back.png`).
  **Causa real:** las capturas "de frente" (`_frame_close`, el shot
  frontal del turnaround, `_frame_full_front`) ponían la cámara
  EXACTAMENTE alineada con el eje del sol de "dawn" (`sun_azim_deg=190`
  ≈ eje +Z del personaje) → superficie uniformemente iluminada, sin
  contraste que mostrar, aunque el pipeline funcionara perfecto (el
  perfil, en un ángulo distinto, ya mostraba banding fuerte con el MISMO
  shader). **Fix aplicado:** `tmp_anatomy.gd` — nuevo helper
  `_key_offset()` que rota 15° alrededor de Y el offset de cámara en esos
  3 encuadres (misma distancia, no cambia el zoom), rompiendo la
  alineación cámara-luz sin dejar de leer como vista de frente. Verificado
  visualmente (capturas regeneradas muestran volumen/sombreado real) +
  los 5 gates de la regla de sesión (`test_core`, `autotest_biomech`,
  `test_combat`, `autotest_slice`, `autotest_ui`) ALL_PASS. La divergencia
  real de `golden_scene.gd:98-99` (ambient_lift/rim_strength hardcodeados
  para los materiales propios de la escena) vs `pipeline_config.gd:11,15`
  sigue existiendo pero es cosmética/menor — el personaje ya usa
  `PipelineConfig.apply_to()` correctamente vía `ToonMaterials.
  toon_mat_opaque()`, no es la causa de nada. **Conclusión: el % de
  fidelidad medido hasta ahora (32→55%) NO estaba contaminado por falta
  de tratamiento visual — esa hipótesis no se sostuvo.** Fase 0.3 (A/B
  banding LINEAR) y 0.4 (re-baseline QA) siguen pendientes si Boris los
  quiere correr, pero ya no son bloqueantes de Fase 1. Segundo hallazgo
  del QA visual, sin investigar aún: los
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
- **Higiene de contexto aplicada (2026-07-16, a pedido de Boris, inspirada
  en la skill "project-context"):** este archivo se recortó a solo el
  presente — antes acumulaba el relato completo de cada sesión desde el
  reseteo (2026-07-04) y llegó a 1,197 líneas / ~21,800 tokens, cargándose
  entero en CADA arranque de sesión por la regla 1 de `CLAUDE.md`. Todo
  ese relato histórico se movió VERBATIM (sin editar contenido, cero
  pérdida) a [[Current-State-Historico]]. El registro append-only sigue
  siendo [[LOG]] — la fuente de verdad de "qué pasó" nunca cambió, solo se
  dejó de auto-cargar en cada sesión. Regla nueva hacia adelante: este
  archivo describe SOLO lo vigente (arranque de próxima sesión + hechos
  actuales); si algo deja de ser "lo que sigue" y pasa a ser "lo que ya
  pasó", se mueve a [[Current-State-Historico]] o vive solo en [[LOG]] —
  no se acumula aquí.

## Hechos vigentes

- **Branch actual:** `feat/c6-anatomy-rework` (ventana de rework de anatomía/
  gráficos en curso desde la Fase 1; detalle histórico completo — incluido
  el cierre de la Fase 1 y el Gate 1 — en [[Current-State-Historico]] y
  [[LOG]]). Playtest permanente: `Start-Playtest-Greybox.bat`. Gates
  permanentes: `autotest_combat.gd`, `autotest_springboard.gd`.
- **Motor: GODOT CONFIRMADO** (ADR-002).
- **Bloqueos:** ninguno.
- **Deuda técnica visible:** pies sin IK y ROM enano/elfo (C4 restante);
  mesh de bloques = etapa (pase visual en producción del slice).
- **Riesgos abiertos:** frame budget térmicamente frágil en la laptop RTX
  2060 (~58 fps warm); export a consolas requiere partner externo (Godot).

**Historial de estados:** ver [[LOG]].
