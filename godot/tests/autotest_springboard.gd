# autotest_springboard.gd — PRD-007 alcance 4 (Gate 1): gate PERMANENTE del
# Seismic Springboard + Dagna aliada en el greybox. Cierra la Fase 1.
#
# Verifica, en juego real (windowed — usa los autoloads Feel/EventBus vivos):
#   A. Boot directo al greybox con aliada (--skip=arena --ally=dagna --spawn=light).
#   B. Dagna spawnea como ALIADA y comparte el array `springboard_waves`.
#   C. pound→onda: Bond (request_bond_pound) → Dagna golpea → onda registrada.
#   D. La cornisa NO se trepa a pie (caminar contra el cliff no sube).
#   E. El salto NORMAL no alcanza la altura de la cornisa (control).
#   F. Springboard-en-ventana → el jugador ATERRIZA sobre la cornisa (imposible
#      por otra vía). Captura del jugador en la meseta.
#   G. Dagna pelea a tu lado y NUNCA cae (piso de vida, alcance 3).
#   H. FPS no colapsado (gate ≥60 se lee en corrida FRÍA; ver Lecciones/térmica).
#
# Launch:
#   godot --path godot -- --autotest=res://tests/autotest_springboard.gd
extends Node

const _GameDirector = preload("res://core/game_director.gd")

var _errors: Array = []
var _director = null
var _arena = null
var _fps: float = 0.0

# ================================================================
func _ready() -> void:
	# HERMÉTICO: purga el save de una corrida previa.
	var save_abs: String = ProjectSettings.globalize_path("user://borisawa_save.json")
	if FileAccess.file_exists("user://borisawa_save.json"):
		DirAccess.remove_absolute(save_abs)
	Debug.args["origin"] = "ironblooded"
	Debug.args["cls"]    = "warrior"
	Debug.args["name"]   = "Boris"
	Debug.args["skip"]   = "arena"
	Debug.args["ally"]   = "dagna"
	Debug.args["spawn"]  = "light"
	await get_tree().process_frame
	_run()

# ================================================================
func _run() -> void:
	_director = _GameDirector.new()
	get_tree().current_scene.add_child(_director)
	_director.start()

	# ---- A. ARENA + aliada + controlador ----
	var ok: bool = await _until(func() -> bool:
		return _director.fsm.current_id == "ARENA" and _director.controller != null \
			and _director.allies.size() == 1, 4.0)
	if not ok:
		_fail("A: setup incompleto (arena/controller/dagna)")
		return _finish()
	_pass("A: boot→ARENA con aliada Dagna")

	_arena = _director.scene
	if _arena == null or not _arena.has_method("is_on_ledge"):
		_fail("A: la escena no es el greybox con cornisa (is_on_ledge ausente)")
		return _finish()

	var ctrl = _director.controller

	# ---- B. Dagna comparte springboard_waves con el controlador ----
	if ctrl.springboard_waves == _director.springboard_waves:
		_pass("B: el controlador comparte springboard_waves con el director")
	else:
		_fail("B: el controlador NO comparte springboard_waves")

	# ---- C. Bond → pound → onda registrada (código real de Dagna) ----
	_director.request_bond_pound()
	var wave_ok: bool = await _until(func() -> bool:
		return _director.springboard_waves.size() >= 1, 2.0)
	if wave_ok:
		_pass("C: Bond→pound→onda registrada")
	else:
		_fail("C: Bond no produjo onda (pound de Dagna)")
	# Deja expirar la onda del pound real antes de aislar los tests de traversal.
	await _until(func() -> bool: return _director.springboard_waves.is_empty(), 2.0)

	# Silencia la IA de Dagna y aparta al enemigo para aislar la traversal
	# (Lección: un actor autónomo inyecta ondas y contamina la sonda de otra
	# mecánica). Se restauran para el test G.
	_silence_dagna()
	var light = _director.enemies[0] if _director.enemies.size() > 0 else null
	var enemy_home: Vector3 = Vector3.ZERO
	if light != null:
		enemy_home = light.position
		light.aggro = false
		light.position = Vector3(30.0, 0.0, 30.0)

	var launch: Vector3 = _arena.ledge_launch_point()
	var ledge_h: float = _arena.LEDGE_H

	# ---- D. La cornisa NO se trepa a pie ----
	_settle(ctrl, launch)
	ctrl._keys_down[KEY_W] = true    # camina recto contra la cara del cliff
	await _wait(1.5)
	ctrl._keys_down.clear()
	if not _arena.is_on_ledge(ctrl.position) and ctrl.position.y < 0.5:
		_pass("D: caminar contra el cliff no lo trepa (y=%.2f)" % ctrl.position.y)
	else:
		_fail("D: se trepó el cliff a pie (on_ledge=%s y=%.2f)" % [
			str(_arena.is_on_ledge(ctrl.position)), ctrl.position.y])

	# ---- E. El salto NORMAL no alcanza la altura de la cornisa ----
	_settle(ctrl, launch)
	var normal_peak: float = await _jump_and_track(ctrl, false)
	if normal_peak < ledge_h - 0.5 and not _arena.is_on_ledge(ctrl.position):
		_pass("E: salto normal no alcanza la cornisa (pico %.2f < %.1f)" % [normal_peak, ledge_h])
	else:
		_fail("E: el salto normal alcanzó la cornisa (pico %.2f)" % normal_peak)

	# ---- F. Springboard-en-ventana → aterriza en la cornisa ----
	_settle(ctrl, launch)
	var sb_peak: float = await _jump_and_track(ctrl, true)
	var on_ledge: bool = _arena.is_on_ledge(ctrl.position)
	if on_ledge:
		_pass("F: Springboard → cornisa ALCANZADA (pico %.2f, pos y=%.2f z=%.2f)" % [
			sb_peak, ctrl.position.y, ctrl.position.z])
	else:
		_fail("F: el Springboard no aterrizó en la cornisa (pico %.2f, y=%.2f, on_ledge=%s)" % [
			sb_peak, ctrl.position.y, str(on_ledge)])
	if sb_peak >= ledge_h:
		_pass("F: el lanzamiento supera la altura de la cornisa (%.2f ≥ %.1f)" % [sb_peak, ledge_h])
	else:
		_fail("F: el lanzamiento no superó la cornisa (%.2f < %.1f)" % [sb_peak, ledge_h])
	# Captura del jugador sobre la meseta (evidencia del gate).
	await _wait(0.15)
	await Debug.screenshot("res://test_out/springboard_gate.png")

	# ---- F2. El salto NO se corta contra el labio (lanzamiento pegado al cliff) ----
	# Regresión del feedback del director (2026-07-09): al lanzarse pegado a la cara
	# del cliff, entrar al footprint por debajo de la tapa clavaba al jugador y
	# cortaba el impulso vertical (pico ~3.3 en vez de ~6). Con el aterrizaje
	# descend-only, el arco debe llegar a su altura plena aunque suba pegado al muro.
	# (El aterrizaje LIMPIO en la meseta lo cubre F; acá solo custodiamos el corte.)
	_settle(ctrl, Vector3(0.0, 0.0, _arena.LEDGE_MAX_Z + 0.2))   # pegado al borde
	ctrl._keys_down[KEY_W] = true                                # empuja contra la cara
	_director.springboard_waves.clear()
	_director.springboard_waves.append({
		"position": ctrl.position, "radius": 4.2, "t": 2.5, "directed": false,
	})
	var edge_peak: float = 0.0
	var edge_launched: bool = false
	ctrl._keys_down[KEY_SPACE] = true
	var et0: int = Time.get_ticks_msec()
	while Time.get_ticks_msec() - et0 < 3500:
		edge_peak = maxf(edge_peak, ctrl.position.y)
		if not ctrl.grounded:
			edge_launched = true
			ctrl._keys_down.erase(KEY_SPACE)
		elif edge_launched:
			break
		await get_tree().process_frame
	ctrl._keys_down.clear()
	if edge_peak >= 5.0:
		_pass("F2: el salto pegado al cliff NO se corta (pico %.2f ≥ 5.0)" % edge_peak)
	else:
		_fail("F2: el salto se cortó contra el labio (pico %.2f < 5.0)" % edge_peak)

	# ---- G. Dagna pelea a tu lado y NUNCA cae ----
	if light != null:
		_restore_dagna()
		# Baja al jugador de la meseta y pone al enemigo encima de Dagna con aggro.
		var dagna = _director.allies[0]
		_settle(ctrl, Vector3(0.0, 0.0, 12.0))
		light.position = dagna.position + Vector3(1.2, 0.0, 0.0)
		light.aggro = true
		var hp0: float = dagna.health
		await _wait(4.0)
		if not dagna.dead and dagna.health >= dagna.HEALTH_FLOOR:
			_pass("G: Dagna pelea a tu lado y no cae (HP %.0f→%.0f, piso %.0f)" % [
				hp0, dagna.health, dagna.HEALTH_FLOOR])
		else:
			_fail("G: Dagna cayó (dead=%s HP=%.0f)" % [str(dagna.dead), dagna.health])
	else:
		_fail("G: no hay enemigo para probar el combate de Dagna")

	# ---- H. FPS (piso catastrófico; el ≥60 se mide en frío) ----
	for _i in range(40):
		await get_tree().process_frame
	_fps = Engine.get_frames_per_second()
	if _fps >= 25.0:
		_pass("H: FPS no colapsado (got %.0f; gate ≥60 se mide en frío)" % _fps)
	else:
		_fail("H: FPS colapsado (%.0f)" % _fps)

	_finish()

# ================================================================
# Helpers
# ================================================================

# _settle — planta al jugador firme en el suelo en `pos`, mirando hacia la cornisa
# (-Z), con stamina llena y sin teclas pegadas.
func _settle(ctrl, pos: Vector3) -> void:
	ctrl._keys_down.clear()
	_director.springboard_waves.clear()
	ctrl.position = pos
	ctrl.vel_y = 0.0
	ctrl.grounded = true
	ctrl.facing = PI          # mira -Z (hacia la meseta)
	ctrl._air_vel = Vector3.ZERO
	ctrl._leaping = false
	_director.stats.stamina = _director.stats.max_stamina
	await _wait(0.2)

# _jump_and_track — fuerza un salto (SPACE) y devuelve la ALTURA de pico ganada.
# Si `springboard`, primero construye momentum hacia la cornisa (W) e inyecta una
# onda DIRIGIDA bajo el jugador (empuje del arco); si no, salto normal en el sitio.
func _jump_and_track(ctrl, springboard: bool) -> float:
	var ground_y: float = ctrl.position.y
	if springboard:
		ctrl._keys_down[KEY_W] = true        # ramp de momentum hacia -Z (la meseta)
		await _wait(0.45)
		_director.stats.stamina = _director.stats.max_stamina
		# Onda DIRIGIDA bajo el jugador, apuntada al borde cercano → empuje del arco.
		_director.springboard_waves.clear()
		_director.springboard_waves.append({
			"position": Vector3(0.0, 0.0, _arena.LEDGE_MAX_Z),
			"radius": 4.2, "t": 2.5, "directed": true,
		})

	ctrl._keys_down[KEY_SPACE] = true
	var peak: float = 0.0
	var launched: bool = false
	var t0: int = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 3500:
		peak = maxf(peak, ctrl.position.y - ground_y)
		if not ctrl.grounded:
			launched = true
			ctrl._keys_down.erase(KEY_SPACE)   # consumido; no re-saltar
		elif launched:
			break                               # volvió a tocar suelo
		await get_tree().process_frame
	ctrl._keys_down.clear()
	return peak

func _silence_dagna() -> void:
	for a in _director.allies:
		if a != null:
			a._ai_pound_cd = 1.0e9   # nunca dispara el pound autónomo durante la traversal

func _restore_dagna() -> void:
	for a in _director.allies:
		if a != null:
			a._ai_pound_cd = 0.0

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

func _pass(msg: String) -> void:
	print("[AutotestSpring] PASS ", msg)

func _fail(msg: String) -> void:
	_errors.append(msg)

func _finish() -> void:
	var report: Dictionary = {
		"arena_reached": _director != null and _director.fsm.current_id == "ARENA",
		"allies":        _director.allies.size() if _director != null else 0,
		"fps":           _fps,
		"errors":        _errors,
	}
	Debug.write_json("res://test_out/springboard_gate.json", report)
	if _errors.is_empty():
		print("[AutotestSpring] ALL_PASS")
		get_tree().quit(0)
	else:
		print("[AutotestSpring] FAILURES: %d" % _errors.size())
		for e in _errors:
			print("  ", e)
		get_tree().quit(1)
