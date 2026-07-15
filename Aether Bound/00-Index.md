# Index — catálogo del Vault

> Una línea por página. Leer primero en toda consulta. Mantenido por Claude
> en cada operación ([[SCHEMA]]).

## Raíz

- [[SCHEMA]] — el modelo de trabajo: capas, plantillas, contratos, regla de oro.
- [[LOG]] — bitácora append-only de operaciones.
- `../VAULT-STARTER.md` — **exportable**: el método completo (VDD ×
  LLM-WIKI + nuestra rutina de cierre §7 + consejos de campo) destilado en
  un archivo único para que cualquier persona arranque su propio Vault
  adjuntándolo a su Claude Code. Generado 2026-07-13.

## 10-Knowledge (diseño del juego, compilado del GDD v2.2)

- [[Visión y Pilares]] — la frase de visión y los 4 filtros de toda decisión.
- [[El Mundo y la Muda]] — lore público vs. la revelación: God-Cores = cadáveres de Wardens; la Muda inconclusa.
- [[Estructura Dramática]] — 3 actos + nudo del Fragmento + traición por convicción + gancho de 3 polos.
- [[Las Tres Razas]] — Elfos/Enanos/Humanos: temperamento, hábitat, por qué nadie quiere a Speck.
- [[La Rueda]] — mapa macro: cubo (Wilds), aro (3 reinos), 3 arterias co-op, Driftmarket, Sunken Archive, First Wound.
- [[Speck]] — la última Warden: 3 estadios, giro Grogu, bautizo, Momentos de Persona.
- [[El Quinteto]] — jugador + C1 afín + C2 opuesto + C3 pivote + C4 chispa (+Speck); matchmaking orgánico.
- [[Los 9 Pivotes]] — matriz y fichas v0: Maren/Torgan/Iven/Sereth/Bram/Lyris/Dagna/Nyael/Vekka.
- [[Acoplamientos]] — roles de co-dependencia sin ultimates; parejas fundadoras; tutorial geográfico.
- [[Los 9 Links del Pivote]] — Skipping Stone…Warforging: qué hace cada uno y qué duele al perderlo.
- [[Bond y el Bond Vacío]] — el único botón de vínculo; el beat del miembro fantasma; la Link Cam.
- [[Matriz Raza x Rol]] — las 9 celdas de arquetipo mecánico.
- [[Locomoción]] — FSM conservada + mantling + escalada zonificada + conservación de impulso.
- [[Combate]] — 4 componentes + HitPayload; marcas como datos; parry racial; verbos 3×3.
- [[Movilidad Realista]] — mandato §4.3: constraints + IK + ROM por raza; el esqueleto manda.
- [[Progresión y Contrato]] — el Contrato que te persigue; loop principal.
- [[Los 4 Finales]] — Guided Molt / Long Winter / Conqueror's Clause / Warden's Choice + ecos Bond.
- [[The Tether]] — Contract Standing vs. Bond por compañero (T1–T3) + Momentos de Persona.
- [[Art Bible]] — "Melancolía Gráfica": Sable×BotW×Hinterberg, regla espacial, pipeline 4 capas.
- [[Nomenclatura]] — AETHER BOUND y todos los nombres canónicos sellados.
- [[Inventario del Prototipo]] — qué se conserva, re-usa o reemplaza del build Godot.
- [[Fenotipos y Creación de Personaje]] — silueta canónica por raza + slots fijos/raciales/libres.
- [[Briefs de Concept Art]] — prompts Nano Banana 2 (fenotipos/keyframes/Speck/foliage/Dagna) + notas de pipeline; ratificada 2026-07-08 (sus outputs ya son canon). Página viva: se añaden los 8 pivotes restantes.
- [[Slice of Bond]] — vertical slice ratificado: Humano Duelist × Dagna; 4 escenas (Nido → Cinder Ascent → eco Sunken Archive → coda Bond vacío), 45–60 min.
- [[Game Feel Bible]] — §6.3 ratificada: hit-stop por masa, shake modelo trauma, cámara libre + soft-assist, feel del Springboard.
- [[Benchmark Biomecánico]] — v1 Sable/Hinterberg: el benchmark es timing y pose (animar en 2s), no más realismo. v2 AAA (B14): motion matching descartado; camino validado = Sifu handkey trifásico + foot IK de HZD. **RATIFICADO (2026-07-06)**. v3 (B15): mediciones frame a frame de los clips del director — hit-stop 2f/3f global, combo sincopado, contacto ≈60% del ciclo (valida 0.58), Sable con raíz continua = canon A/B validado 1:1. §B15d: nuestra build medida con el mismo método (AS IS vs TO BE) — feedback de combate hoy 100% cromático (flash/tinte), 0% corporal/temporal; locomoción ya alineada con Sable; running jump 42 f = analítica del código pero sin pose (canal airborne pendiente en C4). §B15e: playtest dirigido del kit Duelist — 8 tintes de daño en 11.4 s tapan la lectura (fix adelantado), jugador sin reacción de pose, trade-fest; el veredicto del director ("no es Sifu") queda medido. §B15f–B15g: alcance 3 verificado en juego — los 2 asesinos de B15e resueltos (vignette de bordes + reacción corporal), par light/heavy legible por silueta; hallazgo nuevo: presión enemiga baja (tuning); lo que faltaba contra Sifu era temporal — cerrado por el alcance 4 ✅ (2026-07-07, pendiente de playtest).
- [[Dagna]] — ficha completa del Pivote del slice: bio, reclutamiento, tiers del Springboard, quiebre, la Primera Cuña.

## 20-State (dónde está el proyecto)

- [[Current-State]] — **punto de entrada de toda sesión**: milestone, objetivo, prioridad, riesgos.
- [[Task-Board]] — tablero de preproducción: frentes A (producción), B (diseño), C (técnico).
- [[Plan-de-Produccion]] — plan macro A1 ratificado: 5 fases (higiene → link vivo → espina → arco → arte/tuning) con gates de playtest.
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
- [[ADR-002 Motor diferido]] — CERRADA: **Godot confirmado** (2026-07-04) con la evidencia de la golden scene.

## 30-Loops (cómo trabajar)

- [[Ingest Loop]] — fuente nueva en raw → conocimiento compilado.
- [[Design Loop]] — frente abierto → propuesta → ratificación del director.
- [[Feature Loop]] — spec ratificada → implementación → gates QA → sync.
- [[Playtest Loop]] — montage → tuning → aceptación del director.
- [[Lint Loop]] — salud del vault: contradicciones, huérfanas, status, index.
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
