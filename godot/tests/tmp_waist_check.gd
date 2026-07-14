# tmp_waist_check.gd — banco de diagnostico ENFOCADO en la cintura del
# cuerpo DESNUDO (torso->pelvis). Verifica si hay hueco de anatomia entre
# la piel del abdomen (abs_plate) y la pelvis (dark_leather_mat) cuando el
# outfit NO esta puesto (banco de anatomia canonico, sin faja).
# Boot: --autotest=res://tests/tmp_waist_check.gd  (windowed)
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
	_cam.fov = 35.0   # cerrado: cintura llena de cuadro
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
	pheno["warpaint"] = 0   # sin pintura: no distrae de la lectura de piel
	_rig.apply_phenotype(pheno, BASELINE_ORIGIN)
	var arm_r: Node3D = _rig.arms[1]
	(arm_r.get_child(arm_r.get_child_count() - 1) as Node3D).visible = false
	_rig.set_motion(0.0, false)
	await _wait(0.25)

	# ---- diagnostico NUMERICO: AABB mundial de abs_plate vs pelvis ----
	var abs_plate: MeshInstance3D = _rig.upper_spine.find_child("*", false, false)
	# buscar por posicion conocida en vez de nombre (no tiene .name propio)
	var abs_mi: MeshInstance3D = null
	var pelvis_mi: MeshInstance3D = _rig.pelvis as MeshInstance3D
	for c in _rig.upper_spine.get_children():
		if c is MeshInstance3D and (c as MeshInstance3D).mesh is SphereMesh:
			var sm := (c as MeshInstance3D).mesh as SphereMesh
			if absf(sm.radius - 0.055) < 0.001 and (c as MeshInstance3D).scale.y > 1.0:
				abs_mi = c as MeshInstance3D
	if abs_mi != null and pelvis_mi != null:
		var abs_aabb: AABB = abs_mi.get_aabb()
		var abs_lo := INF
		var abs_hi := -INF
		for i in range(8):
			var p: Vector3 = abs_mi.global_transform * abs_aabb.get_endpoint(i)
			abs_lo = minf(abs_lo, p.y)
			abs_hi = maxf(abs_hi, p.y)
		var pel_aabb: AABB = pelvis_mi.get_aabb()
		var pel_lo := INF
		var pel_hi := -INF
		for i in range(8):
			var p2: Vector3 = pelvis_mi.global_transform * pel_aabb.get_endpoint(i)
			pel_lo = minf(pel_lo, p2.y)
			pel_hi = maxf(pel_hi, p2.y)
		print("[WaistCheck] abs_plate world Y: [%.4f, %.4f]" % [abs_lo, abs_hi])
		print("[WaistCheck] pelvis    world Y: [%.4f, %.4f]" % [pel_lo, pel_hi])
		var gap: float = abs_lo - pel_hi
		print("[WaistCheck] GAP (abs_plate.bottom - pelvis.top) = %.4f m" % gap)
		if gap > 0.0:
			print("[WaistCheck] *** HUECO (abs_plate vs pelvis directo): %.1f cm ***" % (gap * 100.0))
		else:
			print("[WaistCheck] Sin hueco: los volumenes se solapan/tocan.")
	else:
		print("[WaistCheck] No se pudo localizar abs_plate/pelvis por metadata.")

	if "waist" in _rig and _rig.waist != null:
		var w_mi: MeshInstance3D = _rig.waist
		var w_aabb: AABB = w_mi.get_aabb()
		var w_lo := INF
		var w_hi := -INF
		for i in range(8):
			var p3: Vector3 = w_mi.global_transform * w_aabb.get_endpoint(i)
			w_lo = minf(w_lo, p3.y)
			w_hi = maxf(w_hi, p3.y)
		print("[WaistCheck] waist     world Y: [%.4f, %.4f]" % [w_lo, w_hi])
		if pelvis_mi != null:
			var pel_hi2 := -INF
			var pel_aabb2: AABB = pelvis_mi.get_aabb()
			for i in range(8):
				pel_hi2 = maxf(pel_hi2, (pelvis_mi.global_transform * pel_aabb2.get_endpoint(i)).y)
			print("[WaistCheck] waist.bottom(%.4f) vs pelvis.top(%.4f) -> overlap=%.4f m" % [w_lo, pel_hi2, pel_hi2 - w_lo])
		if abs_mi != null:
			var abs_lo2 := INF
			var abs_aabb2: AABB = abs_mi.get_aabb()
			for i in range(8):
				abs_lo2 = minf(abs_lo2, (abs_mi.global_transform * abs_aabb2.get_endpoint(i)).y)
			print("[WaistCheck] abs_plate.bottom(%.4f) vs waist.top(%.4f) -> overlap=%.4f m" % [abs_lo2, w_hi, w_hi - abs_lo2])
	else:
		print("[WaistCheck] rig.waist NO existe (parche no aplicado).")

	_gs.attach_post(_cam)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)

	# ---- capturas cerradas de cintura: frente / 3-4 / perfil ----
	var waist_t: Vector3 = _holder.global_position + Vector3(0.0, 1.05, 0.0)
	_cam.look_at_from_position(waist_t + Vector3(0.0, 0.0, 0.55), waist_t, Vector3.UP)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)
	await Debug.screenshot("res://test_out/waist_check_front.png")

	_cam.look_at_from_position(waist_t + Vector3(0.40, 0.0, 0.40), waist_t, Vector3.UP)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)
	await Debug.screenshot("res://test_out/waist_check_34.png")

	_cam.look_at_from_position(waist_t + Vector3(0.55, 0.0, 0.0), waist_t, Vector3.UP)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)
	await Debug.screenshot("res://test_out/waist_check_side.png")

	print("[WaistCheck] DONE")
	get_tree().quit(0)

func _wait(secs: float) -> void:
	var t := 0.0
	while t < secs:
		await get_tree().process_frame
		t += get_process_delta_time()
