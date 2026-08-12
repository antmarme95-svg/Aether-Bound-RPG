extends Node3D
class_name SpikeFootIK

## Spike ADR-003: foot IK stock de Godot (SkeletonIK3D, resuelve CCDIK
## internamente) sobre el mismo rig Humanoid-equivalente que en Unity.
## Se auto-configura en _ready() buscando el Skeleton3D hermano -- no
## depende de que nada externo lo llame durante la construccion de la
## escena, evita el problema de llamar start() fuera del arbol vivo.

@export var raycast_distance: float = 0.6
@export var foot_offset_y: float = 0.05

var skeleton: Skeleton3D
var ik_left: SkeletonIK3D
var ik_right: SkeletonIK3D
var target_left: Node3D
var target_right: Node3D

func _ready() -> void:
	skeleton = _find_skeleton(get_parent())
	if skeleton == null:
		push_warning("SpikeFootIK: no Skeleton3D found under parent " + str(get_parent()))
		return

	target_left = Node3D.new()
	target_left.name = "IKTarget_LeftFoot"
	add_child(target_left)

	target_right = Node3D.new()
	target_right.name = "IKTarget_RightFoot"
	add_child(target_right)

	ik_left = SkeletonIK3D.new()
	ik_left.name = "IK_LeftFoot"
	skeleton.add_child(ik_left)
	ik_left.root_bone = "thigh.L"
	ik_left.tip_bone = "foot.L"
	ik_left.target_node = ik_left.get_path_to(target_left)
	ik_left.interpolation = 1.0

	ik_right = SkeletonIK3D.new()
	ik_right.name = "IK_RightFoot"
	skeleton.add_child(ik_right)
	ik_right.root_bone = "thigh.R"
	ik_right.tip_bone = "foot.R"
	ik_right.target_node = ik_right.get_path_to(target_right)
	ik_right.interpolation = 1.0

	ik_left.start()
	ik_right.start()

func _find_skeleton(node: Node) -> Skeleton3D:
	if node == null:
		return null
	for child in node.get_children():
		if child is Skeleton3D:
			return child
		var found := _find_skeleton(child)
		if found:
			return found
	return null

func _physics_process(_delta: float) -> void:
	if skeleton == null:
		return
	_place_foot(target_left)
	_place_foot(target_right)

func _place_foot(target: Node3D) -> void:
	if target == null:
		return
	var bone_name := "foot.L" if target == target_left else "foot.R"
	var bone_idx := skeleton.find_bone(bone_name)
	if bone_idx < 0:
		return
	var bone_global: Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(bone_idx)
	var origin: Vector3 = bone_global.origin + Vector3.UP * raycast_distance

	var world := get_world_3d()
	if world == null:
		return
	var space_state := world.direct_space_state
	var query := PhysicsRayQueryParameters3D.create(origin, origin + Vector3.DOWN * raycast_distance * 2.0)
	var result := space_state.intersect_ray(query)

	if result:
		target.global_position = result.position + Vector3.UP * foot_offset_y
		var normal: Vector3 = result.normal
		var up := Vector3.UP
		var axis := up.cross(normal)
		if axis.length() > 0.001:
			var angle := up.angle_to(normal)
			target.global_transform.basis = Basis(axis.normalized(), angle)
		else:
			target.global_transform.basis = Basis.IDENTITY
	else:
		target.global_position = bone_global.origin
