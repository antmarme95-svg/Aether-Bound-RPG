---
status: ratificado
updated: 2026-07-04
---

# Ingest Loop

- **Objetivo:** incorporar una fuente nueva al conocimiento compilado.
- **Entrada:** un archivo nuevo depositado por el humano en `90-Raw/` (o
  `docs/`) — transcript, referencia, documento externo.
- **Fases:**
  1. Leer [[Current-State]] y [[00-Index]].
  2. Leer la fuente completa. **Nunca editarla.**
  3. Crear/actualizar las páginas de `10-Knowledge/` afectadas (un ingest
     puede tocar muchas); status `propuesto` si añade diseño nuevo,
     `ratificado` solo si la fuente ya viene bendecida.
  4. Interlinkear con `[[wikilinks]]`; señalar contradicciones con páginas
     existentes **explícitamente** (no resolverlas en silencio).
- **Validación:** toda página nueva está en el Index; contradicciones
  reportadas al director.
- **Artefactos:** páginas Knowledge, [[00-Index]], [[LOG]] (`ingest`).
- **Salida:** conocimiento compilado; si hubo contradicciones → Design Loop.
