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

**✅ Sesión de diseño 2026-07-29 — los 8 críticos + 3 MEDIUM de la 3ª re-corrida están resueltos.** Detalle completo (decisiones + cambios archivo por archivo) en la entrada del 2026-07-29 de [[LOG]]. Resumen de lo que quedó fijado como canon:

- **Agencia de Speck en 3 grados.** F4 = le preguntan (*responder*); F1 = deciden por ella y acepta (*aceptar*); F2a/F2b/F3 = se la arrebatan. El verbo importa: ninguna ficha puede hacer que Speck "elija" en F1. Fuente: `Speck.md §Capa 4`.
- **Regla del Fragmento — `Speck.md §Capa 5`, nueva y fuente única.** Sobrecarga por transferencia de fuerza mecánica cerca de un core activo. Esperar no la mata, cederla no la mata, arrebatarla sí. Ningún otro archivo puede enunciar la regla por su cuenta; todos citan ahí.
- **Transporte de Speck:** la entrega corta el pulso, y el cese del pulso es lo que la suelta del centro. Por eso F2a puede transportarla y `Nyael:261` sigue siendo verdad.
- **Gates desambiguados:** quietud que termina en pregunta = F4; forcejeo = F2b; **parálisis = F2a** (el Pivote entrega por defecto). No decidir hace ganar a la institución.
- **Isolde Marrow** degradada a reclamo de House Marrow. El "Último Reino" pasó a Pendientes como ítem de worldbuilding, ya no es una contradicción viva.
- **Longevidad de los 3 fijos** alineada a [[Las Tres Razas]]; **Darro a ~63 años** (sincronizado al canon de "hace ~30 años" que ya estaba en 6 lugares); **Valen no presenció ninguna Muda** y el "110 años" quedó marcado como error de la Academy.
- **Goggles no retirables** propagado: las 9 fichas + Valen dejaron de decir "se pone los Goggles" en el Archive. Se conserva el primer uso en la oficina de Tobin, donde ahora **no salen** al intentar quitárselos.

**Dos contradicciones raíz que el QA no había reportado, encontradas en esta sesión:** `Speck.md` era la fuente del crítico de Darro F1 (no una línea suelta), y el gate de F4 en `Los 5 Finales:88` colisionaba con la siembra de F2b en `Grove:68`. Más un residuo del gate viejo en `Iven:592`, hallado en el barrido post-fix. Confirma la nota de método: **corregir sin barrer todas las menciones no cierra nada.**

**3 críticos EXTRA encontrados en el barrido objetivo del cierre** (ninguno estaba en el reporte de la 3ª ronda), todos del mismo patrón "corregir sin barrer la clase completa":
- `Valen:58` — los ancianos: *"The Stillspire ha sobrevivido cuatro Mudas"*. Era **la fuente** del "cinco Mudas". Marcada como cosmología heredada falsa.
- `Geografía:613` — ermitaño: *"he visto dos mudas"*. Reescrito: vio dos **falsas alarmas** asentadas como Mudas en los archivos élficos. Lo vuelve testigo del error de registro y explica el respeto mutuo con Valen.
- `Torgan:11` — "75-80 años" contra `:66`, que fija 75 y se declara no negociable. Alineado a 75.

**Aritmética de Valen verificada:** hallazgos a los 140 → 40 años solo (180) → God-Core hace 30 años (200) → presente 230. Cierra con el encabezado "edades 100-180".

### 🔴 SIN COMMITEAR (2026-07-29)

**Todos los cambios de esta sesión están en disco y sin commitear.** El clasificador de Opus quedó fuera de servicio a mitad de sesión y bloqueó Bash, PowerShell y el Agent tool (lectura y edición seguían funcionando). Consecuencias para la próxima sesión:

1. **El commit incluye también los 16 archivos que ya venían modificados** de la sesión anterior — el baseline del Sprint 0 nunca pudo correr, así que los dos conjuntos de cambios están mezclados. Revisar el diff antes de commitear.
2. **Los 2 QAs de la 4ª re-corrida no se lanzaron.** Prompts descritos en el plan; lanzarlos con **Opus, en frío, en paralelo** (dramática + congruencia).

**Nota de método para los QAs:** que un barrido objetivo de 20 minutos sacara 3 críticos nuevos confirma que el cuello de botella no es el QA sino el barrido. Pedirles explícitamente que traten cada dato como una **clase de menciones**, no como una línea suelta.

### 🔜 Único pendiente para cerrar el sprint

**4ª re-corrida QA — 2 subagentes Opus en frío** (dramática + congruencia), sin contexto de los fixes para que no validen su propio trabajo. **Criterio de cierre: 0 críticos.** Si aparecen críticos nuevos, se repite el ciclo con el subconjunto afectado.

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
- **Speck:** último Warden cristalino superviviente, shapeshifteada como zorro. Narrativa + diseño visual 100% completo. Detalle en [[Current-State-Historico]].
- **Anatomía/rework (C6):** oreja élfica 75%, nacimiento de oreja 74/70/78%. Queda: ROM por raza (C4), pies sin IK.
- **Motor:** GODOT confirmado (ADR-002), en revisión por ADR-003.
- **Deuda técnica visible:** pies sin IK, ROM enano/elfo (C4 restante), mesh de bloques = etapa.
- **Riesgos abiertos:** frame budget frágil RTX 2060 (~58 fps warm); export a consolas requiere partner externo.

---

## Pendientes

### 🗓 Inmediato
- **4ª re-corrida QA** (ver arriba) — único criterio de cierre del sprint.
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
