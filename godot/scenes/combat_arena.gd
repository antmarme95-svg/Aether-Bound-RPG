# combat_arena.gd — PRD-006 alcance 5: greybox de combate.
#
# Banco de pruebas MÍNIMO y barato (para el gate de FPS) donde se pelea con el
# kit completo contra spawns parametrizables (ver spawn_spec.gd). Es el escenario
# del Gate 1 ("pelear junto a Dagna en greybox ≥60 FPS") y del autotest_combat.
#
# Implementa el contrato de escena que consumen PlayerController / GameDirector:
#   player_spawn, get_height, clamp_position, get_bounds, get_map_info,
#   is_in_grass, update, interactables/triggers (vacíos).
#
# Suelo plano gris + anillo de límite + postes de parallax. Sin follaje, sin
# clima, sin cores: el greybox es blockout, no el slice.
# Loaded via preload (never class_name — ver Lecciones).
extends Node3D

const RADIUS := 40.0        # anillo jugable
const HARD_R := 42.0        # clamp duro

# ---- contrato de escena (mismos nombres que TheWilds) ----
var player_spawn: Dictionary = {}
var interactables: Array = []
var triggers: Array = []
var enemy_spawns: Array = []
var enemy_spawns_b: Array = []

var _origin: Dictionary = {}

func _init(origin: Dictionary = {}) -> void:
	_origin = origin

func _ready() -> void:
	_build_environment()
	_build_ground()
	_build_boundary()
	_build_posts()
	_setup_metadata()

# ================================================================
func _build_environment() -> void:
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#2a2f38")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#8494a8")
	env.ambient_light_energy = 0.45
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.0
	we.environment = env
	add_child(we)

	var sun := DirectionalLight3D.new()
	sun.light_color = Color("#fff2d8")
	sun.light_energy = 1.1
	sun.rotation_degrees = Vector3(-62.0, -48.0, 0.0)
	sun.shadow_enabled = true
	sun.shadow_blur = 1.6
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	fill.light_color = Color("#bcd0e8")
	fill.light_energy = 0.2
	fill.shadow_enabled = false
	add_child(fill)

# ================================================================
func _build_ground() -> void:
	var plane := PlaneMesh.new()
	plane.size = Vector2(HARD_R * 2.4, HARD_R * 2.4)
	var mi := MeshInstance3D.new()
	mi.mesh = plane
	mi.material_override = ToonMaterials.toon_mat(Color("#6b7079"))
	add_child(mi)

# ================================================================
# Anillo de límite (dos toros concéntricos) para leer la frontera jugable.
func _build_boundary() -> void:
	var ring := TorusMesh.new()
	ring.inner_radius = RADIUS - 0.35
	ring.outer_radius = RADIUS + 0.35
	var mi := MeshInstance3D.new()
	mi.mesh = ring
	mi.material_override = ToonMaterials.toon_mat(Color("#3a3f48"))
	mi.position.y = 0.03
	add_child(mi)

# ================================================================
# Postes bajos alrededor del anillo — dan parallax/orientación al moverse.
func _build_posts() -> void:
	var post_mat := ToonMaterials.toon_mat(Color("#565b64"))
	var count := 12
	for i in range(count):
		var a := float(i) / float(count) * TAU
		var post := MeshInstance3D.new()
		var bm := BoxMesh.new()
		bm.size = Vector3(0.5, 2.2, 0.5)
		post.mesh = bm
		post.material_override = post_mat
		post.position = Vector3(cos(a) * (RADIUS - 1.5), 1.1, sin(a) * (RADIUS - 1.5))
		add_child(post)

# ================================================================
func _setup_metadata() -> void:
	player_spawn = {
		"position": Vector3(0.0, 0.0, 12.0),
		"yaw": PI,   # mira hacia -Z (los spawns aparecen enfrente)
	}
	interactables = []
	triggers = []
	enemy_spawns = []
	enemy_spawns_b = []

# ================================================================
# Public API — contrato de escena
# ================================================================
func get_height(_x: float, _z: float) -> float:
	return 0.0

func get_map_info() -> Dictionary:
	return { "shape": "circle", "label": "Greybox Arena", "radius": HARD_R }

func get_bounds() -> Dictionary:
	return {
		"x_min": -HARD_R, "x_max": HARD_R,
		"z_min": -HARD_R, "z_max": HARD_R,
		"y_min": 0.35, "y_max": 999.0,
	}

func is_in_grass(_pos: Vector3) -> bool:
	return false

func clamp_position(pos: Vector3) -> Vector3:
	var r := sqrt(pos.x * pos.x + pos.z * pos.z)
	if r > HARD_R:
		pos.x *= HARD_R / r
		pos.z *= HARD_R / r
	return pos

func update(_dt: float, _player_pos: Vector3) -> void:
	pass
