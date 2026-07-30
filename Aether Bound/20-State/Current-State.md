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

**✅ 4ª re-corrida cerrada (18→17).** Canon fijado (detalle en [[LOG]]): costo de F1 = colapso tecnológico NO exterminio (F1 no es mejor que F4); gate de F4 = 2 condiciones; matriz de roles fija eliminada; `Geografía` = fuente primaria de ubicaciones; Goggles fuente única en `Nomenclatura`. **12 epílogos F1 reescritos** bajo la regla de costo.

**✅ 5ª re-corrida cerrada (15→13).** Canon fijado (detalle en [[LOG]]): Speck durmió 550 años en crisálida (su humor se refundó desde el desfase del despertar, no de haber mirado caer la civilización); 4 fichas cortas archivadas (`Dagna/Darro/Roen/Valen.md` → `90-Raw/`, regla nueva: una sola fuente viva por personaje); Bond vacío invertido en la celda de Bram; premisa de que la Muda no tiene reloj autónomo; gate de F1 al borde del cráter; Vekka → Deber Institucional. **Los 5 finales visuales completos** (`5c.1-5c.4a/b`, ratificados por Boris) — nota abierta no bloqueante: orejas de zorro simple en vez de pétalos.

## 6ª RE-CORRIDA QA — CORRIDA (2026-07-30). 9 críticos, 8 cerrados

6 de dramática + 3 de congruencia. Detalle completo en [[LOG]].

**Un patrón nuevo:** los 3 críticos de congruencia estaban en material *viejo que nadie había vuelto a mirar* (`Geografía §Beats Narrativos por Acto`, escrito antes de que las 9 fichas fijaran que el Pivote se une en el Acto 1) — no en la propagación de esta sesión, que salió limpia. El gate de F1 que escribí la ronda pasada también se contradecía a sí mismo en la misma frase ("detenido en el borde" + "carga hasta el centro").

**Cerrados:** gate de F1 reescrito sin contradicción (el punto exacto queda abstracto por diseño, cada ficha lo interpreta); Lyris F1/F3 alineadas a su propio sub-beat 5; Nyael y Bram F1 ahora mencionan a su agente sustituto (equipo de extracción / Torgan); premisa "sin reloj autónomo" bajada a la fuente real (`El Mundo y la Muda.md`, no solo a `Los 5 Finales`); ítem huérfano de `Bond y el Bond Vacío` reubicado; **Bound Five formado en Acto 1** propagado a `Geografía` y `Estructura Dramática` (decían Acto 2, las 11 fichas ya decían Acto 1); topología "rueda, no malla" reforzada (Geografía tenía 4 líneas describiendo conexión directa reino-reino); Momento de Persona 7 corregido a Acto 2; matriz de "3 cadenas de poder" con las 2 excepciones (Lyris, Bram); mecanismo de activación de Torgan alineado; gate de F4 con el calificador de Momentos disponibles; "sabor de traición por raza" corregido a "por arquetipo"; referencia rota de `5c.2b` y `CATALOGO.md` desactualizado.

### 🔴 Pendiente — decisión de Boris

**C4 — Iven rompe la fila "Deber Institucional" de la matriz en 2 de sus 5 celdas.** En F1 sobrevive querido en su asentamiento (la fila exige "muere o se autoexilia"); en F2a es "tolerado, no querido" sin ascenso (la fila exige "asciende sin celebración"). Su propia ficha ya se declara *"Deber Institucional en su variante envenenada"* — **¿la excepción es intencional** (Iven es el único cuya institución le mintió, y por eso su fila no puede leerse igual) **o hay que reescribir sus epílogos F1/F2a para que calcen**? No lo decidí por él; es un llamado de diseño, no un fix mecánico.

### Pendientes menores, sin bloquear el cierre
- `Los 9 Links del Pivote`/ficha de Bram no anotan la excepción del Bond invertido (solo vive en `Bond y el Bond Vacío.md`).
- 3 epílogos F4 (Maren, Iven, Bram) cierran en alza sin friccionar con "agridulce, no triunfal"; Roen F4 sin la pasada de tono que sí recibieron Valen/Darro.
- `.claude/worktrees/quirky-wiles-afa8a0/` — worktree real de git (rama `claude/strange-galileo-243fc7`, 62MB) con vault viejo adentro. No la toqué; revisar si hace falta.

### 🔜 Pendiente para cerrar el sprint

1. **Decisión de Boris sobre C4/Iven** (arriba).
2. **7ª re-corrida QA.** Criterio: 0 críticos.

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
