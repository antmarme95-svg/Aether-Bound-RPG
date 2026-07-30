---
status: vivo
updated: 2026-07-29
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

## Estado general (2026-07-29)

**Worldbuilding narrativo:** las 9 fichas de Pivote + los 3 fijos + Speck + toda la estructura política y geográfica están escritos. El vault soporta escribir guión en cuanto cierre el sprint QA.

**Sprint QA de reparación — Fases 0-5 cerradas + 3 re-corridas procesadas.** Relato completo de las fases 0-4 en [[Current-State-Historico]]; detalle operativo de cada bloque y de las 3 re-corridas en [[LOG]].

**✅ 3ª re-corrida cerrada (8 críticos + 3 MEDIUM).** Detalle en [[LOG]]. Canon que quedó fijado:

- **Agencia de Speck en 3 grados** (`Speck.md §Capa 4`): F4 = le preguntan (*responder*); F1 = deciden por ella y acepta (*aceptar*); F2a/F2b/F3 = se la arrebatan. Ninguna ficha puede hacer que Speck "elija" en F1.
- **Regla del Fragmento — `Speck.md §Capa 5`, fuente única.** Sobrecarga por transferencia de fuerza mecánica cerca de un core activo: esperar no la mata, cederla no la mata, **arrebatarla sí**. Nadie más la enuncia; todos citan ahí.
- **Transporte:** la entrega corta el pulso, y el cese del pulso es lo que la suelta del centro. Por eso F2a puede transportarla.
- **Gates:** quietud que termina en pregunta = F4; forcejeo = F2b; **parálisis = F2a** (el Pivote entrega por defecto). No decidir hace ganar a la institución.
- **Isolde Marrow** degradada a reclamo de House Marrow (el "Último Reino" pasó a Pendientes).
- **Longevidad** alineada a [[Las Tres Razas]]; **Darro ~63**; **Valen no presenció ninguna Muda**.
- **Goggles no retirables** propagado a las 9 fichas + Valen.

**Cronología de las Mudas — limpia.** Ninguna se completó en 550 años; las 3 afirmaciones contrarias quedaron **marcadas como error heredado de the Academy**, no borradas: `Valen:58` (los ancianos y sus "cuatro Mudas", fuente del "cinco Mudas"), `Valen:52` (el "110 años") y `Geografía:613` (el ermitaño, hoy testigo del error de registro). Aritmética de Valen: 140 → 180 → 200 → 230.

## 4ª RE-CORRIDA QA — CORRIDA (2026-07-29). 18 críticos, 17 cerrados

Dos QAs Opus en frío, en paralelo: **9 críticos de dramática + 9 de congruencia.** Commits `7550a7d`, `ad3bde7`.

### Decisiones de canon de Boris en esta ronda

- **Costo de F1 = colapso tecnológico, NO exterminio.** Nueva sección `Los 5 Finales §El costo de F1`, con 3 prohibiciones obligatorias para los 12 epílogos F1. Muere la tecnología Aether y la legitimidad de toda institución que vivía del recurso; sobrevive la gente, empobrecida. **F1 no es mejor que F4:** F1 funde la civilización de golpe, F4 la deja adaptarse y cobra a Speck.
- **Gate de F1 = Pivote neutralizado antes del cráter + no intervenir.** Eliminada la rama "hablar con Speck", que era el verbo de F4. F1 es el único final cuya acción de cráter es la ausencia de acción **con nadie más capaz de actuar** — de ahí el requisito del Pivote.
- **Gate de F4 = 2 condiciones** (mayoría "persona" en Momentos + ≥2 compañeros T2+). Eliminada la condición de Goggles/flashes: por no retirables y estar en rieles, el 100% de las partidas la cumplía. Alineado con `The Tether §Gate del Final 4`.
- **`Dagna.md` archivada** a `90-Raw/`. Contradecía a la expandida en origen, apellido y reclutamiento; los tiers del Springboard se migraron antes a [[Los 9 Links del Pivote]].
- **Matriz de roles fija eliminada** de `The Bound Five` (1V/2D/2S cerraba en 4 de 9 celdas). El balance se verifica **por celda**.
- **`Geografía y Ciudades` = fuente primaria única de ubicaciones.** Los cuadrantes de `Briefs de Mapa` son **derivados**, no se editan a mano.
- **Fuente única nueva: `Nomenclatura §the Wanderer's Goggles`** — no retirables + estrictamente privados + **no son gate**.

### ✅ Los 12 epílogos F1 reescritos bajo la regla de costo (2026-07-29)

Los 9 Pivotes + los 3 fijos. Cierra el crítico C1 del QA de dramática. **El costo civilizatorio mejoró el beat en casi todos** — le dio al epílogo un antagonista de escala que antes no tenía. Detalle personaje por personaje en la entrada del 2026-07-29 de [[LOG]].

Muestras del patrón: Vekka termina haciendo bisagras y herrajes, que en el mundo nuevo **son el oficio** porque no queda forja de Aether — y lo vive como degradación. Lyris es la única que ve el costo completo, sobrevolando las tres capitales apagándose una por una. Nyael queda "no retornada" para siempre porque el registro murió antes que ella. A Darro se le apaga **la forja que lo rechazó**, y le sacaron el a dónde volver. Valen es el que nombra el precio en voz alta, con el **M3 cerrado**: su línea ya no asume un Pivote vivo (en 4 de 9 rutas F1 muere o desaparece).

### 🔜 Único pendiente para cerrar el sprint

**5ª re-corrida QA.** Criterio de cierre: 0 críticos. Arranca con `check_canon.py` (hoy en 0) y sigue con los 2 subagentes en frío — ver skill `canon-qa`.

### 🛠️ Herramienta nueva — correr ANTES de gastar subagentes

```
python "Aether Bound/scripts/check_canon.py"
```

Audita **consistencia** en 10 clases mecánicas (citas `§`, wikilinks, fuente
única, aritmética de edades, longevidad, género, reinos, cuadrantes, cifras en
diálogo). Exit 1 si hay críticos. Método: skill `canon-qa` / [[QA de Canon Loop]].

**Orden no negociable:** linter en 0 → subagentes en frío solo para juicio →
fixes **a la fuente** con re-grep → checkpoint → re-corrida. En su primera
corrida encontró 3 violaciones de fuente única que ningún subagente reportó.
Clase determinista nueva = chequeo nuevo en el linter, antes de delegarla.

### Nota de método

El cuello de botella no es el QA, es el **barrido**: la longevidad humana quedó en 2/3 de la clase, el género de Speck se arregló en `Darro-Ficha` y no en `Darro.md`, y Lyris llevaba dos rondas reportada. De ahí salió el linter. Ver [[Lecciones]] y [[QA de Canon Loop]].

Con el sprint cerrado, el frente siguiente es **guión y diálogos por actos**, y se abre la pregunta de bonds de fijos (abajo).

**Verificado en esta sesión:** grep de los 8 datos corregidos → 0 residuos; los 22 "Speck elige" del vault están todos en secciones F4 (el error de F1 no se propagó); `check_vault.py` 🟢 verde, arranque ~5,125 tokens.

**Plan de abordaje con asignación de modelos por sprint:** `~/.claude/plans/haz-un-plan-de-dazzling-lemur.md`.

---

## 🟡 Ediciones directas de Boris (2026-07-28) — estado

✅ **`Nomenclatura.md`** — Isolde (ahora reclamo, resuelto 07-29) + Goggles no retirables (propagado 07-29).
✅ **`Speck.md`** — "Giro Grogu" eliminado; Speck es Warden anciana desde el inicio. Pelaje rojo/naranja, ojos facetados-naranjas.
🟡 **`The Bound Five.md`** — **pregunta de diseño abierta:** mecanismo de bonds/links propios para Roen, Darro y Valen a partir de raza/rol, de forma que los 9 bonds sean protagonistas por igual. Toca [[The Tether]] y [[Bond y el Bond Vacío]]. Arranca al cerrar el QA.
📋 **`Principios de Anatomía 3D.md`** — referencia compilada (DOF por región). Pendiente reestructurar en tablas agnósticas de motor.

**Concept art:** catalogado y trackeado en `90-Raw/concept/CATALOGO.md`.
- §9 gobernantes: 5/6 ✅, King Borran 🟡 provisional · §10 elenco político: 6/6 ✅
- §6d keyframes ciudades: Emberdeep/Stillspire/Mistbound ✅, Rivermeet daylight 🟡, Driftmarket 🔴
- §L UI Mockups: 3/3 ✅ (main-menu 🟡 ajuste menor) · §M Marketing: key-art-poster 🟡 v2 por tone mismatch
- §11: **14/14 briefs corridos y con QA ✅ cerrado** (2026-07-27)

---

## 🔴 BLOQUEO ACTIVO — no se toca código

**[[ADR-003 Reset de desarrollo y motor]] está ABIERTO** (2026-07-28). El director planteó hard reset de código + revisión de la decisión de motor (Godot → posiblemente Unity).

- ❌ No se escribe código de producción, ni en Godot ni en Unity. Frente C del Task-Board congelado.
- ✅ **Sigue desbloqueado:** worldbuilding, guión, concept art, mockups de UI, diseño de sistemas en papel.

**5 criterios a resolver, en orden:** (1) vertical slice mínimo → (2) target de plataforma → (3) alcance v1 vs post-lanzamiento → (4) motor evaluado contra el slice → (5) inventario de qué se conserva. Requiere sesión con el director; no delegable.

**Nota clave:** el riesgo mayor no es el motor — es que el alcance narrativo (9 Pivotes × 5 finales × 9 celdas) creció a escala de estudio mediano. Ningún motor resuelve eso.

---

## Hechos vigentes

- **Branch:** `feat/c6-anatomy-rework`. Playtest: `Start-Playtest-Greybox.bat`. Gates: `autotest_combat.gd`, `autotest_springboard.gd`. **Congelados por ADR-003.**
- **Speck:** la última Warden cristalina superviviente, shapeshifteada como zorro. Narrativa + diseño visual 100% completo. Detalle en [[Current-State-Historico]].
- **Anatomía/rework (C6):** oreja élfica 75%, nacimiento de oreja 74/70/78%. Queda: ROM por raza (C4), pies sin IK.
- **Motor:** GODOT confirmado (ADR-002), en revisión por ADR-003.
- **Deuda técnica visible:** pies sin IK, ROM enano/elfo (C4 restante), mesh de bloques = etapa.
- **Riesgos abiertos:** frame budget frágil RTX 2060 (~58 fps warm); export a consolas requiere partner externo.

---

## Pendientes

### 🗓 Inmediato
- **5ª re-corrida QA** (ver arriba) — único criterio de cierre del sprint.
- **Pregunta de bonds de fijos** de `The Bound Five.md` — arranca al cerrar el QA.

### Worldbuilding — abierto
- **El Último Reino humano pre-Regencias** (nuevo, 2026-07-29): construir backwards qué fue, cuándo cayó y cómo cuadra con 550 años de Regencias. Hoy el reclamo de House Marrow es leyenda deliberadamente no verificable, así que **no bloquea nada** — pero si se quiere hacer canon, hay que escribirlo.
- Culturas por raza — ceremonias, idioma, costumbres (Aether-Born/Iron-Blooded/Restless)
- Lore de civilización Warden pre-caída
- Estrategia militar de los 3 reinos en el clímax
- The First Wound (ficha lore completa), Sunken Archive (ficha lore)
- Cabeza de the Academy of Sages (baja prioridad)

### Narrativa / guión (próximo frente real)
- Guión completo por actos (GDD §1.2 tiene estructura, no hay diálogos)
- Voz narrativa definida (¿narrador? ¿silent protagonist? ¿qué tan verbose?)
- Momentos de Persona de Speck (~7 escenas sin UI)
- Diálogos del Bautizo de Speck (Darro la nombra)
- Los 5 Finales — scripting de diálogos/cinemática; estado post-final jugable
- Variantes C3 vivo/muerto en Finales 2-3

### Fichas de personaje pendientes
- **Old Tobin Hale — ficha expandida.** Solo aparece en `Geografía y Ciudades §The Driftmarket` y `Briefs de Concept Art §10b`. The Reckoning le dio peso dramático mayor (custodio inconsciente de los Goggles hace 40+ años) y ahora también una línea propia sobre el extraño anterior (`Geografía:965`, nueva 07-29). Estimado: ficha corta ~200-300 líneas, sin arco de traición.

### Concept art pendiente
- Revisar las **4 escenas de traición** (`Traición_Dagna`, `La traición ejecutada`, `El primer viso de la muda`, `El Último Vínculo`) — ¿legacy o canon?
- Evaluar el **set de arte de combos** como conjunto — no tiene doc en `10-Knowledge/` todavía
- QA de las **4 variantes de The Wilds** sin procesar (`Arterias`, `Interior`, `Noche con Muda`, `Ruinas`)
- Evaluar **videos Higgsfield** (bloqueo técnico ffmpeg activo)
- **King Borran** 🟡 — si se retoma: prompt en prosa corta (formato que resolvió Kadrun v2)
- **POIs de The Wilds sueltos** — van cuando aparezcan en el guión

### Mapa del mundo
`Aether Bound universe.png` = referencia interna imperfecta (texto corrupto en etiquetas). Plan: documentar por escrito a medida que avanza el worldbuilding → al cerrar el frente, escribir spec exhaustiva. Ver cabecera de [[Briefs de Mapa del Mundo]].

**POSPUESTO (post-lore):** trailer formal, cutscenes cinemáticas, banda sonora.

---

**Historial completo:** [[LOG]] y [[Current-State-Historico]].
