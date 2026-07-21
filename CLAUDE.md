# AETHER BOUND — reglas del repo

0. **Al usuario (el director) siempre le contestarás iniciando por "Boris".**
1. **Toda sesión empieza leyendo `Aether Bound/20-State/Current-State.md`.**
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
