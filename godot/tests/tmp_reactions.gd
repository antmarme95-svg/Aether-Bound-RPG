# tmp_reactions.gd — sonda temporal PRD-006 alcance 3: fuerza las 3
# reacciones por Equilibrio en la bestia (flinch / stagger / posture break)
# y el flinch del jugador, capturando al MIDPOINT de cada fase (Lecciones).
# Boot: --autotest=res://tests/tmp_reactions.gd -- --origin=ironblooded --cls=warrior --skip=wilds
extends Node

const _GameDirector = preload("res://core/game_director.gd")
const _Payload = preload("res://combat/hit_payload.gd")

var _director = null
var _beast = null
var _pin_pos: Vector3 = Vector3.ZERO
var _pin_facing: float = 0.0

func _ready() -> void:
	await get_tree().process_frame
	_run()

func _run() -> void:
	_director = _GameDirector.new()
	get_tree().current_scene.add_child(_director)
	_director.start()

	var elapsed := 0.0
	while elapsed < 10.0:
		if _director.controller != null and _director.controller.enemies.size() > 0 \
				and _director.hud != null and _director.hud.visible:
			break
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	var ctl = _director.controller
	if ctl == null or ctl.enemies.is_empty():
		print("[TmpReactions] FAIL: sin controller/bestias")
		get_tree().quit(1)
		return

	# Bestia frente a la cámara, desplazada lateral para no quedar tapada
	# por el jugador; zoom al mínimo (Lecciones: A/B siempre con zoom).
	var beast = ctl.enemies[0]
	var fwd := Vector3(sin(ctl.facing), 0.0, cos(ctl.facing))
	var right := Vector3(cos(ctl.facing), 0.0, -sin(ctl.facing))
	beast.position = ctl.position + fwd * 2.6 + right * 1.3
	beast.home = beast.position
	beast.health = 9999.0   # que no muera durante la sonda
	ctl.cam_dist = ctl.CAM_DIST_MIN
	# Pin: la IA aggro persigue al jugador y se esconde detrás de él —
	# para el strip se fija posición y facing EN PERFIL cada frame.
	_beast = beast
	_pin_pos = beast.position
	_pin_facing = ctl.facing + PI * 0.5
	for _i in range(5):
		await get_tree().process_frame
	await Debug.screenshot("res://test_out/react_base.png")

	# ---- 1. FLINCH: golpe leve con interrupt ----
	beast.receive_strike(_mk(4.0, 6.0, fwd * 2.0, true), ctl)
	await _wait_sec(0.10)   # midpoint de 0.25 s
	await Debug.screenshot("res://test_out/react_flinch.png")
	await _wait_sec(0.6)

	# ---- 2. STAGGER: barra al 20% y golpe ----
	beast.guard.balance = beast.guard.max_balance * 0.20
	beast.receive_strike(_mk(6.0, 8.0, fwd * 3.0, false), ctl)
	await _wait_sec(0.30)   # midpoint de 0.70 s
	await Debug.screenshot("res://test_out/react_stagger.png")
	await _wait_sec(0.9)

	# ---- 3. POSTURE BREAK: barra casi vacía y golpe ----
	beast.guard.balance = 2.0
	beast.receive_strike(_mk(8.0, 12.0, fwd * 4.0, false), ctl)
	await _wait_sec(0.30)
	await Debug.screenshot("res://test_out/react_break_early.png")
	await _wait_sec(0.5)    # ~0.8 s dentro de la ventana de 1.6 s
	await Debug.screenshot("res://test_out/react_break_mid.png")
	var punishable: bool = beast.guard.is_punishable()
	await _wait_sec(1.2)

	# ---- 4. FLINCH del jugador ----
	var back := -fwd
	ctl.receive_hit(_mk(5.0, 8.0, back * 3.0, true))
	await _wait_sec(0.08)
	await Debug.screenshot("res://test_out/react_player_flinch.png")

	print("[TmpReactions] punishable_during_break=%s guard_state_now=%s" % [punishable, beast.guard.state])
	print("[TmpReactions] DONE")
	get_tree().quit(0)

func _mk(dmg: float, bal: float, force: Vector3, interrupt: bool) -> RefCounted:
	var p = _Payload.new()
	p.damage = dmg
	p.balance_damage = bal
	p.force = force
	p.interrupt = interrupt
	p.source_mass = 1.0
	return p

func _wait_sec(s: float) -> void:
	var t := 0.0
	while t < s:
		if _beast != null:
			_beast.position.x = _pin_pos.x
			_beast.position.z = _pin_pos.z
			_beast.facing = _pin_facing
		await get_tree().process_frame
		t += get_process_delta_time()
