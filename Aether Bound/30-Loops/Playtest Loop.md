---
status: ratificado
updated: 2026-07-04
---

# Playtest Loop

Formaliza el método montage+playtest que tuneó la locomoción (L5/L6) hasta la
aceptación del director.

- **Objetivo:** llevar una mecánica de "funciona" a "se siente bien".
- **Entrada:** feature implementada con gates verdes (Feature Loop) que toca
  movimiento, combate o cámara.
- **Fases:**
  1. Regenerar montages (`tests/autotest_montage.gd`, ~20s) → revisar strips
     como imágenes. **No live window para iterar** ([[Lecciones]]).
  2. Ajustar tunables (JSON data-driven) → repetir 1.
  3. Cuando los montages convencen: **live playtest del director**.
  4. Capturar su feedback como ítems concretos; volver a 2 si hace falta.
  5. Aceptación explícita del director = cierre.
- **Validación:** aceptación verbal del director registrada; gates siguen
  verdes tras el tuning.
- **Artefactos:** tunables JSON, [[Task-Board]], [[LOG]] (`playtest`),
  [[Lecciones]] si el feedback revela un anti-patrón.
- **Salida:** mecánica aceptada; semillas sensoriales anotadas para la Game
  Feel Bible ([[Combate]] §D).
