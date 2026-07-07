# tmp_dagna_golden.gd — sonda temporal: Dagna montada en la GOLDEN SCENE
# (Art Bible "Melancolía Gráfica") con el pase de 4 capas, para ver el look
# real vs. el greybox. Clave técnica (Lecciones): el toon del rig escribe
# ALPHA → pase transparente → el post lo BORRA; hay que pasar sus materiales
# a toon_golden (OPACO) conservando el outline (la línea de tinta).
# Boot: --autotest=res://tests/tmp_dagna_golden.gd
extends Node

const _GOLDEN     = preload("res://scenes/golden_scene.gd")
const _Characters = preload("res://data/characters.gd")
const _TOON_GOLDEN = preload("res://rendering/toon_golden.gdshader")

func _ready() -> void:
	_run.call_deferred()

func _run() -> void:
	if get_tree().current_scene != null:
		get_tree().current_scene.queue_free()
	await get_tree().process_frame

	var cam := Camera3D.new()
	cam.fov = 55.0
	get_tree().root.add_child(cam)
	cam.make_current()

	var gs = _GOLDEN.new()
	get_tree().root.add_child(gs)
	await get_tree().process_frame
	await get_tree().process_frame
	gs.apply_time_preset("dawn")
	await get_tree().process_frame

	# ---- Dagna en el sendero (trail x = sin(z*0.03)*5) ----
	var z := 0.0
	var x: float = sin(z * 0.03) * 5.0
	var holder := Node3D.new()
	get_tree().root.add_child(holder)
	holder.position = Vector3(x, _GOLDEN.terrain_h(x, z), z)
	var rig = CharacterRig.new()
	holder.add_child(rig)
	_Characters.apply_to_rig(rig, "dagna")
	rig.set_motion(0.0, false)
	await get_tree().process_frame
	# Post-safe: sus materiales toon (ALPHA) → toon_golden (opaco).
	_make_opaque(rig)
	holder.rotation.y = 0.3   # 3/4 hacia la cámara

	# ---- contexto: Dagna en el valle, con el pase completo ----
	cam.look_at_from_position(Vector3(1.4, 1.75, 4.4), holder.position + Vector3(0.0, 0.95, 0.0), Vector3.UP)
	gs.attach_post(cam)
	gs.apply_time_preset("dawn")   # recomputa god-rays con la cámara puesta
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	await Debug.screenshot("res://test_out/dagna_golden_dawn.png")

	# ---- cerca: retrato de medio cuerpo bajo el tratamiento ----
	holder.rotation.y = 0.0
	cam.look_at_from_position(Vector3(0.6, 1.35, 2.5), holder.position + Vector3(0.0, 1.0, 0.0), Vector3.UP)
	gs.apply_time_preset("dawn")
	await get_tree().process_frame
	await get_tree().process_frame
	await Debug.screenshot("res://test_out/dagna_golden_close.png")

	# ---- dusk: la regla nocturna (glowing edges aether) ----
	holder.rotation.y = 0.3
	cam.look_at_from_position(Vector3(1.4, 1.75, 4.4), holder.position + Vector3(0.0, 0.95, 0.0), Vector3.UP)
	gs.apply_time_preset("dusk")
	await get_tree().process_frame
	await get_tree().process_frame
	await Debug.screenshot("res://test_out/dagna_golden_dusk.png")

	print("[TmpDagnaGolden] DONE")
	get_tree().quit(0)

## Recorre el subárbol de Dagna y pasa TODO material toon (que escribe ALPHA)
## a toon_golden (opaco) — conservando el next_pass del outline (línea de
## tinta, ya opaco). Los materiales unshaded (tinta/glow) ya son opacos.
func _make_opaque(node: Node) -> void:
	if node is MeshInstance3D:
		_swap(node as MeshInstance3D)
	for c in node.get_children():
		_make_opaque(c)

func _swap(mi: MeshInstance3D) -> void:
	var m = mi.material_override
	if not (m is ShaderMaterial):
		return
	var sh: Shader = (m as ShaderMaterial).shader
	if sh == null or not sh.resource_path.ends_with("toon.gdshader"):
		return   # ya opaco (toon_golden), o no-toon
	var g := ShaderMaterial.new()
	g.shader = _TOON_GOLDEN
	g.set_shader_parameter("toon_ramp", load("res://rendering/toon_ramp.tres"))
	var alb = m.get_shader_parameter("albedo_color")
	var textured = m.get_shader_parameter("use_texture")
	if textured != null and bool(textured):
		alb = Color("#e0a878")   # toon_golden no muestrea textura: piel aprox
	if alb == null:
		alb = Color.WHITE
	g.set_shader_parameter("albedo_color", alb)
	var uvc = m.get_shader_parameter("use_vertex_color")
	g.set_shader_parameter("use_vertex_color", uvc != null and bool(uvc))
	g.set_shader_parameter("rim_color", Color("#f2e6c8"))
	g.set_shader_parameter("rim_strength", 0.10)
	g.set_shader_parameter("ambient_lift", 0.18)
	g.next_pass = (m as ShaderMaterial).next_pass   # conserva el outline de tinta
	mi.material_override = g
