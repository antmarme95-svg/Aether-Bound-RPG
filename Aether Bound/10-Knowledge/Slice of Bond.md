---
status: ratificado
source: "Design Loop 2026-07-04 (pareja, ratificada); Design Loop 2026-07-05 (alcance A2b, RATIFICADO por el director)"
updated: 2026-07-05
---

# Slice of Bond (vertical slice)

Objetivo del slice: **probar Bond / links / traición** con 1 celda de jugador
+ 1 Pivote, de link vivo a [[Bond y el Bond Vacío|Bond vacío]].

## Pareja RATIFICADA (2026-07-04)

**Humano Duelist × Dagna (Enana Vanguard) — link: Seismic Springboard.**

Razones: (1) el momentum chaining / supersalto del prototipo (PRD-005,
aceptado en playtest) **ya es la base técnica del link** — media mecánica
está construida; (2) orfandad mecánica máximamente legible: perderla = perder
la verticalidad, peleas a ras de suelo ([[Los 9 Links del Pivote]]); (3) el
quiebre de Dagna (la ley del clan pesa más que el nido; llora mientras lo
hace) es de los beats más fuertes de [[Los 9 Pivotes]]; (4) Humano = ROM de
referencia del rig ([[Movilidad Realista]]) — el esqueleto más barato de
hacer bien primero.

Beat firma del Bond vacío en el slice: una cornisa que *sabes* que alcanzabas
con ella; picas Bond; nadie golpea el suelo.

## Alcance del slice (A2b) — RATIFICADO 2026-07-05

> Principio rector: el slice es **la Estructura Dramática entera en
> miniatura** — lealtad → intimidad → traición → orfandad — con un solo
> Pivote y cero relleno.

### Tramo de [[La Rueda]] (4 escenas, comprimido)

1. **Cold open — El Nido (The Wilds, ~10 min).** Incidente incitante
   comprimido: la purga, la crisálida de [[Speck]], eliges no matar →
   prófugo. Dagna presencia el pregón y te abre paso (*"You kept the wrong
   promise."*). **T1 Springboard** desde el primer encuentro — el link se
   enseña jugando la huida.
2. **Espina — Cinder Ascent, versión corta (~20 min).** La arteria enana:
   paso de montaña empinado donde el Springboard **ES** la progresión
   (metroidvania-lite por link, fiel a La Rueda). Combate mínimo en el paso.
   A mitad, **camp scene** (el ritual de tocar la tierra) → **T2 Fault
   Line** (la fisura encadena con el slide del PRD-005).
3. **Dungeon — eco del Sunken Archive (~15 min).** Mini-bóveda al final del
   Ascent que guarda el Fragmento. Antes de entrar, escena firma → **T3 The
   Mountain's Answer**. Al salir, **la traición**: clava la Primera Cuña,
   deja el martillo (regla T3 de [[The Tether]]), se lleva el Fragmento.
4. **Coda — Bond vacío (~10 min).** Desandar un tramo del Ascent sin
   verticalidad: peleas a ras de suelo, rutas que ya no existen. La cornisa
   que *sabes* que alcanzabas con ella; picas Bond; nadie golpea el suelo.
   Fin del slice. Ratio con ella / huérfano ≈ 80/20.

### Sistemas que ENTRAN (mínimos)

- **Locomoción PRD-005 completa** (ya viva) + Seismic Springboard T1→T3
  como casos del PushPullComponent (GDD §4.2.B.2 — links y traversal
  comparten sistema físico).
- **Combate §4.2 mínimo:** los 4 componentes + HitPayload. Kit **Humano
  Duelist** (combos largos, momentum de locomoción alimenta el daño, parry
  "Roba"); Dagna con kit **Enano Vanguard reducido** (bloqueo-muralla +
  ground-pound — el mismo Push del Springboard). **2 tipos de enemigo**
  sobre los mismos componentes.
- **[[The Tether]] simplificado:** solo el Bond de Dagna (cordón trenzado,
  sin números). Crece por uso real del link + camp scene, fiel a la regla
  anti-grind, pero **sin tope por acto** (el slice comprime T1→T3 en una
  sesión). **Standing queda FUERA como sistema** — existe solo narrado (el
  pregón del Consejo en el cold open).
- **1 camp scene interactiva** (el ritual) — la pieza de UI de bonds mínima.

### Sistemas que NO entran

[[El Quinteto]] (los otros 8 Pivotes), marcas del Strategist
(`MarkMultiplier` neutro), economía de Standing, momentos de Persona de
Speck como sistema (Speck aparece scriptado en el cold open), Driftmarket,
[[Los 4 Finales]].

### Duración objetivo y criterio de éxito

**45–60 min** primera pasada. Criterio de éxito único: un playtester ajeno
al proyecto **siente la pérdida dos veces** — mecánica (la verticalidad no
está) y emocional (la quería). Si la coda no duele, el slice falla aunque
todo lo demás funcione.

## Pendiente (❓)

Desglose del alcance ratificado en PRDs de implementación (Feature Loops);
B10 (Game Feel Bible) alimenta el feel del Springboard; guion de la camp
scene del ritual (ver [[Dagna]]). → Task-Board.
