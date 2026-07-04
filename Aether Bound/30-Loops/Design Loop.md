---
status: ratificado
updated: 2026-07-04
---

# Design Loop

Formaliza el proceso con el que se cerró el GDD v2 (propuesta → decisión del
director → sellado). Claude = narrador/diseñador experto; el director decide.

- **Objetivo:** resolver un frente de diseño abierto (los ❓ del
  [[Task-Board]] frente B).
- **Entrada:** un ítem de diseño elegido por el director, o una contradicción
  del Ingest/Lint Loop.
- **Fases:**
  1. Leer [[Current-State]] + las páginas Knowledge afectadas + fuentes raw
     relevantes.
  2. Proponer (opciones con recomendación, no encuestas exhaustivas); iterar
     en sesión con el director.
  3. Escribir el resultado en las páginas afectadas con status `propuesto`.
  4. **Ratificación explícita del director** → status `ratificado`.
     Sin ratificación, nada `ratificado` se toca.
  5. Propagar a toda página enlazada afectada (coherencia).
- **Validación:** ninguna página `ratificado` contradice otra; el ítem se
  marca ✅ en el Task-Board.
- **Artefactos:** páginas Knowledge, [[Task-Board]], [[LOG]] (`design`),
  ADR en `20-State/Decisiones/` si la decisión es estructural.
- **Salida:** frente cerrado; siguiente prioridad visible en
  [[Current-State]].
