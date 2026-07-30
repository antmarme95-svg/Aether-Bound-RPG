extends Node

# Beckett live launcher for the golden scene (Fase A: shader iteration).
# Builds camera + golden_scene + post as children of /root and HOLDS OPEN
# (no quit) so Beckett can screenshot the live frame while I tweak the
# melancolia_post shader / core material and re-play. Preset (dawn|dusk) comes
# from a project setting so I can flip it via set_project_setting without an edit.
# Session scaffolding — cleaned up at window close (see plan Cierre).

const _GOLDEN := preload("res://scenes/golden_scene.gd")

func _ready() -> void:
	_build.call_deferred()

func _build() -> void:
	var cam := Camera3D.new()
	cam.fov = 62.0
	get_tree().root.add_child(cam)
	cam.make_current()
	# keyframe framing: on the trail, low, looking down the valley (mirrors autotest_golden)
	cam.look_at_from_position(Vector3(0.0, 4.2, 27.0), Vector3(2.0, 5.0, -120.0), Vector3.UP)
	var gs = _GOLDEN.new()
	get_tree().root.add_child(gs)
	await get_tree().process_frame
	await get_tree().process_frame
	var preset := str(ProjectSettings.get_setting("beckett/golden_preset", "dawn"))
	var nopost := bool(ProjectSettings.get_setting("beckett/golden_nopost", false))
	if not nopost:
		gs.attach_post(cam)
	gs.apply_time_preset(preset)
	print("[GoldenBoot] holding open, preset=", preset, " nopost=", nopost)
