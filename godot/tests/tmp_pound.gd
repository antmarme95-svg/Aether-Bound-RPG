# tmp_pound.gd — sonda PRD-007 alcance 1: el ground-pound de Dagna crea la
# ZONA DE ONDA (fuente del Springboard) + VFX teal + empuja a los enemigos.
# Verifica: onda registrada tras el windup, knockback a un heavy cercano,
# expiración tras la ventana, y captura el VFX.
# Boot: --autotest=res://tests/tmp_pound.gd -- --origin=ironblooded --cls=warrior --skip=arena --ally=dagna --spawn=heavy
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
	Debug.args["spawn"]  = "heavy"
	await get_tree().process_frame
	_run()

func _run() -> void:
	_director = _GameDirector.new()
	get_tree().current_scene.add_child(_director)
	_director.start()

	var t := 0.0
	while t < 4.0:
		if _director.fsm.current_id == "ARENA" and _director.controller != null \
				and _director.allies.size() == 1 and _director.enemies.size() >= 1:
			break
		await get_tree().process_frame
		t += get_process_delta_time()

	if _director.allies.size() != 1 or _director.enemies.is_empty():
		_fail("setup incompleto (allies=%d enemies=%d)" % [_director.allies.size(), _director.enemies.size()])
		return _finish()

	var dagna = _director.allies[0]
	var heavy = _director.enemies[0]

	# Coloca al heavy pegado a Dagna y sin aggro (aísla el knockback de la onda).
	heavy.aggro = false
	heavy.state = "idle"
	heavy.position = dagna.position + Vector3(2.0, 0.0, 0.0)
	await _wait(0.3)
	var heavy_before: Vector3 = heavy.position

	# ---- dispara el pound ----
	dagna.ground_pound()

	# La onda se registra en el impacto (tras el windup ~0.35 s).
	var wave_ok: bool = await _until(func() -> bool:
		return _director.springboard_waves.size() >= 1, 1.5)
	if wave_ok:
		print("[TmpPound] PASS onda registrada (%d activa)" % _director.springboard_waves.size())
	else:
		_fail("la onda no se registró tras el pound")

	# Captura el VFX (burst + anillos) recién nacido.
	await _wait(0.12)
	await Debug.screenshot("res://test_out/pound_wave.png")

	# Knockback: el push_pull del heavy quedó activo por la onda.
	if heavy.push_pull != null and heavy.push_pull.is_active():
		print("[TmpPound] PASS knockback (push_pull activo)")
	else:
		_fail("el heavy no recibió knockback de la onda")

	# Se desplazó lejos del centro de la onda.
	await _wait(0.6)
	var moved: float = Vector2(heavy.position.x - heavy_before.x, heavy.position.z - heavy_before.z).length()
	if moved > 0.4:
		print("[TmpPound] PASS heavy empujado (%.2f m)" % moved)
	else:
		_fail("el heavy apenas se movió (%.2f m)" % moved)

	# La onda expira tras la ventana.
	var expired: bool = await _until(func() -> bool:
		return _director.springboard_waves.is_empty(), 2.0)
	if expired:
		print("[TmpPound] PASS onda expiró tras la ventana")
	else:
		_fail("la onda no expiró")

	_finish()

func _until(fn: Callable, timeout: float) -> bool:
	var t := 0.0
	while t < timeout:
		if fn.call():
			return true
		await get_tree().process_frame
		t += get_process_delta_time()
	return false

func _wait(s: float) -> void:
	var t := 0.0
	while t < s:
		await get_tree().process_frame
		t += get_process_delta_time()

func _fail(msg: String) -> void:
	_errors.append(msg)

func _finish() -> void:
	if _errors.is_empty():
		print("[TmpPound] ALL_PASS")
		get_tree().quit(0)
	else:
		print("[TmpPound] FAILURES: %d" % _errors.size())
		for e in _errors:
			print("  ", e)
		get_tree().quit(1)
