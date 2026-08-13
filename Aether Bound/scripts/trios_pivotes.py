# -*- coding: utf-8 -*-
"""Combinatoria de trios de Pivotes para v1.

Datos de [[Los 9 Links del Pivote]] y [[Los 9 Pivotes]]:
  - cada Pivote empareja con UNA celda raza x rol del JUGADOR (la matriz de
    links es 1:1)
  - cada Pivote ES ademas un personaje raza x rol, con su propio kit de
    Armamento Base

Se cuenta:
  celdas   = celdas raza x rol distintas que hay que construir
             (las del jugador + las propias de los Pivotes, deduplicadas)
  cuerpos  = razas JUGABLES distintas -> superficies jugables de alta
             fidelidad (lo mas caro)
  anatomias= razas distintas en total (jugables + NPC) -> esqueletos/ROM
"""
from itertools import combinations

# pivote -> (celda del jugador que empareja, celda propia del pivote, forma de la perdida)
P = {
    "Maren":  ("Elfo-Duelist",     "Humano-Strategist", "movilidad aerea: arquero condenado al suelo"),
    "Torgan": ("Elfo-Strategist",  "Enano-Duelist",     "el ejecutor: marcas que ya nadie golpea"),
    "Iven":   ("Elfo-Vanguard",    "Humano-Duelist",    "conversion defensa->ataque: el parry deja de lanzar"),
    "Sereth": ("Enano-Duelist",    "Elfo-Strategist",   "la guia: fuerza bruta sin blanco"),
    "Bram":   ("Enano-Strategist", "Humano-Vanguard",   "la proteccion: eres cristal"),
    "Lyris":  ("Enano-Vanguard",   "Elfo-Duelist",      "el alcance aereo: tu solidez es soledad"),
    "Dagna":  ("Humano-Duelist",   "Enano-Vanguard",    "el mundo: se acabo la verticalidad"),
    "Nyael":  ("Humano-Strategist","Elfo-Duelist",      "el pago de tus herramientas: trampas que nadie cruza"),
    "Vekka":  ("Humano-Vanguard",  "Enano-Strategist",  "partes de ti mismo: pierdes verbos del cuerpo"),
}

def race(cell):
    return cell.split("-")[0]

# CORRECCION: los 3 fijos acompanan al jugador TODO el juego y tienen kits
# BESPOKE (Roen pelea a mano limpia, Valen nunca usa arma de combate, Darro
# tiene hachas de silueta propia) -- no son celdas de la matriz. O sea:
#   - son costo CONSTANTE, no discriminan entre trios
#   - pero sus razas SI: Roen humano, Darro enano, Valen elfo
#     => las 3 anatomias hacen falta SIEMPRE, elijas el trio que elijas.
# Por eso la columna "anatomias" que calcule antes era enganosa y se saca.
FIJOS_RAZAS = {"Humano", "Enano", "Elfo"}

def evaluate(trio):
    player_cells = {P[n][0] for n in trio}
    pivote_cells = {P[n][1] for n in trio}
    cells = player_cells | pivote_cells
    playable_races = {race(c) for c in player_cells}
    npc_races = {race(P[n][1]) for n in trio}
    # dos Pivotes con la MISMA celda pelean igual en pantalla
    own = [P[n][1] for n in trio]
    gemelos = len(own) - len(set(own))
    return {
        "trio": trio,
        "cells": len(cells),
        "bodies": len(playable_races),
        "anatomies": len(FIJOS_RAZAS | playable_races | npc_races),
        "gemelos": gemelos,
        "overlap": len(player_cells & pivote_cells),
        "player_cells": sorted(player_cells),
        "playable_races": sorted(playable_races),
    }

rows = [evaluate(t) for t in combinations(sorted(P), 3)]

# frontera de Pareto sobre (celdas, cuerpos): nadie mejor o igual en ambos
def dominated(r, rows):
    for o in rows:
        if o is r:
            continue
        if o["cells"] <= r["cells"] and o["bodies"] <= r["bodies"] and \
           (o["cells"] < r["cells"] or o["bodies"] < r["bodies"]):
            return True
    return False

print("=" * 78)
print("FRONTERA DE PARETO  (nadie es mejor en celdas Y cuerpos a la vez)")
print("=" * 78)
front = [r for r in rows if not dominated(r, rows)]
front.sort(key=lambda r: (r["cells"], r["bodies"]))
seen = set()
for r in front:
    key = (r["cells"], r["bodies"])
    if key in seen:
        continue
    seen.add(key)
    ejemplos = [x for x in front if (x["cells"], x["bodies"]) == key]
    print("\nceldas=%d  cuerpos jugables=%d   -> %d trio(s):" % (r["cells"], r["bodies"], len(ejemplos)))
    for e in ejemplos[:6]:
        print("     %-26s anatomias=%d  razas jugables=%s"
              % (" + ".join(e["trio"]), e["anatomies"], ",".join(e["playable_races"])))

print()
print("=" * 78)
print("SOLO TRIOS QUE INCLUYEN A DAGNA  (el slice ya esta construido sobre ella)")
print("=" * 78)
con_dagna = [r for r in rows if "Dagna" in r["trio"]]
con_dagna.sort(key=lambda r: (r["cells"], r["bodies"], r["anatomies"]))
print("%-28s %7s %8s %7s %9s" % ("trio", "celdas", "cuerpos", "solape", "gemelos"))
for r in con_dagna[:12]:
    print("%-28s %7d %8d %7d %9d"
          % (" + ".join(r["trio"]), r["cells"], r["bodies"], r["overlap"], r["gemelos"]))

print()
print("peor caso con Dagna, para escala:")
for r in con_dagna[-3:]:
    print("%-28s %7d %8d %7d %9d"
          % (" + ".join(r["trio"]), r["cells"], r["bodies"], r["overlap"], r["gemelos"]))

print()
print("=" * 78)
print("FORMAS DE PERDIDA de los candidatos que aparecen arriba")
print("=" * 78)
for n in ["Dagna", "Vekka", "Bram", "Nyael", "Maren", "Iven", "Lyris", "Sereth", "Torgan"]:
    print("  %-7s %s" % (n, P[n][2]))
