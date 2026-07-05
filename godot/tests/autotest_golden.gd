# autotest_golden.gd — B11 golden scene A/B captures vs ratified keyframes.
# Run: godot --path godot -- --autotest=res://tests/autotest_golden.gd
# Live review: add --hold → window stays open; SPACE toggles dawn/dusk,
# F12 saves a screenshot, ESC quits. (Start-GoldenScene.bat does this.)
# Writes: test_out/golden_dawn.png + test_out/golden_dusk.png + golden_results.json
# Gate references: Aether Bound/90-Raw/concept/keyframe-wilds-{dawn,dusk}-v1.png
extends Node

const _GOLDEN := preload("res://scenes/golden_scene.gd")

var _cam: Camera3D = null
var _gs: Node3D = null
var _hold := false
var _preset := "dusk"

func _ready() -> void:
	_run.call_deferred()

func _run() -> void:
	if get_tree().current_scene != null:
		get_tree().current_scene.queue_free()
	await get_tree().process_frame

	_cam = Camera3D.new()
	_cam.fov = 62.0
	get_tree().root.add_child(_cam)
	# keyframe framing: on the trail, low, looking down the valley
	_cam.look_at_from_position(Vector3(0.0, 4.2, 27.0), Vector3(2.0, 5.0, -120.0), Vector3.UP)

	var gs = _GOLDEN.new()
	get_tree().root.add_child(gs)
	await get_tree().process_frame
	await get_tree().process_frame
	# raw shot (no post) — isolates scene content from the 4-layer pass
	gs.apply_time_preset("dawn")
	await get_tree().process_frame
	await get_tree().process_frame
	await Debug.screenshot("res://test_out/golden_dawn_raw.png")
	gs.attach_post(_cam)

	var results := {}
	for preset in ["dawn", "dusk"]:
		gs.apply_time_preset(preset)
		await get_tree().process_frame
		var fps := await _sample_fps(preset)
		await get_tree().process_frame
		await get_tree().process_frame
		await Debug.screenshot("res://test_out/golden_%s.png" % preset)
		print("[autotest_golden] shot golden_", preset, " fps=", fps)
		results[preset] = {"fps": fps}
		if fps < 60.0:
			push_warning("[autotest_golden] %s FPS below gate: %f" % [preset, fps])

	Debug.write_json("res://test_out/golden_results.json", results)
	print("[autotest_golden] done")
	if Debug.args.has("hold"):
		_gs = gs
		_hold = true
		print("[autotest_golden] HOLD mode — SPACE: dawn/dusk · F12: screenshot · ESC: salir")
		return
	get_tree().quit(0)

func _unhandled_input(event: InputEvent) -> void:
	if not _hold or not (event is InputEventKey) or not event.pressed:
		return
	if event.keycode == KEY_SPACE:
		_preset = "dawn" if _preset == "dusk" else "dusk"
		_gs.apply_time_preset(_preset)
		print("[autotest_golden] preset → ", _preset)
	elif event.keycode == KEY_ESCAPE:
		get_tree().quit(0)

func _sample_fps(label: String) -> float:
	var start := Time.get_ticks_msec()
	var samples: Array = []
	while Time.get_ticks_msec() - start < 2500:
		await get_tree().process_frame
		samples.append(Performance.get_monitor(Performance.TIME_FPS))
	var half := samples.size() / 2
	var acc := 0.0
	for i in range(half, samples.size()):
		acc += samples[i]
	var avg := acc / float(max(samples.size() - half, 1))
	print("[autotest_golden] fps[", label, "]=", avg)
	return avg
