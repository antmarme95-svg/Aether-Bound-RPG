# tmp_pressure.gd — sonda temporal PRD-006 (tuning B15g): verifica EN
# JUEGO REAL que la presión enemiga ya no se lee pasiva. Métrica objetiva
# del hallazgo "YDIF plano": durante el estado `recover` el cuerpo se
# MUEVE (circle-strafe) en vez de congelarse. Mide, por enemigo, el camino
# lateral acumulado mientras está en recover y la cadencia de golpes.
# Boot: --autotest=res://tests/tmp_pressure.gd -- --origin=ironblooded --cls=warrior --skip=wilds
extends Node

const _GameDirector = preload("res://core/game_director.gd")
const _Humanoid = preload("res://gameplay/enemy_humanoid.gd")

var _fails: int = 0

func _ready() -> void:
	await get_tree().process_frame
	_run()

func _check(cond: bool, label: String, detail: String = "") -> void:
	if cond:
		print("[TmpPressure] PASS " + label)
	else:
		print("[TmpPressure] FAIL " + label + (" — " + detail if detail != "" else ""))
		_fails += 1

func _run() -> void:
	var director = _GameDirector.new()
	get_tree().current_scene.add_child(director)
	director.start()

	var elapsed := 0.0
	while elapsed < 10.0:
		if director.controller != null and director.hud != null and director.hud.visible:
			break
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	var ctl = director.controller
	if ctl == null:
		print("[TmpPressure] FAIL: sin controller")
		get_tree().quit(1)
		return

	var scene: Node3D = director.scene
	var fwd := Vector3(sin(ctl.facing), 0.0, cos(ctl.facing))
	var right := Vector3(cos(ctl.facing), 0.0, -sin(ctl.facing))

	# Par a media distancia; jugador inmortal y pineado para medir limpio.
	var light = _Humanoid.new("light", ctl.position + fwd * 3.0 - right * 1.2, scene)
	var heavy = _Humanoid.new("heavy", ctl.position + fwd * 3.0 + right * 1.2, scene)
	scene.add_child(light)
	scene.add_child(heavy)
	ctl.enemies.append(light)
	ctl.enemies.append(heavy)
	light.aggro = true
	heavy.aggro = true
	var pin: Vector3 = ctl.position
	for _i in range(5):
		await get_tree().process_frame

	var stats := {
		light: { "path": 0.0, "recover_path": 0.0, "recover_t": 0.0, "strikes": 0 },
		heavy: { "path": 0.0, "recover_path": 0.0, "recover_t": 0.0, "strikes": 0 },
	}
	var prev := {
		light: _flat(light.position),
		heavy: _flat(heavy.position),
	}
	var prev_state := { light: light.state, heavy: heavy.state }

	var t := 0.0
	while t < 8.0:
		ctl.stats.health = 9999.0     # inmortal: la pelea no se corta
		ctl.position = pin            # jugador quieto = medición limpia
		var dt: float = get_process_delta_time()
		for e in [light, heavy]:
			if e.dead:
				continue
			var here: Vector3 = _flat(e.position)
			var d: float = here.distance_to(prev[e])
			stats[e]["path"] += d
			if e.state == "recover":
				stats[e]["recover_path"] += d
				stats[e]["recover_t"] += dt
			if e.state == "strike" and prev_state[e] != "strike":
				stats[e]["strikes"] += 1
			prev[e] = here
			prev_state[e] = e.state
		await get_tree().process_frame
		t += get_process_delta_time()

	for pair in [["light", light], ["heavy", heavy]]:
		var name: String = pair[0]
		var e = pair[1]
		var s: Dictionary = stats[e]
		print("[TmpPressure] %s: strikes=%d recover_t=%.2fs recover_path=%.2fm total_path=%.2fm" \
			% [name, s["strikes"], s["recover_t"], s["recover_path"], s["path"]])

	# El loop de combate cicla (no se plantan sin atacar).
	_check(stats[light]["strikes"] >= 2, "light ataca repetido (loop vivo)",
		"strikes=%d" % stats[light]["strikes"])
	_check(stats[heavy]["strikes"] >= 1, "heavy ataca (loop vivo)",
		"strikes=%d" % stats[heavy]["strikes"])
	# EL hallazgo B15g: durante recover el cuerpo se mueve (adiós YDIF plano).
	# Antes: recover_path ≈ 0 (set_motion(0.0) + posición congelada).
	_check(stats[light]["recover_t"] > 0.3, "light pasa por recover",
		"recover_t=%.2f" % stats[light]["recover_t"])
	_check(stats[light]["recover_path"] > 0.4, "light SE MUEVE en recover (strafe)",
		"recover_path=%.2fm" % stats[light]["recover_path"])
	_check(stats[heavy]["recover_path"] > 0.2, "heavy acecha en recover (no se planta)",
		"recover_path=%.2fm" % stats[heavy]["recover_path"])

	if _fails == 0:
		print("[TmpPressure] ALL_PASS")
		get_tree().quit(0)
	else:
		print("[TmpPressure] FAILURES: %d" % _fails)
		get_tree().quit(1)

func _flat(v: Vector3) -> Vector3:
	return Vector3(v.x, 0.0, v.z)
