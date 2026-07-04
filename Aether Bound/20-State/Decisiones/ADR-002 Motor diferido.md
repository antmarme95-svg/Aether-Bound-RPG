---
status: ratificado
updated: 2026-07-04
---

# ADR-002 — Decisión de motor (Godot vs. Unreal) DIFERIDA

- **Fecha:** 2026-07-03 (registrada en el Vault 2026-07-04)
- **Contexto:** el director consideró Unreal durante el cierre del GDD; se
  diagnosticó que la inquietud real era de dirección de arte ("cel-shaded de
  programador"), no de motor.
- **Decisión:** diferir. Se evalúa **contra evidencia**: (1) [[Art Bible]]
  probada con las 4 capas sobre una golden scene, (2) Game Feel Bible, (3) el
  vertical slice "Slice of Bond".
- **Estado de la evidencia:** las 4 capas son post-proceso screen-space
  viables en Godot; el prototipo Godot ya tiene locomoción/pipeline aceptados
  ([[Inventario del Prototipo]]).
- **Consecuencias:** ningún trabajo de preproducción debe casarse con APIs
  exclusivas de un motor; el combate se especifica agnóstico
  ([[Combate]] — componentes + datos).
