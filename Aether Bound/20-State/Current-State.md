---
status: vivo
updated: 2026-08-23
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`). Higiene de contexto
> aplicada 2026-08-23 (4ta vez) — relato histórico movido a
> [[Current-State-Historico]] VERBATIM; detalle completo también en [[LOG]].

## Estado general

Worldbuilding narrativo completo (9 Pivotes + 3 fijos + Speck + estructura
política/geográfica). Acto 1 con guión completo (5 escenas + primer jefe).
**Regla de idioma vigente** (Boris, 2026-07-30): guión y front-end en
inglés, vault en español — registrada en `CLAUDE.md` regla 9 y
`Nomenclatura.md`. Pendiente sin bloquear: traducir beats ya escritos en
español (Reckoning y otros) cuando se aborde el guión completo.

**Motor: GODOT**, re-confirmado y congelado (ADR-002 + cierre de ADR-003,
sin re-evaluaciones hasta que exista slice jugable). Próximo código de
producción: el vertical slice de 3 escenas con Dagna — nada más está
autorizado (no combate genérico ni sistemas fuera del slice).

### 🛠️ Herramientas del vault

```
python "Aether Bound/scripts/check_vault.py"    # peso de arranque
python "Aether Bound/scripts/check_canon.py"    # consistencia (22 clases)
```
Exit 1 si hay críticos. **Orden no negociable:** linter en 0 → subagentes en
frío solo para juicio → fixes **a la fuente** con re-grep → checkpoint →
re-corrida. Método: skill `canon-qa` / [[QA de Canon Loop]]. Si un QA
encuentra un crítico de una clase que el linter ya cubre, el bug es del
linter, no de la línea. **Al citar una `§`, cerrarla antes de seguir la
frase** — el linter la lee como parte del nombre si no.

---

## Hechos vigentes

- **Branch:** `master`, con el **build del playtest congelado en `8c45bab`**
  (hash `91e3d293934f`). Rama viva en paralelo: **`feat/dagna-rig`**
  (rescate del rig), deliberadamente fuera de `master` para no descongelar
  el build mientras corren los testers.
- **Código del prototipo:** solo en el tag **`archive/prototipo`**
  (2026-08-10). `.claude/worktrees/quirky-wiles-afa8a0/` tiene una copia
  de julio del rig (pre-rework, 2115 líneas) — **candidato a borrar**, es
  una trampa fácil de pisar si se busca código viejo ahí en vez del tag.
- **Dagna está en el motor** (rama `feat/dagna-rig`, commit `6d167a1`):
  `CharacterRig` rescatado del tag al proyecto vivo, sin tocar
  `project.godot` ni el build congelado. Identidad lee bien (trenzas,
  hombreras, martillo-ariete, tatuajes); la escultura no (bola de torso,
  rim de forja quemado, sin cuello). El código de C6 no hubo que
  reconstruirlo — estaba recuperable. Detalle: [[LOG]] §2026-08-21.
- ⚠️ Antes de tocar importación de FBX: leer [[Lecciones]] §Godot 4.7
  (orientación +Z/−Z, escala ×100, árbol duplicado al re-apropiar).

---

## Pendientes

> Boris también escribe acá directo (fuera de sesión con el asistente) —
> cualquier ítem nuevo se revisa junto al arrancar la próxima sesión.

### 🗓 Inmediato — próxima sesión

0. **⏳ SPRINT DE CANON SIGUE SIN CERRAR** (3 rondas de fixes aplicadas hasta
   2026-08-17, linter en 0 críticos/0 medios tras cada tanda; detalle en
   [[LOG]] y [[Current-State-Historico]] §Sprint de canon).
   ⛔ **Hace falta otra re-corrida en frío, y no la puede correr quien
   aplicó estos fixes** (skill `canon-qa` §Anti-objetivos) — cada
   re-corrida histórica encontró algo que la anterior no vio. **Es el
   primer trabajo de la próxima sesión de canon.**
   La lección de método que sobrevive: barrer la clase completa (los tres
   fijos), no un personaje a la vez — misma regla 8 de `CLAUDE.md`.

1. **Playtest — único bloqueo real: agendar a Diego, Santiago y Delmer.**
   Todo lo técnico está listo (protocolo, telemetría, escena gris, feel
   pass, build congelado — detalle en [[Current-State-Historico]]).
   **Riesgos abiertos sin instrumento todavía:** el gancho es una ausencia
   y no se captura en GIF (preguntas 13-14) · el golpe de la pérdida es
   50% audio — mientras el build esté mudo, prohibido concluir la rama
   DISEÑO · la objeción del Outsider al desbloqueo de Bram (pregunta 12) ·
   el acoplamiento 1:1 Pivote↔build raza×rol no tiene instrumento porque
   no es de playtest.

2. **Dos decisiones de diseño abiertas** (bloquean ratificar
   [[Los 3 Links de los Fijos]]):
   - Ninguno de los 3 T3 de los fijos tiene **escena firma** propia (solo
     Roen tiene objeto firma, el escudo) — [[The Tether]] promete ambos.
   - El caso "rol duplicado" vive en T1 para Roen y en T2 para Valen y
     Darro, sin razón declarada, y solo en Roen *sustituye* el sabor base
     en vez de sumarse.

3. **Abierto en Acto 1, sin bloquear nada:**
   - Extraer las tarjetas por Pivote (4 slots ya existen en las 9 fichas,
     en prosa y español — falta extracción + traducción). Waypost pide 2
     más, una nueva (silla en la mesa, acotación muda).
   - Concept art de The Long Vigil (primer boss sin lámina).
   - Pregunta de combate abierta a propósito: ¿se puede terminar la pelea
     de The Long Vigil sin matarla? Cruza con la elección ilusoria.
   - **Frente siguiente: Acto 2** — La Rueda, el Bautizo, el pico de voz
     en la oficina de Old Tobin Hale.

4. **Medios/bajos sin cerrar (no bloquean):**
   - `Vekka` usa la palabra "Warden" en Actos 1-2, cuando
     [[El Mundo y la Muda]] dice que el término no existe públicamente
     hasta el Archive en Acto 3 — y siendo enana no tiene vía canónica.
   - [[The Tether]] cita una "regla T3" que [[Los 9 Links del Pivote]] le
     atribuye — falta verificar esa cita.

5. **Concept art:** §12.1 (V1 del key-art-poster) sigue sin correr.

### Pendientes menores, sin bloquear nada
- Orejas de Speck en las 5 láminas de finales: forma de zorro simple, no
  la forma de pétalos establecida en canon. Refinamiento visual futuro.
- Traducción pendiente de los beats de diálogo ya escritos en español.
- `.claude/worktrees/quirky-wiles-afa8a0/` — candidato a borrar (ver
  Hechos vigentes).

### Worldbuilding — abierto
- **El Último Reino humano pre-Regencias:** construir backwards qué fue,
  cuándo cayó y cómo cuadra con 550 años de Regencias. No bloquea.
- Culturas por raza — ceremonias, idioma, costumbres.
- Lore de civilización Warden pre-caída; estrategia militar de los 3
  reinos en el clímax; The First Wound y Sunken Archive (fichas lore);
  cabeza de the Academy of Sages (baja prioridad).

### Narrativa / guión (próximo frente real — en inglés)
- Guión completo por actos (GDD §1.2 tiene estructura, no diálogos).
- Momentos de Persona de Speck; diálogos del Bautizo (Darro la nombra).
- Los 5 Finales — scripting de diálogos/cinemática; estado post-final
  jugable; variantes C3 vivo/muerto.
- Traducción de los beats de diálogo existentes en español (Reckoning, etc.).

### Concept art pendiente
- Sin tocar esta sesión: revisar las 4 escenas de traición (¿legacy o
  canon?); set de combos sin doc; QA de las 4 variantes de The Wilds;
  videos Higgsfield (bloqueo ffmpeg); POIs sueltos cuando aparezcan en
  el guión.

### Mapa del mundo
`Aether Bound universe.png` = referencia interna imperfecta (texto corrupto
en etiquetas). Plan: documentar por escrito a medida que avanza el
worldbuilding → al cerrar el frente, escribir spec exhaustiva. Ver cabecera de
[[Briefs de Mapa del Mundo]].

**POSPUESTO (post-lore):** trailer formal, cutscenes cinemáticas, banda sonora.

---

**Historial completo:** [[LOG]] y [[Current-State-Historico]].
