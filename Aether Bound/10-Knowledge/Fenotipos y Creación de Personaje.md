---
status: propuesto
source: "Design Loop 2026-07-04 (Sesión 1 de arte) + prototipo godot/data/phenotype_data.gd"
updated: 2026-07-04
---

# Fenotipos y Creación de Personaje

> El afuera del mandato [[Movilidad Realista]]: el ROM es el fenotipo por
> dentro; esta página lo hace visible. Complementa [[Las Tres Razas]] (quiénes
> son) con *cómo se ven y qué puedes tocar*.

## Regla de oro

**Personalizas *dentro* del fenotipo, nunca contra él.** La silueta Raza+Clase
legible a 3m (north star del prototipo, [[Inventario del Prototipo]]) es
intocable. Los sliders comparten UI pero **cada raza re-rangea cada slider**
(patrón ya vivo: `heightRange` por origen).

## Fenotipo canónico por raza

| | **Elfo (Aether-Born)** | **Enano (Iron-Blooded)** | **Humano (the Restless)** |
|---|---|---|---|
| **Silueta** | Una línea continua: vertical, sin interrupciones | Un trapecio: más ancho que alto en lectura | La referencia atlética; se lee "neutral" contra los otros dos |
| **Esqueleto (fijo)** | Palancas largas, hombros estrechos caídos, cuello largo, dedos largos | Palancas cortas, trapecio masivo, cuello hundido, manos enormes, centro bajo | Proporción media versátil ([[Movilidad Realista]]: el ROM de referencia) |
| **Cabeza** | Orejas largas hacia atrás (continúan la línea), ojos grandes tilt alto, pómulos altos, mandíbula fina | Frente pesada, mandíbula ancha, nariz con historia | Máxima variación individual — la raza joven es la más diversa |
| **Piel** | Fríos pálidos + lavanda aether-marked | Bronces cálidos + gris ceniza forge-touched | El rango humano completo (paleta más ancha); mist-mint como tono raro fronterizo |
| **Marca cultural** | **Patrones de Aether luminosos** (el slider `arcaneMod` re-mapeado: venas de mana → grabados) | **Tatuajes de gremio + inlays de metal**; el slot facial es mayor (ver abajo) | **Warpaint/escarificación Mistbound** (fronterizos); cosmética de ciudad para el resto |

## Decisiones ratificadas (2026-07-04)

1. **Mistbound 100% humanos.** Lo beast-folk del kit Mist-Stalker se retira:
   pieles curtidas, máscaras y adornos de niebla; el mist-mint queda como tono
   de piel humano fronterizo raro ([[Las Tres Razas]], [[Nomenclatura]]).
2. **Enanas: trenzas laterales/patillas ornamentadas con anillas de forja** —
   sin barba plena; misma lectura cultural (el metal en el pelo), silueta
   distinta.
3. **El slider peso/músculo es SOLO visual.** La masa mecánica la fija la
   celda 9-cell ([[Matriz Raza x Rol]], [[Locomoción]]) — el feel es promesa
   de la clase, no del slider.

## Slots de la creación

- **Fijo por raza:** proporciones esqueléticas, orejas, ROM, gait.
- **Fijo por clase:** bulk `arch_xz` (Vanguard 1.30 / Duelist 0.80 /
  Strategist + orbe) — ya vivo.
- **Rango racial (mismo slider, rangos distintos):** altura, peso/músculo,
  mandíbula, pómulos, tilt/forma de ojos.
- **Libre (bibliotecas por raza, solapamiento parcial):** tono de piel,
  peinado, color de pelo, marca cultural + color.

## Herencia técnica

El motor de creación del prototipo se conserva entero: campos
`float/pick/color` (`phenotype_data.gd`), `hair_library`, `warpaint_atlas`,
paletas (`palette_data.gd`). Trabajo nuevo = re-rangear por raza, bibliotecas
raciales de pelo/marcas, re-mapeo cultural de `arcaneMod`, y el paso
Aether-Born/Iron-Blooded/Restless sobre `origins_data.gd` (que aún habla de
"Beast-Folk" — [[Nomenclatura]], tarea C1).

**Pendiente (❓):** fichas fenotípicas de los 9 Pivotes y el elenco C1/C2/C4
(hereda de B1/B2); concept art de los 3 fenotipos base (alimenta B11).
