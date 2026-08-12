extends SceneTree
func _initialize():
	var skel := Skeleton3D.new()
	root.add_child(skel)
	skel.add_bone("root"); skel.add_bone("mid"); skel.add_bone("tip")
	skel.set_bone_parent(1, 0); skel.set_bone_parent(2, 1)
	skel.set_bone_rest(1, Transform3D(Basis(), Vector3(0, -0.5, 0)))
	skel.set_bone_rest(2, Transform3D(Basis(), Vector3(0, -0.5, 0)))
	skel.reset_bone_poses()
	var t := Node3D.new(); root.add_child(t)
	var mod := TwoBoneIK3D.new()
	skel.add_child(mod)
	mod.setting_count = 1
	mod.set_root_bone_name(0, "root")
	mod.set_middle_bone_name(0, "mid")
	mod.set_end_bone_name(0, "tip")
	mod.set_target_node(0, mod.get_path_to(t))
	print("== TODAS las propiedades de la instancia configurada ==")
	for p in mod.get_property_list():
		var n: String = p["name"]
		if n.begins_with("_") or n == "script" or p["type"] == TYPE_NIL:
			continue
		print("  %-46s = %s" % [n, str(mod.get(n))])
	quit()
