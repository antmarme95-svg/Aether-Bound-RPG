---
status: draft
created: 2026-07-19
owner: Boris (director) / orquestador
---

# PRD — Catálogo de Peinados v1 (creador de personaje)

> Decisión de Boris (2026-07-19): **6-8 estilos por género** por raza para el
> creador de personaje previo al modo historia. Técnica única: **loft**
> (`HairLibrary._loft`/`_lock`, implementado 2026-07-19 en el piloto de
> FASE 3) + masas de concha. Prohibido cajas/conos para mechones
> ([[PRD-Rework-Modelado-Personajes-v2]] §FASE 3).

## Alcance

- **Matriz:** 3 razas (Elfo Aether-Born / Enano Iron-Blooded / Humano
  the Restless) × 2 géneros × 6-8 estilos = **36-48 peinados**.
- Las 12 siluetas existentes de `hair_library.gd` (wyld mane, norse
  braids, elven topknot, pompadour, ash spikes, curtain long, war
  mohawk, twin tails, shorn scout, drake dreads, frontier crop, prince
  curtain) son el **punto de partida**: se RECONSTRUYEN con
  concha+loft, no se descartan. Faltan ~24-36 estilos nuevos (mujer
  está muy sub-representada en el set actual).
- Sabor cultural por raza según [[Fenotipos y Creación de Personaje]]:
  elfo = líneas limpias/topknots/largos sedosos; enano = trenzas/
  recogidos de forja + barbas (las 4 barbas también migran a loft);
  humano = cortes prácticos fronterizos (frontier crop es el canon) +
  variantes de ciudad aetherpunk.

## Estado de la técnica (piloto 2026-07-19, frontier crop masculino)

- `_loft` (Curve3D + perfil de radios → malla SurfaceTool facetada,
  contrato de ejes documentado) y `_lock` (azúcar de puntos de control)
  viven en `godot/character/hair_library.gd`. Winding verificado en
  captura (el orden inicial dejaba las caras exteriores culled).
- QA imparcial del piloto: **38%** (baseline de SU hilo). Veredicto:
  los mechones de loft existen y tienen punta real (superan a los
  conos), pero el conjunto aún lee "casco con dentículos" — hace falta
  **separación REAL entre mechones** (huecos/valles en la silueta, no
  solo picos sobre la masa) y romper el domo liso de la vista trasera.
  Techo estimado por el juez con esta técnica: 50-55%.
- **Issue conocido de shader (NO del loft):** las piezas de pelo
  colgantes (caras hacia abajo) caen en la banda de sombra del toon con
  tinte azulado — preexistente con los conos (visible en la captura
  anotada de Boris 07-19). Decidir en este PRD si se ajusta la rampa/
  luz de relleno del pelo o se acepta como estilo.

## Orden de trabajo propuesto (pendiente de VoBo)

1. **Ronda de separación del piloto** (frontier crop): huecos reales
   entre puntas del flequillo (silueta con valles), coronilla con
   mechones que rompan el domo trasero, borde de transición rapado→masa
   con irregularidad orgánica. Cerrar con el MISMO juez del piloto
   (hilo `ae66465411065b71b` si sigue vivo; si expiró, anotar quiebre
   de serie).
2. **Template femenino:** 1 estilo mujer humano (media melena con
   mechones de caída — ejercita el loft en largos, el caso que mató al
   prince curtain con cajas).
3. **Producción por lotes:** 2-3 estilos por sesión, gates + galería
   `rig_hair_*` + QA por lote, VoBo de Boris por lote.
4. Migrar barbas a loft al final (bloque aparte).

## Guardas

- Anti-paralelismo entre vecinos (largo/grosor/ángulo) — PRD FASE 3.3.
- Sin "dientes" en silueta frontal: puntas con hueco REAL entre sí, no
  serrucho sobre masa continua (hallazgo CRITICAL del QA del piloto).
- Contrato de ejes de `_loft`: puntos en el frame del grupo, root→tip
  en el orden de los puntos (lección M10-r4).
- Verificar UNA construcción end-to-end en captura antes de autorar en
  lote (lección M10-r4).
- Material del llamador siempre opaco (`toon_opaque`) — nunca ALPHA.
