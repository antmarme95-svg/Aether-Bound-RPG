## tmp_step_probe.gd — sonda temporal (A/B stepping): ¿la pose HOLDEA a 12 Hz?
## Correr (windowed): --path godot -- --autotest=res://tests/tmp_step_probe.gd
extends Node

const DT := 1.0 / 60.0

func _ready() -> void:
	await get_tree().process_frame
	if get_tree().current_scene != null:
		get_tree().current_scene.queue_free()
	await get_tree().process_frame

	for mode in [true, false]:
		var rig := CharacterRig.new()
		add_child(rig)
		rig.set_process(false)
		rig.animation_on_twos = mode
		rig.set_motion(1.0, false, false)   # sprint
		var prev: float = INF
		var holds: int = 0
		var changes: int = 0
		var vals: Array = []
		for i in range(30):
			rig._process(DT)
			var v: float = rig.legs[0].rotation.x
			vals.append("%.4f" % v)
			if prev != INF:
				if absf(v - prev) < 0.00001:
					holds += 1
				else:
					changes += 1
			prev = v
		print("[probe] on_twos=%s  holds=%d  changes=%d" % [str(mode), holds, changes])
		print("[probe]   vals: ", ", ".join(vals))
		rig.queue_free()
	print("[probe] DONE")
	get_tree().quit(0)
