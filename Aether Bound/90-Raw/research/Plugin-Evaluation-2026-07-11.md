---
status: raw
source: "Sesión 2026-07-11: evaluación de 8 zips de plugins (Downloads) + Chickensoft + research de cabello/facial, a pedido del director. Inventario técnico ejecutado por subagente Sonnet; análisis y veredicto por el orquestador."
updated: 2026-07-11
---

# Evaluación de plugins y research visual (2026-07-11)

> Encargo del director: evaluar 8 zips de plugins de Godot descargados en
> `C:\Users\tonom\Downloads`, el ecosistema Chickensoft, y research de
> cabello/facial. Criterio EXPLÍCITO del director: **no adoptar de raíz si no
> aplica — minar partes de código que faciliten alcanzar el [[Art Bible]]**.
> Los zips permanecen en Downloads; la extracción fue en scratchpad temporal
> (no versionada). Todos los plugins son licencia MIT.

## Veredicto ejecutivo

| Plugin | Versión | Tech | Veredicto | Cuándo paga |
|---|---|---|---|---|
| **Dialogue Manager** | 3.10.1 | GDScript (+C# opc.) | **ADOPTAR completo** | Fase 2 (PRD-009 camp scene) → Fase 3 |
| **HTerrain** (zylann) | 1.8.1 dev | GDScript + shaders | **MINAR shaders** (no instalar) | Fase 2 (PRD-008) / Fase 4 (montaña) |
| **ProtonScatter** | 4.0 | GDScript | **MINAR 3 shaders demo** (no instalar) | Fase 4 (foliage/agua) |
| **FancyControls (FACS)** | 1.1.5 | GDScript | **MINAR patrón de tween UI** | Fase 4 (juice de HUD/menús) |
| **MTerrain** | 0.18.0-alpha | GDExtension (binarios ✓) | Referencia menor (2 shaders) | — |
| **Beehave** | 2.9.3-dev | GDScript | Diferir (candidato post-slice) | Si la IA crece post-slice |
| **LimboAI** | 1.8.0 | C++ fuente SIN binarios | **Descartar** (requiere compilar; problema que no tenemos) | — |
| **GodotSteam** | — | zip stub (949 bytes) | **Descartar** (repo movido a Codeberg; además prematuro) | — |
| Chickensoft (URL) | — | Ecosistema C#/.NET | **Descartar** (proyecto es GDScript puro) | — |

Filtros que decidieron: proyecto sin addons (cero dependencias externas hoy),
Y del jugador ANALÍTICA (contrato `get_height`/`clamp_position`, sin física),
look canonizado por shaders propios (`toon_opaque` + post Melancolía 4 capas),
presupuesto térmico RTX 2060, IA del slice mínima POR DISEÑO y ya validada.

## Por plugin

### 1. Dialogue Manager 3.10.1 (Nathan Hoad) — ADOPTAR cuando abra Fase 2

- El ÚNICO hueco real que un plugin cubre: no existe sistema de diálogo y el
  plan lo exige — camp scene del ritual (PRD-009, Fase 2), cold open/pregón/
  reclutamiento (PRD-010), traición (PRD-011), coda (PRD-012).
- GDScript puro, autoload único (`DialogueManager`), lenguaje de guion propio
  (`.dialogue`), balloon re-skinneable a nuestra tinta/paleta. Compat inferida
  4.4+ (58 archivos `.uid`) → OK en 4.6.3.
- **No instalar durante la ventana C6/C4** — entra con el PRD-009.
- Ojo Lecciones: autoloads no viven en `--headless --script` → tests que
  toquen DialogueManager van en sondas windowed.
- Sin shaders dentro (verificado).

### 2. HTerrain 1.8.1 dev (Marc Gilleron) — no instalar; MINAR

Adopción completa choca con la Y analítica y es editor-centric. El botín
(rutas dentro de `addons/zylann.hterrain/` en el zip):

- `shaders/low_poly.gdshader` — **flat shading por derivadas de pantalla**
  (`cross(dFdy(VERTEX), dFdx(VERTEX))`): look faceteado sin autorar normales.
  Candidato directo para facetas de cristal (fine-tuning B11) y terreno del
  Ascent.
- `shaders/detail.gdshader` — **wind sway procedural** en vertex shader +
  tinte por altura + AO vertical. Candidato para el foliage estilizado.
- `shaders/simple4*.gdshader` — splatmapping 4 texturas con depth blending →
  base técnica del **registro montaña** (roca/nieve/ceniza) portable a toon.
- `tools/generator/shaders/perlin_noise.gdshader` (multi-octava + isla con
  falloff radial) y `erode.gdshader` (**erosión morfológica GPU multipase**)
  — generación de heightmap del Cinder Ascent. Nota: la Y analítica puede
  envolver un heightmap horneado (lookup de `Image`) sin romper el contrato.
- `tools/bump2normal_tex.gdshader` — heightmap→normal por diferencias finitas.
- `shaders/include/heightmap_rgb8_encoding.gdshaderinc` — packing float→RGBA8.

### 3. ProtonScatter 4.0 (HungryProton) — no instalar; MINAR demos

El addon es una herramienta de editor (colocación no destructiva); nuestro
pipeline puebla por código. El botín está en sus DEMOS
(`addons/proton_scatter/demos/assets/materials/`):

- `grass.gdshader` — **viento por ruido paneado + camera bend**
  (`instance uniform` que dobla la hierba lejos de la cámara) + gradiente de
  color por altura. Directo al cajón del foliage del Ascent.
- `leaves.gdshader` — mismo viento aplicado a follaje con vaivén vertical.
- `m_water.gdshader` — **toon water** (origen: godotshaders.com/toon-water):
  profundidad Beer-Lambert, gradiente por profundidad, **espuma por umbral
  smoothstep (banding cel)**, distorsión por ruido. Candidato para el registro
  "madera-río humano" cuando haya agua en escena.
- `src/particles/example_random_motion.gdshader` — hash determinista
  por-partícula (`rand_from_seed`) reutilizable para ruido por-instancia.
- `m_rock.tres` — referencia de config de triplanar NATIVO del motor
  (`uv1_triplanar` + `uv1_world_triplanar` en StandardMaterial3D), sin código.

### 4. FancyControls / FACS 1.1.5 (RRandom) — no instalar; MINAR patrón

- **Aclaración importante (2026-07-11):** el consejo externo que recomendó
  "FACS" para RASGOS FACIALES es una confabulación — confundió el acrónimo con
  el Facial Action Coding System. El plugin real es **animación de UI**
  (Control nodes): tweens encadenados con GUI de editor. Cero facial.
- Botín (patrones GDScript, no shaders):
  `Controls/AnimatedItem/AnimatedItem.gd` (tween por propiedad con
  TransitionType configurable), `FancyAnimatedItem.gd` (`chain_action()` —
  acciones compuestas), `Example/test_hover.gd` (**pop de botón con
  `TRANS_BACK` overshoot** — micro-interacción estilo cómic para HUD/menús,
  Fase 4).
- Declarado para Godot 4.4 (existe variante paralela 4.2/4.3 — no confundir).

### 5. MTerrain 0.18.0-alpha (Mohsen Zare) — referencia menor

- Único zip GDExtension CON binarios (Win/Linux/macOS/Android; sin iOS/Web).
  Sobredimensionado (16 km², hierba con colisión, navmesh) para un slice
  lineal; alpha; curva alta; sería nuestra primera dependencia binaria.
- Referencia: `mterrain/start.gdshader` (clipmap LOD con vertex displacement
  por región) y `addons/m_terrain/shaders/boundary.gdshader` (**gizmo de rayas
  diagonales animadas** + función `hsv_adjustment()` en shader — highlight de
  selección estilizado).

### 6. Beehave 2.9.3-dev — diferir

Behavior trees GDScript, instalable tal cual, 2 autoloads propios. La IA del
slice es mínima por diseño y validada en playtest — no hay problema que
resuelva HOY. Si la IA crece post-slice (B4+), Beehave gana a LimboAI por ser
GDScript sin compilación. Zip de branch sin README (bajar release etiquetado
si se adopta).

### 7. LimboAI 1.8.0 — descartar

Declara soporte Godot 4.6, pero el zip de `master` es **fuente C++ sin un solo
binario** (verificado: cero .dll/.so/.dylib): requiere SCons + godot-cpp o
build custom del motor. Costo de toolchain injustificable para un problema
que no tenemos. Si algún día: bajar release con binarios, no `master`.

### 8. GodotSteam — descartar (zip vacío)

Los 949 bytes son un stub: `FUNDING.yml` + readme que apunta a
`codeberg.org/godotsteam/godotsteam` (el repo migró de GitHub). Además,
integración Steam es post-slice por plan.

### Chickensoft (https://chickensoft.games/docs/setup) — descartar

Ecosistema C#/.NET para Godot (requiere .NET 8, tooling GodotEnv/templates/
testing todo C#). Proyecto es GDScript puro por diseño; nada en el plan pide
migrar.

## Research cabello (pedido del director, hilo Reddit inaccesible por login)

No existe plugin de pelo maduro para Godot. Las 3 rutas del ecosistema:
autorar en Blender e importar (no aplica: pipeline 100% procedural in-engine),
shaders de pelo (look ya resuelto por `toon_opaque` + Sobel), shell fur (para
pelaje animal, Godot 3.x). Lo nativo: `SpringBoneSimulator3D` (4.4+) para
física secundaria — **no aplica directo**: requiere `Skeleton3D` y nuestro rig
es jerarquía procedural sin esqueleto; además M10 es problema de FORMA, no de
movimiento. **El enfoque ribbon del M10-r4 (PRD del director) ES la técnica
canónica de pelo estilizado** — no cambiar de herramienta. Upgrade opcional
anotado: si las cadenas de cajas leen escalonadas en close-up, generar la
cinta como malla continua con `SurfaceTool` sobre `Curve3D` (mismo control,
superficie suave).

## Técnicas para el modelado de personajes "más adelante" (mandato del director)

Del devlog twocentstudios (taxonomía de expresiones faciales) + evaluación
crítica del consejo externo:

1. **Expresiones faciales por estado** (neutral/alegre/dolor/vacío) — semilla
   para Fase 3–4: los beats emocionales del slice (camp scene, traición, coda)
   las van a pedir. Vía preferida: variantes de geometría-tinta intercambiables
   por estado (extensión natural del sistema actual de fenotipo).
2. **Spike nodo `Decal` nativo** para marcas/rasgos faciales: proyecta textura
   sobre la superficie opaca del cráneo — esquiva la costura u=0 y la
   compresión no-lineal del atlas (Lecciones) sin planos flotantes. Requiere
   Forward+ (✓ usamos Forward Plus). Verificar interacción con el post.
3. **Reglas para cualquier textura facial futura:** alpha-scissor u opaco
   (NUNCA Transparency estándar — el post la borra, lección del toon);
   margen ~8 mm fuera de superficie (la tinta Sobel se come astillas al ras);
   rasgos dibujados en blanco + tinte por `albedo_color` = compatible con
   nuestro sistema de paleta (ya lo practicamos en pelo/warpaint/piel).
4. **Cel shader del Asset Library: NO** — el look canonizado ya lo cubre y un
   cel genérico es la anti-referencia explícita del Art Bible.
5. Blender/Blockbench: hoy NO se usan (verificado: cero .glb/.gltf/.obj/.blend
   en el repo). Si el procedural topa techo en Fase 4, la conversación sería
   Blender con workflow toon (Blockbench vetado por estética: "no low-poly
   crudo", review v0.1).

---

# SEGUNDA RONDA (mismo día): 4 zips más + tooling

| Plugin                  | Versión | Tech                               | Veredicto                  | Cuándo paga                              |
| ----------------------- | ------- | ---------------------------------- | -------------------------- | ---------------------------------------- |
| **AMSG** (+PoseWarping) | 0.9/0.8 | GDScript (MIT)                     | **MINAR lógica** ⭐         | C2 (mantling) + C4 (poses/gait)          |
| **Humanizer**           | 2.2.0   | GDScript + 394 MB data (Unlicense) | Referencia (esqueleto/ROM) | C6b/C4 (cross-check articular)           |
| skeleleton-2d-asset     | —       | Escenas Skeleton2D (**GPLv3**)     | Solo MIRAR (licencia)      | mapa de articulaciones                   |
| godot-vrm v2.5.7        | 2.5.7 / MToon 3.4.0 | GDScript + GDExtension (binarios ✓) | ⛏️ **MToon minable**   | Referencia toon shading vs. `toon_opaque` |

### AMSG — el hallazgo de la segunda ronda (referencia para C2/C4)

NO se adopta (v0.9, CharacterBody3D/move_and_slide vs nuestra física
analítica, capa de animación AnimationTree+Skeleton3D, APIs muertas en
`set_bone_x_rotation`, mantle por teleport). Se MINA la lógica:

- **Mantling (→ C2, decisión en PRD-008):**
  `addons/AMSG/Components/MantleComponent/MantleComponent.gd` (66 líneas,
  legibles y portables): detección = 3 RayCast3D hacia abajo (LedgeDetect a
  altura del personaje + LedgeGroundDetect adelantado 1 m = punto de
  aterrizaje + LedgeTopDetect 0.25 m arriba que NO debe chocar = clearance)
  + ShapeCast3D con la shape del personaje sobre el punto ("¿quepo ahí?").
  La detección NO depende de CharacterBody3D — se traduce a nuestro contrato
  analítico como el step-block del Gate 1. Lo único acoplado es la ejecución
  (animación + teleport — nosotros la haríamos con arco/curva propia).
- **Poses por estado (→ C4):** `addons/PoseWarping/PoseWarping.gd` (19 KB) —
  orientation warping (torso a cámara, piernas a velocidad — rota caderas +
  cadena de espina), stride warping (targets IK de pierna según velocidad
  real = anti foot-sliding), slope warping (IK de pie a terreno + foot
  locking; rima con el "foot IK de HZD" de B14), distance matching de
  frenado (`CalculateStopLocation/Time`). Taxonomía de estados en
  `addons/AMSG/Global.gd` (movement_state/action/gait/stance/rotation_mode
  — checklist para nuestro pase de poses).
- **Patrón agnóstico:** `CharacterMovementComponent.gd` L518-533 calcula
  velocidad/aceleración REALES por diferencias de posición (Δpos/Δt) —
  independiente del motor de física, útil para alimentar poses por gait.

### Humanizer — no para cuerpos; SÍ como referencia articular

Choca de frente con C6 (cuerpos MakeHuman realistas importados vs procedural
estilizado recién reworkeado con 5+ reviews) y pesa 394 MB. Lo valioso:

- **Tabla de ROM real** en `scripts/core/physical_skeleton.gd` L118-135:
  rodillas HINGE 20°–90°, codos HINGE 0°–90°, conos swing/twist por
  articulación (Head 30/30, UpperArms 60/30, UpperChest 50/20, etc.) —
  cross-check directo contra nuestras tablas de `rig_biomech.gd` en C6b.
- **Posiciones articulares:** `data/assets/rigs/<rig>/skeleton_config.json`
  (rig `game_engine` = 53 huesos estilo UE; `default` = 137 con falanges) —
  head/tail por hueso derivados de la malla base MakeHuman. Sin ROM en data.
- Licencia Unlicense (dominio público) — minable sin fricción.

### skeleleton-2d-asset — intención del director: base articular

El director lo pensó como base para entender DÓNDE hay articulaciones y sus
grados de libertad. El zip: rig `Skeleton2D` hecho a mano, **41 Bone2D
nombrados** con rest transforms (axial Back→Torso→Neck→Head; brazo con 10
articulaciones de dedos por mano; pierna con tobillo/pie/dedos separados) +
animaciones stand/crouch/run/walk. **GPLv3 — solo mirar, NUNCA copiar** al
repo. Sin límites de rotación (Bone2D no los define).

**Semilla derivada (la respuesta real a la intención): VISTA-ESQUELETO de
debug en el banco de anatomía** — toggle en `tmp_anatomy.gd` que dibuje
esferas en articulaciones + líneas de hueso + arcos de ROM (los datos YA
existen en `rig_biomech.gd`; solo falta hacerlos visibles). Pagaría en las
reviews de C6b (ROM enano/elfo) y C4. Referencias de contraste: ROM de
Humanizer (arriba) y lista humanoide VRM (55 huesos estándar, transcrita en
`import_vrm.gd` L302-316 del zip godot-vrm).

### godot-vrm v2.5.7 (re-bajado 2026-07-11) — CORRIGE el zip anterior; MToon minable

El zip original (`godot-vrm-c8b0527...`) era la rama godot3 obsoleta —
Boris re-bajó la correcta: **fork AzPepoze de V-Sekai, v2.5.7** (VRM
importer) + **MToon Shader Inspector v3.4.0**, ambos "for Godot 4.x"
(`plugin.cfg` lo declara explícito). Verificado en el zip nuevo:
`.gdshader` (no `.shader` de Godot 3), archivos `.uid` (autoría 4.4+),
`vrm_physics.gdextension` con `compatibility_minimum = "4.3"` — **compatible
con 4.6.3**. Soporta VRM 0.x y VRM 1.0 (carpetas `importer/v0/` y
`importer/v1/vrmc/`). Licencia MIT (V-Sekai Contributors + Masataka SUMI).

- **GDExtension CON binarios** para `vrm_physics` (spring bones nativos):
  Windows/Linux/**macOS** (debug+release cada uno) — a diferencia del zip
  viejo, esta vez SÍ trae macOS. Sin binario para iOS/Web/Android.
- **MToon — 12 shaders, todos `.gdshader` (Godot 4 nativo)** en
  `addons/mtoon/`: `mtoon.gdshader` (base, vía include compartido
  `mtoon_common.gdshaderinc`) + variantes cutout/trans/cull_off/zwrite +
  `mtoon_outline*.gdshader` (**outline por `render_mode cull_front` +
  `#define IS_OUTLINE`** — la técnica de casco invertido que C6a
  descartó a propósito en favor del Sobel; se ignora esa parte, se mina el
  resto). El shading real (shade shift/toony banding, rim fresnel, matcap,
  emisión) vive en `mtoon_common.gdshaderinc` — es la pieza que vale
  comparar contra `toon_opaque.gdshader` para el fine-tuning de banding
  (B11) si el escalón cel necesita más control.
- **Definición de esqueleto humanoide** (para el cross-check articular
  del director): `import_vrm.gd` sigue siendo la referencia de la lista
  humanoide VRM estándar; en este fork la lógica de bone-mapping vive en
  `importer/common/vrm_bone_renamer_humanoid.gd` (retargeting a huesos
  humanoides) — más completo que el zip viejo, sin límites de ROM (igual
  que antes: el spec VRM no define ángulos, solo jerarquía).
- **No adoptar el addon completo**: seguimos sin pipeline de avatares
  importados (C6 es 100% procedural). Uso previsto: minar `mtoon_common.
  gdshaderinc` como referencia de shading, y opcionalmente el spring-bone
  nativo (`vrm_physics.gdextension`) como dato de comparación si algún día
  el pelo pide física secundaria de verdad — no ahora (M10 es forma, no
  movimiento).

### Benchmark de calidad (2026-07-11) — imágenes en
`90-Raw/research/quality-benchmarks/`, NO en `90-Raw/concept/`

Boris subió 3 PNG de este addon como referencia, con el criterio explícito:
"cualquier output mejor que el nuestro es fuente de referencia para
iterar", comparado contra `godot/test_out/anatomy_*.png`. Criterio sano —
pero con dos matices que hay que dejar registrados para que una compilación
futura no los confunda con dirección de arte:

- **Solo 1 de las 3 imágenes es un render limpio comparable**
  (`v1_GodotVRM_Screenshot.png`, bust frontal de "AliciaSolid"). Las otras
  dos son capturas de HERRAMIENTA, no de arte: `GodotVRM_screenshot.png` es
  el editor con el panel de settings de spring bones; `collision_with_
  environment_v0...` es una vista de debug con gizmos de colisión de física
  encima del personaje.
- **Comparación no es 1:1: asset autorado a mano vs. procedural generado
  por código.** AliciaSolid es un avatar VRM modelado/texturizado por un
  artista (flujo típico: VRoid Studio u otro DCC) que el addon solo importa
  y sombrea; nuestro banco es geometría de primitivas ensamblada por
  `character_rig.gd`, en pleno rework (C6, ~60-65% fidelidad per la review
  v0.1). El "mejor pulido" es esperable del método, no un fallo de técnica.
- **Tensión de estilo sin resolver, a ojo del director:** AliciaSolid es
  estética anime/VTuber (ojos grandes, pelo degradado, vestido frilly) —
  el [[Art Bible]] la nombra en la lista de **anti-referencias** (junto a
  Genshin, "saturación caramelo"). El pulido es real; la dirección apunta
  al lado contrario del norte BotW/Hinterberg/Palia.

**3 lecciones SÍ transferibles a nuestro estilo (no exclusivas de anime),
extraídas del render limpio vs. `anatomy_close.png`/`anatomy_face.png`:**

1. Textura pintada/degradada en vez de color plano de paleta — ya lo
   practicamos parcial en el atlas de warpaint; extensible a más piezas.
2. Curva de transición del banding cel más suave que la nuestra —
   comparar contra `mtoon_common.gdshaderinc` (`_ShadeShift`/`_ShadeToony`,
   ya fichado arriba como minable) cuando toque el fine-tuning de B11.
3. Degradado raíz→punta en el pelo — barato, compatible con el ribbon
   procedural del M10, no depende de estilo anime.

---

# TOOLING (fuera de la matriz): Beckett — MCP for Godot (Lite) 1.8.0

Revisado directamente por el orquestador (no es plugin del juego: es
infraestructura del flujo Claude↔Godot). `addons/beckett/`, GDScript puro,
MIT, servidor MCP **embebido en el editor** (HTTP local, sin Node/Python;
auto-escribe `.mcp.json`). ~50 tools verificadas en código: autoría con
parse-check (`write_script`/`script_patch`/`validate_script`), escena
(`get_scene_tree`/`create_node`/...), y — lo valioso para nosotros —
**observación del juego CORRIENDO**: `play_scene`/`stop_scene`,
`screenshot`, `get_remote_tree`, `runtime_get_property`,
`monitor_properties`, `wait_until`, `game_logs`, `get_performance_monitors`.
Edición Lite gratuita; la Full (de pago, itch.io) añade input driving.

**Potencial:** las rondas visuales (M9/M10: captura→review→retoque) hoy
cuestan una corrida windowed + PNGs por ronda; con Beckett el agente vería
el banco vivo e inspeccionaría transforms en runtime (los "entierros" de
geometría de Lecciones se diagnosticarían en vivo). **Cautelas:** exige el
EDITOR abierto (carga extra en la laptop térmicamente frágil — contraindicado
mientras el banco cuelga por contención); `.mcp.json` en la raíz del
proyecto (gitignorar); registrar el MCP en Claude Code requiere sesión
interactiva; fuente de terceros auditable (MIT). **Propuesta: spike
time-boxeado de 1 sesión** cuando el banco corra limpio — conectar, manejar
`tmp_anatomy` en vivo, medir overhead. Decisión del director.

---

# TERCERA RONDA (2026-07-12): evaluación dirigida cara / esqueleto / movilidad

> Encargo del director: verificación puntual de si algo del listado ayuda
> específicamente a (1) **cara** — facciones más fieles a las láminas RAW,
> (2) **cuerpo** — evaluación de articulaciones/esqueleto, (3) **movilidad**
> — comparado contra AMSG+PoseWarping. Restricción explícita del director:
> **Aether Bound es EXCLUSIVAMENTE tercera persona** — nada específico de
> primera persona se mina.

## 1. Cara — ningún plugin ayuda (verificado)

`humanizer-*.zip` se releyó puntual: `scripts/core/facial_mocap.gd` y
`scripts/core/morphs.gd` completos. Todo su sistema facial es blend-shapes
sobre malla MakeHuman continua — `MeshInstance3D.set_blend_shape_value` +
`Skeleton3D.set_bone_pose_position` + `create_skin_from_rest_transforms`.
Arquitectura incompatible de raíz con nuestro rig (ensamblado procedural de
primitivas box/cylinder/sphere, sin mesh continuo ni skinning). Sin geometría
ni morphs minables.

**Veredicto:** la mejora de cara sigue por las vías ya conocidas —
comparación directa contra láminas RAW (más barata en iteración con Beckett
en vivo, ver TOOLING arriba) y el comparativo Decal vs. triplanar de la
Sesión 5 del plan de rework (ratificado en C8).

## 2. Cuerpo/esqueleto — cross-check concreto definido

Nuestro set de joints en `rig_biomech.ROM` (`godot/character/rig_biomech.gd`
líneas 21-67): `hip_leg`, `knee`, `shoulder`, `elbow`, `spine`,
`spine_upper`, `hips_root`, `head` — dict joint→`Vector2(min,max)` por eje en
radianes, directamente iterable para la vista-esqueleto (Sesión 3 del plan).

Contra: `skeleton_config.json` de Humanizer (rig `game_engine`, 53 huesos) y
lista humanoide VRM (55 huesos, `import_vrm.gd` L302-316).

- **Huecos candidatos detectados** (anotar, NO implementar — decisión del
  director): muñeca, tobillo, clavícula, dedos individuales (hoy geometría
  estática sin ROM propio).
- **Nota técnica confirmada por exploración:** `rig_biomech.gd` NO expone
  posiciones articulares (solo ROM + `clamp_node`); las posiciones salen de
  los nodos del `CharacterRig` vivo (`character_rig.gd:97-117`,
  `_apply_joint_constraints` ~L2400: hips, spine, upper_spine, head,
  arms[]+meta elbow, legs[]+meta knee) vía `global_position`. La
  vista-esqueleto debe combinar ambas fuentes — hoy no hay dict unificado
  joint→{posición, ROM}.

## 3. Movilidad vs. AMSG+PoseWarping — comparación explícita, filtrada a tercera persona

- `AMSG/Components/CameraComponent.gd` (leído completo): sí soporta cámara
  tercera persona sobre-el-hombro con offset (`view_angle.right_shoulder`/
  `left_shoulder`, `CameraHOffset` ±0.45), mismo esquema que nuestro
  `CAM_SHOULDER` derecho. **Todo lo atado a `view_mode.first_person`**
  (`first_person_camera_bone`, SpringArm negativo) **se descarta
  explícitamente — no aplica al proyecto.**
- `PoseWarping.gd` (leído completo, 19 KB): el **orientation warping** es
  matemática agnóstica del motor en su núcleo —
  `set_orientation_warping_direction` calcula la diferencia de ángulo entre
  forward de cámara y dirección de velocidad vía quaternions, con manejo de
  backward/lateral, clamp ±PI/2 y `lerp_angle` por `turn_rate`; el resultado
  se reparte entre cadera (rotación completa) y segmentos de columna
  (contra-rotación repartida: `-direction/n_spines`). **SOLO la aplicación**
  (`set_bone_y_rotation` sobre `Skeleton3D`) está atada a huesos — portable a
  nuestros nodos hips/spine/upper_spine (columna de 2 segmentos ya
  existente) sin adoptar `Skeleton3D`/`SkeletonModifier3D`.
  **CANDIDATO CONCRETO para el pase de poses C4** (hoy el torso no reacciona
  a la cámara en combate). Es evaluación/documentación — la implementación
  es trabajo de C4, no de la ventana C6.
- **Stride warping y slope warping** (foot IK vía `SkeletonIK3D` + raycasts +
  `BoneAttachment3D`) NO aplican — confirman (no cambian) la decisión ya
  tomada de pies IK diferidos.
- `CalculateStopLocation`/`CalculateStopTime` (distance matching de frenado,
  física pura d=vt+½at²) portable, ganancia menor, opcional para C4.

## Veredicto ejecutivo — tercera ronda

| Área | Aporta algo | Veredicto |
|---|---|---|
| **Cara** | No | Ningún plugin minable — seguir vía RAW + Decal/triplanar (Sesión 5) |
| **Cuerpo/esqueleto** | Parcial (referencia) | Cross-check ROM contra Humanizer/VRM; huecos anotados (muñeca/tobillo/clavícula/dedos), sin implementar |
| **Movilidad** | Sí (candidato concreto) | Orientation warping de PoseWarping.gd portable a hips/spine/upper_spine → candidato para pase de poses C4 |
