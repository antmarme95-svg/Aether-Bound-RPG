# Index — catálogo del Vault

> Una línea por página. Leer primero en toda consulta. Mantenido por Claude
> en cada operación ([[SCHEMA]]).

## Raíz

- [[SCHEMA]] — el modelo de trabajo: capas, plantillas, contratos, regla de oro.
- [[LOG]] — bitácora append-only de operaciones.

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
- [[Fenotipos y Creación de Personaje]] — silueta canónica por raza + slots fijos/raciales/libres (propuesto).
- [[Briefs de Concept Art]] — prompts Nano Banana 2 por fenotipo + notas de pipeline (propuesto).
- [[Slice of Bond]] — vertical slice ratificado: Humano Duelist × Dagna; 4 escenas (Nido → Cinder Ascent → eco Sunken Archive → coda Bond vacío), 45–60 min.
- [[Game Feel Bible]] — §6.3 ratificada: hit-stop por masa, shake modelo trauma, cámara libre + soft-assist, feel del Springboard.
- [[Dagna]] — ficha completa del Pivote del slice: bio, reclutamiento, tiers del Springboard, quiebre, la Primera Cuña (propuesto).

## 20-State (dónde está el proyecto)

- [[Current-State]] — **punto de entrada de toda sesión**: milestone, objetivo, prioridad, riesgos.
- [[Task-Board]] — tablero de preproducción: frentes A (producción), B (diseño), C (técnico).
- [[Plan-de-Produccion]] — plan macro A1 ratificado: 5 fases (higiene → link vivo → espina → arco → arte/tuning) con gates de playtest.
- [[Lecciones]] — anti-patrones técnicos, entorno Godot, gates QA, tiering de modelos.
- [[PRD-006 Combate mínimo]] — spec Fase 1 ratificada: columna vertebral = Movilidad Realista (rig restringido primero, ventanas de combo = fases biomecánicas); 4 componentes + HitPayload, kit Duelist, 2 enemigos, feel contra la Bible; anti-objetivo: el prototipo 0.
- [[ADR-001 Adopción del Vault]] — por qué existe este sistema.
- [[ADR-002 Motor diferido]] — CERRADA: **Godot confirmado** (2026-07-04) con la evidencia de la golden scene.

## 30-Loops (cómo trabajar)

- [[Ingest Loop]] — fuente nueva en raw → conocimiento compilado.
- [[Design Loop]] — frente abierto → propuesta → ratificación del director.
- [[Feature Loop]] — spec ratificada → implementación → gates QA → sync.
- [[Playtest Loop]] — montage → tuning → aceptación del director.
- [[Lint Loop]] — salud del vault: contradicciones, huérfanas, status, index.

## 90-Raw (fuentes inmutables)

- `LLM-WIKI.md` — Karpathy: arquitectura de wiki compilada por LLM.
- `Vault-Driven Development (VDD).md` — framework VDD v1.0.
- `../docs/GDD.md` — **GDD v2.2 congelado** (fuente del ingest #1).
- `concept/` — láminas de concept art aprobadas (5 fenotipos, 2026-07-04).
