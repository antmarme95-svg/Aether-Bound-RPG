extends Node

# Beckett bench launcher: mirrors autoload/debug.gd _run_autotest � adds the
# probe as a child of /root (sibling of current_scene), NOT a descendant, so
# the probe self-freeing current_scene never kills itself. Deferred: /root is
# still setting up children during this node own _ready().
func _ready() -> void:
	get_tree().root.add_child.call_deferred(load("res://tests/tmp_anatomy.gd").new())
