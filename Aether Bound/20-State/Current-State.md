---
status: vivo
updated: 2026-09-21
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`). Histórico verbatim en
> [[Current-State-Historico]]; detalle en [[LOG]].
>
> **2026-09-11:** [[LOG]] rotado a `LOG-Archivo/` y `check_vault.py` v4
> instalado como herramienta única del repo. Recorte de este archivo pendiente.
> **2026-09-21:** la rotación dejó 37 críticos de canon — 3 punteros muertos
> reales y 34 falsos positivos del archivo. Cerrado en 0, detalle en [[LOG]]
> §2026-09-21. **Regla que deja: mover un archivo es cambiar la fuente de todo
> lo que lo cita** — re-apuntar es la otra mitad de rotar.

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
python scripts/check_vault.py    # peso de arranque
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

- **Branch:** `master` — **rama única**. El build del playtest sigue
  congelado en `8c45bab` (hash `91e3d293934f`). `feat/dagna-rig` ya se
  fusionó; el 2026-08-23 se limpiaron **17 ramas locales y 8 remotas**, todas
  verificadas como ancestros de `master` antes de borrarlas (0 commits
  propios sin fusionar). Sobrevive `claude/strange-galileo-243fc7` solo
  porque está atada al worktree de abajo.
- **Código del prototipo:** solo en el tag **`archive/prototipo`**
  (2026-08-10). `.claude/worktrees/quirky-wiles-afa8a0/` tiene una copia
  de julio del rig (pre-rework, 2115 líneas) — **candidato a borrar**, es
  una trampa fácil de pisar si se busca código viejo ahí en vez del tag.
- **Dagna está en el motor** (commit `6d167a1`, ya en `master`):
  `CharacterRig` rescatado del tag al proyecto vivo, sin tocar
  `project.godot` ni el build congelado. Identidad lee bien (trenzas,
  hombreras, martillo-ariete, tatuajes); la escultura no (bola de torso,
  rim de forja quemado, sin cuello). El código de C6 no hubo que
  reconstruirlo — estaba recuperable. Detalle: [[2026-08]] §2026-08-21.
- **Las tres razas están en el motor** y el frente de anatomía va por la
  **Pasada 4**. Detalle pasada por pasada, hipótesis viva y trampas ya
  pagadas: §Pendientes §1. Los defectos que quedan son **sistémicos en las
  tres**, no de un personaje.
- ✅ **Los brazos flotantes de Darro: RESUELTOS** (`f412c22`). Eran **11.5 cm
  de aire** entre torso y deltoides — la única combinación del elenco que lo
  produce: enano (`shoulder_x` 1.60) × Duelist (`arch_xz` 0.80). **Nadie más
  junta hombros anchos con torso angosto**, por eso parecía aleatorio y era
  determinista.
- ⚠️ El **ritmo escapulohumeral** de [[Grados de Libertad del Rig]] NO era el
  fix de esto: es ley de **abducción** y el defecto era **estático**. Sigue
  vigente para cuando se anime el brazo.
- 🔴 **El "torso bola" de FRENTE sigue abierto** — el pecho lee como tapa de
  barril con filo duro debajo. **Pero ya NO es `chest_mass`:** medido, su semieje
  x (0.1485) va a ras del radio del cilindro (0.1476) y escala junto al torso, así
  que no desborda en ningún build. **El voladizo son los deltoides.**
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

1. **🎨 ANATOMÍA DEL RIG — 3 fixes aplicados, 2 revertidos, anchos cerrados.**
   Piloto: Roen (humano) / Darro (enano) / Valen (elfo) — las tres razas, para
   validar cada fix en tres cuerpos. Dagna va de **control de regresión** (única
   con las 8 piezas firma). Relato completo de cada pasada en [[LOG]]
   §2026-08-24. Comparativo visual: artifact **Banco de Anatomía del Rig**.
   `Godot --path godot res://scenes/character_lineup_sheet.tscn`
   - ✅ Dorsal ancho (`6ce094f`) · puente escapular (`f412c22`, cerró los brazos
     flotantes de Darro) · anchos ratificados (`3dfa6bc`).
   - ❌ **Dos restricciones que dejaron los fracasos, y valen más que los fixes:**
     el **pectoral NO se puede rotar** a esta escala (cualquier ángulo crea una
     arista que el Sobel entinta), y **mover el deltoides no alcanza** la zona del
     defecto (de perfil reabre la "hombrera de fútbol").
   - ✅ Pectorales recuperados (Pasada 5): estaban **tragados por `chest_mass`**
     — 0.3 mm de relieve contra los ~3 mm que el propio archivo declaraba. Ganancia
     clara en las tres razas, cero regresión. **Lever seguro por construcción:**
     `pec.scale.z` mueve el centro y NO el perímetro, así que no puede reabrir la
     "streak crema" de A6; `position.z` sí lo haría.
   - ⬜ **El pecho de frente sigue abierto, y van TRES hipótesis quemadas.**
     Aplanar `chest_mass` está **descartado por medición**: el intercambio
     protrusión↔arista es monótono, o sea que el fix no es caro — **no existe**
     en esa familia. Abdomen como masa propia (B2 del libro) está **prohibido por
     ratificación** (`abs_plate` falló en 3 magnitudes, 2026-07-14: la lámina no
     tiene nada que sobresalga ahí — **gana la lámina sobre el libro**).
     **La evidencia apunta a los deltoides**, que es el territorio del aviso de
     `SHOULDER_X`. No arrancar la cuarta sin decisión del director.
   - ⬜ **Cadera sin decidir:** sin multiplicador racial ni piso. Defendible para
     un trapezoide, pero es el hueco que queda del sistema de anchos.
   - ⬜ Primitiva del tórax (la más cara: 6 acoplamientos). Hallazgos técnicos ya
     hechos, **no re-derivarlos** — `radial_segments = 6`, no invertir el taper de
     `torso`, bajar `pec.position.z` a ~0.108-0.112. En
     `~/.claude/plans/haz-el-plan-de-idempotent-lobster.md`.
   - ⚠️ **Dos trampas de instrumento ya pagadas:** el **ratio ancho/alto** del
     lineup es **ciego** a la escultura del torso (el AABB lo dominan los brazos).
     Y `godot/test_out/` está en `.gitignore` — **el "antes" se copia ANTES de
     correr** o se pierde.


2. **Playtest — único bloqueo real: agendar a Diego, Santiago y Delmer.**
   Todo lo técnico está listo (protocolo, telemetría, escena gris, feel
   pass, build congelado — detalle en [[Current-State-Historico]]).
   **Riesgos abiertos sin instrumento todavía:** el gancho es una ausencia
   y no se captura en GIF (preguntas 13-14) · el golpe de la pérdida es
   50% audio — mientras el build esté mudo, prohibido concluir la rama
   DISEÑO · la objeción del Outsider al desbloqueo de Bram (pregunta 12) ·
   el acoplamiento 1:1 Pivote↔build raza×rol no tiene instrumento porque
   no es de playtest.

3. **Dos decisiones de diseño abiertas** (bloquean ratificar
   [[Los 3 Links de los Fijos]]):
   - Ninguno de los 3 T3 de los fijos tiene **escena firma** propia (solo
     Roen tiene objeto firma, el escudo) — [[The Tether]] promete ambos.
   - El caso "rol duplicado" vive en T1 para Roen y en T2 para Valen y
     Darro, sin razón declarada, y solo en Roen *sustituye* el sabor base
     en vez de sumarse.

4. **Abierto en Acto 1, sin bloquear nada:**
   - Extraer las tarjetas por Pivote (4 slots ya existen en las 9 fichas,
     en prosa y español — falta extracción + traducción). Waypost pide 2
     más, una nueva (silla en la mesa, acotación muda).
   - Concept art de The Long Vigil (primer boss sin lámina).
   - Pregunta de combate abierta a propósito: ¿se puede terminar la pelea
     de The Long Vigil sin matarla? Cruza con la elección ilusoria.
   - **Frente siguiente: Acto 2** — La Rueda, el Bautizo, el pico de voz
     en la oficina de Old Tobin Hale.

5. **Medios/bajos sin cerrar (no bloquean):**
   - `Vekka` usa la palabra "Warden" en Actos 1-2, cuando
     [[El Mundo y la Muda]] dice que el término no existe públicamente
     hasta el Archive en Acto 3 — y siendo enana no tiene vía canónica.
   - [[The Tether]] cita una "regla T3" que [[Los 9 Links del Pivote]] le
     atribuye — falta verificar esa cita.

6. **Concept art:** §12.1 (V1 del key-art-poster) sigue sin correr.

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
