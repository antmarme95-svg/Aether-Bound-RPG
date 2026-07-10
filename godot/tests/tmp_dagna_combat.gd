# tmp_dagna_combat.gd — sonda PRD-007 alcance 3: IA de combate mínima de Dagna.
# Verifica que Dagna PELEA A TU LADO:
#   A. Aggro por CERCANÍA: los enemigos apuntan al más cercano entre jugador y
#      Dagna (_nearest_target) + el director lo asigna a `combat_target`.
#   B. Pound AUTÓNOMO en contexto: con enemigos a tiro y sin Bond, Dagna golpea
#      sola → onda registrada Y la onda HACE DAÑO al enemigo ("la onda ES un ataque").
#   C. Muralla-block: enemigo en la cara → sube la guardia; sin amenaza → la baja.
#   D. Defensa propia: acusa golpes (el bloqueo reduce el daño) pero NUNCA cae
#      (piso de vida; su pérdida es coda del slice, fuera de alcance).
# Boot: --autotest=res://tests/tmp_dagna_combat.gd -- --origin=ironblooded --cls=warrior --skip=arena --ally=dagna --spawn=light
extends Node

const _GameDirector = preload("res://core/game_director.gd")
const _Payload = preload("res://combat/hit_payload.gd")

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
			and _director.allies.size() == 1 and _director.enemies.size() == 1, 4.0)
	if not ok:
		_fail("setup incompleto (arena/controller/dagna/enemigo)")
		return _finish()

	var ctrl  = _director.controller
	var dagna = _director.allies[0]
	var enemy = _director.enemies[0]
	var scene = _director.scene

	# ---- A. Aggro por cercanía ----
	dagna._ai_pound_cd = 999.0   # que no poundee y perturbe las posiciones
	enemy.position = Vector3(11.0, 0.0, 0.0)
	ctrl.position  = Vector3(0.0, 0.0, 0.0)
	dagna.position = Vector3(10.0, 0.0, 0.0)
	if _director._nearest_target(enemy.position) == dagna:
		print("[TmpDagCbt] PASS nearest = Dagna cuando está más cerca")
	else:
		_fail("nearest no devolvió a Dagna estando más cerca")
	ctrl.position  = Vector3(11.3, 0.0, 0.0)
	dagna.position = Vector3(0.0, 0.0, 0.0)
	if _director._nearest_target(enemy.position) == ctrl:
		print("[TmpDagCbt] PASS nearest = jugador cuando está más cerca")
	else:
		_fail("nearest no devolvió al jugador estando más cerca")
	# Integración: el director asigna combat_target tras unos frames.
	enemy.position = Vector3(11.0, 0.0, 0.0)
	ctrl.position  = Vector3(0.0, 0.0, 0.0)
	dagna.position = Vector3(10.0, 0.0, 0.0)
	await _wait(0.12)
	if enemy.combat_target == dagna:
		print("[TmpDagCbt] PASS el director asigna combat_target = Dagna (enemigo la engancha)")
	else:
		_fail("el enemigo no retargeteó a Dagna estando ella más cerca")
	dagna._ai_pound_cd = 0.0

	# ---- B. Pound autónomo + daño de onda (end-to-end) ----
	dagna._pound_t = 0.0
	dagna._ai_pound_cd = 0.0
	enemy.health = enemy.max_health
	_director.springboard_waves.clear()
	var h0: float = enemy.health
	var got_wave: bool = false
	var t0: int = Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 4500:
		# Fija al enemigo pegado a Dagna (dentro de POUND_SENSE) para que decida golpear.
		var ep: Vector3 = dagna.position + Vector3(2.0, 0.0, 0.0)
		if scene.has_method("get_height"):
			ep.y = scene.get_height(ep.x, ep.z)
		enemy.position = ep
		await get_tree().process_frame
		if _director.springboard_waves.size() > 0:
			got_wave = true
		if enemy.dead or enemy.health <= h0 - 1.0:
			break
	if got_wave:
		print("[TmpDagCbt] PASS Dagna lanzó su pound autónomo (onda registrada sin Bond)")
	else:
		_fail("Dagna no lanzó pound autónomo con enemigos a tiro")
	if enemy.dead or enemy.health < h0:
		print("[TmpDagCbt] PASS la onda HACE DAÑO al enemigo (%.0f → %.0f HP)" % [h0, enemy.health])
	else:
		_fail("la onda no dañó al enemigo (%.0f HP)" % enemy.health)
	await Debug.screenshot("res://test_out/dagna_combat.png")

	# ---- C. Muralla-block ----
	dagna._ai_pound_cd = 999.0   # aísla la lógica de guardia del pound
	dagna._set_guard_ai(false)
	enemy.position = dagna.position + Vector3(2.0, 0.0, 0.0)   # dentro de GUARD_BLOCK_RANGE
	dagna._update_combat_ai([enemy])
	if dagna._guard_ai_on and dagna.guard.blocking:
		print("[TmpDagCbt] PASS muralla ARRIBA con enemigo en la cara")
	else:
		_fail("Dagna no subió la muralla con un enemigo cerca")
	enemy.position = dagna.position + Vector3(6.0, 0.0, 0.0)   # fuera de rango
	dagna._update_combat_ai([enemy])
	if not dagna._guard_ai_on and not dagna.guard.blocking:
		print("[TmpDagCbt] PASS muralla ABAJO sin amenaza cerca")
	else:
		_fail("Dagna no bajó la muralla sin amenaza")

	# ---- D. Defensa propia: bloqueo reduce daño + NUNCA cae ----
	dagna._set_guard_ai(false)
	dagna.guard.balance = dagna.guard.max_balance
	dagna.health = dagna.max_health
	dagna.receive_hit(_payload(20.0, 8.0))
	var unblocked: float = dagna.max_health - dagna.health
	dagna._set_guard_ai(true)
	dagna.guard.balance = dagna.guard.max_balance
	dagna.health = dagna.max_health
	dagna.receive_hit(_payload(20.0, 8.0))
	var blocked: float = dagna.max_health - dagna.health
	if blocked < unblocked:
		print("[TmpDagCbt] PASS el bloqueo reduce el daño (%.1f vs %.1f sin bloquear)" % [blocked, unblocked])
	else:
		_fail("el bloqueo no redujo el daño (%.1f vs %.1f)" % [blocked, unblocked])
	# Martilleo brutal: NUNCA cae.
	dagna._set_guard_ai(false)
	dagna.health = 5.0
	for i in range(20):
		dagna.receive_hit(_payload(50.0, 60.0))
	if not dagna.dead and dagna.health >= dagna.HEALTH_FLOOR - 0.01:
		print("[TmpDagCbt] PASS Dagna acusa el castigo pero NO cae (%.1f HP, dead=%s)" % [dagna.health, str(dagna.dead)])
	else:
		_fail("Dagna cayó pese al piso de vida (%.1f HP, dead=%s)" % [dagna.health, str(dagna.dead)])

	_finish()

func _payload(dmg: float, bal: float) -> RefCounted:
	var p = _Payload.new()
	p.damage = dmg
	p.balance_damage = bal
	p.force = Vector3(1.0, 0.0, 0.0) * 4.0
	p.interrupt = true
	p.weapon_mass = 1.0
	return p

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
		print("[TmpDagCbt] ALL_PASS")
		get_tree().quit(0)
	else:
		print("[TmpDagCbt] FAILURES: %d" % _errors.size())
		for e in _errors:
			print("  ", e)
		get_tree().quit(1)
