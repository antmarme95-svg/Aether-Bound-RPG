extends SceneTree

const FootIKScript = preload("res://scripts/foot_ik.gd")
const CompanionWalkScript = preload("res://scripts/companion_walk.gd")
const AnimInstallerScript = preload("res://scripts/anim_installer.gd")
const WarriorScene = preload("res://assets/dagna/low_poly_warrior.fbx")

# El warrior solo trae 2 poses estaticas; la caminata sale del pack DoubleL
# retargeteada por el importador (BoneMap -> SkeletonProfileHumanoid, ver
# tools/make_bone_maps.gd). Con los dos esqueletos renombrados al mismo
# perfil, las pistas caen sobre los huesos de Dagna sin tocar nada mas.
# El armado del AnimationPlayer lo hace SpikeAnimInstaller en _ready().

func _initialize():
	var root := Node3D.new()
	root.name = "SpikeSlope"

	# --- Light ---
	var light := DirectionalLight3D.new()
	light.name = "DirectionalLight3D"
	light.rotation_degrees = Vector3(-45, -30, 0)
	light.shadow_enabled = true
	root.add_child(light)
	light.owner = root

	# --- Grey material shared by all greybox pieces ---
	var grey_mat := StandardMaterial3D.new()
	grey_mat.albedo_color = Color(0.55, 0.55, 0.55)

	# --- Terrain: bottom platform, ramp, top platform (same dims as Unity) ---
	var slope_root := Node3D.new()
	slope_root.name = "Slope_Root"
	root.add_child(slope_root)
	slope_root.owner = root

	_add_box(slope_root, root, "Platform_Bottom", Vector3(0, -0.5, -5), Vector3.ZERO, Vector3(6, 1, 6), grey_mat)

	# NOTA: la centerline del box de la rampa (rotado) no coincide con la
	# superficie caminable de las plataformas (planas, offset +0.5 en Y
	# mundo puro) -- el desfase geometrico dejaba un hueco real en la
	# union (confirmado visualmente, Dagna caia por ahi). Fix pragmatico
	# para un greybox: la rampa se hace mas larga de lo que "cuenta" para
	# la logica (walkable length/rise siguen siendo 20/8, iguales a
	# Unity) y ese sobrante se entierra dentro de cada plataforma en vez
	# de intentar la trigonometria exacta de un mesh de precision.
	var walkable_length := 20.0
	var ramp_rise := 8.0
	var angle_rad := atan2(ramp_rise, walkable_length)
	var angle_deg := rad_to_deg(angle_rad)
	var overlap := 3.0
	var ramp_length := walkable_length + overlap * 2.0
	var ramp_center_z := walkable_length * 0.5 * cos(angle_rad)
	var ramp_center_y := -0.5 + walkable_length * 0.5 * sin(angle_rad)
	_add_box(slope_root, root, "Ramp", Vector3(0, ramp_center_y, ramp_center_z), Vector3(-angle_deg, 0, 0), Vector3(6, 1.5, ramp_length), grey_mat)

	var top_y := -0.5 + ramp_rise
	var top_z := walkable_length * cos(angle_rad)
	_add_box(slope_root, root, "Platform_Top", Vector3(0, top_y, top_z + 5), Vector3.ZERO, Vector3(6, 1, 10), grey_mat)

	print("Slope built: length=", ramp_length, " rise=", ramp_rise, " angle=", angle_deg, " topY=", top_y, " topZ=", top_z)

	# --- Player ---
	var player := _build_character(root, "PlayerArmature", Vector3(0, 0.05, -6))

	# --- Dagna ---
	var dagna := _build_character(root, "Dagna_Placeholder", Vector3(1.5, 0.05, -6))
	dagna.set_script(CompanionWalkScript)
	dagna.set("walk_speed", 1.5)
	dagna.set("stop_distance", 1.0)
	dagna.set("gravity", -15.0)

	var target := Node3D.new()
	target.name = "TargetTop"
	target.position = Vector3(0, top_y, top_z + 5)
	root.add_child(target)
	target.owner = root
	dagna.set("target", target)

	# --- Camera, framing the whole ramp from the side ---
	var cam := Camera3D.new()
	cam.name = "Camera3D"
	var cam_pos := Vector3(12, 6, ramp_center_z)
	cam.transform = Transform3D.IDENTITY.looking_at(Vector3(0, top_y * 0.5, ramp_center_z) - cam_pos, Vector3.UP)
	cam.position = cam_pos
	root.add_child(cam)
	cam.owner = root
	cam.current = true

	var env_node := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.4, 0.55, 0.75)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.5, 0.5, 0.55)
	env.ambient_light_energy = 0.6
	env_node.environment = env
	env_node.name = "WorldEnvironment"
	root.add_child(env_node)
	env_node.owner = root

	var packed := PackedScene.new()
	packed.pack(root)
	var dir := DirAccess.open("res://")
	if not dir.dir_exists("scenes"):
		dir.make_dir("scenes")
	var err := ResourceSaver.save(packed, "res://scenes/spike_slope.tscn")
	print("Save result: ", err)

	quit()

func _add_box(parent: Node3D, owner: Node, box_name: String, pos: Vector3, rot_deg: Vector3, scale: Vector3, mat: Material) -> void:
	var body := StaticBody3D.new()
	body.name = box_name
	parent.add_child(body)
	body.owner = owner
	body.position = pos
	body.rotation_degrees = rot_deg

	var mesh_inst := MeshInstance3D.new()
	mesh_inst.name = "Mesh"
	var box_mesh := BoxMesh.new()
	box_mesh.size = scale
	mesh_inst.mesh = box_mesh
	mesh_inst.set_surface_override_material(0, mat)
	body.add_child(mesh_inst)
	mesh_inst.owner = owner

	var col := CollisionShape3D.new()
	col.name = "Collision"
	var box_shape := BoxShape3D.new()
	box_shape.size = scale
	col.shape = box_shape
	body.add_child(col)
	col.owner = owner

func _build_character(root: Node3D, char_name: String, pos: Vector3) -> CharacterBody3D:
	var body := CharacterBody3D.new()
	body.name = char_name
	root.add_child(body)
	body.owner = root
	body.position = pos

	var col := CollisionShape3D.new()
	col.name = "Collision"
	var cap := CapsuleShape3D.new()
	cap.radius = 0.28
	cap.height = 1.8
	col.shape = cap
	col.position = Vector3(0, 0.9, 0)
	body.add_child(col)
	col.owner = root

	var model: Node3D = WarriorScene.instantiate()
	model.name = "Model"
	body.add_child(model)
	# Solo el nodo raiz del modelo se apropia: el resto es contenido de la
	# instancia del FBX y se resuelve al cargar. Re-apropiar los hijos hacia
	# que PackedScene los re-declarara con `type=` ADEMAS de guardar el
	# `instance=`, y la escena cargaba con dos arboles -- uno huerfano, que
	# era justo el que encontraba SpikeFootIK (is_inside_tree()==false,
	# errores cada frame) y el que tenia la escala del FBX sin corregir.
	model.owner = root

	var anim_node := Node.new()
	anim_node.name = "SpikeAnimInstaller"
	anim_node.set_script(AnimInstallerScript)
	body.add_child(anim_node)
	anim_node.owner = root

	var ik_node := Node3D.new()
	ik_node.name = "SpikeFootIK"
	ik_node.set_script(FootIKScript)
	body.add_child(ik_node)
	ik_node.owner = root
	# No live setup here on purpose -- SpikeFootIK wires itself up in
	# _ready() when the saved scene actually runs, not during this
	# offline construction (SkeletonIK3D.start() outside a live tree
	# hangs the process).

	return body
