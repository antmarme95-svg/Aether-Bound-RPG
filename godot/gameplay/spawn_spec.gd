# spawn_spec.gd — PRD-006 alcance 5: parser de la spec parametrizable de
# spawns del greybox. Convierte un string de --spawn en una lista plana de
# kinds a instanciar frente al jugador.
#
# Gramática (tolerante):
#   - Tokens separados por ',' o '+'.
#   - Cada token: cuenta entera opcional + kind. Ej: "2light", "heavy", "3beast".
#   - Kinds válidos: light, heavy (humanoides con receive_strike), beast.
#   - Alias "duelpair" = [light, heavy] (compat con el boot del alcance 3).
#   - Vacío / inválido → default [light, heavy].
#
# Lógica pura (RefCounted, headless-safe). Loaded via preload (never class_name —
# ver Lecciones).
extends RefCounted

const VALID_KINDS := ["light", "heavy", "beast"]
const DEFAULT_SPEC := ["light", "heavy"]

## parse — devuelve Array[String] de kinds. Nunca vacío (cae al default).
static func parse(spec: String) -> Array:
	var s := spec.strip_edges().to_lower()
	if s == "" or s == "duelpair":
		return DEFAULT_SPEC.duplicate()

	var out: Array = []
	var tokens := s.replace("+", ",").split(",", false)
	for tok_raw in tokens:
		var tok := String(tok_raw).strip_edges()
		if tok == "":
			continue
		# Prefijo numérico opcional (la cuenta del token).
		var digits := ""
		var idx := 0
		while idx < tok.length() and tok[idx] >= "0" and tok[idx] <= "9":
			digits += tok[idx]
			idx += 1
		var count := int(digits) if digits != "" else 1
		var kind := tok.substr(idx) if digits != "" else tok
		if not VALID_KINDS.has(kind):
			continue
		for _i in range(maxi(count, 0)):
			out.append(kind)

	if out.is_empty():
		return DEFAULT_SPEC.duplicate()
	return out
