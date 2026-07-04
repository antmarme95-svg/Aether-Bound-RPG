---
status: ratificado
updated: 2026-07-04
---

# Feature Loop

Formaliza el protocolo de sprints con el que se construyó el prototipo
(PRD-001…005). Principios VDD: mínimo cambio, evidencia, sincronización.

- **Objetivo:** implementar una feature técnica (frente C del [[Task-Board]]).
- **Entrada:** tarea ⬜ del Task-Board con criterios de aceptación; las
  páginas Knowledge que la especifican en `ratificado`.
- **Fases:**
  1. Leer [[Current-State]], [[Lecciones]] (obligatorio: entorno, tiering,
     anti-patrones) y las páginas de spec.
  2. Planear: impacto, riesgos, archivos.
  3. Implementar en branch `feat/*` (cambios pequeños, reversibles).
  4. **Gates QA:** test_core + tests específicos + autotests visuales cuando
     aplique + gate de FPS (≥60, corrida fría).
  5. Actualizar: [[Task-Board]] (status + QA result + next step),
     [[Current-State]], [[LOG]] (`feature`), Lecciones si algo dolió.
  6. Checkpoint (regla de oro): flush de State + memoria **antes** de la
     siguiente tarea.
- **Validación:** gates verdes; ningún doc desincronizado del código.
- **Salida:** tarea ✅; PR a master cuando el paquete esté completo.
- **Siguiente loop recomendado:** Playtest Loop si la feature es de feel.
