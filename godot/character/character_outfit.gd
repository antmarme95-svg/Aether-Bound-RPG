# character_outfit.gd — OUTFIT "Frontier": faja envuelta + cinturón diagonal
# + cinturón horizontal + pouches. Migra jerkin/strap/belt/buckle_glow que
# antes vivían FOSILIZADOS dentro de CharacterRig._build() (Fase Migración
# de Ropa, debate orquestador↔QA 2026-07-13, GO del director) — el cuerpo
# base ya tiene anatomía completa (pecs/abdomen/clavícula, Benchmark-
# Musculatura-Torso.md) y la ropa se vuelve OUTFIT modular, aditivo,
# desmontable (el banco de anatomía queda desnudo a propósito).
#
# Referencias (Aether Bound/90-Raw/concept/):
#   fenotipo-humano-v1.png       — FAJA envuelta de varias vueltas +
#                                   cinturón diagonal + pouches (canon).
#   fenotipo-humano-torso-v1.png — "Complex tan leather belt" con pouches,
#                                   detalle directo del cinturón.
#
# Mismo patrón que character_signature.gd: RefCounted estático, piezas
# aditivas colgadas de nodos YA construidos del rig (spine/upper_spine/
# hips), materiales toon REUSADOS del rig (cero materiales nuevos). Grupos
# nombrados "outfit_*" y limpiados con el mismo criterio idempotente que
# _fresh_group de character_signature.gd — build_frontier() se puede
# re-llamar en cada apply_phenotype/apply_archetype sin acumular basura.
#
# Loaded via preload (NUNCA class_name cruzado — ver Lecciones.md).
#
# CONFIGURABLE POR PIEZAS (decisión del director 2026-07-13: la faja y la
# bandolera NO van hardcodeadas al personaje): cada pieza del catálogo
# _PIECES es montable/desmontable por separado, un outfit es una LISTA de
# ids de pieza, y los presets nombrados (PRESETS) son solo listas
# predefinidas. El outfit de cada personaje/spawn se declara como config
# (patrón characters.gd); la UI de personalización del jugador (pestaña
# OUTFIT en creación) llega en Fase 4 — esta API ya la soporta.
extends RefCounted

const _Rig := preload("res://character/character_rig.gd")

# Catálogo: id de pieza → [nodo padre (nombre de propiedad del rig),
# nombre del grupo]. Añadir una pieza nueva = entrada aquí + su _attach_*
# + su rama en el match de build().
const _PIECES: Dictionary = {
	"waist_wrap":    ["spine",       "outfit_waist_wrap"],
	"diagonal_belt": ["upper_spine", "outfit_diagonal_belt"],
	"hip_belt":      ["hips",        "outfit_hip_belt"],
}

# Presets nombrados: solo listas de piezas. "frontier" = el conjunto de la
# lámina fenotipo-humano-v1.
const PRESETS: Dictionary = {
	"frontier": ["waist_wrap", "diagonal_belt", "hip_belt"],
}

# ---- mini helpers (mismo estilo que character_signature.gd) ----

static func _fresh_group(parent: Node3D, group_name: String) -> Node3D:
	var old := parent.get_node_or_null(NodePath(group_name))
	if old != null:
		parent.remove_child(old)
		old.queue_free()
	var g := Node3D.new()
	g.name = group_name
	parent.add_child(g)
	return g

static func _box(mat: Material, w: float, h: float, d: float,
		pos: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = Vector3(w, h, d)
	mi.mesh = m
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	return mi

static func _cyl(mat: Material, top_r: float, bot_r: float, h: float,
		pos: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var m := CylinderMesh.new()
	m.top_radius = top_r
	m.bottom_radius = bot_r
	m.height = h
	mi.mesh = m
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	return mi

# ================================================================
# API pública
# ================================================================

## Monta una LISTA de piezas del catálogo sobre un CharacterRig ya montado
## y con apply_phenotype/apply_archetype aplicados (cada pieza lee
## torso.scale/pelvis.scale para seguir el build actual). Idempotente por
## pieza (re-llamar reconstruye sin acumular basura). Ids desconocidos se
## reportan y se saltan (config tolerante, mismo espíritu que spawn_spec).
static func build(rig, pieces: Array) -> void:
	for id in pieces:
		var pid := String(id)
		match pid:
			"waist_wrap":
				_attach_waist_wrap(rig)
			"diagonal_belt":
				_attach_diagonal_belt(rig)
			"hip_belt":
				_attach_hip_belt(rig)
			_:
				push_warning("[CharacterOutfit] pieza desconocida: " + pid)

## Monta un preset nombrado (lista predefinida de piezas).
static func build_preset(rig, preset: String = "frontier") -> void:
	build(rig, PRESETS.get(preset, []))

## Desmonta UNA pieza en caliente (personalización).
static func remove_piece(rig, piece: String) -> void:
	if not _PIECES.has(piece):
		return
	var parent: Node3D = rig.get(String(_PIECES[piece][0]))
	var old := parent.get_node_or_null(NodePath(String(_PIECES[piece][1])))
	if old != null:
		parent.remove_child(old)
		old.queue_free()

## Desmonta TODO el outfit (deja el cuerpo base desnudo).
static func remove_all(rig) -> void:
	for piece in _PIECES:
		remove_piece(rig, piece)

# -- back-compat: los call sites existentes (game_director/enemy_humanoid/
# city_exit/recruitment_office) llaman build_frontier; son ahora aliases
# del preset. El default del jugador podrá venir de config cuando exista
# la pestaña OUTFIT (Fase 4).
static func build_frontier(rig) -> void:
	build_preset(rig, "frontier")

static func remove_frontier(rig) -> void:
	remove_all(rig)

# ================================================================
# 1. FAJA ENVUELTA — 3 cilindros aplastados apilados en la cintura, colgada
# de `spine` (mismo frame donde vivía el jerkin fosilizado, spine y=0.16) —
# lectura de "varias vueltas de tela" con leve rotación alternada en X, sin
# fabricar geometría de tela real (regla dura: la tinta es geometría, NUNCA
# textura de "líneas de fibra/tela" — Benchmark-Musculatura-Torso.md).
#
# Radio: el abdomen nuevo (placa elipsoide de Fase C, upper_spine y=0.02)
# protruye hasta z≈0.127 en build neutro (w=0.5) — la faja debe quedar
# CLARA de esa masa, nunca tangente (lección del anillo: "toda masa nueva
# re-verifica los anillos que la rodean"). Bandas con top_r/bot_r base
# 0.137-0.162, ~10-25% de margen real sobre 0.127 en build neutro.
#
# El escalado sigue el build ACTUAL del rig (peso/clase) igual que hacía
# jerkin.scale en _apply_build: se reconstruye la fórmula original
# (lerp(0.86,1.36,w)*arch_xz*WAIST_XZ) LEYENDO torso.scale/pelvis.scale ya
# aplicados en vez de w/arch_xz privados (torso.scale.x/CHEST_X y
# pelvis.scale.x ya cargan cada uno lerp*arch_xz por separado; promediarlos
# reconstruye el rango de jerkin sin duplicar estado privado del rig).
# ================================================================
static func _attach_waist_wrap(rig) -> void:
	var g := _fresh_group(rig.spine, "outfit_waist_wrap")

	# _Rig por const preload — el header prometía "nunca class_name cruzado"
	# pero la v1 usaba el global CharacterRig (la lección exacta); pagado.
	var torso_w: float = rig.torso.scale.x / _Rig.CHEST_X
	var pelvis_w: float = rig.pelvis.scale.x
	var w_scale: float = (torso_w + pelvis_w) * 0.5 * _Rig.WAIST_XZ

	# [y (spine-local), top_r, bot_r, height, tilt_x (rad)]
	var bands: Array = [
		[0.095, 0.150, 0.162, 0.060,  0.055],
		[0.150, 0.144, 0.153, 0.060, -0.060],
		[0.205, 0.137, 0.146, 0.060,  0.045],
	]
	for b in bands:
		var band := _cyl(rig.leather_mat,
			float(b[1]) * w_scale, float(b[2]) * w_scale, b[3],
			Vector3(0.0, b[0], 0.0), Vector3(b[4], 0.0, 0.0))
		band.name = "outfit_waist_band"
		g.add_child(band)

# ================================================================
# 2. CINTURÓN DIAGONAL — el strap fosilizado (box en upper_spine) migra
# casi tal cual + hebilla chica donde cruza el pecho (lámina: cinturón
# cruzado con hebilla metálica visible sobre el cuero oscuro).
# ================================================================
static func _attach_diagonal_belt(rig) -> void:
	var g := _fresh_group(rig.upper_spine, "outfit_diagonal_belt")

	var strap := _box(rig.dark_leather_mat, 0.07, 0.46, 0.02,
		Vector3(0.02, 0.10, 0.165), Vector3(0.0, 0.0, 0.62))
	strap.name = "outfit_diagonal_strap"
	g.add_child(strap)

	var buckle := _box(rig.metal_mat, 0.045, 0.055, 0.014,
		Vector3(0.02, 0.10, 0.180))
	buckle.name = "outfit_diagonal_buckle"
	g.add_child(buckle)

# ================================================================
# 3. CINTURÓN HORIZONTAL + POUCHES — belt/buckle_glow migran casi tal cual
# desde `hips` (mismo lugar donde vivían fosilizados) + 2 pouches colgando
# (lámina: bolsa frontal grande + bolsa lateral chica, asimétricas).
# ================================================================
static func _attach_hip_belt(rig) -> void:
	var g := _fresh_group(rig.hips, "outfit_hip_belt")
	var hw: float = 0.135 * rig.pelvis.scale.x   # half-width real de la pelvis

	var belt := _box(rig.leather_mat, 0.31, 0.05, 0.2, Vector3(0.0, 0.05, 0.0))
	belt.name = "outfit_belt"
	g.add_child(belt)

	var buckle := _box(rig.accent_glow_mat, 0.06, 0.04, 0.02, Vector3(0.05, 0.05, 0.105))
	buckle.name = "outfit_buckle_glow"
	g.add_child(buckle)  # glow, sin outline — mismo criterio que el original

	# Pouch frontal grande, lado izquierdo (lámina).
	var pouch_a := _box(rig.leather_mat, 0.075, 0.09, 0.05,
		Vector3(-hw * 0.85, -0.02, 0.10), Vector3(0.0, 0.1, 0.0))
	pouch_a.name = "outfit_pouch_a"
	g.add_child(pouch_a)
	var flap_a := _box(rig.dark_leather_mat, 0.08, 0.03, 0.055,
		Vector3(-hw * 0.85, 0.025, 0.10), Vector3(0.0, 0.1, 0.0))
	flap_a.name = "outfit_pouch_a_flap"
	g.add_child(flap_a)

	# Pouch lateral chica, lado derecho (más discreta — lee de perfil).
	var pouch_b := _box(rig.dark_leather_mat, 0.06, 0.075, 0.045,
		Vector3(hw * 0.9, -0.015, 0.04), Vector3(0.0, -0.45, 0.0))
	pouch_b.name = "outfit_pouch_b"
	g.add_child(pouch_b)
