# tmp_warpaint_gallery.gd — banco de evaluación visual de los 6 estilos de
# warpaint (PRD Warpaint Personalizable, 2026-07-14). Renderiza cada índice
# 1-6 de PhenotypeData.WARPAINTS por separado para juzgar si cada uno tiene
# "buena pinta" y es visualmente distinto de los demás, antes de exponerlos
# como elección real de personalización.
# Boot: --autotest=res://tests/tmp_warpaint_gallery.gd  (windowed)
extends Node

const _GOLDEN = preload("res://scenes/golden_scene.gd")
const _Pheno  = preload("res://data/phenotype_data.gd")

const BASELINE_ORIGIN: Dictionary = {
	"id": "anatomy_baseline",
	"heightRange": [1.0, 1.0],
	"theme": {"accent": "#f2e6c8"},
}

var _rig: CharacterRig
var _holder: Node3D
var _cam: Camera3D
var _gs = null

func _ready() -> void:
	_run.call_deferred()

func _run() -> void:
	if get_tree().current_scene != null:
		get_tree().current_scene.queue_free()
	await get_tree().process_frame

	_cam = Camera3D.new()
	_cam.fov = 55.0
	get_tree().root.add_child(_cam)
	_cam.make_current()

	_gs = _GOLDEN.new()
	get_tree().root.add_child(_gs)
	await get_tree().process_frame
	await get_tree().process_frame
	_gs.apply_time_preset("dawn")
	await get_tree().process_frame

	_holder = Node3D.new()
	get_tree().root.add_child(_holder)
	var x: float = 0.0
	var z: float = 0.0
	_holder.position = Vector3(x, _GOLDEN.terrain_h(x, z), z)
	_rig = CharacterRig.new()
	_holder.add_child(_rig)

	var pheno: Dictionary = _Pheno.default_phenotype()
	pheno["skinTone"] = 0
	pheno["hair"] = 10
	pheno["hairColor"] = 4
	pheno["paintColor"] = 4   # wyld green, constante para comparar formas, no colores

	_rig.apply_phenotype(pheno, BASELINE_ORIGIN)
	_rig.hair_mat.set_shader_parameter("albedo_color", Color("#8a6b48"))
	_rig.iris_mat.albedo_color = Color("#4f3b28")
	var arm_r: Node3D = _rig.arms[1]
	var pauldron = arm_r.find_child("pauldron", false, false)
	if pauldron != null:
		(pauldron as Node3D).visible = false
	_rig.set_motion(0.0, false)

	_gs.attach_post(_cam)
	_gs.apply_time_preset("dawn")
	await _wait(0.2)

	var face_t: Vector3 = _holder.global_position + Vector3(0.0, 1.80, 0.0)
	_cam.look_at_from_position(face_t + Vector3(0.0, 0.02, 0.62), face_t, Vector3.UP)

	for idx in range(1, 7):
		pheno["warpaint"] = idx
		_rig.apply_phenotype(pheno, BASELINE_ORIGIN)
		await _wait(0.2)
		var name: String = _Pheno.WARPAINTS[idx]
		var safe := name.replace(" ", "_").to_lower()
		print("[WarpaintGallery] idx=%d name=%s" % [idx, name])
		await Debug.screenshot("res://test_out/warpaint_%d_%s.png" % [idx, safe])

	print("[WarpaintGallery] DONE")

func _wait(secs: float) -> void:
	var t := 0.0
	while t < secs:
		await get_tree().process_frame
		t += get_process_delta_time()
