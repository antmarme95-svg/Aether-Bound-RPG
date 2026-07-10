# combat_arena.gd — PRD-006 alcance 5: greybox de combate.
#
# Banco de pruebas MÍNIMO y barato (para el gate de FPS) donde se pelea con el
# kit completo contra spawns parametrizables (ver spawn_spec.gd). Es el escenario
# del Gate 1 ("pelear junto a Dagna en greybox ≥60 FPS") y del autotest_combat.
#
# PRD-007 alcance 4 (Gate 1): añade UNA cornisa/meseta elevada como OBJETIVO de
# traversal — solo alcanzable con el Seismic Springboard (el salto normal ~0.8 m
# no llega a LEDGE_H 3.5 m; el lanzamiento ~6 m sí). El cliff es un MURO real: no
# se puede trepar a pie (ver is_cliff_wall + el step-block del PlayerController).
#
# Implementa el contrato de escena que consumen PlayerController / GameDirector:
#   player_spawn, get_height, clamp_position, get_bounds, get_map_info,
#   is_in_grass, update, interactables/triggers (vacíos).
#
# Suelo plano gris + anillo de límite + postes de parallax + meseta del Gate 1.
# Sin follaje, sin clima, sin cores: el greybox es blockout, no el slice.
# Loaded via preload (never class_name — ver Lecciones).
extends Node3D

const RADIUS := 40.0        # anillo jugable
const HARD_R := 42.0        # clamp duro

# ---- PRD-007 alcance 4: la cornisa (meseta elevada) ----
# Footprint rectangular (blockout). El jugador solo la alcanza vía Springboard:
# LEDGE_H (3.5) >> salto normal (~0.8 m), < pico del lanzamiento (~6 m). Puesta
# DELANTE del jugador (spawn z=12, mira -Z) y separada del arco de spawn (z=4).
const LEDGE_H     := 3.5       # altura de la meseta (la Y "imposible")
const LEDGE_MIN_X := -5.0
const LEDGE_MAX_X :=  5.0
const LEDGE_MIN_Z := -8.0
const LEDGE_MAX_Z :=  2.0      # borde CERCANO (mirando -Z desde el spawn)
# Solo entras a la meseta con los pies casi a la altura de la tapa (i.e., cayendo
# desde arriba). Ajustado: antes 0.5 dejaba "trepar raspando" la cara del cliff
# subiendo, y el aterrizaje cortaba el salto al llegar al labio. Ahora es un muro
# firme + el aterrizaje solo atrapa descendiendo (ver player_controller).
const LEDGE_STEP_MAX := 0.15

# Faro/objetivo sobre la meseta (feedback de "llegaste").
const LEDGE_BEACON := Vector3(0.0, LEDGE_H, -2.0)
var _ledge_announced: bool = false

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
	_build_ledge()
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
# PRD-007 alcance 4: la cornisa. Un bloque macizo (cara de cliff visible) con la
# cara superior a LEDGE_H, y un faro emisivo sobre la meseta = el OBJETIVO. El
# bloque es puramente visual: la colisión vive en get_height/is_cliff_wall.
func _build_ledge() -> void:
	var cx: float = (LEDGE_MIN_X + LEDGE_MAX_X) * 0.5
	var cz: float = (LEDGE_MIN_Z + LEDGE_MAX_Z) * 0.5
	var sx: float = LEDGE_MAX_X - LEDGE_MIN_X
	var sz: float = LEDGE_MAX_Z - LEDGE_MIN_Z

	var block := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(sx, LEDGE_H, sz)
	block.mesh = bm
	block.material_override = ToonMaterials.toon_mat(Color("#5a616b"))
	block.position = Vector3(cx, LEDGE_H * 0.5, cz)   # base en y=0, tapa en LEDGE_H
	add_child(block)

	# Borde superior resaltado (lee dónde termina la cara y empieza la tapa).
	var lip := MeshInstance3D.new()
	var lm := BoxMesh.new()
	lm.size = Vector3(sx + 0.2, 0.12, sz + 0.2)
	lip.mesh = lm
	lip.material_override = ToonMaterials.toon_mat(Color("#767d88"))
	lip.position = Vector3(cx, LEDGE_H, cz)
	add_child(lip)

	# Faro/objetivo: pilar emisivo teal (misma familia cromática que el Springboard).
	# Energía moderada para que lea TEAL (no un blanco sobreexpuesto bajo el ACES) y
	# delgado para no tapar la meseta.
	var beacon := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius    = 0.16
	cyl.bottom_radius = 0.16
	cyl.height        = 1.8
	beacon.mesh = cyl
	beacon.material_override = ToonMaterials.glow_mat(Color("#4fd8c4"), 1.2)
	beacon.position = LEDGE_BEACON + Vector3(0.0, 0.9, 0.0)
	add_child(beacon)

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
func get_height(x: float, z: float) -> float:
	# PRD-007 alcance 4: dentro del footprint de la meseta, el suelo está a LEDGE_H.
	if _in_ledge_footprint(x, z):
		return LEDGE_H
	return 0.0

func _in_ledge_footprint(x: float, z: float) -> bool:
	return x >= LEDGE_MIN_X and x <= LEDGE_MAX_X and z >= LEDGE_MIN_Z and z <= LEDGE_MAX_Z

# is_cliff_wall — PRD-007 alcance 4: ¿la celda (x,z) es un MURO para quien viene
# de `from_y`? Lo es si es la meseta y subir hasta su tapa excede el step máximo
# (i.e., no llegaste desde arriba). El PlayerController revierte el paso horizontal
# cuando esto da true → el cliff no se trepa a pie; solo se aterriza desde el
# Springboard. Landing desde arriba: from_y ≈ tapa → no es muro → aterrizas.
func is_cliff_wall(from_y: float, x: float, z: float) -> bool:
	if not _in_ledge_footprint(x, z):
		return false
	return LEDGE_H > from_y + LEDGE_STEP_MAX

# is_on_ledge — el jugador está PARADO sobre la meseta (footprint + a la altura de
# la tapa). Base del "cornisa alcanzada" (toast + criterio del autotest).
func is_on_ledge(pos: Vector3) -> bool:
	return _in_ledge_footprint(pos.x, pos.z) and pos.y >= LEDGE_H - 0.3

# Punto de lanzamiento del gate: suelo firme con PISTA frente al borde cercano
# (no pegado al muro), para que el arco del Springboard cruce el labio por encima
# —descendiendo desde el ápice— en vez de raspar la cara del cliff. Nace la onda
# aquí y arranca el lanzamiento hacia la meseta.
func ledge_launch_point() -> Vector3:
	return Vector3(0.0, 0.0, LEDGE_MAX_Z + 4.0)

# Punto de la meseta al que apuntar la onda dirigida (empuje del arco).
func ledge_aim_point() -> Vector3:
	return LEDGE_BEACON

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

func update(_dt: float, player_pos: Vector3) -> void:
	# PRD-007 alcance 4: feedback de "cornisa alcanzada" (una vez).
	if not _ledge_announced and is_on_ledge(player_pos):
		_ledge_announced = true
		EventBus.emit_event("quest:toast", {"text": "¡Cornisa alcanzada!"})
