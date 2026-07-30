---
status: borrador
source: "Debate orquestador↔QA 2026-07-13 (QA-Auditoria-Tronco-Superior) + [[Art Bible]] + fenotipo-humano-v1 + quality-benchmarks VRM. Encargo del director: benchmark para que los músculos se vean bien y adhoc al Art Bible."
updated: 2026-07-13
---

# Benchmark — Musculatura del cuerpo base (torso y piernas)

> Rúbrica de aceptación para esculpir músculo en el rig procedural. Aplica al
> torso sin playera (constraint del director: si un outfit va sin playera,
> los músculos deben estar bien definidos) y a las piernas. El canon visual
> es [[Art Bible]] (Melancolía Gráfica) + la lámina fenotipo-humano-v1.

## Referencias (en orden de autoridad)

1. **`90-Raw/concept/fenotipo-humano-torso-v1.png`** (Nano Banana sobre la
   lámina original, depositada por el director 2026-07-13) — autoridad #1
   **SOLO para el lenguaje de superficie del TORSO desnudo** (alcance
   acotado, decisión del director 2026-07-13): pectorales planos con tinta
   mínima, clavículas discretas, oblicuos sugeridos en 1-2 trazos, abdomen
   tenso SIN six-pack, escápulas sutiles sin dorsales. **NO es referencia
   de identidad**: su barba/pelo/edad/complexión y su pose (manos en
   cadera) DIVERGEN del canon — para cara/pelo/silueta global manda la
   lámina original + rondas M9 aprobadas.
2. **`90-Raw/concept/fenotipo-humano-v1.png`** — LA verdad de identidad,
   proporción y silueta. Su lenguaje: definición por SILUETA (bumps de
   deltoide/bíceps/antebrazo) + POCAS líneas de tinta interiores sobre
   tono acuarela plano. Atleta ENJUTO: fibra, no masa.
3. **Norte del Art Bible**: BotW / Hinterberg / Palia / Torchlight III —
   formas grandes, siluetas limpias, nada de anatomía de figura heroica.
4. **`90-Raw/research/quality-benchmarks/*.png`** (VRM) — techo de pulido
   de referencia para el A/B de calidad general (no de anatomía).

## Reglas duras (heredadas de lecciones pagadas)

- **La tinta ES geometría**: el Sobel entinta escalones de profundidad. Las
  "líneas de fibra" de la lámina se fabrican con relieve + Sobel — NUNCA
  con textura (UVs de primitivas = traicioneros; lección del warpaint).
- **Patrón gemelo** (el único patrón de músculo ratificado por resultados):
  elipsoide escalada SEMI-HUNDIDA en el volumen anfitrión, protrusión
  **≤30% del radio**. Guarda anti-globo: el deltoide r1 (esfera entera
  encima) fue el error; el gemelo (masa que aflora) es el acierto.
- **El bulto se lee de frente por el ensanchamiento LATERAL (X)**, no por
  el sesgo frontal (Z) — lección de Fase B r2.
- **Toda masa nueva re-verifica los anillos/bandas que la rodean**
  (lección de la banda de bíceps ×2).

## Inventario canónico (qué se modela y qué NO)

| Zona | SÍ (masas de cel) | NO (anti-BotW / anti-lámina) |
|---|---|---|
| Torso | 2 pectorales elipsoides aplastadas; 1 placa abdominal única (plano tenso); clavícula-cápsula finísima (o nada) | six-pack, oblicuos, serratos, costillas, línea alba, ombligo, pec-cajas |
| Brazos | deltoide-gota; bíceps/tríceps/brachioradialis aplastados (hechos, r2d) | venas geométricas (van por C8 tonal si acaso) |
| Piernas | cuádriceps (masa frontal del muslo), gemelo (hecho, r4), corva/isquios sutil si el perfil lo pide | definición de rodilla interna, tibial, glúteo marcado |
| Espalda | escápulas opcionales (solo si el sin-playera trasero se ve vacío) | dorsales dibujados, columna acanalada |

## Criterios de aceptación (medibles en el banco)

1. **Distancia media (8 m)**: la silueta del torso muestra pecho→abdomen
   como DOS planos de cel distinguibles; sin líneas interiores de tinta
   nuevas dentro del torso.
2. **Close-up (4 m)**: el valle esternal entre pecs lo dibuja el Sobel
   SOLO (por el escalón entre elipsoides) — si aparece un rectángulo o
   anillo de tinta, la masa está mal hundida.
3. **Perfil**: el pecho protruye sobre el abdomen (~1-2 cm), el abdomen es
   plano-tenso (no cóncavo ni barril). La lectura es "enjuto fibroso".
4. **Horizonte (30 m)**: cero cambio — las masas NO alteran la silueta
   global aprobada (7.5 cabezas, hombros 0.57 m).
5. **A/B contra la lámina**: crop lado a lado (protocolo debate-tronco);
   el registro debe leer "mismo personaje, distinto medio".
6. **Gates**: test_core + autotest_biomech + autotest_combat ALL_PASS
   (las masas son hijas de mallas, jamás tocan pivotes/ROM).

## Vía del "pintado" (C8, ratificado — su rol exacto)

Gradientes procedurales + triplanar aportan SOLO refinamiento tonal
(gradiente acuarela mundo-Y, variación de tono piel). NUNCA líneas de
contorno muscular por textura. Si en Fase 4 el sin-playera pide más
detalle (ombligo, línea alba), se evalúa como C8 tonal — no geometría.
