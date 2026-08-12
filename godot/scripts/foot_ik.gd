extends Node3D
class_name SpikeFootIK

## Spike ADR-003: foot IK stock de Godot (SkeletonIK3D, resuelve CCDIK
## internamente) sobre el mismo rig Humanoid-equivalente que en Unity.
## Se auto-configura en _ready() buscando el Skeleton3D hermano -- no
## depende de que nada externo lo llame durante la construccion de la
## escena, evita el problema de llamar start() fuera del arbol vivo.
##
## Los nombres de hueso son los de SkeletonProfileHumanoid, no los del
## rig Rigify original (`thigh.L`, `foot.L`): el importador los renombra al
## perfil al aplicar el BoneMap de retargeting.

@export var raycast_distance: float = 0.6
@export var foot_offset_y: float = 0.05
@export var thigh_left: String = "LeftUpperLeg"
@export var thigh_right: String = "RightUpperLeg"
@export var foot_left: String = "LeftFoot"
@export var foot_right: String = "RightFoot"

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

	# root_bone/tip_bone se asignan ANTES de entrar al arbol: cada setter
	# revalida la cadena, y con el otro extremo todavia sin poner la
	# validacion falla y escupe errores de motor. Fuera del arbol no corre.
	ik_left = _make_ik("IK_LeftFoot", thigh_left, foot_left, target_left)
	ik_right = _make_ik("IK_RightFoot", thigh_right, foot_right, target_right)

	ik_left.start()
	ik_right.start()

func _make_ik(ik_name: String, root_bone: String, tip_bone: String, target: Node3D) -> SkeletonIK3D:
	var ik := SkeletonIK3D.new()
	ik.name = ik_name
	ik.root_bone = root_bone
	ik.tip_bone = tip_bone
	ik.interpolation = 1.0
	skeleton.add_child(ik)
	ik.target_node = ik.get_path_to(target)
	return ik

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
	var bone_name := foot_left if target == target_left else foot_right
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
