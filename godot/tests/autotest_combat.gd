# autotest_combat.gd — PRD-006 alcance 5: gate automatizado del combate en el
# greybox. Cierra PRD-006 y abre el Gate 1.
#
# Verifica, en juego real (windowed — usa los autoloads Feel/EventBus vivos):
#   1. Boot directo al greybox (--skip=arena).
#   2. Spawn PARAMETRIZABLE: --spawn=light,heavy → 2 hostiles con esos kinds.
#   3. Parry Roba end-to-end: golpe del light → parry → light stunned.
#   4. Kill loop con el kit Duelist real (duelist_attack) → ambos muertos.
#   5. Muestra de FPS (gate ≥60 en corrida fría; ver Lecciones sobre térmica).
#
# Launch:
#   godot --path godot -- --autotest=res://tests/autotest_combat.gd
extends Node

var _errors: Array          = []
var _director: GameDirector = null
var _fps: float             = 0.0

# ================================================================
func _ready() -> void:
	# HERMÉTICO: purga el save de una corrida previa.
	var save_abs: String = ProjectSettings.globalize_path("user://borisawa_save.json")
	if FileAccess.file_exists("user://borisawa_save.json"):
		DirAccess.remove_absolute(save_abs)

	# Boot melee (kit Duelist) directo al greybox con spec parametrizada.
	Debug.args["origin"] = "ironblooded"
	Debug.args["cls"]    = "warrior"
	Debug.args["name"]   = "Boris"
	Debug.args["skip"]   = "arena"
	Debug.args["spawn"]  = "light,heavy"

	await get_tree().process_frame
	_run()

# ================================================================
func _until(fn: Callable, timeout_sec: float, label: String) -> bool:
	var elapsed: float = 0.0
	while elapsed < timeout_sec:
		if fn.call():
			return true
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	_errors.append("FAIL %s (timed out after %.1fs)" % [label, timeout_sec])
	return false

# "down" = fuera de combate: muerto O ya agonizando (health ≤0, state=="dying").
# Clave: seguir golpeando a un enemigo agonizante re-resetea su timer de muerte
# (receive_strike vuelve a la rama health<=0 y pone state_t=0) → nunca muere.
func _down(n) -> bool:
	return n.dead or n.state == "dying"

func _all_down(nodes: Array) -> bool:
	for n in nodes:
		if not _down(n):
			return false
	return true

func _all_dead(nodes: Array) -> bool:
	for n in nodes:
		if not n.dead:
			return false
	return true

func _nearest_alive(nodes: Array):
	var best = null
	var best_d: float = INF
	for n in nodes:
		if _down(n):
			continue
		var d: float = n.position.distance_to(_director.controller.position)
		if d < best_d:
			best_d = d
			best = n
	return best

func _assert_true(condition: bool, label: String) -> void:
	if not condition:
		_errors.append("FAIL %s" % label)
	else:
		print("[AutotestCombat] PASS %s" % label)

# ================================================================
func _run() -> void:
	_director = GameDirector.new()
	get_tree().current_scene.add_child(_director)
	_director.start()

	# ---- 1. ARENA ----
	var arena_ok: bool = await _until(
		func() -> bool: return _director.fsm.current_id == "ARENA",
		3.0, "boot→ARENA")
	if not arena_ok:
		_finish()
		return
	print("[AutotestCombat] PASS boot→ARENA")

	# ---- 2. Spawn parametrizable ----
	var enemies: Array = _director.enemies
	_assert_true(enemies.size() == 2, "spawn count == 2 (--spawn=light,heavy)")
	var kinds: Array = []
	for e in enemies:
		kinds.append(e.get("kind"))
	_assert_true(kinds.has("light") and kinds.has("heavy"),
		"spawn kinds == [light, heavy] (got %s)" % str(kinds))

	if enemies.size() < 2:
		_finish()
		return

	# Evidencia visual del greybox (blockout + par frente al jugador).
	for _i in range(6):
		await get_tree().process_frame
	await Debug.screenshot("res://test_out/combat_arena.png")

	# Identifica light/heavy por kind (el orden lo fija spawn_spec).
	var light = enemies[0] if enemies[0].kind == "light" else enemies[1]
	var heavy = enemies[1] if light == enemies[0] else enemies[0]

	# ---- 3. Parry Roba end-to-end ----
	light.aggro = true
	var parried: bool = await _until(
		func() -> bool:
			# Mantén al jugador pegado y la ventana de parry abierta hasta que
			# el light suelte el golpe y se lo roben.
			var to: Vector3 = light.position - _director.controller.position
			to.y = 0.0
			if to.length() > 1.6:
				_director.controller.position = light.position - to.normalized() * 1.4
			_director.controller.facing = atan2(to.x, to.z)
			if _director.controller.guard != null:
				_director.controller.guard.try_parry()
			return light._stun_t > 0.0 or light.state == "stunned",
		6.0, "light parried → stunned")
	_assert_true(parried, "parry Roba stuns the light")

	# ---- 4. Kill loop con el kit Duelist real ----
	# El arco (110°) + soft-aim reparten el golpe entre ambos, así que se matan
	# en un solo loop. Reposiciono al jugador CADA frame pegado al más cercano:
	# la fase `active` cae ~0.3 s después del input y el enemigo se mueve, así
	# que pinnear solo al arrancar el swing hace fallar la mitad de los golpes.
	# Acotado por TIEMPO REAL (no frames): la IA/combate corre en dt real, así
	# que un cap de frames es dependiente del FPS (a 900 fps, 1800 frames = 2 s
	# y el heavy no alcanza a morir). 20 s reales = ~4× margen sobre lo medido.
	var targets := [light, heavy]
	var elapsed: float = 0.0
	while not _all_down(targets) and elapsed < 20.0:
		var e = _nearest_alive(targets)
		if e != null:
			var to: Vector3 = e.position - _director.controller.position
			to.y = 0.0
			if to.length() > 0.001:
				_director.controller.position = e.position - to.normalized() * 1.5
				_director.controller.facing = atan2(to.x, to.z)
			_director.stats.stamina = _director.stats.max_stamina
			# Cada frame: el kit bufferea la cadena (combo ×4). El heavy tiene
			# torre de Equilibrio (mass 1.8) — un poke suelto solo hace chip; se
			# mata ENCADENANDO para romperle la postura (§B.3).
			_director.controller.duelist_attack()
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	# Ambos en "dying"; se dejó de golpear (si no, el timer de muerte se resetea).
	# Espera a que la animación de muerte resuelva (~0.8 s → dead=true).
	var all_ok: bool = await _until(
		func() -> bool: return _all_dead(targets), 3.0, "dying resuelve")
	_assert_true(all_ok, "both hostiles killed via duelist kit (%.1fs)" % elapsed)
	_assert_true(light.dead, "light dead")
	_assert_true(heavy.dead, "heavy dead")

	# ---- 5. FPS ----
	# Deja correr unos frames para estabilizar la media del motor.
	for _i in range(40):
		await get_tree().process_frame
	_fps = Engine.get_frames_per_second()
	# Piso CATASTRÓFICO solamente: dentro de un autotest windowed el contador
	# refleja el ritmo del propio polling + estado térmico (Lecciones: FPS
	# relativo a la térmica). El gate real ≥60 se lee en corrida FRÍA aparte.
	_assert_true(_fps >= 25.0, "FPS no colapsado (got %.0f; gate ≥60 se mide en frío)" % _fps)

	_finish()

# ================================================================
func _finish() -> void:
	var kills: int = 0
	for e in _director.enemies:
		if e.dead:
			kills += 1
	var spawn_kinds: Array = []
	for e in _director.enemies:
		spawn_kinds.append(e.get("kind"))

	var report: Dictionary = {
		"arena_reached": _director.fsm.current_id == "ARENA",
		"spawn_kinds":   spawn_kinds,
		"spawned_count": _director.enemies.size(),
		"kills":         kills,
		"fps":           _fps,
		"fsm_states_visited": _director.fsm_states_visited,
		"errors":        _errors,
	}
	Debug.write_json("res://test_out/combat_report.json", report)

	print("[AutotestCombat] spawn=", spawn_kinds, " kills=", kills,
		  " fps=", int(_fps), " errors=", _errors.size())

	if _errors.size() == 0:
		print("[AutotestCombat] ALL_PASS")
		get_tree().quit(0)
	else:
		print("[AutotestCombat] FAILURES: %d" % _errors.size())
		for err in _errors:
			print("  ", err)
		get_tree().quit(1)
