# -*- coding: utf-8 -*-
"""Congela el build del Protocolo A y escribe su hash.

    python godot/tools/freeze_build.py

Escribe godot/build_hash.txt, que la telemetria estampa en cada CSV. Sirve
para una sola cosa, pero es una que §4.2 exige: poder demostrar despues que
los tres testers jugaron EXACTAMENTE el mismo build.

El hash es de CONTENIDO, no el commit de git, por dos razones:
  - se puede recalcular y comparar contra un CSV viejo sin depender del
    historial;
  - no es circular: build_hash.txt no entra en el calculo, asi que
    escribirlo no cambia el numero.
"""
import hashlib, io, os, sys

RAIZ = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")

# Todo lo que puede cambiar lo que el tester ve o siente. Si manana se agrega
# un script al build, va aca -- si no, el hash miente.
ENTRADAS = [
    "project.godot",
    "scenes/gray_test.tscn",
    "scripts/gray_player.gd",
    "scripts/gray_session.gd",
    "scripts/bond_driver.gd",
    "scripts/ledge_zone.gd",
    "scripts/telemetry.gd",
]

def main():
    h = hashlib.sha256()
    faltan = []
    for rel in sorted(ENTRADAS):
        p = os.path.join(RAIZ, rel)
        if not os.path.exists(p):
            faltan.append(rel)
            continue
        h.update(rel.encode("utf-8"))
        with io.open(p, "rb") as f:
            h.update(f.read())

    if faltan:
        print("FALTAN archivos del build: %s" % ", ".join(faltan))
        return 1

    corto = h.hexdigest()[:12]
    with io.open(os.path.join(RAIZ, "build_hash.txt"), "w",
                 encoding="utf-8", newline="\n") as f:
        f.write(corto + "\n")

    print("build congelado: %s" % corto)
    print("  archivos: %d" % len(ENTRADAS))
    print("  anotarlo en Protocolo-de-Playtest.md §0.5")
    return 0

if __name__ == "__main__":
    sys.exit(main())
