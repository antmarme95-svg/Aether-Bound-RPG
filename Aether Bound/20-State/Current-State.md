---
status: vivo
updated: 2026-07-17
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

- **➡️ ARRANQUE DE LA PRÓXIMA SESIÓN — REESCRITURA DE LA ESCULTURA DEL RIG
  en curso, Fase R1 (cabeza/rostro) es lo siguiente.** Vehículo:
  [[PRD-Reescritura-Escultura-Rig-v1]] (aprobado por Boris 2026-07-17).
  Por qué: dos QA imparciales consecutivos confirmaron el techo del ajuste
  de parámetros — **rostro 35%** (vs [[fenotipo-humano-rostro-v1]], lámina
  nueva 2026-07-16: "blando/redondeado tipo bola con calcomanías, no por
  masas") y **torso ~40%**. Se reescribe la construcción de meshes POR
  MASAS conservando intacto el andamiaje (API de 12 funciones, pivotes,
  metas, nombres, materiales, contrato outfit/signature/tests — el
  contrato duro completo está en el PRD).
  1. **R0 CERRADA (2026-07-17):** cámara de perfil exonerada (diagnóstico
     DIAG_AXIS con lanzas de eje: 90° real, sin yaw en la cadena — el
     "sobre-rotado" que reportó el QA era la geometría sin relieve facial);
     3 close-ups institucionalizados en `tmp_anatomy.gd`
     (`anatomy_closeup_chin/neckshoulder/chin_front.png`); baseline A/B en
     `90-Raw/reviews/baseline-pre-reescritura-rig-2026-07-17/`.
  2. **R1 EN PAUSA — 52% tras 2 rondas de QA (35→40→52), decisión de
     Boris pendiente.** La estructura nueva ya está en el código (gates
     ALL_PASS, commiteada): mandíbula de cajas con silueta angular real,
     cráneo bajo retraído, boca al ras, ojos a mitad de cara. El QA
     declaró techo parcial: ~60% máximo con primitivas puras; para ≥70%
     hace falta técnica nueva para labios (decal/textura/máscara de
     tinta — SIN borde perimetral) y aceptar o resolver el mentón visto
     desde abajo. Alcanzable sin técnica nueva: pómulo derecho (el
     izquierdo ya fundió), outline de nariz, escalón de silueta, mirada
     3/4. **Boris decide la ruta:** (a) cerrar el margen alcanzable y
     pasar a R2, (b) atacar la técnica de labios/tinta primero, o (c)
     otra. Detalle en [[LOG]].
  3. Luego R2 (torso 3 masas + cintura escapular), R3 (extremidades/
     manos), R4 (integración + batería completa). Cada fase: gates + QA
     imparcial (máx 2 rondas sin reportar) + VoBo.
  4. **Metodología (ver [[Lecciones]]):** marcar con COLOR para aislar
     piezas; 4 vistas del turnaround + close-ups; zoom antes de cerrar
     hallazgos; solape en los 3 ejes entre piezas de padres distintos;
     esfera nunca da borde anguloso (caja); overlap real ≤30%.
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
