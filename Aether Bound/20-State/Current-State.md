---
status: vivo
updated: 2026-07-20
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

- **➡️ ARRANQUE DE LA PRÓXIMA SESIÓN — sesión 2026-07-19 ejecutó: mini-
  ronda de quiebres de mandíbula ✅, GRUPO C ✅, piloto de loft (FASE 3
  pelo) ✅-detenido-en-regla. Queda del día:**
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
- **SCHEMA v1.1 (2026-07-20):** dieta de arranque fusionada desde la skill
  `project-context` — auditoría de tokens en `Aether Bound/scripts/
  check_vault.py` (bloqueada hoy: sin Python real instalado, ver
  [[Lecciones]]). Línea base a mano: ~1,640 tokens de arranque, 🟢 VERDE.
  Detalle completo en [[LOG]] y `../VAULT-STARTER.md` v2.

**Historial de estados:** ver [[LOG]] y [[Current-State-Historico]].
