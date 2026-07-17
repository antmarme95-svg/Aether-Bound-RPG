---
status: vivo
updated: 2026-07-17
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

- **➡️ ARRANQUE DE LA PRÓXIMA SESIÓN — Fase 1 (torso/hombros) EN CURSO, no
  cerrada.** Vehículo: [[PRD-Rework-Modelado-Personajes-v2]]. Fase 0, Fase
  1.1-1.3, y el CRITICAL 2 (cuello de camisa de cartón) ya ejecutados y
  verificados (gates ALL_PASS + QA imparcial CERRADO). Antes de tocar más
  código, leer esto:
  1. **Lo bueno, ya confirmado — no reabrir sin evidencia nueva:** trapecio
     sin hipertrofia, proporción global (~7.5 cabezas) correcta,
     `SHOULDER_X=0.21` confirmado contra la lámina, pipeline de tinta fiel
     al estilo, Y (2026-07-17) **la fusión mentón→mandíbula→cuello** —
     `chin_boss` + `chin_bridge` en `character_rig.gd` (~línea 1018-1031),
     verificada por QA imparcial en las 4 vistas del turnaround, con zoom.
  2. **CRITICAL abierto, SIN resolver:** hallazgo #1 — "torso lee como
     peto/cartón" (contorno de tinta interior completo), del QA de
     2026-07-16. Sin investigar todavía (la sesión del 17 se enfocó en el
     CRITICAL #2, ya cerrado).
  3. **HIGH, no atacados todavía:** hombros como esferas infladas en vista
     trasera (contradice "narrow sloped shoulders" de la lámina); el
     trapecio ya arreglado ahora es ILEGIBLE en el sentido opuesto (sin
     pendiente cuello→hombro, transición abrupta); perfil sin profundidad
     de pecho ni curva lumbar (torso de lado = tabla plana).
  4. **MEDIUM, no atacados todavía:** cintura se lee por una línea de tinta
     dibujada, no por la silueta real; clavícula como 2 trazos flotantes
     desconectados.
  5. **Hallazgos menores nuevos (2026-07-17, del QA que cerró el CRITICAL
     #2, no bloquean nada):** mentón/mandíbula siguen "blandos" sin masas
     angulares definidas; seam visible en la base del cuello contra el
     trapecio/hombro (vistas 3/4 y perfil); marca blanca tipo corchete en
     el cuello, posible artefacto de UV — ninguno investigado todavía.
  6. **Metodología a seguir (ver [[Lecciones]] para el detalle):** para
     encontrar qué pieza causa un defecto, marcar con COLOR (no ocultar).
     Revisar overlaps en las 4 vistas del turnaround, no solo frente.
     **Nuevo (2026-07-17): antes de dar un hallazgo geométrico por
     cerrado, hacer zoom (recortar+ampliar) a la unión exacta** — el
     render completo a 1280×720 puede camuflar un hueco real que un QA
     (o un recorte ampliado) sí detecta; y verificar solape en los 3 ejes
     entre piezas de padres distintos (`chin_boss`↔`neck` se solapaban en
     Y pero no en Z).
  Detalle completo en [[LOG]] y [[PRD-Rework-Modelado-Personajes-v2]]
  Fase 1.
- **➕ FASE 5 (cara: mandíbula/ojos/nariz/mentón/orejas) — borrador
  completo y con VoBo de Boris en sus 6 preguntas abiertas**, pero NO
  fusionada al PRD oficial. Ver [[Fase5-Cara-Propuesta-DRAFT]]
  (`20-State/PRDs/`). **Único paso pendiente antes de arrancar su
  medición: generar y aprobar la lámina de rostro** (brief 8 en
  [[Briefs de Concept Art]]) contra los 5 ejes del [[Art Bible]] — todavía
  no se generó ninguna imagen. Esta fase va DESPUÉS de la Fase 4 (boca) en
  el orden del PRD — no es urgente mientras Fase 1 siga abierta.
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
