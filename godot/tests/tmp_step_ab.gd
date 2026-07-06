## tmp_step_ab.gd — A/B visual temporal: sprint con stack completo (controller+rig),
## captura CADA frame (16 consecutivos) con stepping ON y OFF → 2 tiras en un PNG.
## Correr (windowed): --path godot -- --autotest=res://tests/tmp_step_ab.gd
extends Node

const _PC = preload("res://gameplay/player_controller.gd")
const DT := 1.0 / 60.0
const KW := 87
const KSHIFT := 4194325

var _stage: Node3D = null
var _cam: Camera3D = null
var _dummy_cam: Camera3D = null
var _strips: Array = []

func _ready() -> void:
	await get_tree().process_frame
	if get_tree().current_scene != null:
		get_tree().current_scene.queue_free()
	await get_tree().process_frame
	_build_stage()
	await get_tree().process_frame

	for mode in [true, false]:
		await _run_sprint(mode)

	await _save_combined()
	print("[step_ab] DONE")
	get_tree().quit(0)

func _build_stage() -> void:
	_stage = Node3D.new()
	get_tree().root.add_child(_stage)
	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#0c1622")
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.15
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#bfe8ff")
	env.ambient_light_energy = 0.35
	we.environment = env
	_stage.add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45.0, 30.0, 0.0)
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	_stage.add_child(sun)
	_cam = Camera3D.new()
	_cam.current = true
	_cam.fov = 60.0
	_stage.add_child(_cam)
	_dummy_cam = Camera3D.new()
	_dummy_cam.current = false
	_stage.add_child(_dummy_cam)

func _run_sprint(on_twos: bool) -> void:
	var save := SaveState.new()
	save.origin_id = "miststalker"
	save.class_id = "thief"
	save.player_name = "AB"
	var stats := Stats.new(save)
	var passives := Passives.new(save, stats)
	var rig := CharacterRig.new()
	_stage.add_child(rig)
	rig.apply_phenotype(PhenotypeData.default_phenotype(), OriginsData.get_origin("miststalker"))
	rig.apply_archetype("thief")
	rig.animation_on_twos = on_twos

	var controller = _PC.new()
	_stage.add_child(controller)
	controller.setup(rig, stats, passives, save, _dummy_cam)
	var stub := _make_scene_stub()
	controller.scene = stub
	controller.enemies = []
	controller._enabled = true
	controller.position = Vector3.ZERO
	controller.cam_yaw = 0.0
	controller.facing = 0.0

	var keys := { KW: true, KSHIFT: true }
	for _i in range(20):   # warmup a velocidad de sprint
		controller._keys_down = keys.duplicate()
		controller.update(DT)
		await get_tree().process_frame

	var frames: Array = []
	for _i in range(16):   # 16 frames CONSECUTIVOS (≈0.27 s)
		controller._keys_down = keys.duplicate()
		controller.update(DT)
		var p: Vector3 = controller.position
		_cam.position = Vector3(p.x + 2.4, 0.95, p.z + 0.3)
		_cam.look_at(Vector3(p.x, 0.80, p.z), Vector3.UP)
		await RenderingServer.frame_post_draw
		frames.append(get_viewport().get_texture().get_image())

	_save_strip(frames, "EN_2s" if on_twos else "suave_60")
	controller.queue_free()
	rig.queue_free()
	stub.queue_free()
	await get_tree().process_frame

func _make_scene_stub() -> Node3D:
	var stub := Node3D.new()
	var ground := MeshInstance3D.new()
	var gm := PlaneMesh.new()
	gm.size = Vector2(80.0, 80.0)
	ground.mesh = gm
	ground.material_override = ToonMaterials.toon_mat(Color("#1a2a1a"))
	stub.add_child(ground)
	_stage.add_child(stub)
	var sc := GDScript.new()
	sc.source_code = """
extends Node3D
func get_height(_x: float, _z: float) -> float:
	return 0.0
func clamp_position(pos: Vector3) -> Vector3:
	return pos
func is_in_grass(_pos: Vector3) -> bool:
	return false
"""
	sc.reload()
	stub.set_script(sc)
	return stub

func _save_strip(frames: Array, label: String) -> void:
	var first: Image = frames[0] as Image
	var fw: int = first.get_width()
	var fh: int = first.get_height()
	var crop_w: int = int(min(float(fw), float(fh) * 0.62))
	var cx0: int = int((fw - crop_w) / 2.0)
	const TILE_H := 320
	var scale: float = float(TILE_H) / float(fh)
	var tile_w: int = int(float(crop_w) * scale)
	const SEP := 4
	var total_w: int = frames.size() * (tile_w + SEP) - SEP
	var out := Image.create(total_w, TILE_H, false, Image.FORMAT_RGBA8)
	out.fill(Color(0.08, 0.08, 0.10, 1.0))
	for i in range(frames.size()):
		var img: Image = frames[i] as Image
		var c: Image = img.get_region(Rect2i(cx0, 0, crop_w, fh))
		c.resize(tile_w, TILE_H, Image.INTERPOLATE_BILINEAR)
		c.convert(Image.FORMAT_RGBA8)
		out.blit_rect(c, Rect2i(0, 0, tile_w, TILE_H), Vector2i(i * (tile_w + SEP), 0))
	_strips.append({ "name": label, "img": out })

func _save_combined() -> void:
	const ROW_H := 320
	const LABEL_W := 220
	const SEP := 8
	var max_w: int = 0
	for s in _strips:
		max_w = max(max_w, (s["img"] as Image).get_width())
	var total_w: int = LABEL_W + max_w + SEP * 2
	var total_h: int = _strips.size() * (ROW_H + SEP) + SEP
	var sv := SubViewport.new()
	sv.size = Vector2i(total_w, total_h)
	sv.transparent_bg = false
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(sv)
	var bg := ColorRect.new()
	bg.color = Color(0.06, 0.06, 0.08, 1.0)
	bg.size = Vector2(total_w, total_h)
	sv.add_child(bg)
	var y: int = SEP
	for s in _strips:
		var lbl := Label.new()
		lbl.text = str(s["name"])
		lbl.add_theme_font_size_override("font_size", 28)
		lbl.add_theme_color_override("font_color", Color(0.85, 0.95, 1.0))
		lbl.position = Vector2(14, y + int(ROW_H * 0.5) - 18)
		sv.add_child(lbl)
		var tr := TextureRect.new()
		tr.texture = ImageTexture.create_from_image(s["img"] as Image)
		tr.position = Vector2(LABEL_W, y)
		sv.add_child(tr)
		y += ROW_H + SEP
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var combined: Image = sv.get_texture().get_image()
	var abs_path := ProjectSettings.globalize_path("res://test_out/step_AB_sprint.png")
	DirAccess.make_dir_recursive_absolute(abs_path.get_base_dir())
	var err: int = combined.save_png(abs_path)
	print("[step_ab] wrote step_AB_sprint.png err=%d" % err)
	sv.queue_free()
