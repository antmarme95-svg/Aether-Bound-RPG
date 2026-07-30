#!/usr/bin/env python3
"""Auditoría de CONSISTENCIA del canon del Aether Bound Vault.

Hermano de `check_vault.py`: ese audita **peso** de arranque, este audita
**consistencia de hechos**. Solo lectura.

Existe porque cinco rondas de QA con subagentes LLM fallaron en la misma
clase de errores: citas rotas, aritmética que no cierra, clases de menciones
barridas a dos tercios, reglas declaradas "fuente única" re-enunciadas por
otros archivos, y fichas cortas que duplican (y contradicen) a su versión
expandida. Todo eso es determinista — no necesita juicio, necesita un
script que nunca olvide un tercio de una clase.

**Regla de oro:** este linter barre lo MECÁNICO. Los subagentes de QA en frío
se reservan para lo que sí exige juicio (dramaturgia, tono, si un epílogo
contradice un arco). Ver [[QA de Canon Loop]] en 30-Loops.

Uso (desde la raíz del repo):
    python "Aether Bound/scripts/check_canon.py"              # reporte legible
    python "Aether Bound/scripts/check_canon.py" --json       # JSON
    python "Aether Bound/scripts/check_canon.py" --solo links # una sola clase
    python "Aether Bound/scripts/check_canon.py" --clases     # lista las clases

Salida: exit code 1 si hay hallazgos CRITICAL, 0 si no (usable como gate).
"""
import os, sys, re, json, glob, unicodedata

if sys.stdout.encoding is None or sys.stdout.encoding.lower() != "utf-8":
    sys.stdout.reconfigure(encoding="utf-8")  # consola de Windows no siempre usa UTF-8

VAULT = "Aether Bound"

# Archivos append-only o históricos: sus enlaces rotos son esperables (registran
# nombres de notas que ya no existen). Se reportan como INFO, nunca CRITICAL.
APPEND_ONLY = {
    "LOG.md",
    "Current-State-Historico.md",
}
# Carpetas que no son canon vivo. `30-Loops` SÍ se carga: es canon enlazable
# ([[QA Loop]], [[Lint Loop]]) y sacarlo del índice rompe la resolución.
DIRS_IGNORADOS = ("90-Raw", ".obsidian", "scripts")

# --- Reglas declaradas fuente única -----------------------------------------
# Cada entrada: (archivo dueño, etiqueta de la sección, términos firma).
# Si un archivo que NO es el dueño contiene un término firma y NO cita al dueño
# en la misma línea, es una violación: está re-enunciando la regla por su cuenta.
# Para agregar una regla nueva: declarala en su archivo con "fuente única" y
# sumá su fila acá.
FUENTES_UNICAS = [
    ("10-Knowledge/Speck.md", "Capa 5", [
        "transferencia de fuerza mecánica",
        "arrebatarla la mata",
        "el fragmento reacciona a fuerza física",
        "se sobrecarga con la fuerza física",
    ]),
    ("10-Knowledge/Nomenclatura.md", "the Wanderer's Goggles", [
        "los goggles son privados",
        "los goggles son estrictamente privados",
        "objeto/accesorio no retirable",
    ]),
]

# --- Epítetos fijos con género canónico -------------------------------------
# (regex del error, texto correcto, por qué)
EPITETOS = [
    (r"\búltimo\s+Warden\b", "última Warden", "Speck es femenina"),
    (r"\bWarden\s+adulto\b", "Warden adulta", "Speck es femenina"),
    (r"\bHis\s+name\s+is\s+Speck\b", "Her name is Speck", "Speck es femenina"),
]

# --- Reinos que no son ciudades caminables ----------------------------------
# Un reino no se camina ni se hospeda; se camina su capital.
REINOS = {
    "Ignis Reach": "Emberdeep",
    "Aethelgard": "Rivermeet",
    "Stillwood": "The Stillspire",
}
VERBOS_CAMINABLES = r"(?:camina\w*\s+(?:hacia|a)|sale\s+de|a\s+pie\s+(?:hacia|a)|afueras\s+de|posada\s+en|se\s+muda\s+a)"

# --- Compatibilidad de cuadrantes -------------------------------------------
CUADRANTES = {
    "NW": {"NW", "N", "W", "NOROESTE", "OESTE", "NORTE", "NORTH", "WEST"},
    "NE": {"NE", "N", "E", "NORESTE", "ESTE", "NORTE", "NORTH", "EAST", "NORTH-EAST"},
    "SW": {"SW", "S", "W", "SUROESTE", "OESTE", "SUR", "SOUTH", "WEST"},
    "SE": {"SE", "S", "E", "SURESTE", "ESTE", "SUR", "SOUTH", "EAST"},
    "N":  {"N", "NW", "NE", "NORTE", "NORTH", "NORTH-CENTRAL"},
    "S":  {"S", "SW", "SE", "SUR", "SOUTH"},
    "E":  {"E", "NE", "SE", "ESTE", "EAST", "EAST-CENTRAL", "CENTER-EAST"},
    "W":  {"W", "NW", "SW", "OESTE", "WEST", "CENTER-WEST"},
    "CENTER": {"CENTER", "CENTRO", "CENTRAL", "CENTER-EAST", "CENTER-WEST",
               "CENTER-SOUTH", "EAST-CENTRAL", "NORTH-CENTRAL"},
}

ALIAS_CUADRANTE = {
    "NW": "NW", "NOROESTE": "NW",
    "NE": "NE", "NORESTE": "NE", "NORTH-EAST": "NE",
    "SW": "SW", "SUROESTE": "SW",
    "SE": "SE", "SURESTE": "SE",
    "N": "N", "NORTE": "N", "NORTH": "N", "NORTH-CENTRAL": "N",
    "S": "S", "SUR": "S", "SOUTH": "S",
    "E": "E", "ESTE": "E", "EAST": "E", "EAST-CENTRAL": "E", "CENTER-EAST": "E",
    "W": "W", "OESTE": "W", "WEST": "W", "CENTER-WEST": "W",
    "CENTER": "CENTER", "CENTRO": "CENTER", "CENTRAL": "CENTER",
    "CENTER-SOUTH": "CENTER",
}

RE_WIKILINK = re.compile(r"\[\[([^\]\|#]+?)(?:#[^\]\|]*)?(?:\|[^\]]*)?\]\]")
# Sección citada: entre comillas si las trae (puede contener puntuación), o hasta
# el primer delimitador. Corta ante `[` para no tragarse el wikilink siguiente
# cuando una línea cita dos secciones ("§X y [[Otro]] §Y").
RE_CITA_SEC = re.compile(
    r"\[\[([^\]\|#]+?)(?:\|[^\]]*)?\]\]\s*§\s*(?:[\"“]([^\"”]+)[\"”]|([^\n,;.()\[\]*—]+))")
# Términos que el vault usa como prosa sobre su propia sintaxis, no como enlaces.
META_TERMS = {"wikilink", "wikilinks", "nota", "notas"}
RE_HEADING = re.compile(r"^\s{0,3}#{1,6}\s+(.+?)\s*$")
RE_BOLD_LEAD = re.compile(r"^\s{0,3}\*\*(.+?)\*\*")
RE_EDAD = re.compile(r"\*\*Edad(?:\s+aparente)?:?\*\*\s*~?(\d{1,4})", re.IGNORECASE)
RE_RANGO_HEADER = re.compile(r"^#{2,4}\s+.*?\(\s*edades?\s+(\d{1,4})\s*[-–]\s*(\d{1,4})\s*\)", re.IGNORECASE)
RE_A_LOS = re.compile(r"[Aa]\s+los\s+(\d{1,4})\s+años")
RE_HACE = re.compile(r"hace\s+(?:unos\s+)?(\d{1,4})\s*\+?\s*años")
RE_RAZA_TABLA = re.compile(
    r"\|\s*\*\*(Elfos|Enanos|Humanos)\*\*\s*\|\s*~?(\d{2,4})\s*[-–]\s*(\d{2,4})\s*años", re.IGNORECASE)
RE_DIALOGO = re.compile(r"\*\"(.+?)\"\*", re.DOTALL)
RE_POI = re.compile(r"^####\s+\*\*(.+?)\*\*\s*\((.+?)\)\s*$")
# Sufijos de versión/formato que no cambian de QUIÉN habla el archivo — pelarlos
# es lo que permite detectar "Darro.md" y "Darro-Ficha-Expandida-v1.md" como el
# mismo personaje en dos archivos.
RE_SUFIJO_V = re.compile(r"-v\d+$", re.IGNORECASE)
RE_SUFIJO_FICHA = re.compile(r"-Ficha-Expandida$", re.IGNORECASE)

CLASES = ["links", "citas", "fuente-unica", "edades", "rangos", "longevidad",
          "genero", "reinos", "cuadrantes", "dialogo", "duplicados", "indice"]


def norm(s):
    """Minúsculas sin acentos, espacios colapsados."""
    s = unicodedata.normalize("NFKD", s)
    s = "".join(c for c in s if not unicodedata.combining(c))
    return re.sub(r"\s+", " ", s).strip().lower()


def encontrar_root(start):
    cur = os.path.abspath(start)
    while True:
        if os.path.isfile(os.path.join(cur, "CLAUDE.md")):
            return cur
        parent = os.path.dirname(cur)
        if parent == cur:
            return os.path.abspath(start)
        cur = parent


def cargar_vault(root):
    """rel_path -> {'lines': [...], 'text': str, 'append_only': bool}"""
    docs = {}
    base = os.path.join(root, VAULT)
    for full in glob.glob(os.path.join(base, "**", "*.md"), recursive=True):
        rel = os.path.relpath(full, base).replace("\\", "/")
        if any(rel.startswith(d + "/") or rel == d for d in DIRS_IGNORADOS):
            continue
        try:
            with open(full, encoding="utf-8", errors="replace") as f:
                text = f.read()
        except OSError:
            continue
        docs[rel] = {
            "lines": text.splitlines(),
            "text": text,
            "append_only": os.path.basename(rel) in APPEND_ONLY,
        }
    return docs


def indice_basenames(docs):
    """Índice de resolución de wikilinks: basename y TODO sufijo de ruta.

    Obsidian resuelve `[[Nota]]`, `[[Carpeta/Nota]]` y `[[Ruta/Larga/Nota]]`
    por igual, así que hay que indexar cada sufijo — no solo el basename y la
    ruta completa.
    """
    idx = {}
    for rel in docs:
        partes = rel[:-3].split("/")
        for i in range(len(partes)):
            idx.setdefault(norm("/".join(partes[i:])), []).append(rel)
    return idx


def headings_de(doc):
    """Lista normalizada de encabezados + líneas que abren en negrita.

    El vault usa las dos formas como título de sección citable
    (ej. `#### **F1 — ...**` y `**Capa 4 — ...:**`).
    """
    out = []
    for ln in doc["lines"]:
        m = RE_HEADING.match(ln)
        if m:
            out.append(norm(m.group(1)))
            continue
        m = RE_BOLD_LEAD.match(ln)
        if m:
            out.append(norm(m.group(1)))
    return out


def add(f, nivel, clase, archivo, linea, msg, extra=None):
    item = {"nivel": nivel, "clase": clase, "archivo": archivo,
            "linea": linea, "mensaje": msg}
    if extra:
        item.update(extra)
    f.append(item)


# ---------------------------------------------------------------- chequeos ---

def check_links(docs, idx, f):
    for rel, doc in docs.items():
        for i, ln in enumerate(doc["lines"], 1):
            for target in RE_WIKILINK.findall(ln):
                t = target.strip()
                if not t or t.endswith("/"):
                    add(f, "INFO" if doc["append_only"] else "MEDIUM", "links", rel, i,
                        f"wikilink a carpeta o vacío: [[{t}]]")
                    continue
                key = norm(t[:-3] if t.lower().endswith(".md") else t)
                if key in META_TERMS:
                    continue  # prosa sobre la sintaxis del vault, no un enlace real
                if key not in idx:
                    add(f, "INFO" if doc["append_only"] else "CRITICAL", "links", rel, i,
                        f"wikilink roto: [[{t}]] no resuelve a ningún archivo")


def check_citas(docs, idx, f):
    """Cada `[[Archivo]] §Sección` debe apuntar a una sección que exista."""
    cache = {}
    for rel, doc in docs.items():
        if doc["append_only"]:
            continue
        for i, ln in enumerate(doc["lines"], 1):
            for target, sec_q, sec_p in RE_CITA_SEC.findall(ln):
                seccion = sec_q or sec_p
                t = target.strip()
                key = norm(t[:-3] if t.lower().endswith(".md") else t)
                if key not in idx:
                    continue  # ya lo reporta check_links
                destino = idx[key][0]
                if destino not in cache:
                    cache[destino] = headings_de(docs[destino])
                sec = norm(seccion).strip("\"'“”«»*_ ")
                if len(sec) < 3:
                    continue
                heads = cache[destino]
                if any(sec in h for h in heads):
                    continue
                # Cita compuesta (ej. "§ACTO 3 sub-beat 5" = sección + sub-sección):
                # se acepta si cada palabra significativa vive en algún encabezado
                # del archivo destino.
                palabras = [w for w in re.split(r"[\s\-]+", sec) if len(w) >= 2]
                blob = " | ".join(heads)
                faltan = [w for w in palabras if w not in blob]
                if not faltan:
                    continue
                add(f, "CRITICAL", "citas", rel, i,
                    f"cita a sección inexistente: [[{t}]] §{seccion.strip()} "
                    f"— {destino} no tiene encabezado que la contenga "
                    f"(sin rastro de: {', '.join(faltan)})")


def check_fuente_unica(docs, f):
    """Nadie más que el dueño puede enunciar una regla declarada fuente única."""
    for dueno, seccion, terminos in FUENTES_UNICAS:
        if dueno not in docs:
            add(f, "MEDIUM", "fuente-unica", dueno, 0,
                "el archivo dueño de una regla de fuente única no existe "
                f"(regla: §{seccion}) — revisar FUENTES_UNICAS en el linter")
            continue
        dueno_stem = norm(os.path.basename(dueno)[:-3])
        for rel, doc in docs.items():
            if rel == dueno or doc["append_only"]:
                continue
            for i, ln in enumerate(doc["lines"], 1):
                nl = norm(ln)
                hit = next((t for t in terminos if norm(t) in nl), None)
                if not hit:
                    continue
                # Si cita al dueño en la misma línea, está derivando, no re-enunciando.
                if dueno_stem in nl or norm(seccion) in nl:
                    continue
                add(f, "CRITICAL", "fuente-unica", rel, i,
                    f"re-enuncia por su cuenta una regla de fuente única "
                    f"(\"{hit}\") sin citar {dueno} §{seccion}")


def _edad_declarada(doc):
    for ln in doc["lines"][:80]:
        m = RE_EDAD.search(ln)
        if m:
            return int(m.group(1))
    return None


def check_edades(docs, f):
    """`hace N años` imposible contra la edad declarada del personaje."""
    for rel, doc in docs.items():
        if doc["append_only"]:
            continue
        edad = _edad_declarada(doc)
        if edad is None:
            continue
        for i, ln in enumerate(doc["lines"], 1):
            for n in RE_HACE.findall(ln):
                n = int(n)
                if n > edad:
                    add(f, "CRITICAL", "edades", rel, i,
                        f"\"hace {n} años\" es imposible: el personaje tiene "
                        f"{edad} años declarados (tendría {edad - n})")
                elif edad - n < 5 and n > 5:
                    add(f, "MEDIUM", "edades", rel, i,
                        f"\"hace {n} años\" pone al personaje en {edad - n} años "
                        f"de edad (declarada: {edad}) — verificar si es plausible")


def check_rangos(docs, f):
    """`### ... (edades A-B)` debe contener sus propios datos `A los N años`."""
    for rel, doc in docs.items():
        if doc["append_only"]:
            continue
        activo = None
        for i, ln in enumerate(doc["lines"], 1):
            m = RE_RANGO_HEADER.match(ln)
            if m:
                activo = (int(m.group(1)), int(m.group(2)), i, ln.strip())
                continue
            if activo and RE_HEADING.match(ln):
                lo, hi, _, _ = activo
                if not re.match(r"^#{4,6}\s", ln):  # heading de igual o menor nivel cierra
                    activo = None
            if not activo:
                continue
            lo, hi, hln, htxt = activo
            for n in RE_A_LOS.findall(ln):
                n = int(n)
                if not (lo <= n <= hi):
                    add(f, "MEDIUM", "rangos", rel, i,
                        f"\"A los {n} años\" cae fuera del rango del encabezado "
                        f"(edades {lo}-{hi}, línea {hln}) — el encabezado no "
                        f"encierra sus propios datos")


def _rangos_raza(docs):
    doc = docs.get("10-Knowledge/Las Tres Razas.md")
    if not doc:
        return {}
    out = {}
    for raza, lo, hi in RE_RAZA_TABLA.findall(doc["text"]):
        out[norm(raza).rstrip("s")] = (int(lo), int(hi))
    return out


def check_longevidad(docs, f):
    """Rangos de longevidad citados en fichas contra la tabla canónica."""
    canon = _rangos_raza(docs)
    if not canon:
        add(f, "MEDIUM", "longevidad", "10-Knowledge/Las Tres Razas.md", 0,
            "no se pudo parsear la tabla de longevidad — el chequeo quedó sin correr")
        return
    pat = re.compile(r"\*\*(ELFO|ELFA|ENANO|ENANA|HUMANO|HUMANA)\*\*.{0,40}?"
                     r"viven\s+~?(\d{2,4})\s*[-–]\s*(\d{2,4})\s*años", re.IGNORECASE)
    for rel, doc in docs.items():
        if doc["append_only"]:
            continue
        for i, ln in enumerate(doc["lines"], 1):
            for raza, lo, hi in pat.findall(ln):
                key = norm(raza).rstrip("as").rstrip("o")
                key = {"elf": "elfo", "enan": "enano", "human": "humano"}.get(key, key)
                esperado = canon.get(key)
                if not esperado:
                    continue
                if (int(lo), int(hi)) != esperado:
                    add(f, "CRITICAL", "longevidad", rel, i,
                        f"longevidad de {raza.upper()} declarada {lo}-{hi} pero el canon "
                        f"([[Las Tres Razas]]) dice {esperado[0]}-{esperado[1]}")


def check_genero(docs, f):
    for rel, doc in docs.items():
        if doc["append_only"]:
            continue
        for i, ln in enumerate(doc["lines"], 1):
            for rx, correcto, por_que in EPITETOS:
                if re.search(rx, ln):
                    add(f, "CRITICAL", "genero", rel, i,
                        f"epíteto con género incorrecto — debería ser \"{correcto}\" ({por_que})")


def check_reinos(docs, f):
    for rel, doc in docs.items():
        if doc["append_only"]:
            continue
        for i, ln in enumerate(doc["lines"], 1):
            for reino, capital in REINOS.items():
                if reino not in ln:
                    continue
                if re.search(VERBOS_CAMINABLES + r"\s+(?:las\s+afueras\s+de\s+)?" + re.escape(reino), ln, re.IGNORECASE) \
                   or re.search(r"afueras\s+de\s+" + re.escape(reino), ln, re.IGNORECASE):
                    add(f, "MEDIUM", "reinos", rel, i,
                        f"\"{reino}\" es un REINO, no una ciudad caminable — "
                        f"probablemente debería ser su capital ({capital})")


def _token_cuadrante(texto):
    t = norm(texto).upper().replace("—", " ").replace("_", " ")
    t = re.sub(r"[^A-Z0-9\- ]", " ", t)
    for tok in ("NORTH-EAST", "NORTH-CENTRAL", "CENTER-EAST", "CENTER-WEST",
                "CENTER-SOUTH", "EAST-CENTRAL", "NW", "NE", "SW", "SE",
                "NOROESTE", "NORESTE", "SUROESTE", "SURESTE",
                "CENTER", "CENTRO", "CENTRAL", "NORTH", "SOUTH", "EAST", "WEST",
                "NORTE", "SUR", "ESTE", "OESTE"):
        if re.search(r"\b" + tok + r"\b", t):
            return tok
    return None


def _grupo(tok):
    """Token de cuadrante -> clave canónica. Alias explícito: escanear los sets
    de CUADRANTES daba precedencia por orden de dict (NORTE caía en NW antes
    que en N)."""
    if tok is None:
        return None
    return ALIAS_CUADRANTE.get(tok)


def check_cuadrantes(docs, f):
    """POIs de Geografía (fuente primaria) contra las listas derivadas de Briefs."""
    geo = docs.get("10-Knowledge/Geografía y Ciudades.md")
    briefs = docs.get("10-Knowledge/Briefs de Mapa del Mundo.md")
    if not geo or not briefs:
        return
    canon = {}
    for ln in geo["lines"]:
        m = RE_POI.match(ln)
        if m:
            canon[norm(m.group(1))] = (m.group(1), _token_cuadrante(m.group(2)))

    seccion = None
    for i, ln in enumerate(briefs["lines"], 1):
        h = re.match(r"^###\s+(.+?)\s*$", ln)
        if h:
            seccion = _token_cuadrante(h.group(1))
            continue
        b = re.match(r"^-\s+([A-Z][^(—*]{2,40})", ln)
        if not (b and seccion):
            continue
        nombre = norm(re.sub(r"\s+$", "", b.group(1)))
        entry = canon.get(nombre) or canon.get("the " + nombre)
        if not entry:
            continue
        real, tok_geo = entry
        g_geo, g_brief = _grupo(tok_geo), _grupo(seccion)
        if g_geo and g_brief and g_geo != g_brief and tok_geo not in CUADRANTES.get(g_brief, set()):
            add(f, "MEDIUM", "cuadrantes", "10-Knowledge/Briefs de Mapa del Mundo.md", i,
                f"\"{real}\" está en {seccion} acá pero en {tok_geo} en Geografía "
                f"(fuente primaria) — regenerar esta lista, no editarla a mano")


def check_dialogo(docs, f):
    """Advertencia: números dentro de diálogo. Los más caros de equivocar."""
    for rel, doc in docs.items():
        if doc["append_only"]:
            continue
        for i, ln in enumerate(doc["lines"], 1):
            for cita in RE_DIALOGO.findall(ln):
                nums = re.findall(r"\b(\d{2,4})\s*(?:años|years)\b", cita)
                if nums:
                    add(f, "INFO", "dialogo", rel, i,
                        f"cifra en línea de diálogo ({', '.join(nums)}) — "
                        f"verificar a mano: un número mal en diálogo llega al guion")


def _personaje_stem(rel):
    """Nombre de personaje sin sufijo de versión/ficha, normalizado."""
    base = os.path.basename(rel)[:-3]
    base = RE_SUFIJO_V.sub("", base)
    base = RE_SUFIJO_FICHA.sub("", base)
    base = RE_SUFIJO_V.sub("", base)  # por si el sufijo -vN queda antes del pelado
    return norm(base)


def check_duplicados(docs, f):
    """Dos archivos de 10-Knowledge con el mismo nombre de personaje en
    carpetas distintas = fuente viva partida en dos. Es la clase que costó
    4 fichas archivadas (Dagna, Darro, Roen, Valen) en dos rondas de QA —
    ahora hay una regla explícita en 00-Index ("una sola fuente viva por
    personaje") y esto la hace cumplir mecánicamente."""
    grupos = {}
    for rel, doc in docs.items():
        if doc["append_only"] or not rel.startswith("10-Knowledge/"):
            continue
        stem = _personaje_stem(rel)
        if len(stem) < 3:
            continue
        grupos.setdefault(stem, []).append(rel)
    for stem, archivos in grupos.items():
        carpetas = {os.path.dirname(a) for a in archivos}
        if len(archivos) > 1 and len(carpetas) > 1:
            primero = sorted(archivos)[0]
            add(f, "CRITICAL", "duplicados", primero, 0,
                f"posible ficha duplicada — mismo personaje en carpetas distintas: "
                f"{', '.join(sorted(archivos))}. Regla del vault: una sola fuente "
                f"viva por personaje (ver 00-Index)")


def check_indice(docs, idx, f):
    """Archivos de 10-Knowledge que 00-Index.md no referencia con ningún
    wikilink — huérfanos, o simplemente falta indexarlos. Los enlaces ROTOS
    de 00-Index ya los reporta 'links'; esto es lo complementario: enlaces
    que deberían existir y no existen."""
    index_doc = docs.get("00-Index.md")
    if not index_doc:
        return
    referenciados = set()
    for ln in index_doc["lines"]:
        for target in RE_WIKILINK.findall(ln):
            t = target.strip()
            if not t or t.endswith("/"):
                continue
            key = norm(t[:-3] if t.lower().endswith(".md") else t)
            referenciados.update(idx.get(key, []))
    for rel, doc in docs.items():
        if doc["append_only"] or not rel.startswith("10-Knowledge/"):
            continue
        if rel not in referenciados:
            add(f, "INFO", "indice", rel, 0,
                "no está referenciado desde 00-Index.md — huérfano, o falta indexarlo")


CHEQUEOS = {
    "links": lambda d, i, f: check_links(d, i, f),
    "citas": lambda d, i, f: check_citas(d, i, f),
    "fuente-unica": lambda d, i, f: check_fuente_unica(d, f),
    "edades": lambda d, i, f: check_edades(d, f),
    "rangos": lambda d, i, f: check_rangos(d, f),
    "longevidad": lambda d, i, f: check_longevidad(d, f),
    "genero": lambda d, i, f: check_genero(d, f),
    "reinos": lambda d, i, f: check_reinos(d, f),
    "cuadrantes": lambda d, i, f: check_cuadrantes(d, f),
    "dialogo": lambda d, i, f: check_dialogo(d, f),
    "duplicados": lambda d, i, f: check_duplicados(d, f),
    "indice": lambda d, i, f: check_indice(d, i, f),
}

ORDEN_NIVEL = {"CRITICAL": 0, "MEDIUM": 1, "INFO": 2}


def construir_reporte(root, solo=None):
    docs = cargar_vault(root)
    idx = indice_basenames(docs)
    hallazgos = []
    corridas = [c for c in CLASES if not solo or c in solo]
    for clase in corridas:
        CHEQUEOS[clase](docs, idx, hallazgos)
    hallazgos.sort(key=lambda h: (ORDEN_NIVEL[h["nivel"]], h["clase"], h["archivo"], h["linea"]))
    resumen = {n: sum(1 for h in hallazgos if h["nivel"] == n) for n in ORDEN_NIVEL}
    return {"root": root, "archivos_auditados": len(docs), "clases": corridas,
            "resumen": resumen, "hallazgos": hallazgos}


def imprimir(r):
    print(f"\nCanon: {r['root']}/{VAULT}  ({r['archivos_auditados']} archivos)\n")
    if not r["hallazgos"]:
        print("[LIMPIO] Ningún hallazgo mecánico.\n")
    actual = None
    for h in r["hallazgos"]:
        if (h["nivel"], h["clase"]) != actual:
            actual = (h["nivel"], h["clase"])
            print(f"\n== {h['nivel']} / {h['clase']} ==")
        loc = f"{h['archivo']}:{h['linea']}" if h["linea"] else h["archivo"]
        print(f"  {loc}\n      {h['mensaje']}")
    s = r["resumen"]
    print(f"\n{'-' * 68}")
    print(f"CRITICAL: {s['CRITICAL']}   MEDIUM: {s['MEDIUM']}   INFO: {s['INFO']}")
    if s["CRITICAL"]:
        print("\nCriterio de cierre NO cumplido: hay criticos mecanicos.")
        print("Corregi en la FUENTE del dato, no en la linea reportada, y volve a correr.")
    else:
        print("\nSin criticos mecanicos. Recien aca vale la pena gastar")
        print("subagentes de QA en lo que si exige juicio (dramaturgia, tono, arcos).")
    print()


def main():
    argv = sys.argv[1:]
    if "--clases" in argv:
        print("Clases de chequeo disponibles (--solo a,b,c):")
        for c in CLASES:
            print(f"  {c}")
        return 0
    solo = None
    for a in argv:
        if a.startswith("--solo"):
            val = a.split("=", 1)[1] if "=" in a else (argv[argv.index(a) + 1] if len(argv) > argv.index(a) + 1 else "")
            solo = {x.strip() for x in val.split(",") if x.strip()}
    if solo:
        malas = solo - set(CLASES)
        if malas:
            print(f"Clase desconocida: {', '.join(sorted(malas))}", file=sys.stderr)
            return 2
    pos = [a for a in argv if not a.startswith("--")]
    pos = [p for p in pos if not solo or p not in (",".join(sorted(solo)),)]
    root = encontrar_root(pos[0]) if pos else encontrar_root(os.getcwd())
    r = construir_reporte(root, solo)
    if "--json" in argv:
        print(json.dumps(r, ensure_ascii=False, indent=2))
    else:
        imprimir(r)
    return 1 if r["resumen"]["CRITICAL"] else 0


if __name__ == "__main__":
    sys.exit(main())
