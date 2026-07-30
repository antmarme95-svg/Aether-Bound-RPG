---
status: propuesto
source: "Sesión 2026-07-16: 2 subagentes (uno relee/verifica en código el estado real de la Propuesta-Recursos-de-Modelado ratificada 07-12; uno investiga con web search el ecosistema Godot 4.6 2026 buscando huecos no cubiertos por Plugin-Evaluation-2026-07-11.md). Encargo de Boris: conocer a fondo la propia herramienta de trabajo (Godot) para dejar de tropezar por desconocimiento de API, con orden de prioridad de uso."
updated: 2026-07-16
---

# Catálogo Técnico Godot — prioridad de uso para Aether Bound

> Complementa, sin repetir, [[Inventario del Prototipo]] y los 2 documentos de
> investigación previos (`90-Raw/research/Plugin-Evaluation-2026-07-11.md` —
> veredictos de 12+ addons/zips; [[Propuesta-Recursos-de-Modelado]] —
> 5 recursos ratificados 2026-07-12 para subir el techo del pipeline
> procedural). Este catálogo existe para que la ejecución no vuelva a
> perder tiempo tanteando técnicas que Godot ya resuelve nativamente, ni
> reabra preguntas ya cerradas con evidencia.

## Cómo leer esto

Prioridad = qué tan directo resuelve un problema HOY REGISTRADO del
proyecto (no "qué tan interesante es la técnica"). Un ítem "Baja" no es
malo — es correcto no tocarlo todavía, o ya se evaluó y se descartó con
evidencia (no reabrir sin evidencia nueva).

## Tier 0 — RATIFICADO el 2026-07-12, verificado en código el 2026-07-16: **sin ejecutar**

Antes de cualquier técnica nueva de este catálogo: esto ya se decidió,
tiene mecanismo técnico claro, y grep directo sobre `godot/character/
character_rig.gd` y `godot/rendering/*.gdshader` confirma que sigue sin
tocarse. Es la prioridad #1 real — más que cualquier hallazgo nuevo de
esta sesión.

1. **Loft por perfil (`Curve3D` + `SurfaceTool`)** — generaliza el patrón
   `_ribbon`/`_s_spine` del pelo a torso/brazos/piernas: espina + perfil
   de radios → malla continua, en vez de cadenas de `CylinderMesh`
   discretos. **Confirmado: cero apariciones de `SurfaceTool`/`Curve3D`
   en `character_rig.gd`** — el pelo sigue en su 3er intento con
   cajas/conos en vez de usar esto. Es la apuesta de mayor payoff de
   toda la propuesta 07-12; el piloto natural es el pelo (ya lo dice la
   propuesta original).
2. **Banding suave del cel-shading** — `toon_ramp.tres` tiene
   `interpolation_mode = 1` (**CONSTANT**), 4 escalones duros en offsets
   `0/0.2/0.5/0.78`. Es literalmente la causa de la Lección #2 del
   benchmark VRM ("banding cel más suave que el nuestro"). **Fix más
   barato posible detectado: cambiar `interpolation_mode` a LINEAR (o
   exponer uniforms tipo `_ShadeShift`/`_ShadeToony` de
   `mtoon_common.gdshaderinc`, ya fichado) — candidato a probar en
   minutos, no hay excusa de esfuerzo para no probarlo ya.**
3. **Triplanar para piel/tela** — mata de raíz la costura u=0 y el atlas
   embarrado en cajas (causa de 2 bugs ya pagados en Lecciones).
   Prerequisito conceptual de pintar cualquier textura nueva sobre
   primitivas. Referencia nativa: `uv1_triplanar`/`uv1_world_triplanar`
   de `StandardMaterial3D` (sin código, ya fichado en `m_rock.tres` de
   ProtonScatter).
4. **Gradientes procedurales en materiales** — tinte por gradiente
   mundo-Y (piel/tela) o raíz→punta (pelo) en vez de `albedo_color`
   sólido. Shader-only, horas de costo.
5. **Vista-esqueleto de debug — mecanismo técnico ahora concreto.** La
   propuesta 07-12 lo pedía sin nombrar la API; el research de hoy la
   cierra: la vía más barata y alineada al proyecto es dibujar
   directamente en el banco corriendo con **`ImmediateMesh`** dentro de
   `tmp_anatomy.gd` (esferas en articulaciones + líneas de hueso + arcos
   de ROM leídos de `rig_biomech.gd`) — NO se necesita un
   `EditorNode3DGizmoPlugin` completo (esa vía es más pesada, pensada
   para gizmos dentro del editor, no para un banco de prueba en juego).

## Tier 1 — hallazgo nuevo de hoy, prioridad Alta (deuda técnica real)

- **Migrar el post-proceso manual a `CompositorEffect`** (API nativa
  4.3+, estable en 4.6). Hoy el post se cuelga a mano como quad de
  cámara (`golden_scene.gd:657`, `attach_post`) — funciona, pero es
  scaffolding no reutilizable y diverge de `PipelineConfig` (hallazgo ya
  registrado en el análisis técnico del 2026-07-16, ver [[Current-State]]).
  Referencia transferible casi 1:1: proyecto comunitario **PPMagic**
  (GitHub, MIT) implementa Sobel + Kuwahara multi-pase exactamente con
  esta API — mismo problema que `melancolia_post.gdshader`. No cambia el
  look; sanea la integración con el pipeline de render.

## Tier 2 — contexto útil, no accionable todavía (anotar en Lecciones, no ejecutar)

- **`IKModifier3D`** (familia `TwoBoneIK3D`/`FABRIK3D`/`CCDIK3D`/
  `SplineIK3D`, nuevo en 4.6) — hereda de `SkeletonModifier3D`, exige
  `Skeleton3D` real. **Confirma, no cambia**, la decisión ya tomada de
  pies IK diferidos: el rig es jerarquía `Node3D` sin esqueleto. Vale
  como nota de Lecciones para que si algún día se reabre "¿migramos a
  `Skeleton3D`?" (cambio arquitectónico grande, nadie lo está pidiendo),
  se sepa que esta familia de modificadores ya existe lista para usarse.
- **`RibbonTrailMesh`/`TubeTrailMesh`** (nativos, muestrean `Curve3D`
  para variar ancho) — misma idea que el loft del recurso 2 pero
  empaquetada para trails de partículas, no geometría estática con
  perfil anatómico custom. Referencia de API (`section_length`,
  `curve`) al implementar el loft propio, no reemplazo.
- **`MeshDataTool`** — edita vértices/normales de una malla YA construida.
  Sin uso hoy porque no hay malla continua que editar; se vuelve útil
  DESPUÉS de que el loft (Tier 0.1) exista, para retocar una costura
  puntual sin regenerar toda la malla.
- **Blend shapes** (`MeshInstance3D.set_blend_shape_value`) — solo
  viable si la CARA migra de primitivas discretas a un mesh continuo vía
  loft (hoy no planeado; el loft ratificado apunta a torso/brazos/pelo).
  Si esa migración pasa en Fase D/futuro, esto resuelve directo las
  expresiones faciales por estado que Fase 3-4 va a pedir.

## Tier 3 — evaluado con evidencia y descartado; NO reabrir sin evidencia nueva

- **`CSGShape3D`** — pensado para prototipado de nivel en editor; el
  booleano se recalcula en CPU por frame si cambian operandos/transform,
  carísimo para un rig que se reconstruye en runtime (fenotipo, sliders).
  El truco actual (masas que se penetran + Sobel dibuja solo el contorno
  externo) **ya es funcionalmente una "unión CSG" sin el costo** — no
  cambiar de técnica.
- **Compute shaders (`RenderingDevice`)** — sin cuello de botella de
  rendimiento reportado que lo justifique; no perseguir sin perfilado
  real.
- **Shaders de acuarela/tinta genéricos de la comunidad** (godotshaders.com)
  — el Art Bible ya define el look propio; adoptar uno genérico repite
  el error que "cel shader del Asset Library: NO" ya vetó.
- **Addons de "procedural humanoid mesh"** (ej. Hoodie — visual scripting
  tipo Geometry Nodes, alpha) — genéricos, no anatómicos; romperían la
  iteración same-day con Boris. Candidato SOLO para vegetación/props de
  Fase 4, nunca para el rig de personaje.
- **`godot-ai` y otros MCP servers 2026** (IvanMurzak/Godot-MCP,
  Coding-Solo, mkdevkit) — todos requieren sidecar externo (Python/Node);
  Beckett (ya evaluado 07-11) sigue ganando por ser GDScript puro
  embebido, sin piezas móviles nuevas en una laptop térmicamente frágil.
- **Plugin de pelo maduro para Godot 4.x** — confirmado que sigue sin
  existir en 2026. El ribbon/loft propio (Tier 0.1) sigue siendo la vía
  canónica.
- **`SpringBoneSimulator3D`** — confirmado que sigue exigiendo
  `Skeleton3D` en 4.6; no aplica (M10/pelo es problema de FORMA, no de
  movimiento).

## Catálogo previo (sin repetir aquí — ver el documento original)

`90-Raw/research/Plugin-Evaluation-2026-07-11.md` mantiene los veredictos
completos de: Dialogue Manager (adoptar en Fase 2), HTerrain/ProtonScatter
(minar shaders para Fase 2/4), FancyControls (minar patrón de tween UI),
AMSG+PoseWarping (minar lógica de mantling y orientation warping para
C2/C4), Humanizer/skeleleton-2d-asset (solo referencia articular),
godot-vrm/MToon (minar `mtoon_common.gdshaderinc` para banding), Beckett
MCP (tooling, spike pendiente). Nada de eso cambia con este catálogo.

## Regla de mantenimiento

Cuando se ejecute cualquier ítem del Tier 0 o 1, mover la entrada a un
nuevo bloque "✅ Ejecutado" con fecha y archivo/commit — este catálogo se
vuelve mentiroso si no se actualiza al mismo ritmo que el código (misma
disciplina que [[Lecciones]]).
