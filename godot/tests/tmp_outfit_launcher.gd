extends Node

# Beckett bench launcher (mismo patrón que tmp_anatomy_launcher.gd): el
# probe cuelga de /root, sibling de current_scene, deferred.
func _ready() -> void:
	get_tree().root.add_child.call_deferred(load("res://tests/tmp_outfit.gd").new())
