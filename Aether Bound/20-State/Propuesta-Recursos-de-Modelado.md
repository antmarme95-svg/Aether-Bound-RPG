---
status: ratificado
source: "Design Loop 2026-07-12 — diagnóstico del director técnico tras la evaluación de plugins (90-Raw/research/Plugin-Evaluation-2026-07-11.md) y el benchmark de calidad VRM. RATIFICADA por el director el 2026-07-12 (mismo día): los 5 recursos con su orden, los 3 ajustes al plan de rework paralelo, y el loft como mini-loop propio pre-C6b."
updated: 2026-07-12
---

# Propuesta — Recursos de Modelado de Personajes

> **Frente:** subir el techo de fidelidad del pipeline procedural de
> personajes SIN romper su ventaja (iteración same-day con el director,
> cero fricción de importación). **✅ RATIFICADA (2026-07-12).**

## Diagnóstico

El patrón de las 15+ rondas de C6a/M9/M10: casi todo el esfuerzo se va en
**tuning numérico de parámetros de primitivas** (hombros +12%, HEAD_SCALE
0.84→0.87…) porque las herramientas actuales solo permiten ajustar perillas,
no esculpir. El benchmark de calidad VRM (2026-07-11,
`90-Raw/research/quality-benchmarks/`) confirmó tres brechas de PULIDO
independientes del estilo: color plano vs. textura pintada, banding cel duro
en close-up, pelo sin degradado. Y las Lecciones registran 2 entierros + 2
bugs de UV pagados por pintar sobre primitivas sin UVs limpios.

## Los 5 recursos (orden de prioridad)

1. **Triplanar para piel/tela** — mata de raíz el problema de UVs
   (costura u=0, compresión hacia la ceja, atlas embarrado en cajas).
   Prerequisito técnico del recurso 3. Referencia ya fichada:
   `m_rock.tres` de ProtonScatter (config nativa del motor,
   `uv1_triplanar` + `uv1_world_triplanar`). Costo: una tarde.
2. **Generador de malla por perfil/loft** — generalizar el patrón
   `_ribbon`/`_s_spine` del pelo: `Curve3D` (espina del miembro) + perfil
   de radios → malla continua con `SurfaceTool`. Reemplaza cadenas de
   `CylinderMesh` discretos en torso/brazos/piernas por superficies suaves;
   pasa de "tunear 15 parámetros" a "dibujar la silueta". **La apuesta de
   mayor payoff y mayor esfuerzo → mini-loop PROPIO antes de C6b** (el ROM
   enano/elfo es donde más paga). El upgrade de cinta continua del pelo
   (anotado en el doc de plugins) es el piloto natural de esta técnica.
3. **Gradientes procedurales en materiales** — tinte por gradiente
   (mundo-Y en piel/tela, raíz→punta en pelo) en vez de `albedo_color`
   sólido. Lecciones #1 y #3 del benchmark. Shader-only. Costo: horas.
4. **Control de banding tipo MToon en `toon_opaque`** — portar el patrón
   `_ShadeShift`/`_ShadeToony` (fichado en `mtoon_common.gdshaderinc` del
   zip godot-vrm v2.5.7) para suavizar el corte del escalón cel en
   close-up. Lección #2 del benchmark. Costo: horas, con A/B.
5. **Velocidad de iteración** — vista-esqueleto de debug + spike Beckett
   MCP. Ya agendados en el plan de rework (sesiones 1 y 3 de la otra
   sesión); aquí solo se ratifica su prioridad: el costo real del método
   actual son las RONDAS, no los parámetros.

## Anti-objetivos (lo que NO se pide)

- Blender/Blockbench o artista externo — rompe el pacto de iteración rápida
  ([[Lecciones]]: la ventaja del pipeline). Blockbench además vetado por
  estética (review v0.1: no low-poly crudo).
- Hardware nuevo — antes, perfil de banco "ligero" para iterar bajo throttle.
- Adoptar Humanizer/VRM como generadores de cuerpo — incompatibles con el
  rig procedural y (VRM) anti-referencia de estilo.

## Integración con el plan de rework (sesión paralela 2026-07-12)

El plan "Rework gráfico Humano C6/M10 + spike Beckett" (sesiones 0–5,
escrito en la sesión paralela) queda VALIDADO en secuencia y alcance, con
estos ajustes derivados de esta propuesta:

- **Sesión 2 (peinado):** si el close-up muestra escalonado de cajas, el
  fix es la cinta continua `SurfaceTool` sobre la misma S-spine — piloto
  del recurso 2.
- **Sesión 4 (repaso completo) suma dos sub-tareas shader-only:**
  (a) recurso 3 — gradientes en pelo/piel/tela; (b) recurso 4 — banding
  suavizado en `toon_opaque`, con A/B contra capturas actuales. Ambas
  atacan directamente las brechas del benchmark sin tocar geometría.
- **Sesión 5 (spike de la marca de frente) se vuelve comparativo:**
  `Decal` **vs.** triplanar (recurso 1) — dos soluciones al mismo TODO;
  decide el resultado en captura + costo.
- **Recurso 2 (loft) NO se agenda en ese plan** — mini-loop propio
  pre-C6b, con ratificación aparte del director.

## Ratificación

**✅ RATIFICADA por el director (2026-07-12), sin cambios:** los 5 recursos
y su orden, los 3 ajustes al plan de rework de la sesión paralela, y el
loft como mini-loop propio antes de C6b. Ejecución: los ajustes 1–3 se
implementan dentro del plan de rework (sesiones 2/4/5 de la sesión
paralela); el mini-loop del loft se abre al cerrar ese plan, antes de C6b.
