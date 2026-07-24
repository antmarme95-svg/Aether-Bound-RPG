---
status: vivo
updated: 2026-07-24
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

- **✅ ÚLTIMA SESIÓN (2026-07-24) — Layer político-institucional COMPLETO:**
  3 reinos + Triune Council supra-racial (3 asientos, embajadores
  permanentes designados por cada Corona) + origen social de los 12
  personajes narrativos (9 Pivotes + Roen/Valen/Darro fijos) — ver
  [[Estructura Política]]. Cataclismo recalibrado de 100 a **~550 años
  atrás** (el número viejo era incompatible con la longevidad élfica ya
  establecida en las fichas de Pivotes). Worldbuilding narrativo completo:
  geografía de los 3 reinos + ciudades secundarias, The Wilds (45+ POI),
  estructura política de las 3 razas + Triune Council. Todo listo como
  fuente para escribir guión. Relato completo de la sesión (retcon,
  geografía, política, Council) en [[Current-State-Historico]] y [[LOG]].
  **Siguiente frente:** guión y diálogos por actos.

- **✅ SESIÓN 2026-07-24 (parte 7) — BRIEFS DE CONCEPT ART: GOBERNANTES +
  TRIUNE COUNCIL:** 6 prompts nuevos en [[Briefs de Concept Art]] §9, para
  generar con **Nano Banana 2** (Boris perdió acceso a NB Pro): Reina
  Ithessa, Rey Borran, Regente Edrick Ashcombe, Embajador Cyrion, Embajador
  Kadrun, Consejera Merrit Vance. Cada uno usa el fenotipo racial ya
  ratificado como ancla + regalía/personalidad específica del cargo (Reina/
  Rey regios, Edrick deliberadamente menos regio — cargo precario, los 3
  embajadores diplomáticos no guerreros). **Pendiente:** generar y evaluar
  contra los 5 ejes del [[Art Bible]] cuando Boris corra los prompts.

- **Speck — narrativa + diseño visual 100% COMPLETO** (2026-07-23):
  redireccionamiento mascota→último Warden cristalino cerrado; 4 Finales
  concept art generados y ratificados (95-100%); Golden Scene keyframes
  completados. Detalle completo en [[Current-State-Historico]].

- **Anatomía/rework de personajes (C6):** oreja de elfo cerrada en 75% de
  fidelidad (VoBo de Boris, 2026-07-22); nacimiento de oreja (3 razas)
  cerrado 74/70/78%; proporciones enano/elfo + mandíbula/ceja por raza
  ejecutadas con gates ALL_PASS. Relato completo (rondas de QA, decisiones
  de estilo, metodología) en [[Current-State-Historico]] y [[LOG]].
  **Queda pendiente:** ROM por raza (C4), pies sin IK.

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
  `check_vault.py` corriendo y verificado — arranque de sesión medido y
  verde en cada checkpoint. Detalle completo en [[LOG]] y
  `../VAULT-STARTER.md` v2.

## Pendientes narrativos / lore

**GUIÓN / NARRATIVA ESTRUCTURA — GAPS CRÍTICOS (próximo frente, todo el
worldbuilding de soporte ya está listo):**
- **Guión completo por actos** — GDD §1.2 tiene estructura dramática pero NO hay diálogos/escenas
- **Voz narrativa definida** — ¿Narrador? ¿First person? ¿Silent protagonist? ¿Cuán verbose vs. environmental?
- **Momentos de Persona de Speck** (~7 escenas narrativas sin UI) — mencionadas pero no escritas
- **Diálogos de Bautizo (Darro nombrando Speck)** — narrativa locked pero escena no scripted

**Worldbuilding — Cultura/Lore (pendiente):**
- **Culturas por raza** — Aether-Born/Iron-Blooded/Restless existen narrativamente pero NO tienen ceremonia/idioma/costumbre documentadas
- **Lore de civilización Warden perdida** — menciona en [[El Mundo y la Muda]] pero NO hay historia pre-caída detallada
- **Regla de los Tres Reinos movilizan ejércitos** — mencionada en clímax pero estrategia/alianzas no mapeadas

**Locations — fichas narrativas incompletas:**
- **The First Wound** — cráter clímax, cementerio God-Cores; existe keyframe visual (God-Core Night) pero sin descripción física/ficha lore completa
- **Sunken Archive** — recupera Fragmento; sin ficha ni descripción física
- **The Wilds interior/ecosystem** — zona de inicio pero descripción ecosistema no mapeada

**Finales — scripting incompleto:**
- **Los 4 Finales — diálogos/cinemática** — existen visuals pero NO scripted el "cómo ves cada final" (qué dice el jugador/Quinteto?)
- **Estado post-final jugable** — hay créditos pero post-game state no definido
- **Variantes C3 vivo/muerto en Finales 2-3** — mencionadas pero no impacto narrativo mapeado

**POSPUESTO (Post-Lore):**
- ❌ Trailer formal (requiere guión sólido primero)
- ❌ Cutscenes cinemáticas (requiere script + dirección narrativa)
- ❌ Banda sonora tema principal (después de alpha gameplay)

**Concept art — pendiente de evaluación:**
- Videos Higgsfield sin evaluar (ffmpeg setup incompleto): `Arcane Ballistics.mp4`, `Weaver's Net.mp4`, `Seismic Springboard (2).mp4`, `Speck sneak peek.mp4`
- Fast travel diegético (barcazas Driftmarket, túneles enanos) sin diseñar

**Historial completo:** [[LOG]] y [[Current-State-Historico]].
