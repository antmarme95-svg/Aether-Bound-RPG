extends SceneTree

## Escena MINIMA aislada + barrido de variantes de configuracion, para
## decidir si `TwoBoneIK3D` no aplica nunca o si le falta algun requisito.
##
## Nada de Dagna, nada de retargeting: un esqueleto de 3 huesos hecho a
## mano y un target. Por variante se guardan dos PNG (target en reposo /
## target al costado); si el par difiere, esa variante ANDA.
##
## El juez es el RENDER de una malla pesada 100% al hueso punta: es lo
## unico que no depende del bufer de poses, que devuelve la pose anterior
## a los modifiers.
##
## Uso: godot --path . --script tools/min_ik_repro.gd --resolution 400x400

const OUT := "res://test_out/minik"
const VARIANTS := [
	"base",                # tal cual lo veniamos usando
	"reset",               # + IKModifier3D.reset() despues de configurar
	"virtual_end",         # + use_virtual_end
	"extend_end",          # + extend_end_bone con largo explicito
	"no_mutable_axes",     # + mutable_bone_axes = false
	"config_antes",        # configurado ANTES de entrar al arbol
	"con_hueso_hijo",      # el hueso punta tiene un hijo (como LeftToes)
	"raiz_con_padre",      # la cadena cuelga de un hueso padre, no de la raiz
	"pose_sucia",          # se escribe la pose de un hueso CADA FRAME
	"CONTROL",             # sin IK: se rota el hueso raiz 30 grados a mano.
	                       # Si ESTO no cambia el render, el juez esta roto y
	                       # los ceros de arriba no significan nada.
]

func _initialize() -> void:
	_run()

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	for v in VARIANTS:
		await _variant(v)
	print("LISTO")
	quit(0)

func _variant(variant: String) -> void:
	var scene := Node3D.new()
	root.add_child(scene)
	await process_frame

	var skel := Skeleton3D.new()
	scene.add_child(skel)

	var tip_rest := Vector3(0, -1.0, 0)
	if variant == "raiz_con_padre":
		skel.add_bone("pelvis")
		skel.add_bone("root"); skel.add_bone("mid"); skel.add_bone("tip")
		skel.set_bone_parent(1, 0)
		skel.set_bone_parent(2, 1)
		skel.set_bone_parent(3, 2)
		skel.set_bone_rest(1, Transform3D(Basis(), Vector3(0, 0, 0)))
		skel.set_bone_rest(2, Transform3D(Basis(), Vector3(0, -0.5, 0)))
		skel.set_bone_rest(3, Transform3D(Basis(), Vector3(0, -0.5, 0)))
	else:
		skel.add_bone("root"); skel.add_bone("mid"); skel.add_bone("tip")
		skel.set_bone_parent(1, 0)
		skel.set_bone_parent(2, 1)
		skel.set_bone_rest(1, Transform3D(Basis(), Vector3(0, -0.5, 0)))
		skel.set_bone_rest(2, Transform3D(Basis(), Vector3(0, -0.5, 0)))
		if variant == "con_hueso_hijo":
			skel.add_bone("toe")
			skel.set_bone_parent(3, 2)
			skel.set_bone_rest(3, Transform3D(Basis(), Vector3(0, -0.15, 0)))
	skel.reset_bone_poses()

	var tip_idx := skel.find_bone("tip")

	var mi := MeshInstance3D.new()
	mi.mesh = _box_weighted(tip_idx, tip_rest, 0.18)
	skel.add_child(mi)
	mi.skeleton = mi.get_path_to(skel)
	mi.skin = skel.create_skin_from_rest_transforms()

	var target := Node3D.new()
	scene.add_child(target)
	target.global_position = tip_rest

	var mod := TwoBoneIK3D.new()
	if variant != "config_antes":
		skel.add_child(mod)
	mod.setting_count = 1
	mod.set_root_bone_name(0, "root")
	mod.set_middle_bone_name(0, "mid")
	mod.set_end_bone_name(0, "tip")
	mod.set_pole_direction(0, SkeletonModifier3D.SECONDARY_DIRECTION_PLUS_Z)
	if variant == "virtual_end":
		mod.set_use_virtual_end(0, true)
	if variant == "extend_end":
		mod.set_extend_end_bone(0, true)
		mod.set_end_bone_length(0, 0.15)
		mod.set_end_bone_direction(0, SkeletonModifier3D.BONE_DIRECTION_MINUS_Y)
	if variant == "no_mutable_axes":
		mod.mutable_bone_axes = false
	if variant == "config_antes":
		skel.add_child(mod)
	mod.set_target_node(0, mod.get_path_to(target))
	if variant == "reset":
		mod.reset()

	_setup_view(scene)
	await process_frame

	print("[%s] root=%d mid=%d tip=%d  target=%s" % [
		variant, mod.get_root_bone(0), mod.get_middle_bone(0), mod.get_end_bone(0),
		str(mod.get_node_or_null(mod.get_target_node(0)) != null)])

	# Hipotesis: los modifiers corren dentro del update del Skeleton3D, y el
	# esqueleto solo se actualiza si su pose CAMBIO. En una escena estatica
	# nunca se marca sucio, y el modifier no llega a ejecutarse nunca.
	var dirty := variant == "pose_sucia"
	await _shot(OUT + "/" + variant + "_a.png", skel, dirty)
	if variant == "CONTROL":
		mod.active = false
		skel.set_bone_pose_rotation(0, Quaternion(Vector3(0, 0, 1), 0.5))
	else:
		target.global_position = Vector3(0.45, -0.72, 0)
	await _shot(OUT + "/" + variant + "_b.png", skel, dirty)

	scene.queue_free()
	await process_frame

func _setup_view(scene: Node3D) -> void:
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-40, -30, 0)
	scene.add_child(light)
	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0, 0.6, 0)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(1, 1, 1)
	env.ambient_light_energy = 1.0
	env_node.environment = env
	scene.add_child(env_node)
	var cam := Camera3D.new()
	scene.add_child(cam)
	cam.current = true
	cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	cam.size = 2.2
	cam.global_position = Vector3(0, -0.6, 3)
	cam.look_at(Vector3(0, -0.6, 0), Vector3.UP)

func _shot(path: String, skel: Skeleton3D = null, dirty: bool = false) -> void:
	for i in range(8):
		if dirty and skel:
			# Un cambio minusculo pero real en la pose, para ensuciar el
			# esqueleto y forzar su update.
			skel.set_bone_pose_rotation(0, Quaternion(Vector3.UP, 0.0005 * float(i)))
		await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(path)

func _box_weighted(bone: int, center: Vector3, size: float) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var h := size * 0.5
	var c := [
		Vector3(-h, -h, -h), Vector3(h, -h, -h), Vector3(h, h, -h), Vector3(-h, h, -h),
		Vector3(-h, -h, h), Vector3(h, -h, h), Vector3(h, h, h), Vector3(-h, h, h),
	]
	var faces := [
		[0, 1, 2], [0, 2, 3], [5, 4, 7], [5, 7, 6], [4, 0, 3], [4, 3, 7],
		[1, 5, 6], [1, 6, 2], [3, 2, 6], [3, 6, 7], [4, 5, 1], [4, 1, 0],
	]
	for f in faces:
		for idx in f:
			st.set_bones([bone, 0, 0, 0])
			st.set_weights([1.0, 0.0, 0.0, 0.0])
			st.add_vertex(center + c[idx])
	st.generate_normals()
	return st.commit()
