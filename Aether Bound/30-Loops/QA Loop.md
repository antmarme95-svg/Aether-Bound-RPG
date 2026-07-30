---
status: ratificado
updated: 2026-07-14
---

# QA Loop

Formaliza el método usado para cerrar la brecha de fidelidad de la Fase C
(rework facial): un subagente **QA imparcial** mide contra la lámina RAW en
vez de un VoBo puramente subjetivo, un segundo subagente **PRD** traduce ese
veredicto a un plan ejecutable, y el orquestador itera código↔QA↔PRD hasta
un objetivo medible. Reemplaza el patrón viejo de "VoBo del director →
ajuste a ciegas → VoBo de nuevo" cuando hay una lámina canónica contra la
que medir.

- **Objetivo:** cerrar la brecha entre un asset visual (cara, cuerpo, prop)
  y su lámina de referencia canónica (`90-Raw/concept/`) con iteración
  **medible** (% de fidelidad + hallazgos priorizados), no solo impresión.
- **Entrada:** una ronda de trabajo ya cerrada por el director (código verde,
  QA de regresión ALL_PASS) que toca un asset con lámina de referencia
  identificable, y que el director quiere auditar antes de dar VoBo final.
- **Fases:**
  1. **Spawnear un subagente QA** (`Agent` tool, `general-purpose`, **sin
     contexto previo de la sesión** — la imparcialidad depende de que no
     haya visto el trabajo hacerse) con: rutas de la lámina + capturas del
     banco, qué ignorar (placeholders de fases no relacionadas, ej. pelo de
     Fase D), y el pedido explícito de ser honesto/no validar de más. Pide
     veredicto por rasgo + % global + lista CRITICAL/HIGH/MEDIUM/LOW.
  2. **El orquestador implementa los fixes** citados por el QA, en el mismo
     vocabulario técnico del código real (en este proyecto: primitivas
     esfera/cilindro/caja fusionadas por **overlap real**, no tangencia —
     ver [[Lecciones]]). No delegar la implementación al QA — el QA
     diagnostica, el orquestador ejecuta.
  3. **Re-correr el banco de captura + QA de regresión** (`test_core` /
     `autotest_biomech` / suites relevantes) ALL_PASS antes de volver a
     medir fidelidad — un fix visual no vale si rompe el gate técnico.
  4. **Re-invocar al MISMO agente QA** (por su `agentId` vía `SendMessage`,
     no un agente nuevo) con las capturas actualizadas — conserva el hilo
     de comparación entre rondas (ronda 2 sabe qué decía la ronda 1) sin
     tener que re-explicar contexto.
  5. **Spawnear (o re-invocar) un subagente PRD** separado que traduce el
     output crudo del QA + el código real (archivos/líneas/nombres de
     variable reales, no genéricos) a un documento formal
     (`20-State/PRDs/`, mismo esqueleto que los PRD numerados: frontmatter,
     Objetivo, Alcance por estado CERRADO/pendiente priorizado, Anti-
     objetivos, Definición de terminado). El PRD es el registro accionable
     — cualquiera debería poder ejecutar los pendientes sin releer los
     reportes de QA.
  6. **Repetir 2→5** hasta que el QA confirme el % objetivo que fijó el
     director, o hasta que declare explícitamente que no hay más margen
     real con el vocabulario técnico actual (techo de la técnica — señal
     para escalar a un cambio de enfoque, no seguir iterando parámetros).
  7. **Cierre:** VoBo del director sobre el resultado. El loop no cierra
     solo con un número — el % de fidelidad informa la decisión, no la
     reemplaza.
- **Validación:** QA de regresión (suite headless del proyecto) ALL_PASS en
  cada ronda de código, sin excepción, antes de re-medir fidelidad; el PRD
  queda sincronizado con el estado real del código tras cada ronda (nada
  marcado ✅ que el QA no haya confirmado).
- **Artefactos:** PRD en `20-State/PRDs/` (o standalone si el rework no es
  parte de la secuencia numerada de gameplay — anotar la excepción en el
  propio doc), capturas del banco de prueba, [[LOG]] (`feature`/`fix`),
  [[Current-State]], [[Lecciones]] si un fix revela un anti-patrón nuevo
  (ej. "toda fila 1D de esferas con overlap suficiente para fundirse lee
  pareja/sólida — lo opuesto a una textura ruidosa").
- **Salida:** asset con fidelidad medida y documentada; PRD como plan
  ejecutable si queda trabajo abierto; VoBo del director registrado en
  [[Current-State]].
