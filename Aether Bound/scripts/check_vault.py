#!/usr/bin/env python3
"""Auditoría de salud y peso de arranque del Aether Bound Vault (SCHEMA §8).

Solo lectura. Reporta, por archivo: existe/falta/viejo, nivel
(equipo/privado), peso en tokens estimados, y si se auto-carga al arrancar
la sesión (hard/soft/no). Y a nivel proyecto: TOTAL de tokens de arranque
con semáforo, @imports detectados en CLAUDE.md, estado de git, si los
privados están realmente ignorados (git check-ignore real), y si el Vault
es colaborativo (varios autores tocan Current-State.md/LOG.md/CLAUDE.md).

Uso (desde la raíz del repo):
    python3 "Aether Bound/scripts/check_vault.py"          # tabla legible
    python3 "Aether Bound/scripts/check_vault.py" --json   # JSON

Fuente: VAULT-STARTER.md §9 (fusión con la skill project-context).
"""
import os, sys, re, json, subprocess, datetime

if sys.stdout.encoding is None or sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")  # consola de Windows no siempre usa UTF-8 por defecto

OLD_DAYS = 14
CURRENT_STATE_CEILING = 3000   # techo documentado en SCHEMA §7 (~2,500-3,000)
ARRANQUE_VERDE = 10000
ARRANQUE_AMARILLO = 30000

DATE_RE = re.compile(r"(\d{4})-(\d{2})-(\d{2})")
IMPORT_RE = re.compile(r"^@(\S+)", re.MULTILINE)  # sintaxis @import de Claude Code

# (ruta relativa a la raíz del repo, nivel, ¿chequear antigüedad?, autoload: hard/soft/no)
MANIFEST = [
    ("CLAUDE.md",                                    "equipo",  False, "hard"),
    ("Aether Bound/SCHEMA.md",                        "equipo",  False, "no"),
    ("Aether Bound/00-Index.md",                       "equipo",  False, "no"),
    ("Aether Bound/LOG.md",                            "equipo",  False, "no"),
    ("Aether Bound/20-State/Current-State.md",         "equipo",  True,  "soft"),
    ("Aether Bound/20-State/Lecciones.md",             "equipo",  False, "no"),
    ("Aether Bound/20-State/Notas-Privadas.md",        "privado", False, "no"),
    ("Aether Bound/20-State/Bitacora-Privada.md",      "privado", True,  "no"),
]
PRIVADOS_GITIGNORE = [
    "Aether Bound/20-State/Notas-Privadas.md",
    "Aether Bound/20-State/Bitacora-Privada.md",
]
CONTEXT_LOGS = [
    "Aether Bound/20-State/Current-State.md",
    "Aether Bound/LOG.md",
    "CLAUDE.md",
]


def estimar_tokens(path):
    try:
        return os.path.getsize(path) // 4
    except OSError:
        return 0


def fecha_mas_reciente(path):
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            head = f.read(4000)
    except OSError:
        return None
    fechas = []
    for y, m, d in DATE_RE.findall(head):
        try:
            fechas.append(datetime.date(int(y), int(m), int(d)))
        except ValueError:
            pass
    return max(fechas) if fechas else None


def estado_archivo(full, check_age):
    if not os.path.isfile(full):
        return "falta", None
    if check_age:
        fecha = fecha_mas_reciente(full)
        if fecha is not None:
            edad = (datetime.date.today() - fecha).days
            return ("viejo" if edad > OLD_DAYS else "existe"), f"última fecha {fecha.isoformat()} ({edad}d)"
    return "existe", None


def detectar_imports(root):
    claude = os.path.join(root, "CLAUDE.md")
    if not os.path.isfile(claude):
        return []
    try:
        with open(claude, encoding="utf-8", errors="replace") as f:
            texto = f.read()
    except OSError:
        return []
    out = []
    for ruta in IMPORT_RE.findall(texto):
        full = os.path.join(root, ruta)
        out.append({"ruta": ruta, "existe": os.path.isfile(full),
                    "tokens": estimar_tokens(full) if os.path.isfile(full) else 0})
    return out


def git_check_ignore(root, archivo):
    try:
        r = subprocess.run(["git", "-C", root, "check-ignore", "-q", archivo],
                           capture_output=True, timeout=5)
        return r.returncode == 0
    except (subprocess.SubprocessError, OSError):
        return None


def detectar_colaborativo(root):
    autores = set()
    for archivo in CONTEXT_LOGS:
        full = os.path.join(root, archivo)
        if not os.path.isfile(full):
            continue
        try:
            r = subprocess.run(["git", "-C", root, "log", "--format=%an", "--", archivo],
                               capture_output=True, text=True, timeout=10)
            if r.returncode == 0:
                autores.update(l.strip() for l in r.stdout.splitlines() if l.strip())
        except (subprocess.SubprocessError, OSError):
            pass
    return (len(autores) > 1, sorted(autores))


def semaforo(tokens):
    if tokens < ARRANQUE_VERDE:
        return "verde"
    if tokens < ARRANQUE_AMARILLO:
        return "amarillo"
    return "rojo"


def encontrar_root(start):
    """Sube desde `start` hasta encontrar CLAUDE.md (raíz del repo)."""
    cur = os.path.abspath(start)
    while True:
        if os.path.isfile(os.path.join(cur, "CLAUDE.md")):
            return cur
        parent = os.path.dirname(cur)
        if parent == cur:
            return os.path.abspath(start)
        cur = parent


def construir_reporte(root):
    items = []
    for rel, level, check_age, autoload in MANIFEST:
        full = os.path.join(root, rel)
        status, nota = estado_archivo(full, check_age)
        tokens = estimar_tokens(full) if status != "falta" else 0
        item = {"file": rel, "level": level, "status": status, "nota": nota,
                "tokens": tokens, "autoload": autoload}
        if rel.endswith("Current-State.md") and status != "falta" and tokens > CURRENT_STATE_CEILING:
            item["sobre_techo"] = tokens - CURRENT_STATE_CEILING
        items.append(item)

    imports = detectar_imports(root)
    imports_tokens = sum(i["tokens"] for i in imports)

    arranque = sum(it["tokens"] for it in items if it["status"] != "falta" and it["autoload"] in ("hard", "soft"))
    arranque += imports_tokens

    es_git = os.path.isdir(os.path.join(root, ".git"))
    privados_protegidos = {p: git_check_ignore(root, p) for p in PRIVADOS_GITIGNORE} if es_git else {}
    colaborativo, autores = detectar_colaborativo(root) if es_git else (False, [])

    return {
        "root": root, "items": items, "imports": imports,
        "imports_tokens": imports_tokens, "arranque_tokens": arranque,
        "arranque_semaforo": semaforo(arranque),
        "current_state_ceiling": CURRENT_STATE_CEILING,
        "git": es_git, "colaborativo": colaborativo, "autores_contexto": autores,
        "privados_ignorados": privados_protegidos,
    }


def imprimir_tabla(r):
    icon = {"existe": "OK", "falta": "FALTA", "viejo": "VIEJO"}
    load_tag = {"hard": "hard", "soft": "soft", "no": "-"}
    sem = {"verde": "VERDE", "amarillo": "AMARILLO", "rojo": "ROJO"}
    print(f"\nVault: {r['root']}\n")
    for nivel, etiqueta in (("equipo", "EQUIPO (repo)"), ("privado", "PRIVADO")):
        print(etiqueta)
        for it in r["items"]:
            if it["level"] != nivel:
                continue
            nota = f"  - {it['nota']}" if it["nota"] else ""
            tok = f"{it['tokens']:>6,}t" if it["tokens"] else "     ."
            sobre = f"  +{it['sobre_techo']:,}t SOBRE TECHO" if it.get("sobre_techo") else ""
            print(f"  [{icon[it['status']]:>5}] {load_tag[it['autoload']]:>4} {tok}  {it['file']}{nota}{sobre}")
        print()
    print(f"[{sem[r['arranque_semaforo']]}] ARRANQUE DE SESION: ~{r['arranque_tokens']:,} tokens")
    if r["imports"]:
        print(f"\n@imports en CLAUDE.md (se auto-cargan): {r['imports_tokens']:,} tokens")
        for imp in r["imports"]:
            mark = "" if imp["existe"] else "  NO EXISTE"
            print(f"   @{imp['ruta']} - {imp['tokens']:,}t{mark}")
    else:
        print("\n@imports en CLAUDE.md: ninguno (sano).")
    print(f"\nRepo git: {'si' if r['git'] else 'no'}")
    if r["git"]:
        for p, ok in r["privados_ignorados"].items():
            mark = {True: "ignorado", False: "NO IGNORADO (fuga)", None: "? (no existe todavia)"}[ok]
            print(f"   {p}: {mark}")
        if r["colaborativo"]:
            print(f"   COLABORATIVO - autores: {', '.join(r['autores_contexto'])}")
            print("      -> NO reestructures Current-State.md/LOG.md; solo sacalos del auto-load.")
        else:
            print(f"   Individual - autor: {', '.join(r['autores_contexto']) or '(sin historial)'}")
    print()


def main():
    argv = sys.argv[1:]
    as_json = "--json" in argv
    pos = [a for a in argv if not a.startswith("--")]
    root = encontrar_root(pos[0]) if pos else encontrar_root(os.getcwd())
    reporte = construir_reporte(root)
    if as_json:
        print(json.dumps(reporte, ensure_ascii=False, indent=2))
    else:
        imprimir_tabla(reporte)


if __name__ == "__main__":
    main()
