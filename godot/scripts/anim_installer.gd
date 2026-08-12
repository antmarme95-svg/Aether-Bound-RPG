extends Node
class_name SpikeAnimInstaller

## Spike ADR-003: instala en tiempo de ejecucion las animaciones del
## personaje -- "idle" (una de las 2 poses estaticas que trae el FBX del
## warrior) y "walk" (ciclo real, del pack DoubleL, retargeteado por el
## importador de Godot via BoneMap + SkeletonProfileHumanoid; ver
## tools/make_bone_maps.gd).
##
## Se hace en _ready() y no al construir la escena a proposito: con el
## modelo guardado como instancia del FBX, cualquier animacion que le
## metamos al AnimationPlayer en tiempo de construccion se guarda por
## referencia al recurso importado y se pierde al cargar. Mismo criterio
## de auto-cableado que SpikeFootIK y SpikeCompanionWalk.

## OJO con el clip de origen: `walk_doublel.fbx` es
## `1Hand_Up_Walk_A_B_InPlace` -- el clip **backward** del pack, no el
## forward. El rig de DoubleL tiene el rest mirando al reves del nuestro
## (convencion de Unity, +Z adelante; la de Godot es -Z), y el retargeting
## normaliza los ejes de cada hueso pero no el rumbo global del rest. Con el
## clip "_F" el pie plantado viajaba hacia adelante: moonwalk. La diferencia
## entre los dos rests es un giro de 180 grados en Y, y bajo ese giro el
## "caminar hacia atras" del pack ES el caminar hacia adelante nuestro --
## con la inclinacion y el balanceo de brazos que le corresponden. Medido
## con el pie plantado, no supuesto.
@export var walk_scene_path: String = "res://assets/anim/walk_doublel.fbx"
@export var idle_source: String = "human warrior|human warrior stand 1"
@export var autoplay_on_ready: String = "idle"

func _ready() -> void:
	var player: AnimationPlayer = _find(get_parent(), "AnimationPlayer")
	if player == null:
		push_warning("SpikeAnimInstaller: no AnimationPlayer bajo " + str(get_parent()))
		return
	var skeleton: Skeleton3D = _find(get_parent(), "Skeleton3D")
	if skeleton == null:
		push_warning("SpikeAnimInstaller: no Skeleton3D bajo " + str(get_parent()))
		return

	# Las pistas importadas apuntan a `%GeneralSkeleton` (nombre unico). Con
	# dos personajes en escena ese `%` es ambiguo, asi que se reescriben a la
	# ruta relativa al root_node del AnimationPlayer.
	var anim_root: Node = player.get_node_or_null(player.root_node)
	if anim_root == null:
		push_warning("SpikeAnimInstaller: root_node del AnimationPlayer no resuelve")
		return
	var skeleton_path := String(anim_root.get_path_to(skeleton))

	var lib := AnimationLibrary.new()

	var source: AnimationLibrary = player.get_animation_library("")
	if source != null and source.has_animation(idle_source):
		var idle := _rebase(source.get_animation(idle_source), skeleton_path)
		idle.loop_mode = Animation.LOOP_LINEAR
		lib.add_animation("idle", idle)
	else:
		push_warning("SpikeAnimInstaller: no se encontro la pose " + idle_source)

	var walk_res: PackedScene = load(walk_scene_path)
	if walk_res != null:
		var walk_src: Node = walk_res.instantiate()
		var walk_player: AnimationPlayer = _find(walk_src, "AnimationPlayer")
		if walk_player != null:
			var names: PackedStringArray = walk_player.get_animation_list()
			if names.size() > 0:
				var walk := _rebase(walk_player.get_animation(names[0]), skeleton_path)
				walk.loop_mode = Animation.LOOP_LINEAR
				lib.add_animation("walk", walk)
		walk_src.free()
	else:
		push_warning("SpikeAnimInstaller: no se pudo cargar " + walk_scene_path)

	player.remove_animation_library("")
	player.add_animation_library("", lib)
	if autoplay_on_ready != "" and lib.has_animation(autoplay_on_ready):
		player.play(autoplay_on_ready)

func _rebase(source: Animation, skeleton_path: String) -> Animation:
	var anim: Animation = source.duplicate(true)
	# Se descarta todo lo que no sea hueso. Las poses del FBX del warrior
	# traen una pista de escala sobre el NODO `human warrior` con valor
	# (100,100,100) -- la escala en centimetros del FBX original. El
	# importador la saca del transform del nodo pero la deja en la
	# animacion, asi que reproducirla volvia a inflar el personaje 100x.
	for i in range(anim.get_track_count() - 1, -1, -1):
		var path := String(anim.track_get_path(i))
		if path.begins_with("%GeneralSkeleton"):
			anim.track_set_path(i, NodePath(skeleton_path + path.substr("%GeneralSkeleton".length())))
		else:
			anim.remove_track(i)
	return anim

func _find(node: Node, type_name: String) -> Node:
	if node == null:
		return null
	for child in node.get_children():
		if child.is_class(type_name):
			return child
		var found := _find(child, type_name)
		if found:
			return found
	return null
