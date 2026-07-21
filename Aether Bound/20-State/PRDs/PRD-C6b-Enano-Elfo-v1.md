---
status: draft
created: 2026-07-20
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

1. Cuerpo: mapear qué proporciones ya resuelve `apply_phenotype` vs qué
   necesita geometría nueva (orejas elfo, frente/mandíbula enano).
2. Medir superficies nuevas ANTES de autorar (equivalente a `_on_skull`
   por raza) si hace falta geometría nueva de cabeza/cráneo.
3. Piloto de UN elemento (ej. cuerpo enano) con el ciclo delegado a
   subagente barato — validar que el ahorro de tokens es real antes de
   generalizar el patrón al resto.
4. Cuerpo completo de ambas razas + ROM.
5. Peinados y marca cultural quedan referidos a
   [[PRD-Catalogo-Peinados-v1]] (pospuesto, pero la técnica de loft +
   `_on_skull` ya está probada y se hereda sin costo de re-descubrimiento).

## No-objetivos de este PRD

- No cubre el catálogo completo de peinados/warpaint (eso es
  [[PRD-Catalogo-Peinados-v1]] y Fase 4b, explícitamente pospuestos por
  Boris — "no creo que sea prioridad ahorita").
- No se toca antes de cerrar grupo C (hombro/cintura) y C4 (pies).
