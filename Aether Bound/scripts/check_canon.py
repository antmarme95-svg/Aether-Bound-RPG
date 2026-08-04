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

# --- La escena del cráter ----------------------------------------------------
# Fuente: 10-Knowledge/El Cráter — Matriz de Rutas.md §2. Estas cuatro clases de
# error (mensajero, borde, gate de F4, premisas) aparecieron en CUATRO rondas de
# QA seguidas, siempre igual: un fix entra en la fuente y no baja a las fichas.
# Cada chequeo de acá es un crítico que ya no hay que pagarle a un subagente.

RUTAS_CRATER = {
    # pivote -> (regex de su cadena institucional, cómo se llama su mensajero)
    "maren":  (r"council",                    "mensajero del Council"),
    "sereth": (r"royal academy",              "mensajero de la Royal Academy"),
    "torgan": (r"clan menor",                 "mensajero del clan menor"),
    "iven":   (r"consortium",                 "contacto del Consortium"),
    "dagna":  (r"deepstone|subclan",          "mensajero de Deepstone"),
    "vekka":  (r"great forging clan|gremio",  "mensajero del Great Forging Clan"),
    "lyris":  (r"frontier high command",      "mensajero de Frontier High Command"),
    "nyael":  (r"extraccion",                 "el equipo de extracción"),
    "bram":   (r"torgan",                     "Torgan como segundo agente"),
}

# Quién sostiene a Speck es el agente a neutralizar solo en estas dos rutas.
HOLDER_ES_AGENTE = {"nyael", "bram"}

RE_MENSAJERO_DE = re.compile(
    r"(?:mensajero|contacto|emisario)\s+(?:de\s+la\s+|del\s+|de\s+)([^,.;:—\n()]{3,45})",
    re.IGNORECASE)

# El Pivote se detiene SIEMPRE en el borde (Matriz §1, paso 3).
RE_PIVOTE_ADENTRO = re.compile(
    r"(?:llega|entra|est[aá]|baja|camina|se detiene|espera)\w*\s+"
    r"(?:[^.\n]{0,40}?)\b(?:al|en\s+el|hacia\s+el|hasta\s+el)\s+"
    r"(?:centro|fondo)\s+del\s+cr[aá]ter", re.IGNORECASE)
# "ya está adentro" solo cuenta si habla del cráter — "adentro del asunto" no.
RE_YA_ADENTRO = re.compile(
    r"ya\s+est[aá]\s+adentro(?:[^.\n]{0,30}(?:cr[aá]ter|First\s+Wound))", re.IGNORECASE)
# El mensajero SÍ sube desde dentro; Speck SÍ cruza en F4. No son el Pivote.
RE_BORDE_OK = re.compile(
    r"mensajero|contacto\s+del|equipo\s+de\s+extracci|sube\s+desde|viene\s+subiendo|"
    r"speck\s+cruza|cruza\s+el\s+borde|core\s+central\s+responde|jugador\s+cruza",
    re.IGNORECASE)

# El gate de F4 son 2 condiciones globales y NINGUNA depende del Pivote.
RE_GATE_RUTA = re.compile(
    r"(?:requiere\s+que\s+el\s+jugador\s+haya|sin\s+perd[oó]n|"
    r"no\s+est[aá]\s+en\s+F4|este\s+final\s+requiere)", re.IGNORECASE)

# Premisas derogadas: matar a Speck no sana nada, y no hay reloj autónomo.
PREMISAS_PROHIBIDAS = [
    (re.compile(r"si\s+(?:ella\s+|speck\s+)?muere", re.IGNORECASE),
     "«si muere» — el plan institucional es entrega VIVA (Estructura Dramática, Speck §Capa 5)"),
    (re.compile(r"live\s+if\s+she\s+dies", re.IGNORECASE),
     "«live if she dies» — matarla no sana nada"),
    (re.compile(r"si\s+(?:speck\s+)?madura", re.IGNORECASE),
     "«si madura» — no hay reloj de maduración autónomo (El Mundo y la Muda)"),
    (re.compile(r"sacrificar\s+a\s+speck|sacrificio\s+de\s+speck", re.IGNORECASE),
     "«sacrificar a Speck» — el plan es capturarla y entregarla viva"),
    (re.compile(r"si\s+speck\s+vive", re.IGNORECASE),
     "«si Speck vive» — lo que amenaza al Council es que llegue al cráter, no que viva"),
]
# Enunciar la premisa PARA DESMENTIRLA es correcto y necesario.
RE_DESMIENTE = re.compile(
    r"no\s+sana|no\s+apaga|error\s+de\s+c[aá]lculo|matarla\s+no|no\s+produce|"
    r"est[aá]\s+prohibid|no\s+existe|mundo\s+hipot|hipot[eé]tic|prohibicion|"
    r"crítico\s+de\s+premisa|premisa\s+vieja|derogad", re.IGNORECASE)

# Beats obligatorios por final (Matriz §4).
BEATS_OBLIGATORIOS = {
    "f3": (re.compile(r"suelta|abre\s+el\s+arn[eé]s|baja\s+a\s+speck|abre\s+las\s+manos|"
                      r"la\s+deja\s+ir|cede", re.IGNORECASE),
           "el holder debe SOLTAR a Speck al ver cruzar al jugador (Matriz §4, F3)"),
    "f4": (re.compile(r"se\s+aparta|se\s+apartan|no\s+tiene\s+protocolo|no\s+tiene\s+orden|"
                      r"cierra\s+el\s+malet[ií]n|se\s+va\s+sin\s+decir|baja\s+a\s+speck",
                      re.IGNORECASE),
           "el mensajero debe APARTARSE al ver que Speck responde (Matriz §4, F4)"),
}
RE_HEAD_FINAL = re.compile(r"^#{2,4}\s*\**\s*(F1|F2a|F2b|F3|F4)\b", re.IGNORECASE)

# Los fijos narran su reacción, nunca el quiebre en sí (Matriz §Regla de uso).
FIJOS = ("Roen-Ficha", "Valen-Ficha", "Darro-Ficha")

# La traición ocurre en el CORREDOR del Archive (Matriz §1, paso 1), no en el
# cráter. Los 3 fijos la tenían escenificada en el lugar equivocado y el chequeo
# de descripción no lo veía: detectaba el QUÉ, no el DÓNDE.
RE_ENCABEZADO_CRATER = re.compile(
    r"^#{2,5}.*(?:First\s+Wound|cr[aá]ter)", re.IGNORECASE)
RE_TOMA_A_SPECK = re.compile(
    r"se\s+lleva\s+a\s+speck|el\s+pivote\s+act[uú]a|toma\s+a\s+speck|"
    r"se\s+lleva\s+el\s+fragmento", re.IGNORECASE)

# Un superlativo de reacción vale en UN solo lugar del vault (Matriz §Corolario).
RE_SUPERLATIVO = re.compile(
    r"(?:la\s+[uú]nica\s+vez|el\s+[uú]nico\s+momento|la\s+escena\s+m[aá]s\s+grande|"
    r"lo\s+m[aá]s\s+raro\s+posible)\b[^.\n]{0,80}", re.IGNORECASE)
NOMBRES_FIJOS = ("darro", "roen", "valen")
# Solo verbos de ESCENA (los que reconstruyen el quiebre paso a paso). Mencionar
# el evento en subordinada para hablar de la reacción propia es correcto y es lo
# que los fijos deben hacer: "cuando ella se lleva a Speck, Roen pierde…".
RE_QUIEBRE_VERBO = re.compile(
    r"desmonta\s+(?:el|tu)\s+equipo|fija\s+a\s+speck\s+al\s+yunque|"
    r"la\s+inmoviliza|cierra\s+los\s+ojos\s+un\s+segundo", re.IGNORECASE)

CLASES = ["links", "citas", "fuente-unica", "edades", "rangos", "longevidad",
          "genero", "reinos", "cuadrantes", "dialogo", "duplicados", "indice",
          "crater-mensajero", "crater-borde", "gate-f4", "premisas",
          "crater-beats", "quiebre-fijos", "quiebre-lugar", "superlativos"]


def _pivote_de(rel):
    """Nombre de Pivote si el archivo es una de las 9 fichas, si no None."""
    if "/Pivotes/" not in rel:
        return None
    stem = _personaje_stem(rel)
    return stem if stem in RUTAS_CRATER else None


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


def _secciones_final(doc):
    """línea -> cuál de los 5 finales la contiene ('f1'...'f4'), o None."""
    actual = None
    out = {}
    for i, ln in enumerate(doc["lines"], 1):
        m = RE_HEAD_FINAL.match(ln)
        if m:
            actual = m.group(1).lower()
        elif RE_HEADING.match(ln):
            actual = None          # otro encabezado cierra la sección de final
        out[i] = actual
    return out


def check_crater_mensajero(docs, f):
    """Cada Pivote responde a SU cadena institucional, no al Council por
    defecto. Sereth usando 'mensajero del Council' fue crítico en la 9ª."""
    for rel, doc in docs.items():
        piv = _pivote_de(rel)
        if not piv:
            continue
        permitido, esperado = RUTAS_CRATER[piv]
        for i, ln in enumerate(doc["lines"], 1):
            for cadena in RE_MENSAJERO_DE.findall(ln):
                c = norm(cadena)
                if re.search(permitido, c):
                    continue
                # Otras cadenas se pueden nombrar si NO es el mensajero del cráter
                if re.search(r"cr[aá]ter|borde|entrega|recibirla|F1|F2a", ln, re.IGNORECASE):
                    add(f, "CRITICAL", "crater-mensajero", rel, i,
                        f"mensajero de «{cadena.strip()}» en la ruta {piv.capitalize()} — "
                        f"su cadena es otra: {esperado} "
                        f"(El Cráter — Matriz de Rutas §2)")


def check_crater_borde(docs, f):
    """El Pivote se detiene SIEMPRE en el borde, nunca en el centro. Si cruzara,
    F1/F2b/F4 quedarían inalcanzables en esa ruta."""
    for rel, doc in docs.items():
        piv = _pivote_de(rel)
        if not piv:
            continue
        for i, ln in enumerate(doc["lines"], 1):
            if RE_BORDE_OK.search(ln):
                continue
            if RE_PIVOTE_ADENTRO.search(ln) or RE_YA_ADENTRO.search(ln):
                add(f, "CRITICAL", "crater-borde", rel, i,
                    f"{piv.capitalize()} aparece en el centro/fondo del cráter — "
                    f"el Pivote se detiene SIEMPRE en el borde "
                    f"(El Cráter — Matriz de Rutas §1, paso 3)")


def check_gate_f4(docs, f):
    """El gate de F4 son 2 condiciones globales y ninguna depende del Pivote.
    Cinco fichas habían inventado un «si lo perdonaste» que no existe."""
    for rel, doc in docs.items():
        if not _pivote_de(rel):
            continue
        secs = _secciones_final(doc)
        for i, ln in enumerate(doc["lines"], 1):
            if secs.get(i) != "f4":
                continue
            if "Matriz de Rutas" in ln or "condiciones globales" in ln:
                continue
            if RE_GATE_RUTA.search(ln):
                add(f, "CRITICAL", "gate-f4", rel, i,
                    "el epílogo F4 agrega una condición de ruta — el gate son 2 "
                    "condiciones globales (Momentos + Tether) y ninguna depende "
                    "del Pivote (Los 5 Finales §F4, Matriz §4)")


def check_premisas(docs, f):
    """Premisas derogadas: matar a Speck no sana nada, y no hay reloj de
    maduración autónomo. Dos excepciones legítimas: enunciarlas PARA
    DESMENTIRLAS, y hablar de F2b — el único final donde Speck sí muere."""
    for rel, doc in docs.items():
        if doc["append_only"] or not rel.startswith("10-Knowledge/"):
            continue
        secs = _secciones_final(doc)
        for i, ln in enumerate(doc["lines"], 1):
            if RE_DESMIENTE.search(ln):
                continue
            if secs.get(i) == "f2b" or re.search(r"\bF2b\b", ln):
                continue
            for rx, msg in PREMISAS_PROHIBIDAS:
                if rx.search(ln):
                    add(f, "CRITICAL", "premisas", rel, i, msg)
                    break


def check_crater_beats(docs, f):
    """F3 exige que el holder suelte a Speck; F4, que el mensajero se aparte.
    Sin esos beats el epílogo no ejecuta el gate que dice ejecutar."""
    for rel, doc in docs.items():
        piv = _pivote_de(rel)
        if not piv:
            continue
        secs = _secciones_final(doc)
        texto = {}
        for i, ln in enumerate(doc["lines"], 1):
            s = secs.get(i)
            if s in BEATS_OBLIGATORIOS:
                texto.setdefault(s, []).append(ln)
        for final, (rx, msg) in BEATS_OBLIGATORIOS.items():
            cuerpo = "\n".join(texto.get(final, []))
            if not cuerpo:
                continue
            if not rx.search(cuerpo):
                add(f, "MEDIUM", "crater-beats", rel, 0,
                    f"el epílogo {final.upper()} de {piv.capitalize()} no tiene su "
                    f"beat obligatorio: {msg}")


def check_quiebre_fijos(docs, f):
    """Los fijos narran su REACCIÓN al quiebre, no el quiebre. Cuatro archivos
    describían el de Vekka como su epílogo de F2b — clase entera de la 10ª."""
    for rel, doc in docs.items():
        if not any(nombre in rel for nombre in FIJOS):
            continue
        for i, ln in enumerate(doc["lines"], 1):
            if not RE_QUIEBRE_VERBO.search(ln):
                continue
            if "[[" in ln:      # cita la ficha del Pivote: correcto
                continue
            add(f, "MEDIUM", "quiebre-fijos", rel, i,
                "ficha de fijo describe el quiebre de un Pivote sin citar su ficha — "
                "los fijos narran su reacción, no el evento "
                "(El Cráter — Matriz de Rutas §Regla de uso)")


def check_quiebre_lugar(docs, f):
    """La traición ocurre en el CORREDOR del Archive, no en el cráter. Los 3
    fijos la tenían bajo un encabezado de First Wound — el chequeo anterior
    veía el QUÉ y no el DÓNDE, y por eso la 11ª ronda lo encontró igual."""
    for rel, doc in docs.items():
        if not any(nombre in rel for nombre in FIJOS):
            continue
        # Agrupar por sección: una sección que declara dónde ocurrió la toma
        # (menciona el corredor o cita la Matriz) está bien ubicada aunque
        # después mencione el evento varias veces.
        secciones, actual = [], None
        for i, ln in enumerate(doc["lines"], 1):
            if RE_HEADING.match(ln):
                actual = {"linea": i, "crater": bool(RE_ENCABEZADO_CRATER.match(ln)),
                          "cuerpo": [], "primera": None}
                secciones.append(actual)
                continue
            if actual is None:
                continue
            actual["cuerpo"].append(ln)
            if actual["primera"] is None and RE_TOMA_A_SPECK.search(ln):
                actual["primera"] = i
        for s in secciones:
            if not s["crater"] or s["primera"] is None:
                continue
            cuerpo = "\n".join(s["cuerpo"])
            if re.search(r"corredor|Matriz\s+de\s+Rutas|ya\s+lleg[oó]", cuerpo, re.IGNORECASE):
                continue
            add(f, "CRITICAL", "quiebre-lugar", rel, s["primera"],
                f"la traición está escenificada bajo un encabezado de cráter "
                f"(línea {s['linea']}) sin aclarar que la toma ocurrió en el "
                f"CORREDOR del Sunken Archive (El Cráter — Matriz de Rutas §1, "
                f"paso 1). En el cráter el Pivote ya llegó con Speck")


def check_superlativos(docs, f):
    """Un superlativo de reacción de un fijo ('la única vez que Darro se queda
    mudo') vale en UN solo lugar del vault. La 11ª encontró cuatro escenas
    reclamando el mismo — el corolario estaba escrito y no implementado."""
    vistos = {}
    for rel, doc in docs.items():
        if doc["append_only"] or not rel.startswith("10-Knowledge/"):
            continue
        for i, ln in enumerate(doc["lines"], 1):
            for frase in RE_SUPERLATIVO.findall(ln):
                fn = norm(frase)
                quien = next((n for n in NOMBRES_FIJOS if n in norm(ln)), None)
                if not quien:
                    continue
                # Un superlativo con eje declarado ("el único donde X elige Y")
                # es legítimo: acota en vez de reclamar exclusividad global.
                if re.search(r"\bdonde\b|\bpor\b|no\s+es\s+su", fn):
                    continue
                clave = (quien, re.sub(r"\d+", "", fn)[:45])
                if clave in vistos and vistos[clave][0] != rel:
                    prev_rel, prev_i = vistos[clave]
                    add(f, "MEDIUM", "superlativos", rel, i,
                        f"superlativo de {quien.capitalize()} ya reclamado en "
                        f"{prev_rel}:{prev_i} — un «única vez» vale en un solo lugar "
                        f"del vault (Matriz §Corolario). Re-escopar uno de los dos")
                else:
                    vistos.setdefault(clave, (rel, i))


CHEQUEOS = {
    "links": lambda d, i, f: check_links(d, i, f),
    "crater-mensajero": lambda d, i, f: check_crater_mensajero(d, f),
    "crater-borde": lambda d, i, f: check_crater_borde(d, f),
    "gate-f4": lambda d, i, f: check_gate_f4(d, f),
    "premisas": lambda d, i, f: check_premisas(d, f),
    "crater-beats": lambda d, i, f: check_crater_beats(d, f),
    "quiebre-fijos": lambda d, i, f: check_quiebre_fijos(d, f),
    "quiebre-lugar": lambda d, i, f: check_quiebre_lugar(d, f),
    "superlativos": lambda d, i, f: check_superlativos(d, f),
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
