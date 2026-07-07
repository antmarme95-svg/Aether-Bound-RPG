# tmp_timefeel.gd — sonda temporal PRD-006 alcance 4: verifica EN JUEGO
# REAL el canal temporal (Feel): hit-stop 2 f al conectar, parry = clang
# 3 f + dilation 0.2×0.35 s, trauma > 0 tras el contacto y combat heat
# (canal 3) activo. Muestrea Engine.time_scale POR FRAME (nunca por delta:
# durante el freeze delta = 0).
# Boot: --autotest=res://tests/tmp_timefeel.gd -- --origin=ironblooded --cls=warrior --skip=wilds
extends Node

const _GameDirector = preload("res://core/game_director.gd")
const _Payload = preload("res://combat/hit_payload.gd")

var _fails: int = 0

func _ready() -> void:
	await get_tree().process_frame
	_run()

func _check(cond: bool, label: String, detail: String = "") -> void:
	if cond:
		print("[TmpTimeFeel] PASS " + label)
	else:
		print("[TmpTimeFeel] FAIL " + label + (" — " + detail if detail != "" else ""))
		_fails += 1

func _run() -> void:
	var director = _GameDirector.new()
	get_tree().current_scene.add_child(director)
	director.start()

	var elapsed := 0.0
	while elapsed < 10.0:
		if director.controller != null and director.controller.enemies.size() > 0 \
				and director.hud != null and director.hud.visible:
			break
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	var ctl = director.controller
	if ctl == null or ctl.enemies.is_empty():
		print("[TmpTimeFeel] FAIL: sin controller/bestias")
		get_tree().quit(1)
		return

	# Bestia inmortal justo enfrente, dentro del arco del golpe.
	var beast = ctl.enemies[0]
	var fwd := Vector3(sin(ctl.facing), 0.0, cos(ctl.facing))
	beast.position = ctl.position + fwd * 1.8
	beast.home = beast.position
	beast.health = 9999.0
	for _i in range(5):
		await get_tree().process_frame

	# ---- 1. Golpe conectado (blade 0.9 = normal): 2 f congelados ----
	ctl.duelist_attack()
	var scales: Array = []
	var max_trauma: float = 0.0
	for _i in range(45):
		await get_tree().process_frame
		scales.append(Engine.time_scale)
		max_trauma = maxf(max_trauma, float(Feel.shake.trauma))
	var zeros: int = scales.count(0.0)
	print("[TmpTimeFeel] swing scales(45f): zeros=%d max_trauma=%.3f" % [zeros, max_trauma])
	_check(zeros == 2, "hit conectado = 2 f congelados", "zeros=%d" % zeros)
	_check(max_trauma > 0.1, "trauma aportado al conectar", "max=%.3f" % max_trauma)
	_check(ctl._combat_heat > 0.0, "combat heat activo (canal 3)")

	# dejar asentar (ventana + recovery)
	for _i in range(90):
		await get_tree().process_frame

	# ---- 2. Parry Roba: clang 3 f + dilation 0.2×0.35 s ----
	ctl.guard.try_parry()
	var p = _Payload.new()
	p.damage = 13.0
	p.balance_damage = 10.0
	p.force = -fwd * 3.0
	p.source_mass = 1.2
	p.weapon_mass = 1.2
	var res: Dictionary = ctl.receive_hit(p)
	_check(String(res.get("reaction", "")) == "parried", "el parry entra (ventana abierta)")
	# El clang se cuenta en FRAMES (así está medido B15b); la dilation se
	# mide en TIEMPO REAL — a cualquier fps (la sonda no asume 60).
	await get_tree().process_frame   # Feel aplica el freeze en su _process
	var clang: int = 0
	while Engine.time_scale == 0.0 and clang < 20:
		clang += 1
		await get_tree().process_frame
	var saw_dilation: bool = Engine.time_scale > 0.0 and Engine.time_scale < 0.5
	var t0: int = Time.get_ticks_usec()
	var guard_i: int = 0
	while Engine.time_scale < 1.0 and guard_i < 100000:
		await get_tree().process_frame
		guard_i += 1
	var dil_s: float = float(Time.get_ticks_usec() - t0) / 1000000.0
	print("[TmpTimeFeel] parry: clang=%df dilation=%.3fs (fps~%.0f)" % [clang, dil_s, Engine.get_frames_per_second()])
	_check(clang == 3, "parry = clang 3 f (B15b)", "zeros=%d" % clang)
	_check(saw_dilation, "dilation 0.2 activa tras el clang")
	_check(dil_s > 0.20 and dil_s < 0.50, "dilation dura ~0.35 s reales", "%.3fs" % dil_s)

	# ---- 3. El mundo vuelve a la normalidad ----
	for _i in range(10):
		await get_tree().process_frame
	_check(Engine.time_scale == 1.0, "time_scale vuelve a 1.0")

	if _fails == 0:
		print("[TmpTimeFeel] ALL_PASS")
		get_tree().quit(0)
	else:
		print("[TmpTimeFeel] FAILURES: %d" % _fails)
		get_tree().quit(1)
