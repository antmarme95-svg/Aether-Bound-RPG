extends SceneTree

## Temporal (spike ADR-003): corre la escena unos segundos, mide que las
## piernas de Dagna se muevan de verdad (no solo el CharacterBody) y saca
## capturas. Se borra antes del commit final.

const SHOTS := [1.5, 3.0, 4.5, 6.0]
const OUT_DIR := "res://test_out"

func _initialize() -> void:
	change_scene_to_file("res://scenes/spike_slope.tscn")
	_run()

func _run() -> void:
	await process_frame
	await process_frame

	var dagna: Node3D = root.find_child("Dagna_Placeholder", true, false)
	if dagna == null:
		printerr("no se encontro Dagna_Placeholder")
		quit(1)
		return

	var skel: Skeleton3D = _find_skeleton(dagna)
	var anim: AnimationPlayer = _find_ap(dagna)
	print("Skeleton: ", skel, "  huesos=", (skel.get_bone_count() if skel else -1))
	print("AnimationPlayer: ", anim, "  anims=", (anim.get_animation_list() if anim else []))
	if anim != null:
		print("  root_node=", anim.root_node)

	var thigh := skel.find_bone("LeftUpperLeg") if skel else -1
	var shin := skel.find_bone("LeftLowerLeg") if skel else -1
	print("  LeftUpperLeg idx=", thigh, "  LeftLowerLeg idx=", shin)

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))

	# La camara de la escena encuadra la rampa entera y deja a Dagna del
	# tamano de una hormiga -- inutil para juzgar la caminata. Se agrega una
	# camara de verificacion que la sigue de costado.
	var cam := Camera3D.new()
	cam.name = "VerifyCam"
	root.add_child(cam)
	cam.current = true

	var samples: Array = []
	var elapsed := 0.0
	var next_shot := 0
	while elapsed < 6.5:
		await process_frame
		elapsed += root.get_process_delta_time()
		var focus: Vector3 = dagna.global_position + Vector3(0, 0.9, 0)
		cam.global_position = focus + Vector3(3.2, 0.4, 0.6)
		cam.look_at(focus, Vector3.UP)
		if thigh >= 0:
			var q: Quaternion = skel.get_bone_pose_rotation(thigh)
			samples.append(q)
		if next_shot < SHOTS.size() and elapsed >= SHOTS[next_shot]:
			await RenderingServer.frame_post_draw
			var img: Image = root.get_texture().get_image()
			var path := OUT_DIR + "/godot_walk_%.1fs.png" % SHOTS[next_shot]
			img.save_png(path)
			print("  captura ", path, "  Dagna en ", dagna.global_position, "  anim=", (anim.current_animation if anim else "-"))
			next_shot += 1

	# La prueba dura: si el hueso del muslo nunca cambia de rotacion, lo que
	# hay es traslacion, no caminata.
	var max_delta := 0.0
	if samples.size() > 1:
		var first: Quaternion = samples[0]
		for q in samples:
			max_delta = max(max_delta, rad_to_deg(first.angle_to(q)))
	print("\nRotacion max del muslo izquierdo respecto del primer frame: %.2f grados (%d muestras)" % [max_delta, samples.size()])
	if max_delta < 5.0:
		printerr("FALLA: el muslo no se mueve -- no hay ciclo de caminata real")
		quit(1)
	else:
		print("OK: hay ciclo de piernas real")
	quit(0)

func _find_skeleton(n: Node) -> Skeleton3D:
	if n is Skeleton3D:
		return n
	for c in n.get_children():
		var f := _find_skeleton(c)
		if f:
			return f
	return null

func _find_ap(n: Node) -> AnimationPlayer:
	if n is AnimationPlayer:
		return n
	for c in n.get_children():
		var f := _find_ap(c)
		if f:
			return f
	return null
