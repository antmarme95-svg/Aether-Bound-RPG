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
