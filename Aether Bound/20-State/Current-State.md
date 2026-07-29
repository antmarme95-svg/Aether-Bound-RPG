---
status: vivo
updated: 2026-07-27
---

# Current State

> Punto de entrada de TODA sesión. Describe dónde está el proyecto, nunca cómo
> funciona el juego (eso vive en `10-Knowledge/`).

## Estado general (2026-07-28)

**Worldbuilding narrativo:** las 9 fichas de Pivote + los 3 fijos + Speck + toda la estructura política y geográfica están escritos. El vault soporta escribir guión en cuanto cierre el sprint QA.

**Sprint QA de reparación — Fase 5 en curso, 2 bloques restantes.** Relato completo de las fases 0-4 migrado a [[Current-State-Historico]] (2026-07-28); detalle operativo en [[LOG]]. Plan: `~/.claude/plans/cozy-floating-unicorn.md`.

- **✅ Fases 0-4 completas** — documentos-fuente reescritos (5 finales + Grove of Cycles + Acto 3 en 5 sub-beats + Reckoning), 9/9 fichas de Pivote al canon, lint mecánico, propagación semántica, y re-corrida de verificación que reveló los huecos de cobertura que la Fase 5 está cerrando.
- **✅ Fase 5 Bloque D** — canon "los 9 Pivotes existen simultáneamente" + regla de aparición como NPCs externos + caso Torgan/Bram; matriz de finales corregida; rename a `Los 5 Finales.md` (29 cross-refs).
- **✅ Fase 5 Bloque A** — Torgan (485→579 líneas) e Iven (511→767) reescritas. **9/9 fichas de Pivote migradas.** Torgan: F2b sin suavizar, beat Warden de oficio y linaje, aritmética 55 años, sección de segundo agente de la ruta Bram. Iven: mentira del Council explícita + §Las tres grietas, F2b corregido (el asentamiento muere), F1≠F4, único de los 9 que llora en escena.
  - **✅ Fase 5 Bloque B (2026-07-28)** — propagación completa a Roen/Valen/Darro. Bram ya no traiciona en las 3 fichas (beat del corredor del Archive, aritmética 40 años); las 3 migradas al eje de 5 finales (F1/F2a/F2b/F3/F4, destino de Speck); Roen separa traición (Archive) de quiebre (cráter) + edad corregida a 45; Valen con cosmología reencuadrada como creencia errónea de la Academy (beat en Grove of Cycles) + edad estandarizada a 230; Darro con rechazo-versión-Vekka (aprendiz 30 años atrás, 2 años, rechazo sin explicar) + sección Darro+Vekka reescrita + género de Speck corregido. Tablas de dinámicas: 7/9 entradas de raza/rol falsas corregidas en las 3 fichas (más de las 6 reportadas — Maren/Torgan/Iven también estaban mal). Detalle completo en [[LOG]].
  - **✅ Fase 5 Bloque C (2026-07-28)** — lint final cerrado. Headcount corregido en Lyris/Sereth/Nyael (solo Roen+Valen+Darro+Pivote, sin otros Pivotes en escena — consistente con "solo 1 conoce al jugador"); `Los 9 Pivotes.md` resincronizado (línea de Sereth y de Nyael ya no cruzadas); Sunken Archive = Acto 3; Grove of Cycles tras los 3 sub-actos; Bram 40 años en Estructura Política; Sereth "Royal Academy" en vez de "el Consejo" ambiguo; Geografía F2a/F2b desambiguado; Mistbound "suroeste profundo" en las 2 fichas; Torgan/Dagna ya no comparten "Clan de Forja" en Geografía; Vekka ya no tiembla (Roen); fórmula "primera vez en la historia registrada" desduplicada. **Sprint QA de reparación — Fase 5 CERRADA.** Detalle completo en [[LOG]].

- **🔴 Re-corrida de verificación (2026-07-28) — EL SPRINT NO CIERRA.** Los 2 QAs re-corridos en frío con Opus 5: **7 CRÍTICOS de congruencia + 5 de dramática.** Reporte completo en [[LOG]].
  - **✅ Validado limpio:** cero residuos del esquema viejo de finales en las 9 fichas; Bram no traiciona (consistente en 9 apariciones); Speck femenina (0 errores); raza/rol de los 9 correcta; timeline consistente. Los 9 Pivotes son genuinamente distintos — Torgan e Iven declarados listos para diálogo sin más trabajo.
  - **✅ 6 de los 7 críticos de congruencia YA CORREGIDOS** en la misma sesión. **Varios eran errores míos de los Bloques B/C** (corregir encabezados sin leer el cuerpo debajo; dar archivos por cerrados tras arreglar la primera ocurrencia sin barrer el resto). Detalle honesto en [[LOG]].
  - **✅ C1 CERRADO (2026-07-28) — decisión de Boris.** Torgan es el segundo agente de la ruta Bram, actuando él mismo por su propia cadena de mando — no un mensajero anónimo. Corregido en `Bram-Ficha` (sub-beat 4a) y `Geografía` (§Acto 3 sub-beat 3), alineados con `Los 9 Pivotes` y la sección dedicada en `Torgan-Ficha`. **Los 7 críticos de congruencia quedan en 0.**
  - **✅ D1 CERRADO (2026-07-28) — decisión de Boris.** Roen, Valen y Darro tienen ahora un **pico** (quiebre más hondo, ligado a un Pivote) y **2 versiones suaves** (una por cada otra fila de arquetipo de [[Los 5 Finales]]), en vez de arco solo-en-1-ruta. Roen: pico Dagna (sin cambios) + suave Sereth + suave Lyris. Darro: pico Vekka + suave Lyris + suave Dagna (**gap real encontrado: no existía entrada "Darro + Dagna"**, agregada). Valen: pico nuevo Nyael (espejo de su propia falla — observar sin intervenir) + suave Sereth. Detalle en [[LOG]].
  - **✅ D2 CERRADO (2026-07-28) — decisión de Boris.** F4 ya no se llama "final verdadero" (etiqueta descriptiva nueva: "el único con consentimiento de Speck"). Costo real agregado: Speck no vuelve con el grupo, la calcificación es permanente — el jugador rompe su propio Bond por elección. Sabor explícito: agridulce, misma familia sonora que F2b, no victoria limpia. Detalle en [[LOG]].
  - **✅ D3 CERRADO (2026-07-28) — decisión de Boris.** Los 7 Momentos de Persona escritos en `Speck.md` (antes: frase-placeholder). Cada uno es Speck actuando primero, por su cuenta, con lectura ambigua herramienta/mascota/persona — el Vector C del Grove (ya existente) es ahora el Momento 6 oficial, molde del resto. Colateral: residual "beige" (paleta vieja) limpiado en 4 archivos. Detalle en [[LOG]].
  - **✅ D4 CERRADO (2026-07-28) — decisión de Boris.** La ruta Nyael tiene antagonista funcional en el cráter: el pulso del core no distingue quién carga a Speck, así que su "ruta 7" se rompe ahí igual que le rompería a cualquiera. Nyael sigue sin reaparecer nunca (ausencia total intacta); quien el jugador enfrenta es el equipo de extracción institucional que ella activó. F2a y F3 de su ficha reescritos para no contradecir esto. Detalle en [[LOG]].
  - **✅ D5 CERRADO (2026-07-28) — decisión de Boris. LOS 12 CRÍTICOS EN 0.** F2b ya no se abre por timeout — ahora es elección activa: el jugador intenta arrancarle a Speck por la fuerza y el forcejeo sobrecarga el Fragmento. Propagado a Geografía y a las 2 fichas (Bram, Nyael) que tenían lenguaje pasivo residual. Detalle en [[LOG]].
  - **Patrón de fondo (ambos QAs coinciden):** lo grave está **fuera** de las fichas de Pivote, en los documentos que las citan — `Geografía`, `Estructura Política` y las 3 fichas de fijos quedaron pre-rework mientras las 9 fichas avanzaban. **El próximo pase debe ser de propagación hacia afuera, no de más profundidad hacia adentro.**

  **Reportes completos de los 2 QAs de Fase 4** (con líneas exactas y citas textuales): ver entrada del 2026-07-28 en [[LOG]].

**Decisiones de lore tomadas por Boris (2026-07-28), aplicables a los Bloques A/B/C:**
- **Los 9 Pivotes existen simultáneamente** en el mundo; solo 1 conoce al jugador (ya documentado en Bloque D)
- **Rechazo de Darro:** versión Vekka — fue su aprendiz ~30 años atrás, le enseñó 2 años, al tercero lo rechazó del programa formal en persona y nunca le explicó por qué
- **Cosmología de Valen:** su creencia en "Mudas cada 300 años" es **errónea** — la enseña the Academy of Sages, y descubrirlo es un beat del personaje. Se conserva el texto, cambia el marco
- **Timeline:** Sunken Archive = Acto 3; Grove of Cycles tras cerrar **los 3** sub-actos; 4 God-Cores destruidos antes del Grove

**Worldbuilding narrativo previo:** COMPLETO como fuente para guión (3 reinos + Triune Council + The Elder Circle + Lady Isolde Marrow + Old Tobin Hale + The Reckoning + 12 personajes con fichas + Speck).

---

## 🟡 Ediciones directas de Boris pendientes de procesar (2026-07-28)

Boris editó 4 archivos en Obsidian fuera de la conversación con Claude, con preguntas explícitas para retomar:

- **`Nomenclatura.md`** — nota directa: *"revisar control de cambios porque agregué a propósito ciertos puntos."* Adiciones: Lady Isolde Marrow ahora es **tatara-tataranieta del último rey** (refuerza su reclamo a la Corona hereditaria — verificar consistencia con la genealogía de King Borran, ADR/Estructura Política); the Wanderer's Goggles se vuelven **accesorio no retirable** una vez usado por primera vez (verificar consistencia con Los 5 Finales §F4 y con Geografía §The Reckoning).
- **`Speck.md`** — cambios sin pregunta explícita, revisar intención: pelaje de beige/gris mineral → rojo/naranja (quedó un "beige" residual al final de la oración, posible edición a medias — confirmar con Boris); ojos a facetados-naranjas con nota nueva de que los zorros normales de The Wilds los tienen café-casi-negro (buen detalle de distinción visual); **se eliminó por completo la sección "Giro Grogu"** (memoria de especie / "es la infancia de un guardián menor de mantenimiento") — confirmar si fue intencional o accidental, porque otros documentos podrían asumir ese lore.
- **`The Bound Five.md`** — pregunta de diseño: los Bonds no deben ser solo jugador↔Pivote — desarrollar bonds/links propios para **Roen, Darro y Valen** a partir de su raza/rol. El Bond del Pivote es el más útil narrativamente conforme avanzan los actos (construye "dramatismo silencioso"), pero se necesita un mecanismo donde los 9 bonds totales sean protagonistas por igual, sin importar qué celda (raza/rol) elige el jugador. **Es una pregunta de sistema, no solo de contenido** — probablemente toca `The Tether` y `Bond y el Bond Vacío` también.
- **`Principios de Anatomía 3D.md`** — Boris pegó un dump extenso sin formatear de investigación biomecánica de DOF (grados de libertad): complejo escapulotorácico (+3 DOF), miembro superior completo (10 DOF), complejo de pelvis (+3 DOF), miembro inferior (9 DOF), columna vertebral por regiones (72 DOF total: cervical 21 + torácica 36 + lumbar 15), mano (21-24 DOF), y una sección sobre el trade-off DOF vs. costo de cómputo en videojuegos (IK, rigging, ragdolls). Pide incorporarlo a la **documentación técnica agnóstica de motor** — probablemente amerita reestructurarlo en tablas/secciones legibles en vez de dejarlo como bloque de texto corrido. Nota: esto es insumo de referencia, no bloqueado por ADR-003 (es documentación, no código).

**Concept art:** catalogado y trackeado. Ver `90-Raw/concept/CATALOGO.md`.
- §9 (gobernantes + Council): 5/6 ✅, King Borran 🟡 provisional
- §10 (elenco político nuevo): 6/6 ✅ cerrado
- §6d (keyframes ciudades, QA retroactivo): Emberdeep/Stillspire/Mistbound ✅, Rivermeet daylight 🟡, Driftmarket 🔴 (pendiente re-corrida)
- §L (UI Mockups, 2026-07-28): 3/3 ✅ aprobados (character-creation, main-menu, tether-screen); main-menu 🟡 ajuste visual menor
- §M (Marketing, 2026-07-28): 🟡 key-art-poster v2 genera v2 (tone → cozy-fantasy, Speck + Iron-Blooded presencia)
- Fenotipos / Speck / Finales: renombrados y trackeados

**Motor:** GODOT confirmado (ADR-002). Branch: `feat/c6-anatomy-rework`.

---

## 🔴 BLOQUEO ACTIVO — no se toca código

**[[ADR-003 Reset de desarrollo y motor]] está ABIERTO** (2026-07-28). El director planteó hard reset de código + revisión de la decisión de motor (Godot → posiblemente Unity).

**Mientras esté abierto:**
- ❌ No se escribe código de producción, ni en Godot ni en Unity. Frente C (técnico) del Task-Board congelado.
- ✅ **Sigue desbloqueado:** worldbuilding, guión, concept art, mockups de UI, diseño de sistemas en papel.

**5 criterios a resolver, en orden:** (1) vertical slice mínimo → (2) target de plataforma → (3) alcance v1 vs post-lanzamiento → (4) motor evaluado contra el slice → (5) inventario de qué se conserva. Requiere sesión con el director; no delegable.

**Nota clave del análisis:** el riesgo mayor no es el motor — es que el alcance narrativo (9 Pivotes × 5 finales × 9 celdas) creció a escala de estudio mediano. Ningún motor resuelve eso.

---

## Hechos vigentes

- **Branch actual:** `feat/c6-anatomy-rework`. Playtest: `Start-Playtest-Greybox.bat`. Gates: `autotest_combat.gd`, `autotest_springboard.gd`. **Congelados por ADR-003.**
- **Speck:** último Warden cristalino superviviente, shapeshifteada como zorro. Narrativa + diseño visual 100% completo. Detalle en [[Current-State-Historico]].
- **Anatomía/rework (C6):** oreja élfica 75%, nacimiento de oreja 74/70/78%. Queda: ROM por raza (C4), pies sin IK.
- **Motor:** GODOT confirmado (ADR-002).
- **Bloqueos:** ninguno.
- **Deuda técnica visible:** pies sin IK, ROM enano/elfo (C4 restante), mesh de bloques = etapa.
- **Riesgos abiertos:** frame budget frágil RTX 2060 (~58 fps warm); export a consolas requiere partner externo.

---

## Pendientes — ordenados por fecha

### 🗓 Próxima sesión — re-correr los 2 QAs una última vez (criterio de cierre real)

**Los 12 críticos (7 congruencia + 5 dramática) están en 0** (2026-07-28: C1, D1, D2, D3, D4, D5 todos cerrados — detalle completo en [[LOG]]). No queda ninguna decisión de diseño pendiente de Boris para este sprint.

Falta solo **re-correr los 2 QAs en frío contra el estado actual del vault** — es la tercera re-corrida (Fase 4 original → verificación C1-C7/D1-D5 → esta). Si dan 0 CRÍTICOS, el sprint QA de reparación queda formalmente cerrado y el frente siguiente es **guión y diálogos por actos**, sin bloqueos pendientes.

Después de esas 6: un **pase de propagación hacia afuera** (Geografía, Estructura Política, las 3 fichas de fijos) + rework de Lyris (la ficha más débil por margen grande, con la esencia contradictoria en 3 lugares) + los 14 importantes / 11 menores listados en [[LOG]].

**Nota de método (lección de esta sesión):** corregir encabezados sin leer el cuerpo debajo, y dar un archivo por cerrado tras arreglar la primera ocurrencia de un patrón, produjo 6 hallazgos evitables. Todo fix de lint debe barrer el archivo entero por patrón, no por línea reportada.

**Nota estratégica:** con el sprint cerrado, el próximo frente real es **guión y diálogos por actos** — no queda razón técnica para postergarlo.

### 🔜 Próximas sesiones (sin fecha fija)

**Concept art pendiente:**
- **✅ 14 briefs NB2 nuevos escritos (2026-07-27)** en [[Briefs de Concept Art]] §11 (Haiku 4.5). Batch completo listo para correr en NB2 al ritmo que Boris quiera. Cubre: Driftmarket re-corrida, Wanderer's Goggles (item — inaugura carpeta `90-Raw/concept/props/`), Sunken Archive interior, First Wound clímax jugable, Grove of Cycles interior, oficina de Tobin, 3 torres de guardia (Aethelgard/Ignis Reach/Stillwood Watch), Rivermeet Council Chamber, Emberdeep vertical, Ascending Falls, Iven's Settlement, Mistbound Frontier interior. Todos con regla anti-texto + estilo maestro canónico.
  - **✅ CERRADO (2026-07-27) — 14/14 briefs corridos en NB2 y con QA completo.** 13/14 ratificadas al primer o segundo intento; solo Sunken Archive requirió v2 (v1 se leía como catacumba egipcia con momias, v2 resuelve con cuerpos-cristal fundidos a la piedra). Todas las imágenes ya guardadas en `90-Raw/concept/` (Wanderer's Goggles en `90-Raw/concept/props/`). Detalle completo por brief en [[Briefs de Concept Art]] §11. **§11 del brief-writing y su QA quedan completamente cerrados** — próximo frente de concept art es evaluar el material fuera de este batch (escenas de traición legacy, set de combos, videos Higgsfield).
- Revisar las **4 escenas de traición** (`Traición_Dagna.png`, `La traición ejecutada.png`, `El primer viso de la muda.png`, `El Último Vínculo.png`) — confirmar si son legacy o canon, decidir si archivar o catalogar
- Evaluar el **set de arte de combos** como conjunto (Arcane Ballistics, Skyhook, Mobile Foundry, Weaver's Net, Skipping Stone, Riposte Runner, Guided Avalanche, Warforging, Seismic Springboard + videos) — no tienen doc en `10-Knowledge/` todavía
- QA de las **4 variantes de The Wilds** sin procesar (`Arterias`, `Interior`, `Noche con Muda`, `Ruinas`)
- Evaluar **videos Higgsfield** (bloqueo técnico ffmpeg activo): `Arcane Ballistics.mp4`, `Las Tres Razas.mp4`, `El Mundo.mp4`, `SKYHOOK.mp4`, `Seismic Springboard (2).mp4`, `Speck video.mp4`, `THE WEAVER'S NET.mp4`
- **King Borran** 🟡 — si se retoma: reescribir el prompt en prosa corta (mismo formato que resolvió Kadrun v2)

**Keyframes faltantes de brief (2026-07-27):** ✅ **14 briefs escritos** (ver arriba, §11 de Briefs de Concept Art). Pendiente solamente correr los 14 en NB2 y hacer QA de resultados. Único brief que sigue faltando por escribir:
- **POIs de The Wilds sueltos** según necesidad narrativa (no listados aún, van cuando aparezcan en el guión).

**Narrativa / guión (próximo frente real):**
- Guión completo por actos (GDD §1.2 tiene estructura, no hay diálogos)
- Voz narrativa definida (¿narrador? ¿silent protagonist? ¿qué tan verbose?)
- Momentos de Persona de Speck (~7 escenas sin UI)
- Diálogos del Bautizo de Speck (Darro la nombra)
- Los 4 Finales — scripting de diálogos/cinemática
- Estado post-final jugable
- Variantes C3 vivo/muerto en Finales 2-3

**Worldbuilding — cultura/lore (pendiente):**
- Culturas por raza — ceremonias, idioma, costumbres (Aether-Born/Iron-Blooded/Restless)
- Lore de civilización Warden pre-caída
- Estrategia militar de los 3 reinos en el clímax
- The First Wound (ficha lore completa), Sunken Archive (ficha lore)
- Cabeza de the Academy of Sages (baja prioridad)

**Fichas de personaje pendientes (2026-07-27):**
- **Old Tobin Hale — ficha expandida.** Solo aparece descrito en `Geografía y Ciudades §The Driftmarket` y en `Briefs de Concept Art §10b`. La escena de The Reckoning acaba de darle un peso dramático mayor (custodio inconsciente de los Wanderer's Goggles hace 40+ años) y necesita biografía formal para escribir su diálogo y las variantes por Pivote. Estimado: 1 ficha corta (~200-300 líneas), mismo formato que fichas de fijos pero más contenida (no tiene arco de traición).

**Mapa del mundo:**
- `Aether Bound universe.png` = referencia interna imperfecta (texto corrupto en etiquetas). Plan: documentar el mapa por escrito a medida que avanza el worldbuilding → cuando cierre el frente, escribir spec exhaustiva para re-generar con AI o dibujo a mano. Ver cabecera de [[Briefs de Mapa del Mundo]].

**POSPUESTO (post-lore):** trailer formal, cutscenes cinemáticas, banda sonora.

---

**Historial completo:** [[LOG]] y [[Current-State-Historico]].
