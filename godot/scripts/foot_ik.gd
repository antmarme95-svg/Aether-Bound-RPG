extends Node3D
class_name SpikeFootIK

## Spike ADR-003: foot IK contra el terreno.
##
## Usa `SpikeTwoBoneIK` (scripts/two_bone_ik.gd), solver escrito a mano.
## NO el `TwoBoneIK3D` de fabrica: ese no produce salida en Godot 4.7.1
## -- probado en escena minima con 9 variantes de configuracion, 0 pixeles
## en las 9, contra un CONTROL que si mueve el render
## (tools/min_ik_repro.gd). El nuestro da 2730 pixeles en ese mismo banco.
##
## Sigue el criterio del [[Benchmark Biomecánico]] (§v2), fila de HZD: foot
## IK contra el terreno cada frame. Dos cosas que ese estandar exige y que
## el planteo anterior no hacia:
##   - El objetivo NO es el punto del suelo: es el punto del suelo MAS la
##     altura del tobillo sobre la planta, medida del rig en reposo. Poner
##     el tobillo en el suelo entierra el pie entero.
##   - La planta se alinea con la NORMAL del terreno, no queda horizontal.

@export var raycast_up: float = 0.7
@export var raycast_down: float = 1.4
@export var thigh_left: String = "LeftUpperLeg"
@export var shin_left: String = "LeftLowerLeg"
@export var foot_left: String = "LeftFoot"
@export var thigh_right: String = "RightUpperLeg"
@export var shin_right: String = "RightLowerLeg"
@export var foot_right: String = "RightFoot"
## Huesos que marcan la PLANTA del pie, para medir a que altura va el
## tobillo. Si no existen se cae a un valor por defecto razonable.
@export var sole_bones_left: PackedStringArray = ["heel.02.L", "LeftToes"]
@export var sole_bones_right: PackedStringArray = ["heel.02.R", "RightToes"]
@export var fallback_ankle_height: float = 0.10
## Correccion de calibracion sobre la altura de tobillo leida del rig. El
## rest pose, despues del retargeting con `fix_silhouette`, no es una pose
## de pie apoyado, asi que el numero que sale de los huesos (0.037 m) deja
## el pie hundido. Este offset se ajusta MIDIENDO con
## tools/footik_benchmark.gd hasta que la penetracion en plano de ~0.
@export var ankle_height_offset: float = 0.045

const TwoBoneIKScript = preload("res://scripts/two_bone_ik.gd")

var skeleton: Skeleton3D
var modifier: SkeletonModifier3D
var targets: Array[Node3D] = []
var ankle_heights: PackedFloat32Array = PackedFloat32Array()
var foot_bones: PackedStringArray = PackedStringArray()
var _exclude: Array[RID] = []

func _ready() -> void:
	skeleton = _find_skeleton(get_parent())
	if skeleton == null:
		push_warning("SpikeFootIK: no Skeleton3D found under parent " + str(get_parent()))
		return

	# El propio personaje es un cuerpo de colision: sin excluirlo, el rayo
	# vertical le pega a su capsula antes que al suelo.
	var body := get_parent()
	if body is CollisionObject3D:
		_exclude.append((body as CollisionObject3D).get_rid())

	modifier = TwoBoneIKScript.new()
	modifier.name = "FootTwoBoneIK"
	skeleton.add_child(modifier)

	_setup_leg(0, thigh_left, shin_left, foot_left, sole_bones_left, "IKTarget_LeftFoot")
	_setup_leg(1, thigh_right, shin_right, foot_right, sole_bones_right, "IKTarget_RightFoot")

func _setup_leg(index: int, thigh: String, shin: String, foot: String,
		sole: PackedStringArray, target_name: String) -> void:
	var target := Node3D.new()
	target.name = target_name
	add_child(target)
	targets.append(target)
	foot_bones.append(foot)
	ankle_heights.append(_rest_ankle_height(foot, sole))

	# La rodilla apunta hacia adelante del personaje. El modelo mira a +Z en
	# su propio espacio (ver build_spike_scene.gd), y el esqueleto vive
	# dentro de ese modelo, asi que aca el frente es +Z.
	modifier.add_chain(thigh, shin, foot, target, Vector3(0, 0, 1), true)

## Altura del tobillo sobre la planta, EN REPOSO. Es el numero que evita
## que el pie se entierre: el objetivo del IK es el suelo + esta altura.
func _rest_ankle_height(foot: String, sole: PackedStringArray) -> float:
	var fi := skeleton.find_bone(foot)
	if fi < 0:
		return fallback_ankle_height
	var ankle_y: float = skeleton.get_bone_global_rest(fi).origin.y
	var lowest := INF
	for b in sole:
		var i := skeleton.find_bone(b)
		if i >= 0:
			lowest = minf(lowest, skeleton.get_bone_global_rest(i).origin.y)
	if lowest == INF:
		return fallback_ankle_height
	return maxf(ankle_y - lowest, 0.01)

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
	for i in range(targets.size()):
		_place_foot(i)

func _place_foot(index: int) -> void:
	var target: Node3D = targets[index]
	var bone_idx := skeleton.find_bone(foot_bones[index])
	if bone_idx < 0:
		return

	var bone_global: Transform3D = skeleton.global_transform * skeleton.get_bone_global_pose(bone_idx)
	var origin: Vector3 = bone_global.origin + Vector3.UP * raycast_up

	var world := get_world_3d()
	if world == null:
		return
	var query := PhysicsRayQueryParameters3D.create(origin, origin + Vector3.DOWN * (raycast_up + raycast_down))
	query.exclude = _exclude
	var result := world.direct_space_state.intersect_ray(query)

	if not result:
		# Sin suelo debajo: el IK se aparta y manda la animacion.
		target.global_position = bone_global.origin
		target.global_transform.basis = bone_global.basis
		return

	var normal: Vector3 = result.normal
	# El tobillo va a la altura que tiene en reposo sobre la planta, medida
	# a lo largo de la normal del terreno.
	target.global_position = (result.position as Vector3) + normal * (ankle_heights[index] + ankle_height_offset)

	# La planta acompana la pendiente: se rota la pose del hueso llevando su
	# "arriba" a la normal del terreno, conservando el rumbo.
	var up := bone_global.basis.y
	var axis := up.cross(normal)
	if axis.length() > 0.0001:
		var angle := up.angle_to(normal)
		target.global_transform.basis = Basis(axis.normalized(), angle) * bone_global.basis
	else:
		target.global_transform.basis = bone_global.basis
