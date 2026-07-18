---
status: aprobado
source: "Traducción a PRD (subagente PRD del [[QA Loop]], 2026-07-17) del plan aprobado por Boris: reescritura from-scratch de la escultura de `character_rig.gd`. Insumos: QA imparcial rostro 2026-07-17 (35%), QA imparcial torso 2026-07-16 (~40%), 3 exploraciones de contrato/consumidores, [[Principios de Anatomía 3D]], [[Benchmark-Musculatura-Torso]], [[Lecciones]]."
updated: 2026-07-17
---

# PRD — Reescritura de la Escultura del Rig v1

> **Orquestador/implementador: este chat (Fable).** QA imparcial por fase
> vía subagente sin contexto de sesión (protocolo [[QA Loop]], re-invocación
> del MISMO agente por ronda). Este PRD reemplaza el ajuste de parámetros
> por una reescritura por masas de la construcción de meshes, conservando
> intacto el andamiaje (API, pivotes, contratos con consumidores).

## Objetivo (por qué reescribir, no seguir tuneando)

Dos QA imparciales consecutivos confirmaron que el ajuste de parámetros
tocó su techo:

- **Rostro: 35% de fidelidad** (QA imparcial 2026-07-17 vs
  `fenotipo-humano-rostro-v1.png`): "el modelo lee blando/redondeado tipo
  bola con calcomanías, no por masas"; `chin_boss` lee como rectángulo
  suelto; mandíbula y mentón "simplemente no están". **Baseline
  registrado.**
- **Torso/hombros: ~40% de fidelidad** (QA imparcial 2026-07-16 vs las
  láminas de cuerpo). **Baseline registrado.**

El propio [[QA Loop]] fase 6 dicta qué hacer cuando el QA declara que no
hay más margen con el vocabulario técnico actual: **cambiar de enfoque,
no seguir tuneando**. `character_rig.gd` (3046 líneas) arrastra 6+ rondas
de calibración fosilizada por pieza — cada fix nuevo pelea contra números
heredados que ya nadie puede justificar contra la lámina.

**Decisión aprobada:** reescribir la construcción de meshes (la
"escultura") desde cero, por masas, contra las 3 láminas como autoridad —
conservando intacto el andamiaje (API pública, pivotes biomecánicos,
contrato con outfit/signature/tests/combate) que las 3 exploraciones
mapearon al detalle.

## Contrato DURO a preservar (verificado contra consumidores reales)

No se toca nada de esto — los gates y módulos externos lo consumen:

- **`class_name CharacterRig extends Node3D`** y las 12 funciones públicas
  con firma exacta: `apply_phenotype(p, origin)`, `apply_archetype(id)`,
  `set_motion()`, `play_attack()`, `play_strike()`, `strike_progress()`,
  `strike_phase()`, `play_flinch()`, `set_guard()`, `play_parry()`,
  `constraint_report()`, `reset_constraint_report()`.
- **Jerarquía de pivotes** `body > hips > spine(lumbar) >
  upper_spine(torácico) > head` + `arms[]`/`legs[]`, y las constantes que
  los posicionan (`HEAD_Y`, `NECK_Y`, `SHOULDER_X=0.21` —confirmado vs
  lámina, no tocar—, `SHOULDER_Y`, `UPPER_SPINE_Y`, `HEAD_SCALE`,
  `CHEST_X` — `character_outfit.gd:162` divide por `_Rig.CHEST_X`).
- **Metas**: `arm.{elbow,upper,fore,hand,side}`, `leg.{knee,thigh,shin}`,
  `eye_group.side` — biomech/signature/tests las leen.
- **Nombres de propiedad**: `body, hips, spine, upper_spine, head, torso,
  pelvis, waist, skull, jaw_mesh, arms, legs, eyes, brows, cheeks, veins,
  hair_slot, beard_slot, feature_slot, tail_slot, goggles, prosthetic`.
  Nombres de nodo `"pauldron"` y `"jaw"` (buscados por `find_child`).
- **Materiales**: `skin_mat, head_mat, hair_mat, leather_mat` (+ internos)
  construidos vía autoload `ToonMaterials`; warpaint vía `WarpaintAtlas`;
  pelo vía `HairLibrary` en `hair_slot` (NO se reescribe pelo — el loft es
  la Propuesta-Recursos #2, fase aparte).
- **`_apply_build()`** escribiendo `torso/pelvis/waist.scale` y
  `upper/fore/thigh/shin.scale` (contrato con outfit/signature), con
  `arch_xz` warrior=1.30 / thief=0.80.
- **`rig_biomech.gd`** (`_Biomech`), `_apply_joint_constraints`, ROM,
  fases de strike — cero cambios de comportamiento.
- **Modelo de datos** intacto: `PhenotypeData`, `OriginsData`,
  `CharactersData`, `Config` + JSONs. Los sliders `jaw/cheek/eyeTilt/
  eyeShape/weight/height` deben seguir teniendo efecto equivalente.

## Alcance: lo que SÍ se reescribe (el interior viciado)

Los bloques de construcción de primitivas dentro de `_build()` de
`godot/character/character_rig.gd` (secciones cara líneas ~894-1307,
torso/hombros ~385-594, masas musculares) y los tramos de
`apply_phenotype` que escalan esas piezas. Se eliminan
`_add_outline_pass`/`_apply_outline_to_children` (no-ops confirmados) y
todo el historial de comentarios r1-r6 — el archivo nuevo documenta la
REGLA de cada masa (qué lámina/página del libro la justifica), no la
arqueología.

## Principios de escultura (canon ya ratificado, no inventar)

De [[Principios de Anatomía 3D]] + [[Benchmark-Musculatura-Torso]] +
[[Lecciones]]:

1. **Primitiva por masa**: caja = todo plano/borde (mandíbula, mentón,
   pómulo, pelvis, acromion); cilindro = segmentos rígidos + caja torácica
   ("bullet", nunca caja recta); esfera = SOLO articulaciones y masas
   genuinamente redondas. Una esfera nunca da borde anguloso bajo el toon.
2. **Torso = 3 masas** (caja torácica 2/3 + cintura deformable + pelvis
   inclinada), sin reloj de arena masculino; cintura escapular
   (clavícula-S ×2 + acromion + trapecio con pendiente) como bloque
   montado SOBRE la caja torácica.
3. **Cara por masas**: cráneo con forma + plano facial; mandíbula/mentón
   como estructura angular DE CAJAS fundida (no esfera + parche); ojos a
   la MITAD de la cara, separados 1 ancho de ojo; nariz con raíz y quiebre
   de puente; boca integrada al plano facial (hoy sobresale como pico de
   pato — CRITICAL/HIGH del QA); pómulos como planos que emergen, no
   calcomanías. La órbita ósea no se mueve con la ceja (sliders).
4. **Fusión**: overlap real ≤30% de protrusión, verificado en LOS 3 EJES
   (lección `chin_boss`↔`neck`: padres distintos se solapaban en Y, no en
   Z), caras frontales con `pos_z + radio` calculado, no estimado.
5. **Todo salto de tinta es geometría** — el Sobel full-screen de
   `melancolia_post.gdshader` entinta cualquier hueco real de profundidad;
   no existe outline por pieza.

## Fases de ejecución

Cada fase cierra con: gates de regresión verdes + QA imparcial + VoBo de
Boris. **Regla de freno: máx. 2 rondas de QA por fase sin reportar a
Boris**; si el QA declara techo de técnica, se para y se decide, no se
tunea.

### R0 — Banco confiable (medio día)

- Verificar la cámara de perfil: el QA la vio sobre-rotada (~110-120°)
  pero `tmp_anatomy.gd:138` es un 90° geométrico exacto — diagnosticar
  contra el PNG real (candidatos: yaw del `_holder` o del rig). Corregir
  lo que sea que esté mal.
- Agregar al banco 2-3 capturas CLOSE-UP institucionales (mentón/cuello,
  unión hombro-cuello) — la lección del zoom deja de ser un paso manual
  de PowerShell y queda horneada en `tmp_anatomy.gd`.
- Baseline: correr el banco y guardar el set pre-reescritura para
  comparación A/B.

**Cierre R0:** cámara de perfil verificada/corregida + close-ups en el
banco + set baseline A/B guardado + gates mínimos verdes.

### R1 — Cabeza/rostro desde cero — ✅ CERRADA (2026-07-17, 57% final)

**Ejecutado (8 rondas internas + 3 rondas de QA imparcial Fable, mismo
agente):** mandíbula como estructura de cajas (`jaw_mesh` central — su
AABB sigue siendo el mentón que mide el banco, el slider `jaw` escala la
estructura completa vía hijas — + 2 ramas + 2 facets de cuerpo); cráneo
con la mitad inferior retraída (coronilla intacta; la mandíbula dibuja
la silueta de la cara baja — el fix de mayor impacto según el QA); boca
aplastada casi al ras; raíz de nariz nueva; pómulos acostados sobre la
normal local (rampa, no pared); ojos a mitad de cara con convergencia
~3.5°; glint espejado; labio rosa-tierra (absorbe la Fase 4a del PRD
v2). `chin_boss`/`chin_bridge`/`jaw_angle` retirados. Sliders
`jaw/cheek/eyeTilt/eyeShape` re-conectados. Warpaint y slots intactos.

**Resultado: 35% → 40% → 52% → 57%. Sin regresiones. Techo de la
técnica de primitivas (~60%) alcanzado y certificado por el QA ("no
gastar más rondas; el costo/beneficio ya es negativo"). VoBo de ruta de
Boris: cerrar aquí y seguir a R2.** Gates ALL_PASS en cada ronda.

**LISTA RESIDUAL (insumo directo de la futura pasada con técnica nueva
— NO atacar con primitivas, ya se demostró que no responde):**
- **HIGH — Labios decal/malla:** sustituir la cápsula con borde café por
  labios como cambio de plano al ras + color por textura/vertex color
  SIN contorno perimetral. Verificar frente (hoy "curita"), 3/4, y
  ángulo bajo (hoy rebasa la silueta facial).
- **HIGH — Máscara de tinta selectiva:** el Sobel entinta el perímetro
  360° de la nariz y deja restos en el pómulo derecho. Criterio de
  aceptación: en close-up frontal ninguna línea de tinta forma polígono
  cerrado alrededor de un rasgo.
- **HIGH — Fusión del bloque mandibular en vistas no frontales:**
  biselar esquinas ortogonales visibles desde abajo/perfil cercano.
- **MEDIUM — Oreja con volumen** (hélix; hoy óvalo-decal de perfil) —
  geometría por-origen. **MEDIUM — quiebre goníaco biselado** (hoy
  vértice de caja; la lámina lo suaviza con masetero).
- **LOW — Mirada 3/4 residual** (esclerótica exterior de más en el ojo
  lejano; subir convergencia o córnea curva).

### R2 — Torso/hombros por masas (cierra la Fase 1 del PRD v2: 40%)

- 3 masas de torso + cintura escapular según el libro; resuelve de raíz
  el CRITICAL "peto/cartón", los HIGH (hombros-globo, trapecio sin
  pendiente, perfil tabla) y MEDIUM (cintura dibujada, clavícula
  flotante).
- `_apply_build()` se re-implementa sobre las masas nuevas conservando su
  contrato de escalas.

**Cierre R2:** gates + QA imparcial vs `fenotipo-humano-torso-v1.png` +
`fenotipo-humano-v1.png` + VoBo.

### R3 — Extremidades y manos — ✅ CERRADA (2026-07-17)

**Ejecutado (4 rondas internas + 3 rondas de QA de fase, mismo hilo):**
palma plana + prisma de taper (nudillos anchos → muñeca angosta); dedos
con bases abiertas y puntas convergentes (mitón frontal roto), curl
distinto por dedo, nudillos hasta la silueta dorsal; pulgar hundido
naciendo de la eminencia tenar (nueva); muñeca encogida (punto más
delgado real); gemelo con bulge posterior de silueta en perfil. Brazos/
piernas: patrón gemelo conservado sin cambios.

**Resultado: MANOS 45% → 60% → 70% (objetivo ≥70% CUMPLIDO);
EXTREMIDADES 60% → 68% (techo de primitivas — el gap restante es
íntegramente la bolsa de bisel/malla).** Gates ALL_PASS. La regresión
de ronda 3 (isla de tinta en dorso izquierdo) se resolvió antes del
cierre, verificada en pixel.

**Residuales R3 (registro):**
- Bolsa bisel/malla (heredada, compartida con R1/R2): anillos de tinta
  codo/hombro (look maniquí), escalón de rodilla, transición abrupta
  del bulge del gemelo.
- LOW de primitivas: slivers naranjas (2-3 px) en canto del pulgar
  derecho; pulgar izquierdo sin dirección de enrosque legible; seam
  highlight horizontal en muñeca izquierda; chevrones toscos de
  separación frontal de dedos (aceptables a distancia de juego); muslo
  tubular sin cuádriceps (ROI casi nulo con pantalón oscuro — no
  atacar).

### R4 — Integración y cierre

- Cuerpo completo ensamblado, orígenes (`_build_origin_features`
  re-anclado a la geometría nueva: orejas por raza, armadura iron,
  venas), outfit y signature verificados encima del rig nuevo, Dagna y
  enemigos en el greybox.
- Batería completa: `test_core`, `autotest_biomech`, `autotest_combat`,
  `autotest_springboard`, `autotest_rig`, `autotest_slice`, `autotest_ui`
  ALL_PASS + playtest visual en `Start-GoldenScene.bat`.

**Cierre R4:** batería completa ALL_PASS + QA imparcial final de cuerpo
completo + VoBo de Boris.

## Verificación end-to-end (transversal a las fases)

1. Por fase: `tmp_anatomy.gd` (4 vistas + close-ups nuevos + medidas
   numéricas: 7.5 cabezas, hombros ~2 cabezas, pierna ~50%) comparado
   contra el baseline A/B de R0.
2. Gates de regresión tras CADA fase (mínimo `test_core` +
   `autotest_biomech`); batería completa en R4.
3. % de fidelidad por QA imparcial por fase.
4. El loop no cierra con el número: cierra con VoBo de Boris sobre las
   capturas.

## Anti-objetivos (fuera de alcance explícito)

- **Pelo nuevo** — espera el loft ([[Propuesta-Recursos-de-Modelado]]
  recurso 2; Fase 3 del [[PRD-Rework-Modelado-Personajes-v2]]).
- **Biomecánica/ROM/combate** (`rig_biomech.gd` cero cambios).
- **Shaders/post** (Sobel, banding, LUT — nada se toca).
- **UI** (creación de personaje, elección de warpaint).
- **Herramientas externas** (Blender/VRM) — el pipeline sigue 100%
  procedural en GDScript.
- **Fenotipos enano/elfo reales** (C6b) — pero la geometría nueva debe
  dejar los puntos de ramificación limpios donde hoy están:
  `apply_phenotype`, `_apply_build`, `_build_origin_features`.

## Proceso y roles (protocolo [[QA Loop]], ratificado)

- **Orquestador/implementador**: el chat principal (Fable).
- **QA imparcial por fase**: subagente Fable SIN contexto de sesión, con
  láminas + capturas + close-ups, veredicto por rasgo + % + lista
  priorizada. Re-invocación del MISMO agente por ronda (`SendMessage`).
- **Regla de freno**: máx 2 rondas QA por fase sin reportar a Boris; si
  el QA declara techo de técnica, se para y se decide, no se tunea.
- **Cierre de cada fase**: gates verdes + capturas + [[LOG]] +
  [[Current-State]] + [[Lecciones]] si aparece anti-patrón nuevo +
  commit/push ([[SCHEMA]] §7).

## Definición de terminado

1. Batería completa de gates ALL_PASS (`test_core`, `autotest_biomech`,
   `autotest_combat`, `autotest_springboard`, `autotest_rig`,
   `autotest_slice`, `autotest_ui`) — regresión cero.
2. QA imparcial: **≥70% rostro y ≥70% torso PROPUESTOS** — los números
   finales los fija Boris al ver los resultados por fase (baselines de
   partida: rostro 35% del 2026-07-17, torso ~40% del 2026-07-16).
3. **VoBo de Boris** sobre las capturas de cuerpo completo (frente/
   perfil/3-4/espalda + close-ups). El % no cierra el loop; el VoBo sí.

## Relación con otros PRDs

- [[PRD-Rework-Modelado-Personajes-v2]]: sus Fases 1 (torso/hombros) y 2
  (manos) quedan SUPERSEDED por R2 y R3 de este PRD respectivamente. Sus
  Fases 3 (pelo/loft) y 4 (boca/warpaint) siguen vigentes allá y se
  retoman después de esta reescritura.
