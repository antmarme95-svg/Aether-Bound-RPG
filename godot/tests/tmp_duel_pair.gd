# tmp_duel_pair.gd — sonda temporal PRD-006 alcance 3 paso 2: spawnea el
# par light/heavy, deja que ataquen (telegraph biomecánico) y captura:
# windup del heavy (carga de cadera legible), arcos del light, y las
# reacciones por Equilibrio en el rig humanoide.
# Boot: --autotest=res://tests/tmp_duel_pair.gd -- --origin=ironblooded --cls=warrior --skip=wilds
extends Node

const _GameDirector = preload("res://core/game_director.gd")
const _Humanoid = preload("res://gameplay/enemy_humanoid.gd")
const _Payload = preload("res://combat/hit_payload.gd")

var _director = null

func _ready() -> void:
	await get_tree().process_frame
	_run()

func _run() -> void:
	_director = _GameDirector.new()
	get_tree().current_scene.add_child(_director)
	_director.start()

	var elapsed := 0.0
	while elapsed < 10.0:
		if _director.controller != null and _director.hud != null and _director.hud.visible:
			break
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	var ctl = _director.controller
	if ctl == null:
		print("[TmpDuelPair] FAIL: sin controller")
		get_tree().quit(1)
		return

	var scene: Node3D = _director.scene
	var fwd := Vector3(sin(ctl.facing), 0.0, cos(ctl.facing))
	var right := Vector3(cos(ctl.facing), 0.0, -sin(ctl.facing))
	ctl.cam_dist = ctl.CAM_DIST_MIN

	# ---- spawn del par a la vista ----
	var light = _Humanoid.new("light", ctl.position + fwd * 5.0 - right * 1.5, scene)
	var heavy = _Humanoid.new("heavy", ctl.position + fwd * 5.0 + right * 1.5, scene)
	scene.add_child(light)
	scene.add_child(heavy)
	ctl.enemies.append(light)
	ctl.enemies.append(heavy)
	light.aggro = true
	heavy.aggro = true
	for _i in range(8):
		await get_tree().process_frame
	await Debug.screenshot("res://test_out/pair_spawn.png")

	# ---- dejar correr la IA: captura el acercamiento y el primer golpe ----
	var heavy_windup_shot := false
	var light_strike_shot := false
	var t := 0.0
	while t < 8.0 and not (heavy_windup_shot and light_strike_shot):
		if not heavy_windup_shot and heavy.state == "strike" and heavy.combat.phase() == "windup" \
				and heavy.combat.strike_k > 0.15:
			await Debug.screenshot("res://test_out/pair_heavy_windup.png")
			heavy_windup_shot = true
		if not light_strike_shot and light.state == "strike" and light.combat.phase() == "active":
			await Debug.screenshot("res://test_out/pair_light_active.png")
			light_strike_shot = true
		await get_tree().process_frame
		t += get_process_delta_time()
	print("[TmpDuelPair] heavy_windup_shot=%s light_strike_shot=%s (t=%.1f)" % [heavy_windup_shot, light_strike_shot, t])
	print("[TmpDuelPair] states: light=%s heavy=%s player_hp=%.0f" % [light.state, heavy.state, ctl.stats.health])

	# ---- reacciones por Equilibrio en el humanoide ----
	# stagger del light (postura frágil: masa 0.7 → torre baja)
	light.guard.balance = light.guard.max_balance * 0.2
	var p = _Payload.new()
	p.damage = 5.0; p.balance_damage = 9.0; p.force = fwd * 3.0
	light.receive_strike(p, ctl)
	await _wait_sec(0.25)
	await Debug.screenshot("res://test_out/pair_light_stagger.png")
	print("[TmpDuelPair] light guard.state=%s (esperado stagger)" % light.guard.state)
	await _wait_sec(0.8)

	# posture break del heavy (torre: hay que vaciarla)
	heavy.guard.balance = 2.0
	var p2 = _Payload.new()
	p2.damage = 8.0; p2.balance_damage = 14.0; p2.force = fwd * 4.0
	heavy.receive_strike(p2, ctl)
	await _wait_sec(0.5)
	await Debug.screenshot("res://test_out/pair_heavy_break.png")
	print("[TmpDuelPair] heavy guard.state=%s punishable=%s (esperado broken/true)" % [heavy.guard.state, heavy.guard.is_punishable()])

	print("[TmpDuelPair] DONE")
	get_tree().quit(0)

func _wait_sec(s: float) -> void:
	var t := 0.0
	while t < s:
		await get_tree().process_frame
		t += get_process_delta_time()
