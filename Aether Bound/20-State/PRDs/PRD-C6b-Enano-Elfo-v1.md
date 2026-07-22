---
status: en curso (piloto de proporciones ejecutado, VoBo pendiente)
created: 2026-07-20
updated: 2026-07-21
owner: Boris (director) / orquestador
---

# PRD — C6b: Enano y Elfo reales (cuerpo + arte racial)

> Orden acordado con Boris (2026-07-20): grupo C restante (hombro→torso,
> cintura) → pies (C4) → **este PRD**. No arrancar antes de esa señal.

## Alcance (más ancho de lo que dice el nombre "C6b")

El histórico ([[Current-State-Historico]]) definía C6b como cuerpo + ROM
enano/elfo. Boris amplía el alcance explícitamente: **cada raza necesita
también su propio catálogo de arte** — peinados y marca cultural
(warpaint/tatuajes/aether) distintos por raza, no solo la malla del
cuerpo. Confirmado en [[Fenotipos y Creación de Personaje]]: marca
cultural = aether luminoso (elfo) / tatuajes de gremio + inlays de metal
(enano, trenzas con anillas de forja) / warpaint Mistbound (humano, ya
resuelto). Este PRD cubre las 3 capas:

1. **Cuerpo:** proporciones esqueléticas fijas por raza (elfo: palancas
   largas, hombros estrechos caídos, cuello largo; enano: palancas
   cortas, trapecio masivo, cuello hundido, manos enormes, centro bajo),
   ROM, gait — [[Fenotipos y Creación de Personaje]] tabla completa.
2. **Peinados:** catálogo racial (comparte técnica con
   [[PRD-Catalogo-Peinados-v1]], pospuesto pero la TÉCNICA sí se hereda).
3. **Marca cultural:** aether luminoso (elfo, re-mapeo del slider
   `arcaneMod`) y tatuajes de gremio + inlays de metal (enano, slot
   facial mayor) — análogo al warpaint humano ya resuelto en
   `warpaint_atlas.gd`.

## Por qué optimizar ahora (pedido explícito de Boris)

> "¿Ves viable que podamos optimizar algo de trabajo tuyo en código para
> cuando lleguemos al enano y al elfo? Cada feature nos toma muchísimos
> tokens."

El costo real de esta ventana de trabajo (mandíbula, pelo, boca/mentón)
no fue el código en sí — fue el patrón **ajustar a ojo → renderizar →
zoom → leer imagen → ajustar de nuevo**, repetido decenas de veces por
pieza (el pelo se llevó ~25 rondas). Tres optimizaciones concretas para
C6b, en orden de impacto:

### 1. Reutilizar el rig humano vía `apply_phenotype`, no reconstruir geometría

La mayor parte del CUERPO enano/elfo ya tiene mecanismo: `character_rig.gd`
escala/reproporciona por slider (mismo patrón que `heightRange` por
origen, ya vivo). El trabajo real es **fijar los rangos y pivotes por
raza** (palancas largas vs cortas, hombros anchos vs caídos), no
autorar primitivas nuevas desde cero — eso es lo que sí fue caro en el
pelo (loft nuevo, fade nuevo, todo sin precedente). Antes de generar
ninguna pieza nueva, mapear qué % del cuerpo se resuelve con parámetros
existentes vs qué necesita geometría genuinamente nueva (orejas largas
del elfo, frente pesada del enano) — solo lo segundo paga el costo alto
de iteración visual.

### 2. Medir la superficie ANTES de autorar, como `_on_skull()`

La lección más cara del pelo: 3 rondas completas se perdieron por
asumir semiejes de cráneo inventados en vez de medirlos
(`SKULL_SEMI`/`SKULL_C` en `hair_library.gd`). Para C6b: derivar el
equivalente medido (semiejes de cráneo elfo/enano, tabla de ROM ya
referenciada en [[Current-State-Historico]] — "Humanizer + skeleton_config
53 huesos") ANTES de la primera pieza, no durante. Un helper mal medido
cuesta una ronda completa de render→zoom→corrección; un helper medido
correctamente desde el inicio la ahorra por completo.

### 3. Delegar el ciclo render→zoom→describir a un subagente barato

El costo de tokens de ESTE orquestador (Opus) creció principalmente por
leer directamente decenas de capturas con zoom intermedias durante la
iteración ciega. Patrón nuevo para C6b: un subagente Haiku (o Sonnet si
Haiku no distingue detalle suficiente — validar con 1 caso de prueba
antes de generalizar) ejecuta el loop render→zoom→comparar contra
lámina y devuelve SOLO el diagnóstico (qué falla, dónde, cuánto) — el
orquestador no gasta contexto en imágenes intermedias, solo en las
capturas de CIERRE de cada ronda (cuando decide si continuar o parar) y
en los QA formales (que ya usan subagentes). Riesgo a vigilar: un
modelo barato puede perder matices finos de silueta (ya documentado:
"un QA fresco no distingue tinta Sobel de banda de cel-shading") — por
eso el diagnóstico intermedio se trata como señal barata y rápida, no
como veredicto; el veredicto de cierre de ronda lo sigue dando el QA
formal + el ojo del orquestador, como hasta ahora.

## Orden de ejecución (cuando Boris dé la señal)

1. ✅ Cuerpo: mapeado qué proporciones ya resuelve `apply_phenotype` vs
   qué necesita geometría nueva (2026-07-21) — hallazgo: el cuerpo
   enano/elfo era un clon humano con solo `scale` UNIFORME (ninguna
   RATIO cambiaba); orejas/accent cultural YA existían.
2. Medir superficies nuevas ANTES de autorar (equivalente a `_on_skull`
   por raza) — pendiente, solo aplica cuando se ataque geometría nueva
   (orejas élficas largas, frente/mandíbula de enano). El PILOTO de
   proporciones (paso 3) no necesitó geometría nueva, solo reposicionar.
3. ✅ Piloto EJECUTADO (2026-07-21, sin subagente delegado — hecho
   directo por el orquestador): nuevo campo `"proportions"` por origin
   (`limb_len`/`shoulder_x`/`neck_len`/`head_scale`/`hand_scale`) sobre
   los MISMOS hooks de escala de peso/clase, sin geometría nueva. Medido
   en banco (no a ojo): enano 4.49 cabezas (objetivo 4.5), elfo 8.17
   (objetivo 8.0). Gates ALL_PASS, cero regresión humano. **Nota de
   optimización #3 (subagente barato para render→zoom): NO se probó
   esta ronda** — el ciclo completo (mapear→medir→piloto de ambas
   razas) se resolvió con pocas iteraciones numéricas (banco imprime
   "CABEZAS" directo, sin necesitar zoom manual), así que delegar no
   hacía falta todavía; queda para cuando entre geometría nueva
   (orejas/mandíbula), que sí es el tipo de iteración visual ciega cara.
   Detalle completo: [[LOG]].
4. ✅ Geometría nueva adelantada (2026-07-21, mismo día, pedido directo
   de Boris antes de esperar el VoBo del paso 3): oreja élfica
   rediseñada (alargada + barrida hacia atrás — leía como nudo
   horizontal, diagnosticado con `ANATOMY_HAIR=8` para ver la geometría
   sin el peinado default tapándola) y mandíbula/ceja por raza (campo
   `"face"` en `origins_data.gd`: `jaw_width`/`jaw_depth`/`brow_scale`/
   `brow_y`, mismo patrón de sesgo sobre rango de slider compartido que
   `proportions`). Verificado en banco (frente/3-4/perfil), gates
   ALL_PASS.
   **Ronda 2 de oreja (mismo día):** Boris pasó 2 referencias nuevas
   (Frieren + Zelda TotK) que reemplazan el criterio de la lámina de
   concept art para este rasgo — hacia afuera + leve arriba, no el
   barrido dramático hacia atrás de la ronda 1. 2 rondas de ajuste
   (rake trasero `rotation.x` -0.38→-0.15).
   **Ronda 3 — QA imparcial formal (2026-07-22, protocolo [[QA Loop]]):**
   ronda 1 del QA 40% (CRITICAL ángulo, HIGH punta roma, MEDIUM base
   gruesa) → fixes (z-tilt a ~8° sobre horizontal, rake -0.06,
   `radial_segments=4`, `bottom_radius` más fina) → ronda 2 del QA
   (mismo agente) **60-65%**, los 3 hallazgos RESUELTOS y verificados
   por píxel. Pendiente nuevo (MEDIUM, el propio QA lo marca como
   probable techo de la técnica de un solo cono): silueta compuesta
   tipo "hoja" — necesitaría más segmentos a lo largo del eje de la
   oreja, no un parámetro suelto. Gates mínimos ALL_PASS.
   **Ronda 4 — experimento de "hoja compuesta" (2026-07-22): CERRADO,
   REVERTIDO.** Se reusó `HairLibrary._loft`/`_lock` (curva+perfil de
   radios) con un plan formal (modo plan aprobado por Boris) — 3 rondas
   con QA imparcial de por medio en cada una, TODAS midieron peor que el
   cono (40% → 45% → 45-50%, vs 60-65% del cono). Diagnóstico del QA:
   a la escala de este rasgo, un perfil de radio decreciente lee "sin
   volumen" y una curva concentrada al final lee "gancho", no remate
   suave — el cono simple comunica la forma base con más claridad.
   Revertido al cono de la Ronda 3 (mejor estado medido). Nueva Lección
   documentada ([[Lecciones]]): loft/ribbon puede leer peor que un cono
   simple en rasgos chicos y cortos, no transferir la técnica de pelo
   sin verificar contra el baseline. **Estado final: oreja = cono,
   60-65%, sin cambio neto.** Gates ALL_PASS.
   **Ajuste puntual (mismo día):** base 25% más ancha (`bottom_radius`
   0.019→0.024) por pedido directo de Boris, sin tocar ángulo/largo/
   punta. Verificado en banco, gates ALL_PASS — sin re-medir con QA.
   **ROM por raza (`rig_biomech.gd`) sigue pendiente — PENDIENTE VoBo de
   Boris sobre TODO lo ejecutado (proporciones + orejas + mandíbula/
   ceja) antes de seguir.**
5. Peinados y marca cultural quedan referidos a
   [[PRD-Catalogo-Peinados-v1]] (pospuesto, pero la técnica de loft +
   `_on_skull` ya está probada y se hereda sin costo de re-descubrimiento).

## No-objetivos de este PRD

- No cubre el catálogo completo de peinados/warpaint (eso es
  [[PRD-Catalogo-Peinados-v1]] y Fase 4b, explícitamente pospuestos por
  Boris — "no creo que sea prioridad ahorita").
- No se toca antes de cerrar grupo C (hombro/cintura) y C4 (pies).
