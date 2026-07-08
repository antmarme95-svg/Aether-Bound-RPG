# tmp_guard.gd — sonda temporal (feedback del director 2026-07-08): confirma
# que la GUARDIA (RMB hold) ahora tiene CUERPO. Captura al jugador de frente en
# neutral vs. guardia, guardia en 3/4, y guardia + flinch (compose), más el
# reporte de constraints para verificar que la pose no viola ROM.
# Boot: --autotest=res://tests/tmp_guard.gd -- --origin=ironblooded --cls=warrior --skip=arena
extends Node

const _GameDirector = preload("res://core/game_director.gd")

var _director = null
var _ctl = null

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
	if ctl == null or ctl.rig == null:
		print("[TmpGuard] FAIL: sin controller/rig")
		get_tree().quit(1)
		return
	_ctl = ctl

	# Escenario limpio: UI fuera, bestias fuera de cuadro.
	_director.hud.visible = false
	if _director.quest_ui != null:   _director.quest_ui.visible = false
	if _director.minimap_ui != null: _director.minimap_ui.visible = false
	_park_enemies()

	# La sonda toma control TOTAL de la cámara: congelar el director (que la
	# re-sincroniza cada frame) y encuadrar de frente al jugador.
	_director.set_process(false)
	var rig = ctl.rig
	rig.set_motion(0.0, false)
	var cam: Camera3D = ctl.cam
	var fwd := Vector3(sin(ctl.facing), 0.0, cos(ctl.facing))
	var base: Vector3 = rig.global_position + Vector3(0.0, 0.95, 0.0)

	# ---- neutral (sin guardia) ----
	rig.set_guard(false)
	_place(cam, base + fwd * 3.0 + Vector3(0.0, 0.2, 0.0), base)
	await _wait_sec(0.6)
	await Debug.screenshot("res://test_out/guard_neutral.png")

	# ---- guardia sostenida (de frente) ----
	rig.set_guard(true)
	await _wait_sec(0.8)   # deja que el blend suba
	await Debug.screenshot("res://test_out/guard_on.png")
	var rep: Dictionary = rig.constraint_report() if rig.has_method("constraint_report") else {}
	print("[TmpGuard] constraint_report (guardia): ", rep)

	# ---- parry deflect flick (Capa 2): batazo (de frente) ----
	# Nota: con pose en 2s (~12 Hz) hay que dejar pasar al menos un tick de pose
	# tras play_parry para que el batazo se muestre; 0.12 s < 0.30 s de dur, así
	# que _parry_t sigue alto (s≈0.8, batazo fuerte).
	rig.play_parry()
	await _wait_sec(0.12)
	await Debug.screenshot("res://test_out/guard_parry.png")
	await _wait_sec(0.4)    # deja recular a la guardia antes del 3/4

	# ---- guardia en 3/4 (silueta) ----
	var q := Vector3(sin(ctl.facing + 0.7), 0.0, cos(ctl.facing + 0.7))
	_place(cam, base + q * 3.0 + Vector3(0.0, 0.25, 0.0), base)
	await _wait_sec(0.4)
	await Debug.screenshot("res://test_out/guard_on_34.png")

	# ---- guardia + flinch: el cuerpo acusa el golpe SIN bajar la guardia ----
	rig.play_flinch(1.0)
	await _wait_sec(0.12)
	await Debug.screenshot("res://test_out/guard_flinch.png")

	print("[TmpGuard] DONE (rev neutral/on/parry/34/flinch)")
	get_tree().quit(0)

func _place(cam: Camera3D, eye: Vector3, center: Vector3) -> void:
	cam.global_position = eye
	cam.look_at(center)

func _park_enemies() -> void:
	if _ctl == null:
		return
	for e in _ctl.enemies:
		if is_instance_valid(e):
			e.visible = false
			e.position = _ctl.position + Vector3(400.0, 0.0, 400.0)

func _wait_sec(s: float) -> void:
	var t := 0.0
	while t < s:
		_park_enemies()
		await get_tree().process_frame
		t += get_process_delta_time()
