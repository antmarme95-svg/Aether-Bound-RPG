---
status: vivo
updated: 2026-07-19
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

- **➡️ ARRANQUE DE LA PRÓXIMA SESIÓN — la REESCRITURA DE LA ESCULTURA
  está COMPLETA (R0-R4 + regla de tinta + sprints A y B, 2026-07-17);
  quedan exactamente 2 cosas:**
  1. **VoBo de Boris sobre capturas** — PARCIAL 2026-07-19: cara "90%
     bien"; los quiebres azules que circuló (junturas de mandíbula/
     mentón) se resolvieron en mini-ronda dirigida de 2 rondas (ver
     [[LOG]] 07-19; gates ALL_PASS). Set FRESCO regenerado en
     `godot/test_out/`. Falta su VoBo final sobre las capturas nuevas.
     Lo único que NO le convence: el CABELLO → decidió piloto de loft
     (FASE 3 del PRD) hoy + catálogo 6-8 estilos/género/raza después.
  2. **Grupo C del sprint: re-medición con juez canónico ÚNICO** (un
     prompt+hilo por región) — ESPERAR renovación del presupuesto de
     subagentes (se agotó el mensual el 07-17). El % de un juez solo
     compara dentro de su propio hilo (varianza entre jueces ±10-17
     pts, ver [[Lecciones]]).
  - **Fidelidad al cierre:** manos 70% (objetivo cumplido); rostro
    48-57% y torso 38-55% MEDIDOS ANTES de los sprints A/B (baselines
    35%/40%) — el número real post-sprint lo dará C.
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
  - **Tras VoBo + C, frentes siguientes** (orden a gusto de Boris):
    Fases 3 (pelo/loft) y 4b (warpaint) del
    [[PRD-Rework-Modelado-Personajes-v2]]; C6b (enano/elfo reales); C4
    (pies IK / ROM).
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
