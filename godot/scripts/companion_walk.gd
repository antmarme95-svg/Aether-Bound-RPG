extends CharacterBody3D
class_name SpikeCompanionWalk

## Spike ADR-003: mueve a Dagna hacia un punto fijo para observar el
## foot IK en la pendiente. La traslacion la hace este script; el ciclo de
## piernas viene de una animacion real retargeteada con la herramienta
## stock de Godot (BoneMap + SkeletonProfileHumanoid, ver
## tools/make_bone_maps.gd) desde el pack DoubleL. El FBX del warrior solo
## trae 2 poses estaticas, de ahi el retargeting.

@export var walk_speed: float = 1.5
@export var stop_distance: float = 1.0
@export var gravity: float = -15.0
@export var target_name: String = "TargetTop"
@export var walk_anim: String = "walk"
@export var idle_anim: String = "idle"

var target: Node3D
var vertical_velocity: float = 0.0
var anim: AnimationPlayer
var current_anim: String = ""

func _ready() -> void:
	# Autonomo: busca su target por nombre en vez de depender de que algo
	# externo lo asigne -- una var no-@export asignada durante la
	# construccion de la escena no sobrevive el guardado a .tscn.
	if target == null:
		target = get_tree().root.find_child(target_name, true, false)
		if target == null:
			push_warning("SpikeCompanionWalk: target node '" + target_name + "' not found")

	# Mismo criterio que SpikeFootIK: el nodo se cablea solo buscando hacia
	# abajo, sin depender de una NodePath guardada en la escena.
	anim = _find_animation_player(self)
	if anim == null:
		push_warning("SpikeCompanionWalk: no AnimationPlayer under " + str(name))

func _find_animation_player(node: Node) -> AnimationPlayer:
	for child in node.get_children():
		if child is AnimationPlayer:
			return child
		var found := _find_animation_player(child)
		if found:
			return found
	return null

func _play(anim_name: String) -> void:
	if anim == null or anim_name == current_anim:
		return
	if not anim.has_animation(anim_name):
		return
	anim.play(anim_name)
	current_anim = anim_name

func _physics_process(delta: float) -> void:
	var speed := 0.0

	if target != null:
		var to_target: Vector3 = target.global_position - global_position
		to_target.y = 0.0
		var distance := to_target.length()

		if distance > stop_distance:
			var dir := to_target.normalized()
			var target_basis := Basis.looking_at(dir, Vector3.UP)
			global_transform.basis = global_transform.basis.slerp(target_basis, delta * 5.0)
			speed = walk_speed

	_play(walk_anim if speed > 0.0 else idle_anim)

	if is_on_floor():
		vertical_velocity = -2.0
	else:
		vertical_velocity += gravity * delta
		vertical_velocity = max(vertical_velocity, -20.0)

	var forward: Vector3 = -global_transform.basis.z
	velocity = forward * speed + Vector3.UP * vertical_velocity
	move_and_slide()

	if global_position.y < -20.0:
		global_position = Vector3(global_position.x, 0.5, global_position.z)
		vertical_velocity = 0.0
