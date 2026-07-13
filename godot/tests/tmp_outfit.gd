# tmp_outfit.gd — sonda MÍNIMA temporal: verifica el look VESTIDO (outfit
# "Frontier") tras la Migración de Ropa (2026-07-13). Mismo patrón que
# tmp_anatomy.gd (golden scene + rig + apply_phenotype) + una sola línea
# extra: CharacterOutfit.build_frontier(rig). Captura frente/perfil/espalda
# a test_out/outfit_*.png y sale. Boot: tests/tmp_outfit_boot.tscn.
extends Node

const _GOLDEN   = preload("res://scenes/golden_scene.gd")
const _Pheno    = preload("res://data/phenotype_data.gd")
const _Outfit   = preload("res://character/character_outfit.gd")

const BASELINE_ORIGIN: Dictionary = {
	"id": "outfit_baseline",
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
	_holder.position = Vector3(0.0, _GOLDEN.terrain_h(0.0, 0.0), 0.0)
	_rig = CharacterRig.new()
	_holder.add_child(_rig)

	var pheno: Dictionary = _Pheno.default_phenotype()
	pheno["skinTone"] = 0
	pheno["hair"] = 11
	pheno["hairColor"] = 4
	pheno["warpaint"] = 6
	pheno["paintColor"] = 4
	_rig.apply_phenotype(pheno, BASELINE_ORIGIN)
	_rig.hair_mat.set_shader_parameter("albedo_color", Color("#8a6b48"))
	_rig.iris_mat.albedo_color = Color("#4f3b28")
	var arm_r: Node3D = _rig.arms[1]
	(arm_r.get_child(arm_r.get_child_count() - 1) as Node3D).visible = false
	_rig.set_motion(0.0, false)

	# ---- EL PUNTO DE LA SONDA: cuelga el outfit "Frontier" ----
	_Outfit.build_frontier(_rig)

	await _wait(0.25)

	_gs.attach_post(_cam)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)

	_frame_full_front(4.0)
	await _wait(0.15)
	await Debug.screenshot("res://test_out/outfit_full_front.png")

	_holder.rotation.y = PI * 0.5
	await _wait(0.15)
	await Debug.screenshot("res://test_out/outfit_full_side.png")
	_holder.rotation.y = PI
	await _wait(0.15)
	await Debug.screenshot("res://test_out/outfit_full_back.png")

	# DIAGNÓSTICO (bandas 360°): close-up a la cintura AÚN en rotation=PI,
	# antes de resetear — aísla si la faja se ve desde atrás sin ambigüedad
	# de timing de reset.
	var waist_back_t: Vector3 = _holder.global_position + Vector3(0.0, 1.1, 0.0)
	_cam.look_at_from_position(waist_back_t + Vector3(0.35, 0.05, 1.1), waist_back_t, Vector3.UP)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)
	await Debug.screenshot("res://test_out/outfit_waist_back_close.png")

	_holder.rotation.y = 0.0
	await _wait(0.15)

	# Close-up de cintura (faja + cinturón + pouches — el detalle que importa)
	var waist_t: Vector3 = _holder.global_position + Vector3(0.0, 1.1, 0.0)
	_cam.look_at_from_position(waist_t + Vector3(0.35, 0.05, 1.1), waist_t, Vector3.UP)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)
	await Debug.screenshot("res://test_out/outfit_waist_close.png")

	print("[TmpOutfit] DONE")
	if not bool(ProjectSettings.get_setting("beckett/hold_anatomy_bench", false)):
		get_tree().quit(0)

func _wait(secs: float) -> void:
	var t := 0.0
	while t < secs:
		await get_tree().process_frame
		t += get_process_delta_time()

func _frame_full_front(dist: float) -> void:
	var target: Vector3 = _holder.global_position + Vector3(0.0, 0.95, 0.0)
	var eye_h: float = 1.35 + (dist - 4.0) * 0.06
	_cam.look_at_from_position(target + Vector3(0.0, eye_h - 0.95, dist), target, Vector3.UP)
	_gs.apply_time_preset("dawn")
