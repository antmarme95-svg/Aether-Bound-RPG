# tmp_spawnflag.gd — sonda temporal: verifica que --spawn=duelpair mete el
# par light/heavy en Wilds (boot del playtest del director, alcance 3).
# Boot: --autotest=res://tests/tmp_spawnflag.gd -- --origin=ironblooded --cls=warrior --skip=wilds --spawn=duelpair
extends Node

const _GameDirector = preload("res://core/game_director.gd")

func _ready() -> void:
	await get_tree().process_frame
	_run()

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

	var kinds := []
	for e in ctl.enemies:
		if e.get("kind") != null:
			kinds.append(e.kind)
	print("[TmpSpawnFlag] enemies=%d humanoids=%s" % [ctl.enemies.size(), str(kinds)])

	for _i in range(20):
		await get_tree().process_frame
	await Debug.screenshot("res://test_out/spawnflag_pair.png")

	if kinds.has("light") and kinds.has("heavy"):
		print("[TmpSpawnFlag] PASS")
		get_tree().quit(0)
	else:
		print("[TmpSpawnFlag] FAIL: par incompleto")
		get_tree().quit(1)
