# autotest_biomech.gd — PRD-006 alcance 0 acceptance test.
# Run via: godot --path godot -- --autotest=res://tests/autotest_biomech.gd
#
# Asserts (Movilidad Realista §4.3):
#   A. Gait / crouch-walk / slide at realistic speeds attempt ZERO ROM
#      violations (the accepted poses are authored inside the envelope).
#   B. The weight-transfer strike runs its phases in biomech order
#      (windup → active → recovery) and attempts ZERO ROM violations.
#   C. The constraint pass WORKS: adversarial joint values (hyperextended
#      elbow/knee, overhead-past shoulder) get clamped back inside ROM and
#      the attempts are recorded in the report.
# Screenshots of the three strike phases go to test_out/ for montage review
# ("¿el golpe nace en la cadera?").
extends Node

var _rig: CharacterRig = null
var _cam: Camera3D = null
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
	var origin: Dictionary = OriginsData.get_origin("aetherborn")
	_rig.apply_phenotype(PhenotypeData.default_phenotype(), origin)
	_rig.apply_archetype("thief")  # Duelist — the slice cell
	await get_tree().process_frame
	await get_tree().process_frame

	# ---- A. Locomotion poses stay inside ROM ----
	_rig.reset_constraint_report()
	for spd in [0.35, 0.7, 1.0]:
		_rig.set_motion(spd, false, false)
		await _run_for(1.0)
	_rig.set_motion(0.5, true, false)    # crouch-walk at realistic speed
	await _run_for(1.0)
	_rig.set_motion(0.9, false, true)    # slide pose
	await _run_for(0.7)
	_rig.set_motion(0.0, false, false)
	await _run_for(0.4)
	_check_zero_violations("locomotion", _rig.constraint_report())

	# ---- B. Strike: phase order + zero violations + montage shots ----
	_rig.reset_constraint_report()
	var phases_seen: Array = []
	# Screenshot at each phase MIDPOINT so the pose is at its most readable
	# (coil fully loaded / chain mid-release / re-balance in progress).
	var shot_marks: Dictionary = {"windup": 0.16, "active": 0.45, "recovery": 0.78}
	_rig.play_strike(0.55)
	var guard: int = 0
	while _rig.strike_phase() != "" and guard < 600:
		var ph: String = _rig.strike_phase()
		if phases_seen.is_empty() or phases_seen[phases_seen.size() - 1] != ph:
			phases_seen.append(ph)
		if shot_marks.has(ph) and _rig.strike_progress() >= float(shot_marks[ph]):
			shot_marks.erase(ph)
			await Debug.screenshot("res://test_out/biomech_strike_" + ph + ".png")
		await get_tree().process_frame
		guard += 1
	if phases_seen != ["windup", "active", "recovery"]:
		_errors.append("FAIL strike phase order: %s" % [phases_seen])
	else:
		print("[autotest_biomech] PASS strike phases: windup -> active -> recovery")
	_check_zero_violations("strike", _rig.constraint_report())
	_results.append({"case": "strike_phases", "order": phases_seen})

	# One more strike for the settle path, then let it finish
	_rig.play_strike(0.4)
	await _run_for(0.7)
	_check_zero_violations("strike_short", _rig.constraint_report())

	# ---- C. Adversarial: constraints must clamp and record ----
	_rig.reset_constraint_report()
	var elbow_r: Node3D = _rig.arms[1].get_meta("elbow")
	var knee_l: Node3D = _rig.legs[0].get_meta("knee")
	elbow_r.rotation.x = 1.2    # hyperextension (limit 0.03)
	knee_l.rotation.x = -0.9    # backward knee (limit 0.0)
	_rig.arms[1].rotation.x = -3.4  # past overhead (limit -3.0)
	await get_tree().process_frame
	await get_tree().process_frame
	var rep: Dictionary = _rig.constraint_report()
	_assert_true(elbow_r.rotation.x <= 0.031, "elbow clamped (got %.3f)" % elbow_r.rotation.x)
	_assert_true(knee_l.rotation.x >= -0.001, "knee clamped (got %.3f)" % knee_l.rotation.x)
	_assert_true(_rig.arms[1].rotation.x >= -3.001, "shoulder clamped (got %.3f)" % _rig.arms[1].rotation.x)
	_assert_true(rep.has("elbow_r") and int(rep["elbow_r"]["attempts"]) > 0, "elbow violation recorded")
	_assert_true(rep.has("knee_l") and int(rep["knee_l"]["attempts"]) > 0, "knee violation recorded")
	_results.append({"case": "adversarial_clamp", "report": rep})

	# ---- Write results + verdict ----
	Debug.write_json("res://test_out/biomech_results.json", {
		"cases": _results, "errors": _errors, "done": true,
	})
	if _errors.is_empty():
		print("[autotest_biomech] ALL_PASS")
		get_tree().quit(0)
	else:
		for e in _errors:
			print("[autotest_biomech] ", e)
		print("[autotest_biomech] FAILED (%d errors)" % _errors.size())
		get_tree().quit(1)

# ---- helpers ----

func _run_for(seconds: float) -> void:
	var elapsed: float = 0.0
	while elapsed < seconds:
		await get_tree().process_frame
		elapsed += get_process_delta_time()

func _check_zero_violations(label: String, report: Dictionary) -> void:
	if report.is_empty():
		print("[autotest_biomech] PASS %s: zero ROM violations" % label)
		return
	_errors.append("FAIL %s attempted ROM violations: %s" % [label, report])

func _assert_true(cond: bool, label: String) -> void:
	if cond:
		print("[autotest_biomech] PASS ", label)
	else:
		_errors.append("FAIL " + label)

func _build_stage() -> void:
	var we = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#0c1622")
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.15
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#bfe8ff")
	env.ambient_light_energy = 0.35
	we.environment = env
	get_tree().root.add_child(we)

	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45.0, 30.0, 0.0)
	sun.light_energy = 1.2
	sun.light_color = Color("#fff4e0")
	sun.shadow_enabled = true
	get_tree().root.add_child(sun)

	_cam = Camera3D.new()
	# Three-quarter view so the hip lead reads in the screenshots
	_cam.position = Vector3(1.6, 1.35, 1.8)
	_cam.look_at_from_position(_cam.position, Vector3(0.0, 1.0, 0.0), Vector3.UP)
	get_tree().root.add_child(_cam)
