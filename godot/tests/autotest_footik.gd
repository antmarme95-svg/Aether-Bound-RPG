# autotest_footik.gd — C4 frente 2 (2026-07-21): "pies plantados en
# pendiente" ([[Movilidad Realista]]). Verifica la capa de IK analítica
# agregada a `character_rig.gd`/`rig_biomech.gd` (ankle nuevo + solve_knee_
# for_height + solve_ankle_level), llamada vía `CharacterRig.apply_foot_ik`.
# Run via: godot --path godot -- --autotest=res://tests/autotest_footik.gd
#
# Asserts:
#   A. Sin llamar apply_foot_ik nunca (bancos/escenas viejas): ankle queda
#      en reposo (0,0,0) — cero regresión donde no se usa.
#   B. Suelo llano (misma altura ambos pies, normal UP): converge con
#      ankle ~0 y CERO violaciones de ROM.
#   C. Rampa (un pie más alto que el otro + normal inclinada): la rodilla
#      se dobla lo justo para que el tobillo alcance la altura objetivo
#      (dentro de tolerancia) y el tobillo se nivela — sin violaciones.
#   D. Adversarial: altura objetivo fuera de alcance (agujero profundo)
#      no revienta — la rodilla clampea a ROM (0..2.4), sin NaN.
extends Node

var _rig: CharacterRig = null
var _errors: Array = []
var _results: Array = []

func _ready() -> void:
	_run.call_deferred()

func _run() -> void:
	if get_tree().current_scene != null:
		get_tree().current_scene.queue_free()
	await get_tree().process_frame

	_build_stage()

	_rig = CharacterRig.new()
	get_tree().root.add_child(_rig)
	_rig.position = Vector3.ZERO
	# Origen humano NEUTRO a propósito (proportions vacío = limb_len 1.0):
	# esta prueba verifica el MECANISMO de IK, no el tuning racial de C6b,
	# que cambia con cada ronda de medición — no acoplar el gate al valor
	# de "aetherborn"/"ironblooded" del día.
	var origin: Dictionary = OriginsData.get_origin("miststalker")
	_rig.apply_phenotype(PhenotypeData.default_phenotype(), origin)
	_rig.set_motion(0.0, false, false)
	await get_tree().process_frame
	await get_tree().process_frame

	# ---- A. Nunca llamado apply_foot_ik → ankle en reposo ----
	var ankle_l: Node3D = _rig.legs[0].get_meta("ankle")
	var ankle_r: Node3D = _rig.legs[1].get_meta("ankle")
	await _run_for(0.4)
	_assert_true(ankle_l.rotation == Vector3.ZERO and ankle_r.rotation == Vector3.ZERO,
			"sin apply_foot_ik: ankle en reposo (got l=%s r=%s)" % [ankle_l.rotation, ankle_r.rotation])

	# ---- B. Suelo llano: converge a ankle ~0, cero violaciones ----
	# Lección "loops acotados por FRAMES dependen del FPS" — este banco
	# corre sin vsync (cientos de fps); un conteo fijo de frames representa
	# tiempo real distinto según la máquina. Se acota por TIEMPO REAL.
	_rig.reset_constraint_report()
	var hip_y: float = _rig.legs[0].global_position.y
	await _drive_ik_for(0.6, hip_y - 0.90, hip_y - 0.90, Vector3.UP, Vector3.UP)
	_assert_true(ankle_l.rotation.length() < 0.05 and ankle_r.rotation.length() < 0.05,
			"llano: ankle converge cerca de reposo (got l=%.3f r=%.3f)" % [ankle_l.rotation.length(), ankle_r.rotation.length()])
	_check_zero_violations("llano", _rig.constraint_report())

	# ---- C. Rampa: un pie 0.15 m más alto + normal a 20° ----
	_rig.reset_constraint_report()
	var theta: float = deg_to_rad(20.0)
	var slope_n := Vector3(0.0, cos(theta), sin(theta)).normalized()
	var target_r: float = hip_y - 0.90 + 0.15
	var target_l: float = hip_y - 0.90
	await _drive_ik_for(0.9, target_l, target_r, Vector3.UP, slope_n)
	await Debug.screenshot("res://test_out/footik_slope.png")

	var knee_r: Node3D = _rig.legs[1].get_meta("knee")
	var achieved_r: float = ankle_r.global_position.y
	var err_r: float = absf(achieved_r - target_r)
	_assert_true(err_r < 0.06, "rampa: tobillo derecho alcanza altura objetivo (target=%.3f got=%.3f err=%.3f)" % [target_r, achieved_r, err_r])
	_assert_true(knee_r.rotation.x >= -0.001 and knee_r.rotation.x <= 2.401,
			"rampa: rodilla derecha dentro de ROM (got %.3f)" % knee_r.rotation.x)
	_assert_true(absf(ankle_r.rotation.x) > 0.02 or absf(ankle_r.rotation.z) > 0.02,
			"rampa: tobillo derecho se inclinó para nivelar (got x=%.3f z=%.3f)" % [ankle_r.rotation.x, ankle_r.rotation.z])
	_check_zero_violations("rampa", _rig.constraint_report())
	_results.append({"case": "rampa", "target_r": target_r, "achieved_r": achieved_r, "ankle_r": [ankle_r.rotation.x, ankle_r.rotation.z]})

	# ---- D. Adversarial: agujero fuera de alcance — no revienta, clampea ----
	_rig.reset_constraint_report()
	await _drive_ik_for(0.4, hip_y - 5.0, hip_y - 0.90, Vector3.UP, Vector3.UP)
	var knee_l: Node3D = _rig.legs[0].get_meta("knee")
	_assert_true(not is_nan(knee_l.rotation.x), "agujero: rodilla izquierda sin NaN")
	_assert_true(knee_l.rotation.x >= -0.001 and knee_l.rotation.x <= 2.401,
			"agujero: rodilla izquierda clampeada a ROM (got %.3f)" % knee_l.rotation.x)

	# ---- Write results + verdict ----
	Debug.write_json("res://test_out/footik_results.json", {
		"cases": _results, "errors": _errors, "done": true,
	})
	if _errors.is_empty():
		print("[autotest_footik] ALL_PASS")
		get_tree().quit(0)
	else:
		for e in _errors:
			print("[autotest_footik] ", e)
		print("[autotest_footik] FAILED (%d errors)" % _errors.size())
		get_tree().quit(1)

# ---- helpers ----

func _run_for(seconds: float) -> void:
	var elapsed: float = 0.0
	while elapsed < seconds:
		await get_tree().process_frame
		elapsed += get_process_delta_time()

## Llama apply_foot_ik CADA frame (como lo haría player_controller) durante
## `seconds` de tiempo REAL — no un conteo fijo de frames (Lección: acotar
## por frames depende del FPS de la corrida).
func _drive_ik_for(seconds: float, l_h: float, r_h: float, l_n: Vector3, r_n: Vector3) -> void:
	var elapsed: float = 0.0
	while elapsed < seconds:
		_rig.apply_foot_ik(l_h, r_h, l_n, r_n)
		await get_tree().process_frame
		elapsed += get_process_delta_time()

func _check_zero_violations(label: String, report: Dictionary) -> void:
	if report.is_empty():
		print("[autotest_footik] PASS %s: zero ROM violations" % label)
		return
	_errors.append("FAIL %s attempted ROM violations: %s" % [label, report])

func _assert_true(cond: bool, label: String) -> void:
	if cond:
		print("[autotest_footik] PASS ", label)
	else:
		_errors.append("FAIL " + label)

func _build_stage() -> void:
	var we = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#0c1622")
	we.environment = env
	get_tree().root.add_child(we)

	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45.0, 30.0, 0.0)
	sun.light_energy = 1.2
	get_tree().root.add_child(sun)

	var cam := Camera3D.new()
	# Encuadre bajo, a la altura de las piernas — donde vive esta prueba.
	cam.position = Vector3(1.3, 0.85, 1.3)
	cam.look_at_from_position(cam.position, Vector3(0.0, 0.55, 0.0), Vector3.UP)
	get_tree().root.add_child(cam)
	cam.make_current()
