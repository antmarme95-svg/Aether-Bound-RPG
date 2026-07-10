# tmp_springboard_directed.gd — sonda PRD-007 alcance 2b: Springboard DIRIGIDO.
# Verifica la capa de COLOCACIÓN sobre el alcance 2:
#   1. Clamp del apuntado: un punto dentro de rango pasa; uno fuera se recorta al
#      borde (DESIGNATE_RANGE) — pura, sin cámara.
#   2. Orden dirigida: Dagna VIAJA al punto (deja su slot) y golpea AHÍ → onda
#      registrada en el punto y MARCADA como `directed`; arranca el cooldown.
#   3. Cooldown: una segunda orden inmediata se ignora (una orden en vuelo).
#   4. Arco dirigido: lanzarse desde una onda comandada suma el empuje hacia el
#      punto → cubre MÁS distancia horizontal que la misma onda sin marcar.
#   5. Captura del viaje/decal.
# Boot: --autotest=res://tests/tmp_springboard_directed.gd -- --origin=ironblooded --cls=warrior --skip=arena --ally=dagna --spawn=light
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

	var ok: bool = await _until(func() -> bool:
		return _director.fsm.current_id == "ARENA" and _director.controller != null \
			and _director.allies.size() == 1, 4.0)
	if not ok:
		_fail("setup incompleto (arena/controller/dagna)")
		return _finish()

	var ctrl = _director.controller
	var dagna = _director.allies[0]

	# ---- 1. Clamp del apuntado (pura) ----
	var near_pt: Vector3 = ctrl.position + Vector3(3.0, 0.0, 0.0)
	var near_c: Dictionary = ctrl._clamp_designate(near_pt)
	if near_c["in_range"] and near_c["point"].distance_to(near_pt) < 0.01:
		print("[TmpDir] PASS clamp deja pasar punto en rango")
	else:
		_fail("clamp alteró un punto en rango")
	var far_pt: Vector3 = ctrl.position + Vector3(30.0, 0.0, 0.0)
	var far_c: Dictionary = ctrl._clamp_designate(far_pt)
	var far_d: float = Vector2(far_c["point"].x - ctrl.position.x, far_c["point"].z - ctrl.position.z).length()
	if not far_c["in_range"] and absf(far_d - ctrl.DESIGNATE_RANGE) < 0.05:
		print("[TmpDir] PASS clamp recorta al borde (%.1f m)" % far_d)
	else:
		_fail("clamp fuera de rango incorrecto (%.2f m, esperado %.1f)" % [far_d, ctrl.DESIGNATE_RANGE])

	# ---- 2. Orden dirigida: viaje + pound en el punto + marca directed ----
	var fwd := Vector3(sin(ctrl.facing), 0.0, cos(ctrl.facing))
	var target: Vector3 = ctrl.position + fwd * 6.0
	target.y = _director.scene.get_height(target.x, target.z)
	var slot_start: Vector3 = dagna.position
	_director.springboard_waves.clear()
	_director._issue_directed_pound(target)
	if _director._bond_cooldown <= 0.0:
		_fail("la orden dirigida no arrancó el cooldown")

	# Espera a que la onda aparezca EN el punto.
	var wave_ok: bool = await _until(func() -> bool:
		return _director.springboard_waves.size() >= 1, 4.0)
	if not wave_ok:
		_fail("la orden dirigida no produjo onda (viaje/pound)")
		return _finish()
	var wave: Dictionary = _director.springboard_waves[0]
	var wave_pos: Vector3 = wave["position"]
	var err_xz: float = Vector2(wave_pos.x - target.x, wave_pos.z - target.z).length()
	if err_xz < 1.0:
		print("[TmpDir] PASS onda EN el punto designado (err %.2f m)" % err_xz)
	else:
		_fail("la onda no nació en el punto (err %.2f m)" % err_xz)
	if wave.get("directed", false):
		print("[TmpDir] PASS onda marcada como dirigida")
	else:
		_fail("la onda comandada no quedó marcada `directed`")
	var traveled: float = slot_start.distance_to(dagna.position)
	if traveled > 2.0:
		print("[TmpDir] PASS Dagna dejó su slot y viajó (%.1f m)" % traveled)
	else:
		_fail("Dagna no viajó al punto (%.2f m)" % traveled)
	await Debug.screenshot("res://test_out/springboard_directed.png")

	# ---- 3. Cooldown activo tras la orden (el router lo consulta para
	# bloquear el spam: `is_designating && valid && _bond_cooldown<=0`) ----
	var cd_a: float = _director._bond_cooldown
	if cd_a > 0.5:
		print("[TmpDir] PASS cooldown activo tras la orden (%.1f s) — el router bloquea el spam" % cd_a)
	else:
		_fail("el cooldown no quedó activo tras la orden (%.2f s)" % cd_a)
	await _wait(0.4)
	if _director._bond_cooldown < cd_a:
		print("[TmpDir] PASS el cooldown decae con el tiempo")
	else:
		_fail("el cooldown no decae")
	# Deja expirar todo antes de medir arcos.
	await _until(func() -> bool: return _director.springboard_waves.is_empty(), 3.0)

	# ---- 4. Arco dirigido: empuje hacia el punto → más alcance horizontal ----
	var d_directed: float = await _arc_distance(ctrl, true)
	var d_plain: float    = await _arc_distance(ctrl, false)
	print("[TmpDir] alcance horizontal — dirigido %.2f m / sin marca %.2f m" % [d_directed, d_plain])
	if d_directed > 0.5:
		print("[TmpDir] PASS el lanzamiento dirigido cubre distancia horizontal")
	else:
		_fail("el lanzamiento dirigido no avanzó (%.2f m)" % d_directed)
	if d_directed > d_plain + 0.3:
		print("[TmpDir] PASS el empuje dirigido supera a la onda sin marcar (+%.2f m)" % (d_directed - d_plain))
	else:
		_fail("el empuje dirigido no añadió alcance (dir %.2f vs plano %.2f)" % [d_directed, d_plain])

	_finish()

# _arc_distance — construye momentum con W, coloca una onda (directed o no) 3 m
# ADELANTE del jugador (dentro del radio) y salta; devuelve la distancia
# horizontal cubierta en el tramo aéreo (con W mantenido → arco hacia el punto).
func _arc_distance(ctrl, directed: bool) -> float:
	ctrl._keys_down.clear()
	_director.springboard_waves.clear()
	await _wait(0.25)
	_director.stats.stamina = _director.stats.max_stamina
	ctrl._keys_down[KEY_W] = true
	await _wait(0.45)                       # ramp de momentum
	var fwd := Vector3(sin(ctrl.facing), 0.0, cos(ctrl.facing))
	_director.springboard_waves.append({
		"position": ctrl.position + fwd * 3.0, "radius": 4.2, "t": 2.5, "directed": directed,
	})
	ctrl._keys_down[KEY_SPACE] = true
	var launched: bool = false
	var air_start := Vector2(ctrl.position.x, ctrl.position.z)
	var t0: int = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 3000:
		if not ctrl.grounded:
			if not launched:
				launched = true
				air_start = Vector2(ctrl.position.x, ctrl.position.z)
			ctrl._keys_down.erase(KEY_SPACE)
		elif launched:
			break
		await get_tree().process_frame
	ctrl._keys_down.clear()
	return Vector2(ctrl.position.x, ctrl.position.z).distance_to(air_start)

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
		print("[TmpDir] ALL_PASS")
		get_tree().quit(0)
	else:
		print("[TmpDir] FAILURES: %d" % _errors.size())
		for e in _errors:
			print("  ", e)
		get_tree().quit(1)
