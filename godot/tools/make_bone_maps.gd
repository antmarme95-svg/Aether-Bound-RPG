extends SceneTree

## Spike ADR-003: genera los dos BoneMap de retargeting contra
## SkeletonProfileHumanoid -- uno para el rig Rigify de Dagna (198 huesos,
## nombres tipo `thigh.L`) y otro para el rig del pack de animacion DoubleL
## (70 huesos, nombres tipo `Left_UpperLeg`). Con los dos esqueletos
## renombrados al mismo perfil, el ciclo de caminata del pack se reproduce
## sobre Dagna sin escribir un solo solver -- retargeting stock del
## importador de Godot.
##
## Se corre una sola vez; los .tres resultantes se versionan.

const OUT_DAGNA := "res://assets/bonemap_dagna_rigify.tres"
const OUT_ANIM := "res://assets/bonemap_doublel.tres"

# Rigify (metarig humano). La cadena `spine`..`spine.006` es el torso:
# spine = caderas, .004/.005 = cuello, .006 = cabeza.
const DAGNA := {
	"Hips": "spine",
	"Spine": "spine.001",
	"Chest": "spine.002",
	"UpperChest": "spine.003",
	"Neck": "spine.004",
	"Head": "spine.006",
	"LeftEye": "eye.L",
	"RightEye": "eye.R",
	"Jaw": "jaw",
	"LeftShoulder": "shoulder.L",
	"LeftUpperArm": "upper_arm.L",
	"LeftLowerArm": "forearm.L",
	"LeftHand": "hand.L",
	"LeftThumbMetacarpal": "thumb.01.L",
	"LeftThumbProximal": "thumb.02.L",
	"LeftThumbDistal": "thumb.03.L",
	"LeftIndexProximal": "f_index.01.L",
	"LeftIndexIntermediate": "f_index.02.L",
	"LeftIndexDistal": "f_index.03.L",
	"LeftMiddleProximal": "f_middle.01.L",
	"LeftMiddleIntermediate": "f_middle.02.L",
	"LeftMiddleDistal": "f_middle.03.L",
	"LeftRingProximal": "f_ring.01.L",
	"LeftRingIntermediate": "f_ring.02.L",
	"LeftRingDistal": "f_ring.03.L",
	"LeftLittleProximal": "f_pinky.01.L",
	"LeftLittleIntermediate": "f_pinky.02.L",
	"LeftLittleDistal": "f_pinky.03.L",
	"RightShoulder": "shoulder.R",
	"RightUpperArm": "upper_arm.R",
	"RightLowerArm": "forearm.R",
	"RightHand": "hand.R",
	"RightThumbMetacarpal": "thumb.01.R",
	"RightThumbProximal": "thumb.02.R",
	"RightThumbDistal": "thumb.03.R",
	"RightIndexProximal": "f_index.01.R",
	"RightIndexIntermediate": "f_index.02.R",
	"RightIndexDistal": "f_index.03.R",
	"RightMiddleProximal": "f_middle.01.R",
	"RightMiddleIntermediate": "f_middle.02.R",
	"RightMiddleDistal": "f_middle.03.R",
	"RightRingProximal": "f_ring.01.R",
	"RightRingIntermediate": "f_ring.02.R",
	"RightRingDistal": "f_ring.03.R",
	"RightLittleProximal": "f_pinky.01.R",
	"RightLittleIntermediate": "f_pinky.02.R",
	"RightLittleDistal": "f_pinky.03.R",
	"LeftUpperLeg": "thigh.L",
	"LeftLowerLeg": "shin.L",
	"LeftFoot": "foot.L",
	"LeftToes": "toe.L",
	"RightUpperLeg": "thigh.R",
	"RightLowerLeg": "shin.R",
	"RightFoot": "foot.R",
	"RightToes": "toe.R",
}

# DoubleL: nombres estilo Unity Humanoid. El pulgar de Unity
# (Proximal/Intermediate/Distal) corre un eslabon corrido respecto del perfil
# de Godot (Metacarpal/Proximal/Distal), y su meñique se llama Pinky.
const ANIM := {
	"Hips": "Hips",
	"Spine": "Spine",
	"Chest": "Chest",
	"UpperChest": "UpperChest",
	"Neck": "Neck",
	"Head": "Head",
	"LeftEye": "Left_Eye",
	"RightEye": "Right_Eye",
	"Jaw": "Jaw",
	"LeftShoulder": "Left_Shoulder",
	"LeftUpperArm": "Left_UpperArm",
	"LeftLowerArm": "Left_LowerArm",
	"LeftHand": "Left_Hand",
	"LeftThumbMetacarpal": "Left_ThumbProximal",
	"LeftThumbProximal": "Left_ThumbIntermediate",
	"LeftThumbDistal": "Left_ThumbDistal",
	"LeftIndexProximal": "Left_IndexProximal",
	"LeftIndexIntermediate": "Left_IndexIntermediate",
	"LeftIndexDistal": "Left_IndexDistal",
	"LeftMiddleProximal": "Left_MiddleProximal",
	"LeftMiddleIntermediate": "Left_MiddleIntermediate",
	"LeftMiddleDistal": "Left_MiddleDistal",
	"LeftRingProximal": "Left_RingProximal",
	"LeftRingIntermediate": "Left_RingIntermediate",
	"LeftRingDistal": "Left_RingDistal",
	"LeftLittleProximal": "Left_PinkyProximal",
	"LeftLittleIntermediate": "Left_PinkyIntermediate",
	"LeftLittleDistal": "Left_PinkyDistal",
	"RightShoulder": "Right_Shoulder",
	"RightUpperArm": "Right_UpperArm",
	"RightLowerArm": "Right_LowerArm",
	"RightHand": "Right_Hand",
	"RightThumbMetacarpal": "Right_ThumbProximal",
	"RightThumbProximal": "Right_ThumbIntermediate",
	"RightThumbDistal": "Right_ThumbDistal",
	"RightIndexProximal": "Right_IndexProximal",
	"RightIndexIntermediate": "Right_IndexIntermediate",
	"RightIndexDistal": "Right_IndexDistal",
	"RightMiddleProximal": "Right_MiddleProximal",
	"RightMiddleIntermediate": "Right_MiddleIntermediate",
	"RightMiddleDistal": "Right_MiddleDistal",
	"RightRingProximal": "Right_RingProximal",
	"RightRingIntermediate": "Right_RingIntermediate",
	"RightRingDistal": "Right_RingDistal",
	"RightLittleProximal": "Right_PinkyProximal",
	"RightLittleIntermediate": "Right_PinkyIntermediate",
	"RightLittleDistal": "Right_PinkyDistal",
	"LeftUpperLeg": "Left_UpperLeg",
	"LeftLowerLeg": "Left_LowerLeg",
	"LeftFoot": "Left_Foot",
	"LeftToes": "Left_Toes",
	"RightUpperLeg": "Right_UpperLeg",
	"RightLowerLeg": "Right_LowerLeg",
	"RightFoot": "Right_Foot",
	"RightToes": "Right_Toes",
}

func _initialize():
	_build(DAGNA, "res://assets/dagna/low_poly_warrior.fbx", OUT_DAGNA, "Dagna (Rigify)")
	_build(ANIM, "res://assets/anim/walk_doublel.fbx", OUT_ANIM, "DoubleL (walk)")
	quit()

func _build(mapping: Dictionary, fbx_path: String, out_path: String, label: String) -> void:
	print("\n--- ", label, " ---")

	# Verificacion contra los huesos reales del FBX: un typo en el diccionario
	# se convierte silenciosamente en un hueso sin mapear, y eso se ve recien
	# al final como una animacion rota. Se chequea aca.
	var actual := _bone_names(fbx_path)
	var missing: Array = []
	for profile_bone in mapping:
		if not actual.has(mapping[profile_bone]):
			missing.append(profile_bone + " -> " + mapping[profile_bone])
	if missing.size() > 0:
		printerr("  HUESOS NO ENCONTRADOS EN EL FBX (", missing.size(), "):")
		for m in missing:
			printerr("    ", m)
	else:
		print("  los ", mapping.size(), " huesos mapeados existen en el FBX")

	var profile := SkeletonProfileHumanoid.new()
	var bm := BoneMap.new()
	bm.profile = profile
	var mapped := 0
	for i in range(profile.bone_size):
		var profile_bone := profile.get_bone_name(i)
		if mapping.has(profile_bone):
			bm.set_skeleton_bone_name(profile_bone, mapping[profile_bone])
			mapped += 1
		else:
			print("  (sin mapear: ", profile_bone, ")")
	var err := ResourceSaver.save(bm, out_path)
	print("  ", mapped, "/", profile.bone_size, " slots mapeados -> ", out_path, " (err=", err, ")")

func _bone_names(fbx_path: String) -> Dictionary:
	var names := {}
	if not ResourceLoader.exists(fbx_path):
		printerr("  no existe: ", fbx_path)
		return names
	var inst: Node = (load(fbx_path) as PackedScene).instantiate()
	var skel := _find_skeleton(inst)
	if skel != null:
		for i in range(skel.get_bone_count()):
			names[skel.get_bone_name(i)] = true
	inst.free()
	return names

func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for c in node.get_children():
		var f := _find_skeleton(c)
		if f:
			return f
	return null
