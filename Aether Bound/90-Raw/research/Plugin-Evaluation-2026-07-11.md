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

| Plugin | Versión | Tech | Veredicto | Cuándo paga |
|---|---|---|---|---|
| **AMSG** (+PoseWarping) | 0.9/0.8 | GDScript (MIT) | **MINAR lógica** ⭐ | C2 (mantling) + C4 (poses/gait) |
| **Humanizer** | 2.2.0 | GDScript + 394 MB data (Unlicense) | Referencia (esqueleto/ROM) | C6b/C4 (cross-check articular) |
| skeleleton-2d-asset | — | Escenas Skeleton2D (**GPLv3**) | Solo MIRAR (licencia) | mapa de articulaciones |
| godot-vrm (este zip) | 1.2p3 | GDScript+GDNative **Godot 3** | ❌ Rama equivocada | re-bajar master (4.x) si se quiere MToon |

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

### godot-vrm — rama equivocada, descartar ESTE zip

Es la rama godot3 (enero 2022): GDNative, sintaxis `.shader` de Godot 3,
README explícito ("use master for Godot 4.x"). Si se quiere el **MToon**
(toon shader maduro del ecosistema VRM: shade shift/toony banding, rim
fresnel, matcap) como referencia de comparación contra `toon_opaque`,
re-descargar la rama master (ya portada a 4.x). Su outline es casco
invertido = lo que C6a eliminó; esa parte se ignora.

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
