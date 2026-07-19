---
status: vivo
updated: 2026-07-19
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

- **➡️ ARRANQUE DE LA PRÓXIMA SESIÓN — sesión 2026-07-19 ejecutó: mini-
  ronda de quiebres de mandíbula ✅, GRUPO C ✅, piloto de loft (FASE 3
  pelo) ✅-detenido-en-regla. Queda del día:**
  1. **VoBo de Boris pendiente sobre el FULL REWORK del cabello**
     (frontier crop reconstruido con la jerarquía de 3 pasadas del
     libro; QA imparcial **52%**, subió de 38% del piloto — defecto de
     "dientes" ELIMINADO, sin cuenco trasero, nuca corta con piel,
     color castaño correcto). Es el checkpoint de "cabello decente" que
     Boris pidió ANTES de la última ronda de cara. Set fresco en
     `godot/test_out/` (anatomy_face*.png). Residual conocido (HIGH,
     refinable): el faceting duro de las tiras lee "placas"; falta
     taper en la línea del pelo (techo estimado 65-75%). Siguiente si
     Boris aprueba: última ronda de AJUSTES DE CARA (VoBo de mandíbula
     era TEMPORAL, se cierra con el pelo puesto).
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
  - **Frentes siguientes** (orden a gusto de Boris): ronda de
    separación del pelo + catálogo ([[PRD-Catalogo-Peinados-v1]]);
    Fase 4b (warpaint) del [[PRD-Rework-Modelado-Personajes-v2]];
    ataque a los hallazgos del grupo C (boca/mentón-perfil/hombro/
    cintura); C6b (enano/elfo reales); C4 (pies IK / ROM).
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
  gráficos en curso desde la Fase 1; detalle histórico completo en
  [[Current-State-Historico]] y [[LOG]]). Playtest permanente:
  `Start-Playtest-Greybox.bat`. Gates permanentes: `autotest_combat.gd`,
  `autotest_springboard.gd`.
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

**Historial de estados:** ver [[LOG]] y [[Current-State-Historico]].
