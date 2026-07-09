# tmp_springboard.gd — sonda PRD-007 alcance 2: Seismic Springboard T1.
# Verifica el paquete completo de la mecánica:
#   1. Bond (request_bond_pound) → Dagna golpea → onda registrada.
#   2. Saltar DENTRO de la onda → lanzamiento amplificado (altura "imposible").
#   3. Saltar FUERA de la onda → salto normal (control, altura baja).
#   4. Air control conservado: con W mantenido durante el lanzamiento, el
#      jugador se desplaza en horizontal (puede dirigirse a la cornisa).
#   5. Captura del ápice del lanzamiento (VFX teal + cue de HUD).
# Boot: --autotest=res://tests/tmp_springboard.gd -- --origin=ironblooded --cls=warrior --skip=arena --ally=dagna --spawn=light
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
	Debug.args["spawn"]  = "light"
	await get_tree().process_frame
	_run()

func _run() -> void:
	_director = _GameDirector.new()
	get_tree().current_scene.add_child(_director)
	_director.start()

	# Espera el setup de ARENA (controller + Dagna aliada).
	var ok: bool = await _until(func() -> bool:
		return _director.fsm.current_id == "ARENA" and _director.controller != null \
			and _director.allies.size() == 1, 4.0)
	if not ok:
		_fail("setup incompleto (arena/controller/dagna)")
		return _finish()

	var ctrl = _director.controller
	# Que el controlador comparta el array de ondas del director (wiring del enter).
	if ctrl.springboard_waves != _director.springboard_waves:
		_fail("el controlador no comparte springboard_waves con el director")

	# ---- 1. Bond → pound → onda registrada ----
	_director.request_bond_pound()
	var wave_ok: bool = await _until(func() -> bool:
		return _director.springboard_waves.size() >= 1, 1.5)
	if wave_ok:
		print("[TmpSpring] PASS Bond→pound→onda registrada")
	else:
		_fail("Bond no produjo onda (pound de Dagna)")
	# Deja expirar la onda del pound real para aislar los tests de altura.
	await _until(func() -> bool: return _director.springboard_waves.is_empty(), 2.0)

	# ---- 2. Salto DENTRO de la onda → lanzamiento ----
	var launch_h: float = await _jump_peak(ctrl, true, false)
	print("[TmpSpring] altura con onda = %.2f m" % launch_h)
	if launch_h >= 4.0:
		print("[TmpSpring] PASS lanzamiento amplificado (>=4 m)")
	else:
		_fail("el lanzamiento no alcanzó altura de springboard (%.2f m)" % launch_h)

	# ---- 3. Salto FUERA de la onda → salto normal (control) ----
	var normal_h: float = await _jump_peak(ctrl, false, false)
	print("[TmpSpring] altura sin onda = %.2f m" % normal_h)
	if normal_h <= 2.2:
		print("[TmpSpring] PASS salto normal fuera de onda (<=2.2 m)")
	else:
		_fail("el salto normal salió demasiado alto (%.2f m)" % normal_h)
	if launch_h > normal_h * 2.0:
		print("[TmpSpring] PASS lanzamiento >> salto normal (%.1fx)" % (launch_h / maxf(normal_h, 0.01)))
	else:
		_fail("el lanzamiento no supera claramente al salto normal")

	# ---- 4. Air control: W mantenido durante el lanzamiento → desplazamiento ----
	var moved: float = await _jump_peak(ctrl, true, true)
	print("[TmpSpring] desplazamiento horizontal con W = %.2f m" % moved)
	if moved > 0.5:
		print("[TmpSpring] PASS air control conservado en el lanzamiento")
	else:
		_fail("sin air control en el lanzamiento (%.2f m)" % moved)

	_finish()

# _jump_peak — coloca una onda (o no) bajo el jugador, fuerza un salto (SPACE)
# y devuelve, o bien la ALTURA máxima ganada (si `measure_horizontal` es false),
# o bien el DESPLAZAMIENTO horizontal total (si es true, con W mantenido).
# Captura el ápice en el primer lanzamiento con onda.
func _jump_peak(ctrl, with_wave: bool, measure_horizontal: bool) -> float:
	# Reposo firme en el suelo.
	ctrl._keys_down.clear()
	_director.springboard_waves.clear()
	await _wait(0.25)
	_director.stats.stamina = _director.stats.max_stamina
	var ground_y: float = ctrl.position.y
	var start_xz := Vector2(ctrl.position.x, ctrl.position.z)

	# Air control conserva/dirige el MOMENTUM existente (no acelera desde cero,
	# igual que el salto normal): el jugador real llega corriendo a la onda. Para
	# medirlo, construimos velocidad con W en el suelo ANTES de saltar.
	if measure_horizontal:
		ctrl._keys_down[KEY_W] = true
		await _wait(0.45)                 # ramp de planar_speed (sigue dentro del radio 4.2)
		ground_y = ctrl.position.y

	if with_wave:
		_director.springboard_waves.append({
			"position": ctrl.position, "radius": 4.2, "t": 2.5,
		})

	# Dispara el salto (SPACE hasta despegar). W se mantiene si medimos air control.
	ctrl._keys_down[KEY_SPACE] = true

	var peak_h: float = 0.0
	var launched: bool = false
	var shot: bool = false
	var air_start_xz := Vector2(ctrl.position.x, ctrl.position.z)
	var t0: int = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 3000:
		var h: float = ctrl.position.y - ground_y
		peak_h = maxf(peak_h, h)
		if not ctrl.grounded:
			if not launched:
				launched = true
				air_start_xz = Vector2(ctrl.position.x, ctrl.position.z)  # tramo AÉREO
			ctrl._keys_down.erase(KEY_SPACE)   # consumido; no re-saltar
			# Captura del ápice del lanzamiento con onda (una sola vez).
			if with_wave and not measure_horizontal and not shot and ctrl.vel_y <= 0.5:
				shot = true
				await Debug.screenshot("res://test_out/springboard_launch.png")
		elif launched:
			break   # volvió a tocar suelo
		await get_tree().process_frame
	ctrl._keys_down.clear()

	if measure_horizontal:
		return Vector2(ctrl.position.x, ctrl.position.z).distance_to(air_start_xz)
	return peak_h

func _until(fn: Callable, timeout: float) -> bool:
	var t0: int = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(timeout * 1000.0):
		if fn.call():
			return true
		await get_tree().process_frame
	return false

func _wait(s: float) -> void:
	var t0: int = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < int(s * 1000.0):
		await get_tree().process_frame

func _fail(msg: String) -> void:
	_errors.append(msg)

func _finish() -> void:
	if _errors.is_empty():
		print("[TmpSpring] ALL_PASS")
		get_tree().quit(0)
	else:
		print("[TmpSpring] FAILURES: %d" % _errors.size())
		for e in _errors:
			print("  ", e)
		get_tree().quit(1)
