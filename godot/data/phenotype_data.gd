# Phenotype slider/pick definitions — direct port of src/data/phenotype.js.
class_name PhenotypeData extends RefCounted

const HAIR_STYLES: Array[String] = [
	"Wyld Mane", "Norse Braids", "Elven Topknot", "Pompadour Undercut", "Ash Spikes",
	"Curtain Long", "War Mohawk", "Twin Tails", "Shorn Scout", "Drake Dreads",
]

const BEARD_STYLES: Array[String] = ["Clean", "Stubble", "Braided Jarl", "Goatee"]

# PRD Warpaint Personalizable (2026-07-14): "Scout Marks" (índice 6) se
# agrega a la lista seleccionable — ya existía en el atlas/geometría
# (`warpaint_atlas.gd` lo deja vacío A PROPÓSITO porque su marca real es
# geometría en `character_rig._face_mark`) pero nunca estuvo expuesto en
# este array, así que la UI de creación de personaje (Fase 4) no podía
# ofrecerlo como opción.
const WARPAINTS: Array[String] = ["None", "Slash Crimson", "Hexbrand", "Tribal Tide", "Eye of Ash", "Jagged Crown", "Scout Marks"]

# kind: "float" => slider 0..1  |  "pick" => button grid index  |  "color" => swatch index
const PHENOTYPE_FIELDS: Array[Dictionary] = [
	# --- BODY & TECH ---
	{"id": "weight",    "label": "Weight / Muscle",       "kind": "float", "tab": "body", "section": "Frame",       "default": 0.5,  "hint": "lean & wiry ↔ bulky & heavy"},
	{"id": "height",    "label": "Height",                 "kind": "float", "tab": "body", "section": "Frame",       "default": 0.5,  "hint": "scaled within your origin's range"},
	{"id": "arcaneMod", "label": "Arcane Modification",   "kind": "float", "tab": "body", "section": "Technomancy", "default": 0.0, "hint": "glowing mana veins → prosthetic aether limb"},
	{"id": "skinTone",  "label": "Skin Tone",              "kind": "color", "tab": "body", "section": "Skin",        "default": 1,    "paletteKey": "skin"},
	# --- HEAD & FACE ---
	{"id": "jaw",       "label": "Jaw Definition",         "kind": "float", "tab": "face", "section": "Structure",   "default": 0.5},
	{"id": "cheek",     "label": "Cheekbone Height",       "kind": "float", "tab": "face", "section": "Structure",   "default": 0.5},
	{"id": "eyeTilt",   "label": "Eye Tilt",               "kind": "float", "tab": "face", "section": "Structure",   "default": 0.5},
	{"id": "eyeShape",  "label": "Eye Shape",              "kind": "float", "tab": "face", "section": "Structure",   "default": 0.5,  "hint": "narrow glare ↔ wide anime"},
	# --- STYLIZED AESTHETICS ---
	{"id": "hair",       "label": "Hair",       "kind": "pick",  "tab": "face", "section": "Hair & Beard",     "default": 0, "options": HAIR_STYLES},
	# AJUSTE FINO post-QA (2026-07-14, feedback directo del director: "no me
	# gusta nada"): default vuelve a Clean (0) — pese a 6+ rondas de ajuste
	# (esferas dispersas → bloque sólido → conicidad → pulido de contorno,
	# ver [[PRD-Fase-C-Ajuste-Facial]] y [[LOG]]) el resultado no convenció
	# al director. El fenotipo humano canónico queda lampiño de nuevo. El
	# slider/estilo Stubble (`_beard_stubble`, `hair_library.gd`) NO se
	# borra — sigue disponible para personalización del jugador, solo deja
	# de ser el default.
	{"id": "beard",      "label": "Beard",      "kind": "pick",  "tab": "face", "section": "Hair & Beard",     "default": 0, "options": BEARD_STYLES},
	# AJUSTE FINO post-QA (2026-07-14, pedido del director): la densidad de
	# la barba (solo aplica al estilo Stubble) queda CONFIGURABLE en vez de
	# fija — 0 = sombra de 3 días apenas insinuada, 1 = barba corta pareja
	# tipo `fenotipo-humano-torso-v1`. Default 0.35: más cerca del extremo
	# ligero (el director la pidió "menos densa").
	{"id": "beardDensity", "label": "Beard Density", "kind": "float", "tab": "face", "section": "Hair & Beard", "default": 0.35, "hint": "sparse 3-day shadow ↔ full trimmed beard"},
	{"id": "hairColor",  "label": "Hair Color", "kind": "color", "tab": "face", "section": "Hair & Beard",     "default": 2, "paletteKey": "hair"},
	{"id": "warpaint",   "label": "Warpaint",   "kind": "pick",  "tab": "face", "section": "Warpaint & Ink",   "default": 0, "options": WARPAINTS},
	{"id": "paintColor", "label": "Paint Color","kind": "color", "tab": "face", "section": "Warpaint & Ink",   "default": 0, "paletteKey": "paint"},
]

static func default_phenotype() -> Dictionary:
	var p: Dictionary = {}
	for f in PHENOTYPE_FIELDS:
		p[f["id"]] = f["default"]
	return p
