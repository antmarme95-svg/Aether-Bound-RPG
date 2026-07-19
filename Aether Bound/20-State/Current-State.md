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
  2. **R1 CERRADA (2026-07-17) — 57% final (35→40→52→57), techo de
     primitivas ~60% alcanzado, VoBo de ruta de Boris.** Mandíbula de
     cajas con silueta angular, cráneo bajo retraído, boca al ras, ojos
     a mitad de cara con convergencia, pómulos fundidos por rampa. La
     brecha al 70% vive en 3 límites de técnica aceptados (labios sin
     borde perimetral, máscara de tinta selectiva, bisel del bloque
     mandibular) — lista residual completa en
     [[PRD-Reescritura-Escultura-Rig-v1]], se ataca como recurso nuevo
     DESPUÉS de la reescritura, no ahora.
  3. **R2 con escultura nueva commiteada** (trapecio-rampa, deltoide
     gota, clavículas retiradas, masas de pecho/espalda/abdomen, cintura
     sin escalón; su hilo de QA midió 40→45→55).
  3b. **REGLA DE TINTA ADOPTADA (2026-07-17, VoBo de Boris con A/B):**
     `melancolia_post.gdshader` `edge_threshold` 0.30→1.00 — murieron
     las costuras interiores entre masas (el techo común de R1 y R2);
     silueta, pliegues hondos y follaje intactos. Ver [[Lecciones]].
  3c. **⚠️ Lección de medición (leer antes de citar cualquier %):** al
     expirar los hilos de QA, jueces frescos midieron rostro 48% y torso
     38% (vs 57%/55% de los hilos de fase), con veredictos opuestos en
     la espalda. El % solo es comparable dentro del mismo hilo de
     agente; estado honesto: **R1 rostro 48-57%, R2 torso 38-55%** —
     ambos muy por encima de sus baselines (35%/40%), ambos abajo del
     70%. Los insumos CRITICAL/HIGH consolidados de los 4 QA están en
     [[PRD-Reescritura-Escultura-Rig-v1]]; los más accionables para la
     próxima ronda de escultura: extremos del hombro (escalones trap/
     deltoide/brazo apilados, visibles de espalda), tercio inferior de
     la cara (mentón aún profundo, boca-píldora por contraste de
     MATERIAL — ya no de tinta), unión pec↔deltoide.
  4. **R3 CERRADA: manos 45→70% (objetivo CUMPLIDO), extremidades 60→68%
     (techo de primitivas).**
  5. **R4 CERRADA (2026-07-17): LA REESCRITURA ESTÁ COMPLETA.** Batería
     entera ALL_PASS; orígenes/outfit/Dagna/arcano verificados en pixel
     sobre el rig nuevo; bug de escalado de masas nuevas con el build
     arreglado (reparentadas a torso/waist). **Lo que sigue: SPRINT DE
     AJUSTES (pedido de Boris)** — backlog consolidado y priorizado en
     [[PRD-Reescritura-Escultura-Rig-v1]] (sección BACKLOG DEL SPRINT):
     grupo A = calibración de primitivas (anillo de cuello aetherborn,
     panza weight_max, cintura escapular sin escalar, hombros de
     espalda, LOWs de manos/cara), grupo B = bolsa bisel/malla (labios
     decal, bisel mandibular, oreja con hélix, anillos de
     articulaciones), grupo C = re-medición con juez canónico único.
     Falta el VoBo de Boris sobre capturas (cierre real del loop).
  6. **SPRINT GRUPO A COMPLETO (2026-07-17, 9/9):** A1 anillo aetherborn
     ✓, A2 panza weight_max ✓, A3 sin cambio (por diseño) ✓, A4 espalda
     pendiente única ✓, A5 cintura ~77% ✓, A6 streaks/divot ✓, A7 LOWs
     de manos ✓, A8 arbitrado por Boris (párpado pesado + mentón
     aligerado) ✓, A9 doc tmp_dagna ✓.
  7. **SPRINT GRUPO B COMPLETO (2026-07-17):** B1 labios sin frontera de
     material (tono piel oscurecida, la comisura lee) ✓, B2 chaflán del
     mentón + goníaco redondeado ✓, B3 oreja con hélix (toro — adiós
     óvalo-decal de perfil) ✓, B4 rodilla sin repisa + gemelo suave ✓.
     Los anillos de codo/hombro quedan como ESTILO ACEPTADO salvo veto
     de Boris. **Queda solo grupo C** (re-medición con juez canónico
     único — esperar renovación del presupuesto de subagentes) y el VoBo
     final de Boris sobre capturas.
  5. **Metodología (ver [[Lecciones]]):** marcar con COLOR para aislar
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
