# Index — catálogo del Vault

> Una línea por página. Leer primero en toda consulta. Mantenido por Claude
> en cada operación ([[SCHEMA]]).

## Raíz

- [[SCHEMA]] — el modelo de trabajo: capas, plantillas, contratos, regla de oro.
- [[LOG]] — bitácora append-only de operaciones.
- `../VAULT-STARTER.md` — **exportable**: el método completo (VDD ×
  LLM-WIKI + rutina de cierre + dieta de arranque §9 + consejos de campo)
  destilado en un archivo único para que cualquier persona arranque su
  propio Vault adjuntándolo a su Claude Code. Generado 2026-07-13,
  fusionado con `project-context` (auditoría de tokens, niveles
  equipo/privado, puentes) el 2026-07-20.
- `scripts/check_vault.py` — auditoría de **peso** de arranque del Vault
- `scripts/hook_current_state.sh` + `.claude/settings.json` (raíz del repo) —
  hook `PostToolUse` que corre `check_vault.py` automáticamente al editar
  `Current-State.md` y devuelve el semáforo al mismo turno
- `scripts/check_canon.py` — auditoría de **consistencia** del canon (citas,
  aritmética, fuente única, clases incompletas). Correr ANTES de gastar
  subagentes de QA; exit 1 si hay críticos
  (SCHEMA §8): semáforo de tokens, `@imports`, niveles equipo/privado,
  detección individual/colaborativo. Solo lectura.

## 10-Knowledge (diseño del juego, compilado del GDD v2.2)

- [[Visión y Pilares]] — la frase de visión y los 4 filtros de toda decisión.
- [[El Mundo y la Muda]] — lore público vs. la revelación: God-Cores = cadáveres de Wardens; la Muda inconclusa.
- [[Geografía y Ciudades]] — mapeo completo: 3 reinos + ciudades secundarias + zonas neutras + beats por acto + viajes.
- [[Bestiario]] — eje de salud del Aether (Sano/Ambiental/Corrupto/Aberración), los 4 bosses ya nombrados + 3 nuevos que completan los 5 dungeons formales.
- [[Flora y Ecosistemas]] — mismo eje aplicado a vegetación; el Jacarandá de Rivermeet, la Hoja de Maelys (referencia cruzada a Dagna).
- [[Villanos Menores]] — amenazas de mundo abierto: 3 facciones de las razas existentes (Compañías Impagas, Sin Nombre, No Licenciados) + 2 razas nuevas no sapientes nacidas de la corrupción (Vaciados, Motas). Sin jefe final — decisión deliberada.
- [[Estructura Dramática]] — 3 actos + nudo del Fragmento + traición por convicción + gancho de 3 polos.
- [[Voz Narrativa]] — sin narrador durante el juego; único bookend: Roen viejo en taberna, apertura neutra + 5 cierres variables por final. Ratificado 2026-08-07.
- [[Guion/Apertura — Roen Viejo]] — primera escena literal del juego, guión en inglés, `status: ratificado`.
- [[Guion/Cierres — Roen Viejo]] — 5 cierres variables por final (F1/F2a/F2b/F3/F4), formato conversación con un Barkeep fijo, `status: ratificado`. Bookend completo.
- [[Guion/Encuentro con Roen]] — primer guión jugado del juego (no bookend): la emboscada de los 3 Hollowed (excepción de manada, [[Villanos Menores]] §The Hollowed) + intervención de Roen, cierre del tutorial de Los Desfiladeros de Zephyr. 2 modos por rol (Duelist/Strategist: Roen lanza un Hollowed y el jugador remata, arma por celda para Duelist / acción a distancia para Strategist; Vanguard: "doble ancla", T1), `status: provisional`. **17ª ronda de QA (2026-08-10): 13 críticos entre 2 subagentes, todos corregidos a la fuente** — detalle en [[LOG]]. Pendiente re-corrida antes de ratificar.
- [[Guion/Caminata y Taberna — Valen se suma]] — segunda escena jugada: la caminata silenciosa Roen+jugador hasta la ciudad natal (Rivermeet/Emberdeep/Stillspire) + la taberna donde **Valen se suma** (locación 1 de [[Geografía y Ciudades]] §Beats Narrativos). Blocking único con 3 ambientaciones por raza y **una** línea variable (reconocimiento, celda raza×rol×género de [[Valen-Ficha-Expandida-v1]]). Sin combate: el T1 de Valen se enseña en el tramo siguiente. `status: provisional`.
- [[Guion/Frontera — Camino al Nido]] — tercera escena jugada (Acto 1, locación 2): el cruce de la torre de guardia del reino ([[Geografía y Ciudades]] §M) hacia The Wilds, con Roen y Valen. **Enseña el T1 de Valen** (*The Long Calculus*, los dos orbes en beats separados + el uso de traversal) y es el primer tramo donde un Duelist tiene daño pleno sostenido ([[Acoplamientos]]). Fauna de grado Ambiental sin nombre; el paso a Corrupto anuncia el nido. `status: provisional`.
- [[Guion/El Nido — El Primero]] — cuarta escena jugada y la más cargada del Acto 1 (locación 3): guardianas semi-corrompidas + primer jefe · la crisálida · **el Pivote se suma** · **la elección ilusoria** ([[Speck]] §El encuentro, fuente única) donde el protagonista **habla por primera vez en todo el juego** (una palabra: *"No."*, dicha al contrato) · **Momento de Persona 1**, el único del Acto 1 · el primer God-Core apagado con Speck mirando (siembra del Acto 3: son cadáveres Warden). 4 slots por Pivote, todos ya escritos en las 9 fichas. `status: provisional`. **Hueco detectado:** el primer jefe no tiene ficha en [[Bestiario]].
- [[Guion/Waypost — Los Cinco]] — quinta escena jugada y **cierre del Acto 1** (locación 4): Darro se suma último, se enseña su link *Open Seam*, y el grupo **se vuelve equipo** — el beat lo dispara Darro con una pregunta de cortesía (*"So what happens tomorrow?"*) que nadie contesta. Misma sala del bookend, 30 años antes ([[Geografía y Ciudades]] §K). El Bautizo **no** es acá (es Acto 2). `status: provisional`.
- [[Armamento Base — Matriz Raza x Rol]] — arma/verbo/mecánica clave de las 9 celdas de [[Matriz Raza x Rol]] + equipamiento de los 3 fijos (Roen/Darro/Valen), `status: ratificado` (2026-08-07). Corrige un error de canon sobre el parry (sabor racial, no regla transversal — [[Combate]] §B4) y devuelve los 3 Strategist a su arquetipo original (manipulador psíquico / ingeniero / gadgeteer) en vez de converger en "sanador". Incluye la ventana de input del remate (whiff = se pierde el bonus del link, no el combate). El escudo de Roen se resolvió (regalo anónimo, mismo recurso que los Wanderer's Goggles). **Barrido 2026-08-07:** cruzado contra los 9 Pivotes, resolvió 2 colisiones de arma (Torgan/Darro, Lyris/Nyael, ambos pares Enano/Elfa Duelist con la misma arma).
- [[Las Tres Razas]] — Elfos/Enanos/Humanos: temperamento, hábitat, por qué nadie quiere a Speck. Incluye tabla de longevidad (elfos 650-700 / enanos ~200-250 / humanos ~70-90).
- [[Estructura Política]] — cómo se gobierna cada reino: Queen Ithessa + The Elder Circle + 2 Academias (elfos); King Borran + Great Forging Clan (enanos); Regent Edrick Ashcombe + Triune Council (humanos, sin dinastía estable). Nombres propios en inglés — ver [[Nomenclatura]].
- [[La Rueda]] — mapa macro: cubo (Wilds), aro (3 reinos), 3 arterias co-op, Driftmarket, Sunken Archive, First Wound.
- [[Speck]] — la última Warden: un estadio de revelación (no crece, se revela), bautizo, Momentos de Persona. **§Capa 5 = fuente única de la regla física del Fragmento**; §Capa 4 = los 4 grados de agencia de Speck por final.
- [[The Bound Five]] — jugador + C1 afín + C2 opuesto + C3 pivote + C4 chispa (+Speck); matchmaking orgánico.
- [[Los 9 Pivotes]] — matriz y fichas v0: Maren/Torgan/Iven/Sereth/Bram/Lyris/Dagna/Nyael/Vekka.
- **`10-Knowledge/Pivotes/` — 9 fichas narrativas expandidas COMPLETAS (2026-07-23):** [[Pivotes/Maren-Ficha-Expandida-v1|Maren]] / [[Pivotes/Torgan-Ficha-Expandida-v1|Torgan]] / [[Pivotes/Iven-Ficha-Expandida-v1|Iven]] / [[Pivotes/Sereth-Ficha-Expandida-v1|Sereth]] / [[Pivotes/Bram-Ficha-Expandida-v1|Bram]] / [[Pivotes/Lyris-Ficha-Expandida-v1|Lyris]] / [[Pivotes/Nyael-Ficha-Expandida-v1|Nyael]] / [[Pivotes/Vekka-Ficha-Expandida-v1|Vekka]] / [[Pivotes/Dagna-Ficha-Expandida-v1|Dagna]]. Incluye: bio pre-aventura, Conocimiento Previo (fijo ve Pivote), encuentro player-único, arco 3-actos, traición, **5 epílogos** (F1/F2a/F2b/F3/F4), línea canónica/privada, dinámicas, diseño visual. **Propagación de la ruptura de dos tiempos completa (2026-08-12):** las 9 declaran ahora en el **sub-beat 2b** (sala del Fragmento), traen el obstáculo firma del link perdido durante el ascenso, y su índice es de **6 sub-beats (1, 2, 2b, 3, 4, 5)**. Fuentes: [[Bond y el Bond Vacío]] §La traición tiene dos tiempos + [[Geografía y Ciudades]] §ACTO 3.
- [[Acoplamientos]] — roles de co-dependencia sin ultimates; parejas fundadoras; tutorial geográfico.
- [[Los 9 Links del Pivote]] — Skipping Stone…Warforging: qué hace cada uno y qué duele al perderlo.
- [[Los 3 Links de los Fijos]] — Second Catch (Roen) / The Long Calculus (Valen) / Open Seam (Darro), provisional 2026-08-05, pendiente de QA.
- [[Bond y el Bond Vacío]] — el único botón de vínculo; el beat del miembro fantasma; la Link Cam. **Fuente única de la traición en dos tiempos** (ruptura en la sala del Fragmento → ascenso como ventana → toma en el corredor) y de las dos excepciones declaradas (Bram, Nyael). Propagada a las 12 fichas el 2026-08-12.
- [[Matriz Raza x Rol]] — las 9 celdas de arquetipo mecánico.
- [[Locomoción]] — FSM conservada + mantling + escalada zonificada + conservación de impulso.
- [[Combate]] — 4 componentes + HitPayload; marcas como datos; parry racial; verbos 3×3.
- [[Movilidad Realista]] — mandato §4.3: constraints + IK + ROM por raza; el esqueleto manda.
- [[Progresión y Contrato]] — el Contrato que te persigue; loop principal.
- [[Los 5 Finales]] — Guided Molt / Long Winter (Handed Over · Fallen) / Conqueror's Clause / Warden's Choice + ecos Bond. **Filosofía y sabor** de cada final; la mecánica de la escena vive en la Matriz de Rutas.
- [[El Cráter — Matriz de Rutas]] — **fuente única de la mecánica del clímax** (2026-08-03): secuencia fija de 6 pasos (más un paso 0 de contexto), tabla de parámetros por ruta (mensajero y cadena institucional de cada Pivote), los 5 gates, beats obligatorios por final, y las reglas globales que las fichas citan en vez de re-enunciar. Las 9 fichas de Pivote + 3 fijos + [[Los 9 Pivotes]] **heredan de acá**.
- [[The Tether]] — Contract Standing vs. Bond por compañero (T1–T3) + Momentos de Persona.
- [[Grove of Cycles — Escena del Acto 2]] — el debate del Elder Circle (Threnn/Ilyara/Corwyn/Maelys) que siembra los finales; fuente primaria de por qué el grupo llega ahí y del Vector C (gate: mayoría "persona" en los Momentos de Persona, sin conteo de flashes).
- [[Art Bible]] — "Melancolía Gráfica": Sable×BotW×Hinterberg, regla espacial, pipeline 4 capas.
- [[Nomenclatura]] — AETHER BOUND y todos los nombres canónicos sellados.
- [[Inventario del Prototipo]] — qué se conserva, re-usa o reemplaza del build Godot.
- [[Catálogo Técnico Godot]] — librerías/técnicas de Godot 4.6 priorizadas para el proyecto; confirma en código que los 5 recursos de [[Propuesta-Recursos-de-Modelado]] (loft, banding, triplanar) siguen SIN ejecutar; suma `CompositorEffect` (Alta, deuda técnica del post manual) y descarta CSG/compute shaders/plugins de pelo con evidencia.
- [[Benchmark-Musculatura-Torso]] — rúbrica de aceptación para músculo esculpido en el rig procedural (torso sin playera + piernas). Canon visual: [[Art Bible]] + lámina fenotipo-humano-v1. `status: borrador`.
- [[Principios de Anatomía 3D]] — minado de "Anatomy for 3D Artists" (157 páginas, 5 subagentes, 2026-07-16): torso en 3 masas (caja torácica 2/3 + cintura + pelvis 1/3), cintura escapular como bloque separado, sistema de mitades sucesivas para nudillos, pelo = masa completa primero + variación anti-paralelismo entre mechones. Insumo directo para `SHOULDER_X`/manos/pelo, nada aplicado aún en código.
- [[Fenotipos y Creación de Personaje]] — silueta canónica por raza + slots fijos/raciales/libres.
- [[Briefs de Concept Art]] — prompts Nano Banana 2 (fenotipos/keyframes/Speck/foliage/Dagna) + notas de pipeline; ratificada 2026-07-08 (sus outputs ya son canon). Página viva: se añaden los 8 pivotes restantes. **§5c — los 5 finales visuales de Speck completos (2026-07-30):** F1/F2a/F2b/F3/F4, todos ratificados y consistentes con `Los 5 Finales` actual. **§15 (2026-08-07): Los Desfiladeros de Zephyr, 3 briefs (skin humana/enana/élfica) del tutorial de Acto 1 — 3/3 RATIFICADAS, cada una con nota menor no bloqueante.** **§16 (2026-08-07): emboscada de los 3 Hollowed + llegada de Roen — RATIFICADA, nota menor de continuidad de pelo de Roen vs. §14.1.** **§17 (2026-08-07): re-roll de Lyris (bumeranes élficos + limpieza de texto) — RATIFICADO, `lyris-v2.png`.** **§12.2 (2026-08-07): key-art-poster V2 — RATIFICADO retroactivamente (generado 2026-07-28, hallado sin evaluar en Downloads).**
- [[Briefs de Mapa del Mundo]] — brief profesional para generar mapa Tolkien × Sable × BotW (45+ POI mapeados, fidedigno para RAW + concept). Estilo línea clara, desaturación cálida, isométrico.
- [[Slice of Bond]] — vertical slice ratificado: Humano Duelist × Dagna; 4 escenas (Nido → Cinder Ascent → eco Sunken Archive → coda Bond vacío), 45–60 min.
- [[Game Feel Bible]] — §6.3 ratificada: hit-stop por masa, shake modelo trauma, cámara libre + soft-assist, feel del Springboard.
- [[Benchmark Biomecánico]] — v1 Sable/Hinterberg: el benchmark es timing y pose (animar en 2s), no más realismo. v2 AAA (B14): motion matching descartado; camino validado = Sifu handkey trifásico + foot IK de HZD. **RATIFICADO (2026-07-06)**. v3 (B15): mediciones frame a frame de los clips del director — hit-stop 2f/3f global, combo sincopado, contacto ≈60% del ciclo (valida 0.58), Sable con raíz continua = canon A/B validado 1:1. §B15d: nuestra build medida con el mismo método (AS IS vs TO BE) — feedback de combate hoy 100% cromático (flash/tinte), 0% corporal/temporal; locomoción ya alineada con Sable; running jump 42 f = analítica del código pero sin pose (canal airborne pendiente en C4). §B15e: playtest dirigido del kit Duelist — 8 tintes de daño en 11.4 s tapan la lectura (fix adelantado), jugador sin reacción de pose, trade-fest; el veredicto del director ("no es Sifu") queda medido. §B15f–B15g: alcance 3 verificado en juego — los 2 asesinos de B15e resueltos (vignette de bordes + reacción corporal), par light/heavy legible por silueta; hallazgo nuevo: presión enemiga baja (tuning); lo que faltaba contra Sifu era temporal — cerrado por el alcance 4 ✅ (2026-07-07, pendiente de playtest).
- [[Pivotes/Dagna-Ficha-Expandida-v1]] — ficha viva del Pivote del slice (bio Deepstone, 5 años con el jugador, arco 3 actos, 5 finales, visual v2). Los tiers del Springboard y la Primera Cuña viven en [[Los 9 Links del Pivote]].
- **Los 3 fijos — una sola fuente viva cada uno:** [[Roen-Ficha-Expandida-v1]] · [[Valen-Ficha-Expandida-v1]] · [[Darro-Ficha-Expandida-v1]]. **Los tres migrados a la ruptura de dos tiempos (Roen 2026-08-12, Valen y Darro 2026-08-13):** su reacción al quiebre vive en **§Escena 1 — la sala del Fragmento (sub-beat 2b)**, citando por ruta las líneas ya escritas en las 9 fichas de Pivote; la escena del cráter quedó recortada a reacción contenida y a los 5 finales. Detalle en [[LOG]] §2026-08-13.
- [[Old-Tobin-Hale-Ficha-Expandida-v1]] — personaje de apoyo, sin arco de traición (2026-07-30). Único del elenco político sin agenda oculta; dispara el falso positivo del Reckoning + entrega the Wanderer's Goggles. El extraño que le dejó los Goggles queda deliberadamente sin resolver.

> ⚠️ **Las 4 fichas cortas (`Dagna.md`, `Darro.md`, `Roen.md`, `Valen.md`) están ARCHIVADAS** en `90-Raw/*-ficha-v0-ARCHIVADA.md` (2026-07-29). Contradecían a sus expandidas en hechos centrales — origen y apellido de Dagna, si Darro y Dagna se conocían de antes, si Darro grita o se calla en la traición, el gesto de Roen en el cráter, la cosmología de Valen. **No crear fichas cortas nuevas:** dos archivos por personaje generaron 3 críticos en dos rondas de QA. Una sola fuente viva por personaje.

## 20-State (dónde está el proyecto)

- [[Current-State]] — **punto de entrada de toda sesión**: milestone, objetivo, prioridad, riesgos. Recortado 2 veces el mismo día (2026-07-16 y 2026-07-17, higiene de contexto — vuelve a crecer rápido en sesiones largas de rework visual) — solo lo vigente; el relato histórico completo vive en [[Current-State-Historico]].
- [[Current-State-Historico]] — archivo (NO se auto-carga): relato sesión-por-sesión que antes vivía en Current-State, movido verbatim (2 tandas, 2026-07-16 y 2026-07-17) para no inflar el arranque de sesión.
- [[Task-Board]] — tablero de preproducción: frentes A (producción), B (diseño), C (técnico).
- [[Plan-de-Produccion]] — plan macro A1 ratificado: 5 fases (higiene → link vivo → espina → arco → arte/tuning) con gates de playtest.
- [[Protocolo-de-Playtest]] — los **2 protocolos** que salieron del consejo del 2026-08-13: **A** (test gris del Bond: cápsula, cornisa, 5 min con el botón y 5 sin él) y **B** (sesión completa del slice, con registro separado por eje gameplay/visual/narrativa + recuerdo a 7 días). Incluye guión minuto a minuto, guion del facilitador con redacción literal, disciplina de silencio, hojas de registro, spec del hook de telemetría, y el mapeo de cada pregunta al árbol de fallos de [[ADR-003 Reset de desarrollo y motor]]. **§0 es el criterio de muerte, se firma antes de correr nada** — incluye la regla de que un negativo del test gris NO puede falsear el pilar. **Hook de telemetría implementado el 2026-08-13** (`godot/scripts/telemetry.gd` + `ledge_zone.gd` + `bond_driver.gd`, derivador y test en `godot/tools/`, 50 verificaciones en ALL_PASS); queda pendiente la escena gris.
- [[Lecciones]] — anti-patrones técnicos, entorno Godot, gates QA, tiering de modelos.
- [[PRD-006 Combate mínimo]] — spec Fase 1 ratificada: columna vertebral = Movilidad Realista (rig restringido primero, ventanas de combo = fases biomecánicas); 4 componentes + HitPayload, kit Duelist, 2 enemigos, feel contra la Bible; anti-objetivo: el prototipo 0. **CERRADO en código + playtest (alcances 0–5).**
- [[PRD-007 Dagna aliada + Seismic Springboard T1]] — spec Fase 1 ratificada (2026-07-08): Dagna aliada mínima-real + Springboard T1 (onda + salto en ventana, input Bond=`R`) en el greybox → Gate 1. Reusa PushPull + supersalto PRD-005 + pipeline de personajes. Solo T1; Tether/T2/T3 diferidos. **✅ COMPLETO — alcances 0–4 en código + playtest (2026-07-09).** El Gate 1 (cornisa vía Springboard + `autotest_springboard`) aprobado por el director: **🏁 Fase 1 CERRADA.**
- [[PRD-Fase-C-Ajuste-Facial]] — spec cerrada (2026-07-14): [[QA Loop]] de
  ajuste fino facial post-Fase-C, 75% de fidelidad alcanzado (boca, barba,
  ojos, pómulos, mentón, warpaint); barba quitada del default por veredicto
  directo del director pese al % técnico.
- [[PRD-Rework-Fenotipo-Humano-Cuerpo-Completo]] — spec (2026-07-14): QA
  visual imparcial post-Fase-C reveló ~32% de fidelidad de CUERPO COMPLETO
  (el 75% facial no se sostiene con pelo/torso/manos incluidos); 13 puntos
  priorizados con archivo/línea/valor concreto, ratificados por
  QA↔técnico↔QA antes de tocar código. **Los 13 puntos EJECUTADOS EN CÓDIGO
  (2026-07-14 noche)**: venas cian + arcaneMod, pelo Frontier Crop, torso/
  hombros, manos, warpaint (2 trazos verticales — corrigió un hallazgo
  erróneo del propio PRD sobre el índice 6), boca, nariz, cejas, piel
  (investigado: confirma LUT, no tocado sin Boris), abdomen, columna
  (riesgo alto, gates ANTES/DESPUÉS ALL_PASS). QA completo ALL_PASS. **Nota
  abierta:** la métrica "cabezas" bajó 7.49→7.13 tras la curva dorsal —
  probablemente artefacto de medición AABB sobre cráneo inclinado (ver
  Lecciones), no confirmado como regresión real. **Pendiente: VoBo de
  Boris + nuevo QA visual imparcial contra las láminas para medir el
  nuevo % de fidelidad.**
- [[PRD-Rework-Modelado-Personajes-v2]] — **orden de fases 0→4 APROBADO por
  Boris (2026-07-16), banding LINEAR autorizado para A/B, criterio
  "medición manda" para SHOULDER_X confirmado**: instrucciones ejecutables
  para Sonnet del rework completo de modelado. **Fase 0 EJECUTADA Y CERRADA
  (2026-07-16, mismo día): la premisa "personaje sin tinta" no se sostuvo
  contra el píxel real (zoom ×4 confirmó tinta+banding funcionando) — el
  fix real fue el ángulo de cámara del banco (`tmp_anatomy.gd`, alineado
  con el sol de "dawn", ahora rotado 15°). 5 gates ALL_PASS. Fase 1 arranca
  directo, sin re-baseline obligatorio.** Fase 1 torso en 3 masas +
  cintura escapular (SHOULDER_X solo si la lámina lo pide), Fase 2 manos
  (convergencia + nudillos), Fase 3 pelo (loft ratificado, prohibido 4º
  intento con cajas), Fase 4 boca/warpaint. Cruza [[Principios de Anatomía
  3D]] + [[Catálogo Técnico Godot]] + [[Lecciones]] con anclas de código
  verificadas. **Fase 0 ejecutada y cerrada (2026-07-16): el pipeline de
  tinta funcionaba bien, fix real fue el ángulo de cámara del banco.
  Fase 1 en curso (primera pasada, mismo día): SHOULDER_X confirmado sin
  cambios (biacromial de la lámina coincide con el render actual),
  trapecio agrandado (antes invisible en perfil), cintura con pellizco
  real (antes copiaba el torso exacto), clavícula partida en 2 (curva S),
  acromion agregado + trapecio corrido para solapar el deltoide (Fase 1.3
  completa, verificación honesta: bien en perfil, sutil en frente/3-4).
  **Corrección: Boris detectó el trapecio hipertrofiado ("tres cabezas" en
  espalda) — 3 variantes A/B/C comparadas, eligió B (escala 1.0/0.7/0.55).**
  Gates ALL_PASS. Pendiente: QA imparcial + VoBo de Boris antes de cerrar
  Fase 1.**
- [[PRD-Reescritura-Escultura-Rig-v1]] (`20-State/PRDs/`) — **APROBADO
  (2026-07-17)**: reescritura from-scratch de la escultura de
  `character_rig.gd` por masas contra las 3 láminas (baselines: rostro 35%,
  torso ~40% — techo del tuning confirmado 2 veces), fases R0-R4 con
  contrato duro de API/pivotes/biomech intacto; supersede las Fases 1-2 del
  [[PRD-Rework-Modelado-Personajes-v2]] (sus Fases 3-4 siguen vigentes).
  Backlog Grupo C (07-19) frente 1 CERRADO (2026-07-21): hombro-esfera
  fundido + cintura con pellizco real en frente Y perfil (medido por
  píxel), gates ALL_PASS, VoBo pendiente.
- [[PRD-C6b-Enano-Elfo-v1]] (`20-State/PRDs/`) — **en curso (2026-07-22)**:
  cuerpo+ROM enano/elfo (histórico) AMPLIADO por Boris a incluir catálogo
  racial de peinados + marca cultural (aether élfico, tatuajes/inlays de
  forja enanos). Proporciones (enano 4.49 cabezas / elfo 8.17, objetivos
  4.5/8.0) + geometría nueva de oreja élfica y mandíbula/ceja por raza
  (campo `"face"`) EJECUTADAS y medidas en banco, sin regresión. Oreja de
  elfo REWORK completo ronda 9-10 (2026-07-22): 4 masas compuestas
  (cuerpo+punta+base+hélix), variante Zelda, plan traducido por subagente
  Opus a partir de la spec anatómica de Boris — reemplaza el cono de
  8 rondas previas. QA imparcial (mismo agente, 2 re-invocaciones):
  35-40%→55-60%→75%, sin CRITICAL abierto — la reapertura de la decisión
  "casi horizontal" (oreja ahora con elevación real hacia arriba) fue el
  cambio que destrabó el % final. Gates ALL_PASS. **✅ VoBo de Boris
  recibido, ronda cerrada.** Frente nuevo detectado (sin ejecutar, PRD
  propio pendiente): "nacimiento" de oreja (bug compartido humano/enano —
  esfera pegada sin lóbulo/hélix; el elfo le falta pabellón visible) —
  detalle en [[Current-State]]/[[LOG]]. Sigue pendiente ROM por raza.
- [[PRD-Nacimiento-de-Oreja-v1]] (`20-State/PRDs/`) — **CERRADO (2026-07-22)**: 
  pasos 1-3 CERRADOS con VoBo. Humano 74% (4 rondas QA), enano 70% (2 rondas QA) 
  + helper `_build_ear` factorizado, elfo 78% (2 rondas QA) + pabellón SphereMesh. 
  Transición de nacimiento orgánica en 3 razas, techo de 3 primitivas declarado.
  Anti-objetivo duro: no reabrir la oreja de elfo (75%, con VoBo).
- [[PRD-Catalogo-Peinados-v1]] (`20-State/PRDs/`) — **draft (2026-07-19)**:
  catálogo 6-8 estilos × 2 géneros × 3 razas para el creador de personaje
  (decisión de Boris); técnica única = loft (`_loft`/`_lock` implementados en
  el piloto FASE 3, QA 38% con techo estimado 50-55%: falta separación real
  entre mechones). Orden: ronda de separación del piloto → template femenino
  → producción por lotes → barbas.
- [[Fase5-Cara-Propuesta-DRAFT]] (`20-State/PRDs/`) — **borrador de trabajo,
  NO fusionado al PRD**, pedido por Boris como Fase 5 posterior a la boca:
  rework dirigido de mandíbula/ojos/nariz/mentón/orejas sobre la cara ya
  cerrada en Fase C (75%). Primera pasada de minado había reportado
  erróneamente que el libro no cubre cabeza/cara — Boris señaló los
  capítulos exactos ("3D male Part 01" §10-11 + "Advanced 3D male Part 01 |
  Head, neck, and face", Djordje Nagulov, pp.94-121) y se re-minaron,
  agregados a [[Principios de Anatomía 3D]] → "Cabeza, cuello y cara".
  Único vacío real del libro: proporción/estructura de OREJA (solo mención
  tangencial de animación). Mandíbula/mentón/nariz ya tienen 4-8 rondas de
  ajuste fino estables — recomendación: priorizar ojos/orejas. **Ampliado
  (mismo día): 3 secciones nuevas en [[Principios de Anatomía 3D]] (piernas/
  pies, brazos, piel) + brecha real detectada** — `jaw`/`eyeTilt`/
  `eyeShape` usan un solo rango para las 3 razas pese a que [[Fenotipos y
  Creación de Personaje]] ya ratificó rango racial para esos 3 rasgos (la
  oreja sí lo cumple). Un subagente Fable incorporó la propuesta de sesgo
  racial (§1/§4 del borrador) y una pregunta abierta nueva (#6). **Las 6
  preguntas quedaron RESUELTAS por Boris (2026-07-16, mismo día):** lámina
  de rostro nueva SÍ se genera (brief 8 en [[Briefs de Concept Art]]), fase
  toca solo oreja neutra, sí verificar extremos de slider, las 5 partes
  parejo, sesgo racial fuera (entra con elfo/enano). Falta generar/aprobar
  la lámina antes de medir. Colateral (RESUELTO 2026-07-16, sesión
  paralela): `origins_data.gd` tratada a Mist-Stalker como raza Beast-Folk
  completa pese al canon ya ratificado — reconvertida a Mistbound (variante
  cultural humana), geometría bestial quitada de `character_rig.gd`. Detalle
  en [[Fenotipos y Creación de Personaje]] y [[LOG]].
- [[PRD-Warpaint-Personalizable]] — bug real encontrado y corregido
  (2026-07-14): la "V" geométrica de warpaint se dibujaba para CUALQUIER
  índice >0, tapando los 5 patrones del atlas. Evaluación visual de los 6
  estilos: 3 con buena pinta (Hexbrand, Eye of Ash, Scout Marks) + None,
  3 rotos/débiles (Slash Crimson, Tribal Tide invisible, Jagged Crown)
  pendientes de rework de atlas. UI de elección = Fase 4.
- [[PRD-Geometria-Nueva-Pelo-Torso-Manos-Boca]] — propuesta (2026-07-14,
  esperando ratificación de Boris): tras 18 puntos de ajuste de parámetros
  (32%→49%), el QA imparcial ubica el techo en ~50-55% mientras pelo/
  torso/manos/boca sigan con la MISMA construcción. Observación directa
  (zoom) de ambas láminas por el orquestador — no un QA intermediario —
  con propuesta de masas concreta por área; boca queda con 2 opciones a
  elegir por falta de referencia directa en pose neutra. Nota fuera de
  alcance: las dos láminas dibujan el warpaint distinto (asimétrico en
  cara, bilateral en torso) — decisión pendiente de Boris.
- [[Propuesta-Recursos-de-Modelado]] — **RATIFICADA 2026-07-12**: 5 recursos para subir el techo del pipeline procedural de personajes (triplanar, loft/perfil, gradientes, banding MToon, iteración) + 3 ajustes al plan de rework C6/M10 de la sesión paralela; loft = mini-loop pre-C6b.
- [[ADR-001 Adopción del Vault]] — por qué existe este sistema.
- [[ADR-002 Motor diferido]] — CERRADA: **Godot confirmado** (2026-07-04) con la evidencia de la golden scene. ⚠️ Parcialmente superada por ADR-003.
- [[ADR-003 Reset de desarrollo y motor]] — ✅ **CERRADO, ratificado por el director** (2026-08-10). Hard reset ejecutado: `godot/` eliminado del árbol de trabajo, recuperable en el tag `archive/prototipo`. **Motor GODOT** (ADR-002 vuelve a plena vigencia) · slice = [[Slice of Bond]] recortado a 3 escenas con Dagna, greybox de entorno pero **no** de cuerpo · PC únicamente · alcance de v1 diferido hasta tener el costo real en horas. 3 playtesters registrados (Diego/Santiago/Delmer) con protocolo de sesión. **§Tercera vía:** gauntlet-loop es método de producción, no motor. Insumos: [[Brief para el Consejo — Motor y Fases de Desarrollo]] · transcript del consejo en `90-Raw/council-2026-08-10-motor-y-fases.md`.

## 30-Loops (cómo trabajar)

- [[Comparativa de Motores — Godot vs Unity]] — pros/contras y FODA de los dos motores (pedido del director, 2026-08-12). **No reabre la decisión** — Godot sigue confirmado; existe para sostenerla con los ojos abiertos. Marca qué es medido en el spike, qué es hecho de plataforma y qué es juicio.
- [[Veredicto de Motor y Lectura del Proyecto]] — **opinión del asistente**, pedida por el director (2026-08-12) como insumo para el consejo: ratifica Godot (por instrumentabilidad y licencia, no por capacidad — la comparación técnica dio empate), y lee la solidez y el techo del proyecto sin timeline. Recomendación incómoda: v1 con 3 Pivotes, no 9; y playtest antes que guión. **Pasó por consejo el 2026-08-13** — transcript en `90-Raw/council-2026-08-13-veredicto-motor-y-alcance.md`: Godot congelado, playtest antes que guión 5 de 5, el trío queda como intención pero no como compromiso hasta tener horas/Pivote, y lo primero es el **test gris del Bond** con criterio de muerte escrito antes de correrlo.
- [[Ingest Loop]] — fuente nueva en raw → conocimiento compilado.
- [[Design Loop]] — frente abierto → propuesta → ratificación del director.
- [[Feature Loop]] — spec ratificada → implementación → gates QA → sync.
- [[Playtest Loop]] — montage → tuning → aceptación del director.
- [[Lint Loop]] — salud del vault: contradicciones, huérfanas, status, index.
- [[QA de Canon Loop]] — consistencia de **canon textual**: linter primero
  (`check_canon.py`), subagentes en frío solo para juicio, fixes a la fuente.
  Skill ejecutable: `canon-qa`.
- [[QA Loop]] — subagente QA imparcial mide fidelidad vs. lámina RAW +
  subagente PRD traduce el veredicto a plan ejecutable; itera código↔QA↔PRD
  hasta un % objetivo o el techo real de la técnica. Nace de la Fase C
  (rework facial, 2026-07-14).

## 90-Raw (fuentes inmutables)

- `LLM-WIKI.md` — Karpathy: arquitectura de wiki compilada por LLM.
- `Vault-Driven Development (VDD).md` — framework VDD v1.0.
- `../docs/GDD.md` — **GDD v2.2 congelado** (fuente del ingest #1).
- `concept/` — concept art aprobado (Melancolía Gráfica). 2026-07-04: 5
  fenotipos + keyframes dawn/dusk + trilogía Speck. 07-05: Dagna v1 +
  foliage. 07-07: Fenotipos+Speck, Traición_Dagna, Seismic Springboard,
  El primer viso de la muda. **07-08: 4 acoplamientos (Weaver's Net /
  Skyhook / Arcane Ballistics / Mobile Foundry) + 4 beats narrativos
  (El Último Vínculo, La traición ejecutada, Final 1 sacrificio
  silencioso, Final 4 aether renacido).**
- `reviews/` — reviews de arte del director, verbatim (checklist de
  aceptación en [[Task-Board]]): **Character-Blockout-Review-v0.1**
  (cuerpo humano, 2026-07-10) · **Character-Head-Review v0.2–v0.5**
  (cabeza/busto, rondas M9/M10, 2026-07-10).
- `research/Plugin-Evaluation-2026-07-11.md` — evaluación de 13 plugins
  Godot + Chickensoft + research cabello/facial: Dialogue Manager =
  adoptar en Fase 2; shaders minables de HTerrain/Scatter/godot-vrm(MToon)
  para Fase 2/4; AMSG = referencia de lógica para C2/C4; semillas de
  expresiones faciales, spike `Decal` y vista-esqueleto de debug.
  **4ª ronda (2026-07-16):** skill "Godot-Claude-Skills" (GdUnit4 +
  PlayGodot) — PlayGodot descartado (exige compilar fork custom del
  motor, Beckett ya cubre lo mismo sin eso); GdUnit4 no se adopta
  completo, solo un spike puntual de 30 min sobre el problema de
  autoloads en headless.
  **5ª ronda (2026-07-16):** "Godot AI Builder" (HubDev-AI) descartado
  como framework completo (sidecar Node.js, exige editor abierto, instala
  addons solo, compite con el SCHEMA/Vault); de sus 9 skills evaluadas la
  mayoría asume Godot **2D** (`CharacterBody2D`/`move_and_slide`) — choque
  de dimensión con el proyecto 100% 3D analítico, no solo de estilo.
  Único ítem portable: Audio Manager Pattern de `godot-effects`.
- `research/quality-benchmarks/` — capturas EXTERNAS de calidad de
  render (no concept art canon, no confundir con `concept/`): 3 PNG del
  addon godot-vrm (avatar VRM "AliciaSolid"), aportados por el director
  como benchmark de pulido. Estilo anime = anti-referencia del [[Art
  Bible]]; lecciones transferibles extraídas en el doc de arriba.
  **Ampliada 2026-07-14 (aporte del director):** `link-01/02/03.jpg` +
  `zelda.jpg` (Link/Zelda de BotW/TotK) — fenotipo BASE recomendado para
  cuando arranque el modelado del elfo (Fase C6b/C6c): resultado YA
  logrado dentro de un videojuego real (no solo still de concept), norte
  directo para ojos almendra con esclerótica visible, nariz fina, boca
  seria de línea simple. `sable-01..05.{webp,jpg}` y
  `dungeons-of-hinterberg-01..03.jpg` — referencia visual directa de los
  dos pilares del norte artístico ([[Art Bible]] "Melancolía Gráfica":
  Sable × Hinterberg), complementa el texto de la Art Bible con capturas
  reales del juego.
