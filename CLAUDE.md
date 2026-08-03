# AETHER BOUND — reglas del repo

0. **Al usuario (el director) siempre le contestarás iniciando por "Boris".**
1. **Toda sesión empieza leyendo el `Current-State` de SU eje.** El repo
   tiene dos ejes independientes:
   - **Aether Bound** (el juego) → `Aether Bound/20-State/Current-State.md`.
     Es el default: si no está claro de qué trata la sesión, es este.
   - **Inversión** (cartera personal) → `Inversión/10-Portafolios/…/Current-State.md`,
     con su propio método en `Inversión/METODO.md`. Carpeta en `.gitignore`,
     puede no existir en un clon.

   **No se cargan los dos.** Mezclarlos desperdicia contexto en ambos
   sentidos. Las reglas 2-9 de abajo son de Aether Bound y no aplican al eje
   Inversión, que se rige por su propio `METODO.md`.
2. El modelo de trabajo (capas, loops, plantillas) está en
   `Aether Bound/SCHEMA.md` — toda operación sigue un loop de
   `Aether Bound/30-Loops/`.
3. `docs/GDD.md` (v2.2) y `BACKLOG.md` están **congelados** — fuentes
   históricas, no se editan. La verdad viva del diseño vive en
   `Aether Bound/10-Knowledge/`; el estado, en `Aether Bound/20-State/`.
4. Ningún loop termina sin actualizar `00-Index.md`, `LOG.md` y
   `Current-State.md` (checkpoint tras **cada** tarea).
5. Código: `godot/` es la implementación (Godot 4.6.3); `src/` (Three.js) es
   referencia congelada. Lecciones técnicas obligatorias antes de tocar
   código: `Aether Bound/20-State/Lecciones.md`.
6. Arranque de sesión barato por diseño (SCHEMA §8): nada se auto-carga vía
   `@import` salvo lo indispensable en CADA sesión. Auditoría de peso:
   `Aether Bound/scripts/check_vault.py` (semáforo 🟢<10k/🟡10-30k/🔴>30k
   tokens). Si sale 🟡/🔴, es trabajo del Lint Loop aunque nada falte.
7. **Antes de auditar canon con subagentes, correr el linter:**
   `python "Aether Bound/scripts/check_canon.py"` (exit 1 si hay críticos).
   Barre lo mecánico — citas rotas, aritmética, fuente única, clases
   incompletas. Los subagentes de QA se reservan para lo que exige juicio.
   Método completo: skill `canon-qa` / [[QA de Canon Loop]].
8. **Todo fix de canon va a la FUENTE del dato, no a la línea reportada.**
   Grep de la clase completa de menciones en todo el vault antes de cerrarlo.
   Cuatro rondas de QA fallaron por corregir líneas sueltas.
9. **Idioma (decisión de Boris, 2026-07-30): el guión y todo el contenido de
   front-end (diálogos, líneas canónicas, UI, textos in-game) se escribe en
   **inglés** de acá en adelante.** El vault (prosa de diseño, análisis,
   nombres de sección) sigue en español — es donde Boris y el asistente
   conversan, no lo que ve el jugador. Las conversaciones de trabajo pueden
   seguir en español o inglés, indistinto. Nota: varios beats de diálogo ya
   escritos (ej. las líneas del Reckoning en `Geografía y Ciudades.md`) están
   en español, de antes de esta decisión — pendiente de pasada de traducción
   cuando se aborde el guión en serio; no bloquea nada mientras tanto.
