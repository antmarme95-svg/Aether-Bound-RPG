# tmp_vignette.gd — sonda temporal B15e: dispara combat:playerHit y captura
# el decay del vignette de daño (t=0, ~0.1s, ~0.25s, ~0.5s).
# Boot: --autotest=res://tests/tmp_vignette.gd -- --origin=ironblooded --cls=warrior --skip=wilds
extends Node

const _GameDirector = preload("res://core/game_director.gd")

var _director = null

func _ready() -> void:
	await get_tree().process_frame
	_run()

func _run() -> void:
	_director = _GameDirector.new()
	get_tree().current_scene.add_child(_director)
	_director.start()

	# esperar FREE_ROAM/WILDS con HUD visible
	var elapsed := 0.0
	while elapsed < 10.0:
		if _director.hud != null and _director.hud.visible:
			break
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	if _director.hud == null or not _director.hud.visible:
		print("[TmpVignette] FAIL: HUD nunca visible")
		get_tree().quit(1)
		return

	for _i in range(5):
		await get_tree().process_frame

	EventBus.emit_event("combat:playerHit", {})
	await get_tree().process_frame
	await Debug.screenshot("res://test_out/vignette_t000.png")
	await _wait_sec(0.10)
	await Debug.screenshot("res://test_out/vignette_t010.png")
	await _wait_sec(0.15)
	await Debug.screenshot("res://test_out/vignette_t025.png")
	await _wait_sec(0.25)
	await Debug.screenshot("res://test_out/vignette_t050.png")
	print("[TmpVignette] DONE")
	get_tree().quit(0)

func _wait_sec(s: float) -> void:
	var t := 0.0
	while t < s:
		await get_tree().process_frame
		t += get_process_delta_time()
