---
status: vivo
updated: 2026-07-24
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

- **✅ SESIÓN 2026-07-24 — RETCON CATACLISMO + MAPA DEL MUNDO REFINADO:**
  Mapa del mundo generado en NB Pro (Tolkien × Sable × BotW, 45+ POI) revisado
  por Boris — detonó corrección de canon: **cataclismo movido de 100 a ~550
  años atrás**, techo de vida élfico fijado en 650-700 años (Eragon-style, no
  inmortalidad Tolkien), nueva sección **Los Tres Niveles de Conocimiento**
  en [[El Mundo y la Muda]] (elfos ~5-10% memoria directa / enanos tradición
  oral ritualizada / humanos folclore regional deformado). Speck: soledad
  100+→**550+ años**. Tabla de longevidad nueva en [[Las Tres Razas]] (elfos
  650-700 / enanos ~200-250 / humanos ~70-90). Detalle completo en [[LOG]].
  **Otros ajustes de mapa:** Mistbound reposicionado (tierra interior remota,
  no frontera con The Wilds — Rivermeet es la puerta real vía River Road);
  The Monolith sin revelación mecánica (se descartó "Warden Waystone", queda
  solo una leyenda ambigua de Valen + Warden's Crypt debajo sin confirmación
  verbal); 3 Torres de Guardia nuevas por raza en cada entrada a The Wilds;
  Stillwood redefinido como continuación orgánica de The Wilds en elevación
  (Rivendell/Imladris) con cascada nueva The Ascending Falls.
  **Pendiente:** el PNG del mapa ya generado tiene "100 years" horneado en
  texto — requiere regeneración cuando se itere el asset visual (brief fuente
  ya corregido).

- **✅ SESIÓN 2026-07-23 — SPECK + FINALES + GOLDEN SCENES COMPLETO:**
  Redireccionamiento narrativo de Speck CERRADO. Transformación involuntaria 
  (Fragmento) + asunción de destino con gracia divina (F1/F4) vs. agencia robada 
  (F2/F3). **Todos 4 finales concept art GENERADOS Y RATIFICADOS (95-100%):**
  - E3 F1 (The Guided Molt): majestuosa, propósito, luz cálida ✅
  - E3 F2 (The Long Winter): monumento muerto, desolación, fría ✅
  - E3 F3 (The Conqueror's Clause): prisionera, trauma, cadenas ✅
  - E3 F4 (The Warden's Choice): God-Core vivo, libre, eternidad cálida ✅
  
  **Golden Scene keyframes completados (4 landmarks visuales):**
  - The Wilds Dawn (existe) ✅
  - The Wilds Dusk (existe) ✅
  - Rivermeet (generado, ratificado 95%+) ✅
  - God-Core Night (generado, ratificado 100%) ✅
  
  Siguiente: **Decisión roadmap post-NB Pro** (Trailer? Cutscenes? Banda sonora?)

- **Boris rechazó la ronda 2 de ajustes** ("Todavía no me gustan") y
  encargó traducir su propia spec anatómica (triángulo curvo tipo sable,
  eje 20-40° atrás, proporción 1.5-2× oreja humana MISMO grosor, punta
  50-70° redondeada) contra Zelda TotK/Frieren a un plan técnico, vía un
  **subagente Opus dedicado**. Decisiones que tomó Boris sobre el plan:
  recortar a la proporción 1.5-2× (revierte el ancho de las 2 rondas
  previas), variante **Zelda puro**, técnica = **composición de
  primitivas sólidas** (no reintentar el loft, ya falló 3 veces).
- **✅ REWORK EJECUTADO (2026-07-22, ronda 9):** cono de un solo taper
  reemplazado por 4 masas (cuerpo + punta + base + hélix, las 3 últimas
  hijas del cuerpo para alineación garantizada). Diagnóstico nuevo del
  subagente: el cono medía 3.1× la oreja humana del rig, muy por encima
  del 1.5-2× pedido — ahora ≈1.8× (largo total ≈0.14).
- **✅ QA imparcial corrido (protocolo [[QA Loop]], mismo agente
  re-invocado 2 veces): 35-40%→55-60%→75%.** Ronda 9 midió CRITICAL en
  el eje (leía casi lateral, sin rake). Sub-ronda 1 resolvió proporción y
  costura (55-60%) pero el eje persistió. Diagnóstico descartó bug de
  cálculo (verificado con matrices `Basis` explícitas) — la causa real
  era que la oreja venía "casi horizontal" por decisión de las rondas
  4-5; al re-mirar las referencias con el hallazgo en mente, ambas
  muestran la oreja apuntando hacia ARRIBA. **Boris reabrió esa decisión**
  y se subió la elevación (~28° arriba + ~20° atrás, construcción directa
  de dirección en vez de ángulos Euler encadenados) → **75%, sin
  CRITICAL abierto**. Quedan 2 hallazgos menores: MEDIUM (verificar
  cuando el pelo definitivo reemplace el placeholder — riesgo de que
  tape la punta) y LOW (ángulo 5-6° por encima del techo de 40° pedido,
  sin impacto visual reportado). Gates `test_core.gd` ALL_PASS en cada
  sub-ronda. Detalle completo en [[LOG]]. **VoBo de Boris sobre el 75%:
  conforme con el resultado** ("Sí, dale, así queda") — cierra la ronda
  10 de la oreja de elfo.
- **✅ NACIMIENTO DE OREJA — pasos 1-3 CERRADOS (2026-07-22, VoBo de Boris):**
  [[PRD-Nacimiento-de-Oreja-v1]] CERRADO. Paso 1 humano: 74% (4 rondas QA).
  Paso 2 enano + helper `_build_ear`: 70% (2 rondas QA, reparametrización
  racial visible). Paso 3 elfo + pabellón: 78% (2 rondas QA, dos MEDIUM
  resueltos). El nacimiento lee como transición orgánica en las 3 razas
  (no "cono pegado"). Techo de 3 primitivas declarado (concha/antihelix
  imposibles). Gates ALL_PASS, sin regresión. Anti-objetivo duro respetado:
  cono élfico intacto (eje, largo, punta sin toque).
- **Sesión 2026-07-21 cerró el frente 1
  (hombro→torso+cintura) y frente 2 (C4 pies IK), y en
  [[PRD-C6b-Enano-Elfo-v1]] ejecutó DOS pasadas: (1) piloto de
  PROPORCIONES (campo `"proportions"` por origin: `limb_len`/
  `shoulder_x`/`neck_len`/`head_scale`/`hand_scale`, reutiliza hooks de
  escala existentes) — enano 4.49 cabezas / elfo 8.17 (objetivos 4.5/8.0);
  (2) geometría nueva de OREJA élfica (alargada + barrida hacia atrás,
  antes leía como nudo horizontal) y MANDÍBULA/CEJA por raza (campo
  `"face"`: `jaw_width`/`jaw_depth`/`brow_scale`/`brow_y` — enano frente
  pesada/mandíbula ancha, elfo mandíbula fina). Gates ALL_PASS en ambas
  pasadas, cero regresión humano/miststalker (proportions/face vacío).
  Detalle completo en [[LOG]]. **Queda VoBo de Boris sobre TODO C6b hasta
  ahora antes de seguir con ROM por raza.**
  Capturas guardadas para VoBo en `godot/test_out/`:
  `anatomy_dwarf_full_front/_side.png`, `anatomy_dwarf_face/_34/_profile.png`,
  `anatomy_elf_full_front/_side.png`, `anatomy_elf_face/_34/_profile.png`
  (banco corrido con `ANATOMY_ORIGIN=ironblooded|aetherborn` +
  `ANATOMY_HAIR=8` para juzgar oreja/mandíbula sin el peinado tapando —
  ambos env vars nuevos y reutilizables en `tmp_anatomy.gd`, mismo patrón
  que `DIAG_*`). `anatomy_face*.png`/`anatomy_full_*.png` normales
  restaurados al humano baseline (7.35 cabezas).
  Chip aparte (fuera de C6b, YA EN EJECUCIÓN por el director en otra
  sesión): cámara de close-up rota en `autotest_classes.gd` (preexistente,
  confirmado con `git stash`, NO introducida por C6b).
  **Ronda 2-3 de oreja élfica (mismo día + 2026-07-22):** Boris pasó 2
  referencias nuevas (Frieren + Zelda TotK, en `Downloads/`) — reemplazan
  el criterio de la lámina de concept art para este rasgo. Ajuste manual
  (2 rondas) + **QA imparcial formal** (protocolo [[QA Loop]], mismo
  agente re-invocado): 40%→60-65% de fidelidad medida. CRITICAL (ángulo),
  HIGH (punta roma), MEDIUM (base gruesa) RESUELTOS y verificados por
  píxel por el propio QA.
  **Experimento de "hoja compuesta" (mismo día, 2026-07-22): CERRADO,
  revertido.** Se probó `HairLibrary._loft`/`_lock` (curva+radios, el
  reemplazo vigente de la técnica de pelo vieja) para el hallazgo de
  silueta "hoja" que el QA marcó como techo del cono — 3 rondas con QA
  de por medio, las 3 midieron PEOR que el cono (40%→45%→45-50% vs
  60-65%). Revertido al cono (mejor estado medido); nueva Lección
  documentada (loft puede leer peor que un cono simple en rasgos chicos/
  cortos). Gates ALL_PASS.
  **Ajuste puntual (mismo día):** Boris pidió base 25% más ancha sobre
  el cono ya validado — `bottom_radius` 0.019→0.024, sin tocar ángulo/
  largo/punta. Verificado en banco, gates ALL_PASS. **Estado final de la
  oreja: cono con base más ancha, sobre el 60-65% ya medido (cambio
  puntual sin nueva medición de QA — pendiente si Boris quiere
  re-medir).**
- **Sesión 2026-07-19 ejecutó: mini-ronda de quiebres de mandíbula ✅,
  GRUPO C ✅, piloto de loft (FASE 3 pelo) ✅-detenido-en-regla. Queda del
  día:**
  0. **✅ MANDÍBULA: VoBo RATIFICADO por Boris (2026-07-20)** — la mini-
     ronda de quiebres queda PERMANENTE (ya no es temporal). Cierra ese
     frente; la cara vuelve solo en la ronda de ajustes finales.
  1. **PELO: frontier crop reconstruido** (jerarquía de 3 pasadas del
     libro; defecto de "dientes" ELIMINADO, sin cuenco trasero, nuca
     corta con piel, color castaño correcto). Set fresco en
     `godot/test_out/` (anatomy_face*.png). **PELO REFINADO en MÚLTIPLES
     rondas (07-19/20):** quiebres suavizados, taper, fade completo
     (temporales/patillas/nuca/costado como BANDAS continuas + casquete
     elipsoide, nunca tiras — corolario en [[Principios de Anatomía 3D]]);
     reestructura por jerarquía de 3 pasadas del libro; patilla suelta
     eliminada (decisión de Boris); roseta de nuca rota; nacimiento con
     espaciado irregular; nuca baja subdividida. **Último QA de ZONAS vs
     referencia de cráneo (07-20):** coinciden patilla/oreja/occipucio/
     nuca; hueco de coronilla-frontal tapado ~95% con bandas que hugean
     (pinhole residual de PIEL solo visible a 3× zoom — confirmado por
     diagnóstico de color; se paró tras 3 intentos por regla del Vault).
     Gates ALL_PASS. **Pendiente artístico menor:** pinhole de coronilla
     + nacimiento algo despareja. **Siguiente frente:** última ronda de
     AJUSTES DE CARA (el VoBo de mandíbula era TEMPORAL, se cierra con el
     pelo puesto) — a criterio de Boris.
     - **Herramienta nueva reutilizable:** `HairLibrary._on_skull(x,y,
       lift,back)` da el punto de la superficie del cráneo REAL — TODO
       peinado futuro del [[PRD-Catalogo-Peinados-v1]] se autora con
       ella, no a ojo (3 rondas se perdieron por semiejes inventados).
     - **Bug de shader cerrado:** `hair_mat.rim_strength` 0.18→0.04
       (el rim azul bañaba las tiras finas completas — causa del "tinte
       azulado" que venía desde el piloto).
  2. **Grupo C EJECUTADO (07-19):** jueces canónicos nuevos — rostro
     34%, torso 32% (manos 70% quedó de la serie anterior). Baselines
     de la serie NUEVA (no comparables con 48-57%/38-55% de jueces
     previos, varianza ±10-17). Hallazgos accionables que sobrevivieron
     el arbitraje: boca-cápsula (20%), mentón-cuboide en perfil,
     hombro→torso y cintura recta. El presupuesto de subagentes es
     ventana de 5h (confirmado) — sondear antes de asumir espera.
  - **Registro:** fases y backlog con estado en
    [[PRD-Reescritura-Escultura-Rig-v1]]; narrativa del día en [[LOG]].
  - **Decisiones de estilo vigentes:** regla de tinta
    `edge_threshold=1.00` (VoBo con A/B); anillos de codo/hombro =
    estilo toon aceptado salvo veto; hombros no escalan con el build
    (por diseño, pivotes fijos).
  - **Metodología (ver [[Lecciones]]):** color de diagnóstico; 4 vistas
    + close-ups + zoom antes de cerrar; solape en 3 ejes entre padres
    distintos; caja para bordes, rampa/tangente para que el Sobel no
    recorte; masas del torso = hijas de `torso`/`waist`.
  - **Orden acordado con Boris (2026-07-20):** (1) hallazgos restantes
    del grupo C — hombro→torso y cintura recta; (2) C4 — pies IK/ROM;
    (3) [[PRD-C6b-Enano-Elfo-v1]] (cuerpo+ROM enano/elfo, AMPLIADO a
    incluir catálogo de peinados + marca cultural por raza, con plan de
    optimización de tokens). Catálogo de peinados humano
    ([[PRD-Catalogo-Peinados-v1]]) y Fase 4b (warpaint) del
    [[PRD-Rework-Modelado-Personajes-v2]] quedan POSPUESTOS — Boris:
    "no creo que sea prioridad ahorita" (son trabajo de catálogo, no
    frente urgente). **No arrancar nada de esto sin señal explícita de
    Boris** (pidió verificar alineación primero, sin ejecutar).
- **Fases 1-2 del [[PRD-Rework-Modelado-Personajes-v2]] quedaron
  SUPERSEDED** por R2/R3 (nota de estado en el propio PRD); sus Fases 3
  (pelo/loft) y 4 (boca-color/warpaint) siguen vigentes para DESPUÉS de la
  reescritura. [[Fase5-Cara-Propuesta-DRAFT]] queda absorbida
  conceptualmente por R1 (la lámina de rostro que le faltaba ya existe:
  [[fenotipo-humano-rostro-v1]]).
- **Higiene de contexto aplicada 2 veces el mismo día (2026-07-16-17):**
  este archivo se recorta a solo el presente cada vez que crece con el
  relato sesión-por-sesión; ese relato se mueve VERBATIM a
  [[Current-State-Historico]] (el registro append-only autoritativo sigue
  siendo [[LOG]]). Si esta sección vuelve a crecer con narrativa histórica,
  repetir el recorte — no acumular aquí.

## Hechos vigentes

- **Branch actual:** `feat/c6-anatomy-rework` (ventana de rework de anatomía/
  gráficos + redireccionamiento narrativo de Speck en curso desde la Fase 1;
  detalle histórico completo en [[Current-State-Historico]] y [[LOG]]). Playtest
  permanente: `Start-Playtest-Greybox.bat`. Gates permanentes: `autotest_combat.gd`,
  `autotest_springboard.gd`.
- **REDIRECCIONAMIENTO SPECK (2026-07-23):** Speck dejó de ser "mascota ajolotl"
  → ahora es **último Warden cristalino superviviente** de civilización perdida.
  Shapeshifteada imperfectamente como zorro. Encuentro accidental en misión de
  purga. Protocolo del silencio. Humor pragmático (enano). Poder innato del
  jugador revela verdad en flashes silenciosos. Coming-of-age narrativo.
  E1 brief ejecutado, E2/E3 pendientes.
- **Motor: GODOT CONFIRMADO** (ADR-002).
- **Bloqueos:** ninguno.
- **Deuda técnica visible:** pies sin IK y ROM enano/elfo (C4 restante);
  mesh de bloques = etapa (pase visual en producción del slice).
- **✅ CERRADO (2026-07-16, sesión paralela):** `origins_data.gd` ya no
  trata a Mist-Stalker como raza Beast-Folk aparte — reconvertido a
  Mistbound (subcultura humana fronteriza), geometría bestial (orejas/cola/
  pelaje falso) quitada de `character_rig.gd`. Gates ALL_PASS. Detalle en
  [[LOG]] y [[Fenotipos y Creación de Personaje]].
- **Riesgos abiertos:** frame budget térmicamente frágil en la laptop RTX
  2060 (~58 fps warm); export a consolas requiere partner externo (Godot).
- **SCHEMA v1.1 (2026-07-20):** dieta de arranque fusionada desde la skill
  `project-context`. Python 3.12 instalado (ver [[Lecciones]]);
  `check_vault.py` corriendo y verificado: **~1,894 tokens de arranque,
  🟢 VERDE**, sin `@imports`, privados protegidos en `.gitignore`
  (confirmado con `git check-ignore`). Detalle completo en [[LOG]] y
  `../VAULT-STARTER.md` v2.

## Pendientes narrativos / lore (2026-07-23)

**Speck — 100% COMPLETO (cierre 2026-07-23):**
- ✅ Narrativa redireccionada (mascota → último Warden) + asunción de destino
- ✅ E1 Warden (Trueform Speck translucent) LOCKED
- ✅ Forma zorro (Shapeshifted Speck + Flashes) LOCKED
- ✅ E3 F1 (The Guided Molt) GENERADO + RATIFICADO 100%
- ✅ E3 F2 (The Long Winter) GENERADO + RATIFICADO 95%+
- ✅ E3 F3 (The Conqueror's Clause) GENERADO + RATIFICADO 95%+
- ✅ E3 F4 (The Warden's Choice) GENERADO + RATIFICADO 100%

**GUIÓN / NARRATIVA ESTRUCTURA — GAPS CRÍTICOS:**
- **Guión completo por actos** — GDD §1.2 tiene estructura dramática pero NO hay diálogos/escenas
- **Voz narrativa definida** — ¿Narrador? ¿First person? ¿Silent protagonist? ¿Cuán verbose vs. environmental?
- **Momentos de Persona de Speck** (~7 escenas narrativas sin UI) — mencionadas pero no escritas
- **Diálogos de Bautizo (Darro nombrando Speck)** — narrativa locked pero escena no scripted

**✅ PERSONAJES — LOS 9 PIVOTES + 3 FIJOS (2026-07-23):**
- **✅ Fichas Narrativas Expandidas COMPLETAS (9 Pivotes):** Maren, Torgan, Iven, Sereth, Bram, Lyris, Nyael, Vekka, Dagna
  - Biografía pre-aventura única por Pivote
  - Cómo lo ve Personaje Fijo (misma raza): Conocimiento Previo (Roen→3 Humanos, Valen→3 Elfos, Darro→3 Enanos)
  - Encuentro con jugador específico por cell (raza/rol)
  - Arco 3-actos completo (Lealtad → Comunidad → Desilusión)
  - Clímax + traición (9 patrones narrativos distintos)
  - 4 Epílogos por Final (Perdón/Muerte/Encadenamiento/Síntesis)
  - Línea canónica + línea privada
  - Dinámicas con Roen/Valen/Darro
  - Diseño visual ratificado + arma/técnica
- **✅ Roen, Valen, Darro fichas:** Concepto completo con encuentros personalizados (18 total)

**✅ WORLDBUILDING — GEOGRAFÍA Y CIUDADES + THE WILDS COMPLETO (2026-07-23):**

**3 Reinos:**
- ✅ Aethelgard (Rivermeet, Mistbound Frontier, Iven's Settlement)
- ✅ Ignis Reach (Emberdeep, Ember Workshops)
- ✅ Stillwood (The Stillspire, Sky Watchtowers)

**The Wilds — 45+ POI (Points of Interest):**
- ✅ Ruinas Antiguas (3): The Shattered Spire, The Echoing Archive, The God's Throne
- ✅ Asentamientos Abandonados (3): Riverstone, Ironforge Outpost, Stillwood Sanctuary
- ✅ Landmarks Naturales (4): Lake of Mirrors, The Monolith, Shattered Cascade, Ossuary Grove
- ✅ Dungeons Secundarios (3): The Hollow Deep, The Rift, Submerged Halls
- ✅ Puntos Narrativos (4): Warden's Rest, The Battlefield, Observation Point, Speck's First Glimpse
- ✅ Santuarios por Raza (3): Shrine of First Hammer (enano), Grove of Cycles (élfico), Vigil of Broken Oath (humano)
- ✅ Poder Aether (3): The Aether Well, The Crystal Heart, The Fountain of Echoes
- ✅ Lugares Privados Pivotes (10): Roen/Maren/Torgan/Iven/Sereth/Bram/Lyris/Nyael/Vekka/Dagna
- ✅ Bosses Menores (4): Crowned Leviathan, Burning Shepherd, Mirror Stalker, Aether Wyrm
- ✅ Vistas Narrativas (2): World's Crown, Scar of Breaking
- ✅ Refugios (3): Hermit's Cave, Bandits' Hideout, Warden's Crypt
- ✅ Interdimensional (2): The Mirror Pool, The Closed Door

**Beats narrativos por acto:**
- ✅ Acto 1 (tu gajo) — Desfiladeros + El Nido
- ✅ Acto 2 (rueda completa) — 3 sub-actos (Rivermeet / Emberdeep / Stillwood) + Interludios Driftmarket
- ✅ Acto 3 (clímax) — Sunken Archive → The First Wound → 4 Finales

**Conectividad:**
- ✅ Arterias de conexión: River Road / Cinder Ascent / Gloomvault
- ✅ Personajes mapeados a ciudades
- ✅ Tiempos de viaje estimados
- ✅ Pendiente: Fast travel diegético (barcazas, túneles)

**Worldbuilding — Cultura/Lore:**
- **Culturas por raza** — Aether-Born/Iron-Blooded/Restless existen narrativamente pero NO tienen ceremonia/idioma/costumbre documentadas
- **Lore de civilización Warden perdida** — menciona en [[El Mundo y la Muda]] pero NO hay historia pre-caída detallada
- **Regla de los Tres Reinos movilizan ejércitos** — mencionada en clímax pero estrategia/alianzas no mapeadas

**Locations — fichas narrativas incompletas:**
- **The First Wound** — cráter clímax, cementerio God-Cores; existe keyframe visual (God-Core Night) pero sin descripción física/ficha lore completa
- **Sunken Archive** — recupera Fragmento; sin ficha ni descripción física
- **The Wilds interior/ecosystem** — zona de inicio pero descrip¿ción ecosistema no mapeada

**Finales — scripting incompleto:**
- **Los 4 Finales — diálogos/cinemática** — existen visuals pero NO scripted el "cómo ves cada final" (qué dice el jugador/Quinteto?)
- **Estado post-final jugable** — hay créditos pero post-game state no definido
- **Variantes C3 vivo/muerto en Finales 2-3** — mencionadas pero no impacto narrativo mapeado

**POSPUESTO (Post-Lore):**
- ❌ Trailer formal (requiere guión sólido primero)
- ❌ Cutscenes cinemáticas (requiere script + dirección narrativa)
- ❌ Banda sonora tema principal (después de alpha gameplay)

---

## Estado de concept art (2026-07-23)

**✅ SPECK — REDIRECCIONAMIENTO + FINALES COMPLETOS (2026-07-23):**
- `Trueform Speck translucent.png` (E1 Warden) — RATIFICADO, LOCKED
- `Shapeshifted Speck.png` + Flashes 1-3 (zorro) — EXISTE, RATIFICADO
- `Speck - Awakened Warden Form / The Guided Molt` (E3 F1) — GENERADO, RATIFICADO 100%
- `Speck - Imprisoned Warden Form Final 3` (E3 F2) — GENERADO, RATIFICADO 95%+
- `Speck - Imprisoned Warden Form - Traumatized` (E3 F3) — GENERADO, RATIFICADO 95%+
- `Speck - Ancient Warden Form / Final 4 Aether Renacido` (E3 F4) — GENERADO, RATIFICADO 100%
- **Narrativa:** Redireccionamiento completo documentado en [[Speck.md]] y [[Briefs de Concept Art]] §5

**COMPLETADO (2026-07-22/23) — NB PRO + HIGGSFIELD:**

*NB Pro — Finales Speck (sesión 2026-07-23):*
- `Speck - Awakened Warden Form` (F1) — ✅ GENERADO, RATIFICADO 100%
- `Speck - Imprisoned Warden Form Final 2 The Long Winter` — ✅ GENERADO, RATIFICADO 95%+
- `Speck - Imprisoned Warden Form Final 3 Traumatized` — ✅ GENERADO, RATIFICADO 95%+
- `Speck - Ancient Warden Form Final 4 Aether Renacido` — ✅ GENERADO, RATIFICADO 100%
- `Rivermeet keyframe` — ✅ GENERADO, RATIFICADO 95%+
- `God-Core Night keyframe` — ✅ GENERADO, RATIFICADO 100%

*NB Pro — Links/Acciones Pivotes (2026-07-22):*
- `Guided Avalanche.jpeg` — Sereth (elfo) + Torgan (enano duelist). ✅ Evaluated
- `Riposte Runner.jpeg` — Iven (humano acróbata) + Elfo Vanguard. ✅ Evaluated

*Higgsfield — Links/Acciones + Creature (2026-07-22):*
- `Warforging.png` — Vekka (enana ingeniera) + Humano Vanguard. ✅ Evaluated
- `Speck sneak peek.mp4` — Evaluation pending (ffmpeg setup)

**Pendiente de evaluación (ffmpeg setup):**
- Videos Higgsfield: `Arcane Ballistics.mp4`, `Weaver's Net.mp4`, `Seismic Springboard (2).mp4`
- `Speck sneak peek.mp4`

**Historial:** [[LOG]] y [[Current-State-Historico]].
