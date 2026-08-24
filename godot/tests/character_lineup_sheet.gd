# character_lineup_sheet.gd — Pasada 1 del piloto Roen/Darro/Valen: renderiza
# los 4 personajes nombrados de data/characters.gd (dagna, roen, darro, valen)
# CON EL RIG TAL COMO ESTÁ HOY, sin ningún fix de anatomía todavía. Es el
# "antes" de control — confirma si los defectos medidos en Dagna (torso-bola,
# sin cuello, hombreras flotantes) son sistémicos en las 3 razas o propios de
# ella, antes de tocar character_rig.gd.
#
# Generaliza dagna_sheet.gd (que se deja intacto, es historial de esa sonda)
# a una lista de personajes, mismo método de encuadre por AABB real. Corre
# con:
#
#   Godot --path godot res://scenes/character_lineup_sheet.tscn
#
# Los PNG salen en godot/test_out/<id>_sheet_<vista>.png — comparables 1:1
# contra las láminas de 90-Raw/concept/ (roen-v3.png, darro-v1.png,
# valen-v4.png, dagna-v2.png).
extends Node3D

const _Characters = preload("res://data/characters.gd")

## Personajes a renderizar, en orden. Uno por uno (no simultáneos en escena)
## para que el AABB y el encuadre de cada uno sean limpios y no se contaminen
## entre sí.
const CHARACTER_IDS: Array[String] = ["dagna", "roen", "darro", "valen"]

const VIEWS: Array = [
	{"name": "front",   "yaw": 0.0},
	{"name": "profile", "yaw": PI * 0.5},
	{"name": "back",    "yaw": PI},
]

const FRAME_FILL: float = 0.78
const SHEET_SIZE := Vector2i(900, 1200)

var _cam: Camera3D = null


func _ready() -> void:
	get_window().size = SHEET_SIZE
	_build_stage()
	_run.call_deferred()


func _build_stage() -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#f2e4c9")
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
	_cam.fov = 40.0
	add_child(_cam)
	_cam.make_current()


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://test_out"))

	var summary: Array = []

	for id in CHARACTER_IDS:
		var holder := Node3D.new()
		add_child(holder)

		var rig := CharacterRig.new()
		holder.add_child(rig)
		_Characters.apply_to_rig(rig, id)
		if rig.has_method("set_motion"):
			rig.set_motion(0.0, false)

		await get_tree().process_frame
		await get_tree().process_frame

		var aabb := _rig_aabb(rig, holder)
		if aabb.size.y <= 0.0:
			push_error("[CharacterLineup] %s: el rig no produjo geometría medible" % id)
			holder.queue_free()
			continue

		var center := aabb.get_center()
		var height := aabb.size.y
		var ratio := aabb.size.x / height
		print("[CharacterLineup] %-6s altura=%.3f m  ancho=%.3f m  ratio=%.2f"
			% [id, height, aabb.size.x, ratio])
		summary.append("%s: h=%.3f w=%.3f ratio=%.2f" % [id, height, aabb.size.x, ratio])

		var half_fov := deg_to_rad(_cam.fov) * 0.5
		var dist := (height * 0.5 / FRAME_FILL) / tan(half_fov)

		for v in VIEWS:
			holder.rotation.y = float(v["yaw"])
			_place_camera(center, dist)
			await _settle()
			await _shoot("res://test_out/%s_sheet_%s.png" % [id, String(v["name"])])

		holder.queue_free()
		await get_tree().process_frame

	print("[CharacterLineup] DONE — %d personajes" % CHARACTER_IDS.size())
	for line in summary:
		print("  " + line)
	get_tree().quit(0)


func _place_camera(target: Vector3, dist: float) -> void:
	_cam.global_position = target + Vector3(0.0, 0.0, dist)
	_cam.look_at(target)


func _settle() -> void:
	for _i in range(6):
		await get_tree().process_frame


func _shoot(path: String) -> void:
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.save_png(ProjectSettings.globalize_path(path))
	print("[CharacterLineup] %s" % path)


## Nodos de VFX de arquetipo que NO son cuerpo y deben quedar fuera del AABB.
## Sin esto, el anillo de sigilo en el piso y el orbe flotante del Strategist
## inflan la caja: en la primera corrida Roen dio 3.10 m y Valen 3.34 m contra
## los ~1.44 m de Dagna, y la cámara se alejaba tanto que el personaje salía
## diminuto. Son efectos, no anatomía — no deben influir en el encuadre.
## Lista completa tomada de los `.name =` de character_rig.gd, no adivinada:
## el `chrono_dome` del Strategist aetherborn es una esfera de 0.88 m de radio
## (1.76 m de diámetro) y por sí solo explicaba los 1.92 m de ancho que dio
## Valen en la segunda corrida.
const VFX_NODES: Array[String] = [
	"focus_orb", "aegis_shield", "pack_wisp", "stealth_ring",
	"chrono_dome", "chrono_ring", "thermite_embers", "thermite_ring",
	"siphon_ring", "drain_ring", "shaman_aura", "iron_sparks",
]


func _is_vfx(node: Node) -> bool:
	var n: Node = node
	while n != null:
		var nm := String(n.name)
		if nm in VFX_NODES or nm.begins_with("steam_jet_"):
			return true
		n = n.get_parent()
	return false


## AABB en espacio de `root` (el holder), no del rig — así cada personaje
## se mide en su propio marco local aunque holders sucesivos se reutilicen
## en la misma posición de escena.
func _rig_aabb(rig: Node3D, root: Node3D) -> AABB:
	var out := AABB()
	var first := true
	for m in _all_meshes(rig):
		var mi: MeshInstance3D = m
		if not mi.visible or mi.mesh == null:
			continue
		if _is_vfx(mi):
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
