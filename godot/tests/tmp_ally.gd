# tmp_ally.gd — sonda PRD-007 alcance 0: Dagna aliada spawnea y SIGUE al
# jugador en el greybox. Verifica spawn (--ally=dagna), que se mueve del punto
# de aparición, y que mantiene la distancia acotada mientras el jugador avanza.
# Boot: --autotest=res://tests/tmp_ally.gd -- --origin=ironblooded --cls=warrior --skip=arena --ally=dagna
extends Node

const _GameDirector = preload("res://core/game_director.gd")

var _errors: Array = []
var _director = null

func _ready() -> void:
	var save_abs: String = ProjectSettings.globalize_path("user://borisawa_save.json")
	if FileAccess.file_exists("user://borisawa_save.json"):
		DirAccess.remove_absolute(save_abs)
	Debug.args["origin"] = "ironblooded"
	Debug.args["cls"]    = "warrior"
	Debug.args["skip"]   = "arena"
	Debug.args["ally"]   = "dagna"
	await get_tree().process_frame
	_run()

func _plan_dist(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()

func _run() -> void:
	_director = _GameDirector.new()
	get_tree().current_scene.add_child(_director)
	_director.start()

	# Espera ARENA + controller.
	var t := 0.0
	while t < 4.0:
		if _director.fsm.current_id == "ARENA" and _director.controller != null:
			break
		await get_tree().process_frame
		t += get_process_delta_time()

	var ctl = _director.controller
	if ctl == null or _director.fsm.current_id != "ARENA":
		_fail("no llegó a ARENA con controller")
		return _finish()

	# ---- spawn ----
	if _director.allies.size() != 1:
		_fail("allies=%d (esperaba 1 con --ally=dagna)" % _director.allies.size())
		return _finish()
	var dagna = _director.allies[0]
	print("[TmpAlly] PASS spawn (1 aliada)")
	var spawn_pos: Vector3 = dagna.position

	# Deja asentarse al slot inicial.
	await _wait(1.0)
	var settled_start: float = _plan_dist(dagna.position, ctl.position)

	# ---- el jugador avanza en pasos; Dagna debe seguir ----
	var max_settled: float = 0.0
	for step in range(6):
		ctl.position += Vector3(0.0, 0.0, -4.0)   # avanza 4 m hacia -Z
		await _wait(1.0)                            # deja que Dagna alcance el slot
		var d: float = _plan_dist(dagna.position, ctl.position)
		max_settled = maxf(max_settled, d)
		print("[TmpAlly] step %d: dist=%.2f m" % [step, d])

	# ---- asserts ----
	var moved: float = _plan_dist(dagna.position, spawn_pos)
	if moved < 3.0:
		_fail("Dagna no siguió (se movió solo %.2f m del spawn)" % moved)
	else:
		print("[TmpAlly] PASS Dagna siguió (%.1f m recorridos)" % moved)

	if max_settled > 4.5:
		_fail("Dagna se descolgó (dist máx asentada %.2f m > 4.5)" % max_settled)
	else:
		print("[TmpAlly] PASS distancia acotada (máx asentada %.2f m)" % max_settled)

	# Evidencia visual (Dagna al hombro del jugador).
	await _wait(0.3)
	await Debug.screenshot("res://test_out/ally_dagna_follow.png")
	_finish()

func _wait(s: float) -> void:
	var t := 0.0
	while t < s:
		await get_tree().process_frame
		t += get_process_delta_time()

func _fail(msg: String) -> void:
	_errors.append(msg)

func _finish() -> void:
	if _errors.is_empty():
		print("[TmpAlly] ALL_PASS")
		get_tree().quit(0)
	else:
		print("[TmpAlly] FAILURES: %d" % _errors.size())
		for e in _errors:
			print("  ", e)
		get_tree().quit(1)
