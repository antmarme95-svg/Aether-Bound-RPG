---
status: borrador
updated: 2026-08-10
---

# Brief para el Consejo — Motor y Fases de Desarrollo

> Insumo para correr `/llm-council` (o sesión equivalente) sobre
> [[ADR-003 Reset de desarrollo y motor]]. Compila todo lo que el
> consejo necesita sin tener que releer el vault — pero **no reemplaza
> la sesión con el director**, que ADR-003 marca como no delegable.

## La pregunta que decide el consejo

Con el alcance narrativo y las opciones técnicas ya mapeadas: ¿qué
vertical slice se construye primero, con qué motor, y bajo qué método
de producción — para probar que el juego funciona antes de comprometer
meses de desarrollo completo?

## Premisa de fases (escrita por Boris, 2026-08-07/10, textual)

**Fase 1 — Vertical slice.** Aether Bound con creación de personaje (9
combinaciones raza×rol × 2 géneros = 18) incluyendo selección de
marcas/tatuajes/warpaint, estilo y color de cabello (+ vello facial si
aplica), prólogo + tutorial + game title sequence + Encuentro con Roen
y rescate. Game feel correcto, low poly aceptable, biomecánica y
fluidez correctas. Incluye mecánicas de juego básicas, características
de personaje, sistema de combate y habilidades (bond con Roen).

**Fase 2 — Desarrollo completo**, después de cerrar guión y demás
pendientes tipo GDD. **Sin límite de tiempo declarado** — no es un
proyecto con fecha de lanzamiento fijada; es pasión/hobby antes que
negocio, aunque un resultado comercial exitoso se agradece si ocurre.

## ⚠️ Tensión a resolver antes de correr el consejo

**El candidato de slice que trae `ADR-003` no es el mismo que describe
la premisa de arriba.** `ADR-003` §1 propone [[Slice of Bond]] (Humano
Duelist × Dagna, 4 escenas, 45-60 min, ya ratificado) como "el vertical
slice mínimo". La premisa de Boris pide algo bastante más grande:
**creación de personaje completa (18 combinaciones)**, prólogo,
tutorial, secuencia de título, y el Encuentro con Roen — que ya tiene
guión escrito ([[Guion/Encuentro con Roen]], `provisional`, pendiente
de re-corrida de QA).

No son incompatibles, pero sí son alcances distintos:
- **Slice of Bond** prueba la tesis narrativa/emocional (¿funciona el
  bond como árbol de habilidades? ¿duele la traición?) con una sola
  celda de jugador.
- **La premisa de Boris** prueba la tesis de **producción**: ¿se puede
  construir el pipeline completo de personalización (18 combinaciones
  visuales) + el primer tramo jugable con calidad final de game feel?
  Es un slice de "onboarding + primeras impresiones", no de arco
  narrativo profundo.

El consejo necesita saber cuál pregunta está respondiendo — o si son
dos slices secuenciales (primero onboarding, después Slice of Bond como
prueba de profundidad narrativa).

## Insumos ya resueltos (no volver a debatir en el consejo)

- **Godot vs Unity — evidencia:** [[ADR-002 Motor diferido]] (golden
  scene, 430-530 fps, look aprobado) + análisis de ADR-003 (Unity
  favorecido por animación/rigging, consolas, precedente de Sable,
  herramientas de diálogo maduras; Godot favorecido por evidencia real
  ya corrida, sin licencias, más liviano).
- **Gauntlet Loop no es una tercera vía de motor** — es un método de
  producción ortogonal, aplicable sobre cualquiera de los dos motores.
  Detalle completo en [[ADR-003 Reset de desarrollo y motor]] §Tercera
  vía. Ya disponible parcialmente en esta sesión vía skill `/loop`; lo
  que falta es disciplina de prompt (objetivo grande + house rules +
  estándar medible — candidato natural: [[Benchmark Biomecánico]] — +
  crítico independiente), no tooling nuevo.
- **Los 5 criterios de ADR-003, en orden:** (1) vertical slice mínimo
  → (2) target de plataforma → (3) alcance v1 vs post-lanzamiento → (4)
  motor evaluado contra el slice → (5) inventario de qué se conserva.

## Lo que el consejo debería producir

1. Resolución de la tensión de alcance de arriba (¿qué slice se
   construye primero, o en qué orden si son dos).
2. Recomendación de motor **condicionada** a esa resolución (no en
   abstracto).
3. Si aplica, cómo encaja el patrón Gauntlet Loop en la fase 1 —
   ¿constructor/crítico contra qué estándar medible, para qué piezas?
4. Una lista corta de siguientes pasos accionables, no otro documento
   de análisis.

## Pendiente antes de correr el consejo

Confirmación de Boris: ¿corremos `/llm-council` ahora con este brief, o
prefiere revisar/ajustar la premisa primero?
