# dagna_sheet.gd — lámina de contraste: Dagna montada desde su config de datos
# (data/characters.gd → CharacterRig procedural) y capturada en las MISMAS
# tres vistas que la lámina canónica, sobre el mismo fondo de papel cálido:
#
#   Aether Bound/90-Raw/concept/dagna-v2.png  (frente / perfil / espalda, 4.5 cabezas)
#
# Es una sonda de comparación, no una escena de juego: no depende del
# GameDirector ni de ningún autoload — instancia el rig, lo encuadra por su
# AABB real y escribe los PNG. Correr con:
#
#   Godot --path godot res://scenes/dagna_sheet.tscn
#
# Los PNG salen en godot/test_out/dagna_sheet_*.png
extends Node3D

const _Characters = preload("res://data/characters.gd")

## Vistas de la lámina: nombre de archivo → giro del MODELO en radianes.
## La cámara nunca se mueve entre vistas (encuadre fijo, nivelado) — rota el
## modelo, igual que la sonda original: así las tres vistas son comparables
## entre sí pixel a pixel, que es lo que se mide contra la lámina.
const VIEWS: Array = [
	{"name": "front",   "yaw": 0.0},
	{"name": "profile", "yaw": PI * 0.5},
	{"name": "back",    "yaw": PI},
	{"name": "detail",  "yaw": -0.5},   # 3/4 cercano: cuña de la trenza + tatuajes
]

var _rig: Node3D = null
var _holder: Node3D = null
var _cam: Camera3D = null


## Alto de la figura como fracción del alto del cuadro. La lámina deja aire
## arriba y abajo; 0.78 iguala ese encuadre, que es lo que hace comparables
## las proporciones medidas a ojo entre render y lámina.
const FRAME_FILL: float = 0.78
const SHEET_SIZE := Vector2i(900, 1200)   # retrato, como la lámina


func _ready() -> void:
	get_window().size = SHEET_SIZE
	_build_stage()
	_run.call_deferred()


## Escenario neutro de lámina: fondo de papel cálido plano, una direccional
## de tres cuartos y relleno ambiental alto — sin cielo procedural ni niebla,
## para que lo único que se juzgue sea la silueta y el color del personaje.
func _build_stage() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#f2e4c9")   # papel cálido de la lámina
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#fff2d8")
	env.ambient_light_energy = 0.85
	var we := WorldEnvironment.new()
	we.environment = env
	add_child(we)

	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-38.0, -35.0, 0.0)
	key.light_energy = 1.15
	key.light_color = Color("#fff4e0")
	add_child(key)

	var fill := DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20.0, 145.0, 0.0)
	fill.light_energy = 0.35
	fill.light_color = Color("#d8e2f0")
	add_child(fill)

	_cam = Camera3D.new()
	_cam.fov = 40.0        # tele suave: menos deformación de proporción que 55
	add_child(_cam)
	_cam.make_current()


func _run() -> void:
	_holder = Node3D.new()
	add_child(_holder)

	_rig = CharacterRig.new()
	_holder.add_child(_rig)
	_Characters.apply_to_rig(_rig, "dagna")
	if _rig.has_method("set_motion"):
		_rig.set_motion(0.0, false)

	# Dos frames para que el rig termine de construirse y de aplicar pose
	# antes de medirlo — medir en el frame 0 da un AABB de rig a medio armar.
	await get_tree().process_frame
	await get_tree().process_frame

	var aabb := _rig_aabb(_rig)
	if aabb.size.y <= 0.0:
		push_error("[DagnaSheet] el rig no produjo geometría medible")
		get_tree().quit(1)
		return

	var center := aabb.get_center()
	var height := aabb.size.y
	print("[DagnaSheet] altura del rig = %.3f m  ancho = %.3f m  (ratio ancho/alto = %.2f)"
		% [height, aabb.size.x, aabb.size.x / height])

	# Encuadre fijo: cuerpo entero con aire arriba y abajo, cámara a media
	# altura y NIVELADA — sin picada, para no falsear la proporción enana.
	# La distancia se DERIVA del fov y del alto real: encuadrar "a ojo" con
	# un múltiplo fijo del alto cambia el llenado del cuadro cada vez que se
	# toca la proporción del rig, y entonces las láminas dejan de compararse.
	var half_fov := deg_to_rad(_cam.fov) * 0.5
	var dist := (height * 0.5 / FRAME_FILL) / tan(half_fov)
	_place_camera(center, dist)

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test_out"))

	for v in VIEWS:
		_holder.rotation.y = float(v["yaw"])
		if String(v["name"]) == "detail":
			_place_camera(Vector3(center.x, aabb.position.y + height * 0.86, center.z),
				(height * 0.22 / FRAME_FILL) / tan(half_fov))
		else:
			_place_camera(center, dist)
		await _settle()
		await _shoot("res://test_out/dagna_sheet_%s.png" % v["name"])

	print("[DagnaSheet] DONE")
	get_tree().quit(0)


func _place_camera(target: Vector3, dist: float) -> void:
	_cam.global_position = target + Vector3(0.0, 0.0, dist)
	_cam.look_at(target)


## El rig anima en `_process` (pose en 2s, body pop): unos frames de asiento
## evitan capturar un intermedio del pop y dan tiempo al swap de materiales.
func _settle() -> void:
	for _i in range(6):
		await get_tree().process_frame


func _shoot(path: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(path))
	print("[DagnaSheet] %s" % path)


## AABB en espacio del rig, uniendo la de cada MeshInstance3D visible.
## Se hace a mano porque el rig es un árbol de nodos procedural sin un
## VisualInstance raíz que ya la agregue.
func _rig_aabb(root: Node3D) -> AABB:
	var out := AABB()
	var first := true
	for m in _all_meshes(root):
		var mi: MeshInstance3D = m
		if not mi.visible or mi.mesh == null:
			continue
		var local: AABB = mi.get_aabb()
		var xform: Transform3D = root.global_transform.affine_inverse() * mi.global_transform
		var world: AABB = xform * local
		if first:
			out = world
			first = false
		else:
			out = out.merge(world)
	return out


func _all_meshes(node: Node) -> Array:
	var acc: Array = []
	if node is MeshInstance3D:
		acc.append(node)
	for c in node.get_children():
		acc.append_array(_all_meshes(c))
	return acc
