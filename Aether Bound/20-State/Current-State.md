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

**✅ 3ª re-corrida cerrada.** Canon fijado (detalle en [[LOG]]): agencia de Speck en 3 grados (`Speck.md §Capa 4`); regla del Fragmento fuente única (`Speck.md §Capa 5` — esperar no mata, ceder no mata, **arrebatar sí**); transporte corta el pulso; gates (pregunta=F4, forcejeo=F2b, **parálisis=F2a**); Isolde=reclamo de House Marrow; longevidad alineada; Goggles no retirables; Mudas ninguna completada en 550 años (error heredado marcado, no borrado).

**✅ 4ª re-corrida cerrada (18→17).** Commits `7550a7d`, `ad3bde7`. Canon fijado (detalle en [[LOG]]): costo de F1 = colapso tecnológico NO exterminio (`Los 5 Finales §El costo de F1`, F1 no es mejor que F4); gate de F4 = 2 condiciones (fuera Goggles/flashes); matriz de roles fija eliminada; `Geografía` = fuente primaria de ubicaciones; Goggles fuente única en `Nomenclatura`. **Los 12 epílogos F1 reescritos** bajo la regla de costo — mejoró el beat en casi todos (Vekka, Lyris, Nyael, Darro).

## 5ª RE-CORRIDA QA — CORRIDA (2026-07-29). 15 críticos, 13 cerrados

6 de dramática + 9 de congruencia. Commits `c92b7fe` y siguientes. Detalle en [[LOG]].

**Dos de los críticos eran fixes míos hechos en la línea y no en la clase** (reclutamiento de C4: 1 de 4 lugares; rechazo de Darro: 2 de 5). Es el patrón que la regla 8 del CLAUDE.md existe para evitar, y volvió a pasar dentro de la misma sesión que lo documentó.

### Decisiones de canon de Boris en esta ronda

- **Speck durmió 550 años en crisálida** — NO estuvo despierta disfrazada de zorro. Era la versión mayoritaria (15 archivos) contra 3 líneas outlier de `Speck.md`. **Su humor se refundó:** no viene de haber mirado caer la civilización (no vio nada), viene de milenios de Warden previos + **el desfase del despertar** — todo lo que el grupo trata como normal a ella le resulta literalmente absurdo, y no puede explicar por qué. La ironía es el único registro disponible para alguien que entiende el chiste y no puede contarlo. El POI del avistamiento pasó a ser **The Guardians' Trail**: rastros de las bestias que la custodiaron.
- **Las 4 fichas cortas archivadas** (`Dagna.md`, `Darro.md`, `Roen.md`, `Valen.md`) → `90-Raw/`. Verificado antes: las líneas canónicas y las secciones visuales ya vivían en las expandidas. **Regla nueva: una sola fuente viva por personaje**, anotada en `00-Index`.
- **El Bond vacío se invierte en la celda de Bram** — el único Pivote que rehúsa nunca pierde el link, así que el beat obligatorio se juega al revés: el jugador pica Bond esperando el vacío que el juego entero le enseñó a temer, **y Bram responde.** Le paga su superlativo con mecánica, no con diálogo. Su costo llega igual en el cráter: rehúsa y el Council entrega con las manos de Torgan.
- **Premisa corregida:** la Muda **no tiene reloj autónomo**. El F1 de Iven decía que "iba a ocurrir sola" en 2 años, lo que hacía físicamente imposible el statu quo de F2a y volvía el clímax un trámite. La prohibición 2 ahora cubre las dos cosas: ni *gratis* ni *iba a ocurrir sola*.
- **Gate de F1 al borde del cráter, no antes** — choca con la puesta en escena si es antes (el agente carga a Speck hasta el centro). Con las 3 variantes por ruta: Pivote / equipo de extracción (Nyael) / Torgan segundo agente (Bram).
- **Vekka es Deber Institucional**, no Aritmética (su ficha y el cuerpo de `Los 5 Finales` ya lo decían; la fila de la matriz era el outlier).

### ✅ Los 5 finales visuales completos (2026-07-30)

`5c.1` (F1, arte viejo ya correcto) / `5c.2a` (F2a, brief nuevo — sola, contención clínica, paleta fría) / `5c.2b` (F2b, ex-"Final 2") / `5c.3` (F3) / `5c.4` (F4, brief rehecho — sin pedestal, mirada recíproca al jugador, sin halo triunfal). Los tres briefs nuevos (`5c.2a`, `5c.4`, y el ancla vulpina de `5c.1`) generados y **ratificados por Boris**. Detalle y prompts completos en [[LOG]].

**Nota abierta, no bloqueante (aplica a las 5 láminas):** las orejas quedaron con forma de zorro simple en vez de la forma de pétalos establecida en canon — anotado en `Briefs de Concept Art §Base visual común a todos los finales`. Refinamiento futuro si hay margen.

### 🔜 Pendiente para cerrar el sprint

1. **6ª re-corrida QA.** Criterio: 0 críticos.

### 🛠️ Herramienta nueva — correr ANTES de gastar subagentes

```
python "Aether Bound/scripts/check_canon.py"
```

Audita **consistencia** en 12 clases mecánicas (citas `§`, wikilinks, fuente
única, aritmética de edades, longevidad, género, reinos, cuadrantes, diálogo,
**fichas duplicadas**, **huérfanos de índice**). Exit 1 si hay críticos. Método:
skill `canon-qa` / [[QA de Canon Loop]].

**Orden no negociable:** linter en 0 → subagentes en frío solo para juicio →
fixes **a la fuente** con re-grep → checkpoint → re-corrida. En su primera
corrida encontró 3 violaciones de fuente única que ningún subagente reportó.
Clase determinista nueva = chequeo nuevo en el linter, antes de delegarla.

### Nota de método

El cuello de botella no es el QA, es el **barrido**: la longevidad humana quedó en 2/3 de la clase, el género de Speck se arregló en `Darro-Ficha` y no en `Darro.md`, y Lyris llevaba dos rondas reportada. De ahí salió el linter. Ver [[Lecciones]] y [[QA de Canon Loop]].

Con el sprint cerrado, el frente siguiente es **guión y diálogos por actos**, y se abre la pregunta de bonds de fijos (abajo).

**Plan de abordaje con asignación de modelos por sprint:** `~/.claude/plans/haz-un-plan-de-dazzling-lemur.md`.

---

## 🟡 Ediciones directas de Boris (2026-07-28) — estado

✅ **`Nomenclatura.md`** — Isolde (ahora reclamo, resuelto 07-29) + Goggles no retirables (propagado 07-29).
✅ **`Speck.md`** — "Giro Grogu" eliminado; Speck es Warden anciana desde el inicio. Pelaje rojo/naranja, ojos facetados-naranjas.
🟡 **`The Bound Five.md`** — **pregunta de diseño abierta:** mecanismo de bonds/links propios para Roen, Darro y Valen a partir de raza/rol, de forma que los 9 bonds sean protagonistas por igual. Toca [[The Tether]] y [[Bond y el Bond Vacío]]. Arranca al cerrar el QA.
📋 **`Principios de Anatomía 3D.md`** — referencia compilada (DOF por región). Pendiente reestructurar en tablas agnósticas de motor.

**Concept art:** estado por sección en `90-Raw/concept/CATALOGO.md` (fuente). Pendientes vivos: King Borran 🟡, Rivermeet daylight 🟡, Driftmarket 🔴, key-art-poster 🟡. **Y el set de finales §5c hay que rehacerlo** (ver arriba).

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
- **6ª re-corrida QA** (ver arriba) — único criterio de cierre del sprint.
- **Pregunta de bonds de fijos** de `The Bound Five.md` — arranca al cerrar el QA.

### Herramientas — estado
✅ **Hook de `check_vault.py` al editar `Current-State.md` — CONSTRUIDO Y PROBADO (2026-07-30).** `.claude/settings.json` (proyecto, versionado) + `Aether Bound/scripts/hook_current_state.sh`. `PostToolUse` en `Edit|Write`; si el archivo tocado es `Current-State.md`, corre `check_vault.py` y devuelve el semáforo como contexto del mismo turno. Probado en vivo con una edición real (funcionó, incluido el fix de encoding UTF-8 del hook mismo).
✅ `check_canon.py` +2 clases (2026-07-29): `duplicados` (CRITICAL, hoy en 0) y `indice` (INFO, cerró 2 huérfanos).

### Worldbuilding — abierto
- **El Último Reino humano pre-Regencias** (nuevo, 2026-07-29): construir backwards qué fue, cuándo cayó y cómo cuadra con 550 años de Regencias. Hoy el reclamo de House Marrow es leyenda deliberadamente no verificable, así que **no bloquea nada** — pero si se quiere hacer canon, hay que escribirlo.
- Culturas por raza — ceremonias, idioma, costumbres (Aether-Born/Iron-Blooded/Restless)
- Lore de civilización Warden pre-caída
- Estrategia militar de los 3 reinos en el clímax
- The First Wound (ficha lore completa), Sunken Archive (ficha lore)
- Cabeza de the Academy of Sages (baja prioridad)

### Narrativa / guión (próximo frente real)
- Guión completo por actos (GDD §1.2 tiene estructura, no hay diálogos)
- Voz narrativa (¿narrador? ¿silent protagonist? ¿qué tan verbose?)
- Momentos de Persona de Speck; diálogos del Bautizo (Darro la nombra)
- Los 5 Finales — scripting de diálogos/cinemática; estado post-final jugable; variantes C3 vivo/muerto

### Fichas de personaje pendientes
- **Old Tobin Hale — ficha expandida.** Solo aparece en `Geografía y Ciudades §The Driftmarket` y `Briefs de Concept Art §10b`. The Reckoning le dio peso dramático mayor (custodio inconsciente de los Goggles hace 40+ años) y ahora también una línea propia sobre el extraño anterior (`Geografía:965`, nueva 07-29). Estimado: ficha corta ~200-300 líneas, sin arco de traición.

### Concept art pendiente
- **§5c finales:** 5c.1 (F1) ya OK con el asset viejo; falta escribir 5c.4 (F4) y 5c.2/F2a — ver arriba
- Revisar las 4 escenas de traición (¿legacy o canon?); set de combos sin doc; QA de las 4 variantes de The Wilds; videos Higgsfield (bloqueo ffmpeg); King Borran 🟡; POIs sueltos cuando aparezcan en el guión

### Mapa del mundo
`Aether Bound universe.png` = referencia interna imperfecta (texto corrupto en etiquetas). Plan: documentar por escrito a medida que avanza el worldbuilding → al cerrar el frente, escribir spec exhaustiva. Ver cabecera de [[Briefs de Mapa del Mundo]].

**POSPUESTO (post-lore):** trailer formal, cutscenes cinemáticas, banda sonora.

---

**Historial completo:** [[LOG]] y [[Current-State-Historico]].
