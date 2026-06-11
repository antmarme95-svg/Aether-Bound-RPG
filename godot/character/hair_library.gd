## HairLibrary — ports HairLibrary.js 10 hair + 4 beard builders to Godot 4.
## All primitives (SphereMesh, CapsuleMesh, BoxMesh, CylinderMesh) mirror
## the JS geometry with equivalent transforms. Skull radius R = 0.15.
class_name HairLibrary extends RefCounted

const R: float = 0.15

# ---- primitive helpers ----

## Sphere mesh node, placed at (x,y,z) with optional scale and rotation.
static func _sphere(mat: Material, radius: float, x: float, y: float, z: float,
		sx: float = 1.0, sy: float = 1.0, sz: float = 1.0,
		rx: float = 0.0, ry: float = 0.0, rz: float = 0.0) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = Vector3(x, y, z)
	mi.rotation = Vector3(rx, ry, rz)
	mi.scale = Vector3(sx, sy, sz)
	return mi

## Cone mesh node (using CylinderMesh with top_radius=0).
static func _cone(mat: Material, base_r: float, height: float, x: float, y: float, z: float,
		rx: float = 0.0, ry: float = 0.0, rz: float = 0.0) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.top_radius = 0.001
	mesh.bottom_radius = base_r
	mesh.height = height
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = Vector3(x, y, z)
	mi.rotation = Vector3(rx, ry, rz)
	return mi

## Box mesh node.
static func _box(mat: Material, w: float, h: float, d: float,
		x: float, y: float, z: float,
		rx: float = 0.0, ry: float = 0.0, rz: float = 0.0) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(w, h, d)
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = Vector3(x, y, z)
	mi.rotation = Vector3(rx, ry, rz)
	return mi

## CapsuleMesh node.
static func _capsule(mat: Material, radius: float, height: float,
		x: float, y: float, z: float,
		rx: float = 0.0, ry: float = 0.0, rz: float = 0.0) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var mesh = CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = Vector3(x, y, z)
	mi.rotation = Vector3(rx, ry, rz)
	return mi

## Cylinder mesh node.
static func _cylinder(mat: Material, top_r: float, bot_r: float, height: float,
		x: float, y: float, z: float,
		rx: float = 0.0, ry: float = 0.0, rz: float = 0.0) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.top_radius = top_r
	mesh.bottom_radius = bot_r
	mesh.height = height
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = Vector3(x, y, z)
	mi.rotation = Vector3(rx, ry, rz)
	return mi

## Cap: skull-hugging hemisphere shell. In JS this is a partial SphereGeometry.
## Approximated as a sphere scaled down in y (upper hemisphere) sitting on top.
static func _cap(mat: Material, scale: float = 1.06, y_scale: float = 1.0) -> MeshInstance3D:
	var mi = _sphere(mat, R * scale, 0.0, R * scale * y_scale * 0.5, -0.01)
	# Flatten into cap by scaling y and clipping appearance via position
	mi.scale = Vector3(1.0, y_scale * 0.75, 0.88)
	return mi

## Braid: chain of progressively-smaller spheres along a direction vector.
## Mirrors JS braid(mat, segments, x, y, z, dirX, dirY, dirZ, startR).
static func _braid(mat: Material, segments: int,
		x: float, y: float, z: float,
		dx: float, dy: float, dz: float,
		start_r: float = 0.035) -> Node3D:
	var g = Node3D.new()
	var px = x
	var py = y
	var pz = z
	var r = start_r
	for i in range(segments):
		g.add_child(_sphere(mat, r, px, py, pz))
		px += dx
		py += dy
		pz += dz
		r *= 0.88
	return g

# ---- public API ----

## Build a hair style node by index (0-9). Returns Node3D root.
static func build_hair(index: int, mat: Material) -> Node3D:
	match index:
		0:
			return _hair_wyld_mane(mat)
		1:
			return _hair_norse_braids(mat)
		2:
			return _hair_elven_topknot(mat)
		3:
			return _hair_pompadour(mat)
		4:
			return _hair_ash_spikes(mat)
		5:
			return _hair_curtain_long(mat)
		6:
			return _hair_war_mohawk(mat)
		7:
			return _hair_twin_tails(mat)
		8:
			return _hair_shorn_scout(mat)
		9:
			return _hair_drake_dreads(mat)
		_:
			return Node3D.new()

## Build a beard style node by index (0-3). Returns Node3D root.
static func build_beard(index: int, mat: Material) -> Node3D:
	match index:
		0:
			return Node3D.new()   # Clean — empty group
		1:
			return _beard_stubble(mat)
		2:
			return _beard_braided_jarl(mat)
		3:
			return _beard_goatee(mat)
		_:
			return Node3D.new()

# ---- hair builders ----

# 0 — Wyld Mane: cap + 10 radiating spikes
static func _hair_wyld_mane(mat: Material) -> Node3D:
	var g = Node3D.new()
	g.add_child(_cap(mat, 1.1))
	for i in range(10):
		var a = (float(i) / 10.0) * PI * 2.0
		var tilt = 0.5 + float(i % 3) * 0.35
		# Spike: cone pointing outward from cap
		var spike_h = 0.16 + float(i % 4) * 0.05
		var cx = cos(a) * R * 0.72
		var cz = sin(a) * R * 0.72 - 0.03
		var spike = _cone(mat, 0.045, spike_h,
			cx,
			0.1 + float(i % 2) * 0.05,
			cz)
		# Tilt the spike outward: rotate away from center axis
		spike.rotation.x = PI * 0.5 + (0.4 - tilt * 0.2)
		spike.rotation.y = a
		g.add_child(spike)
	return g

# 1 — Norse Braids: cap + twin side braids + back braid
static func _hair_norse_braids(mat: Material) -> Node3D:
	var g = Node3D.new()
	g.add_child(_cap(mat, 1.07))
	g.add_child(_braid(mat, 5, R * 0.85, -0.02, 0.02, 0.004, -0.05, -0.004))
	g.add_child(_braid(mat, 5, -R * 0.85, -0.02, 0.02, -0.004, -0.05, -0.004))
	g.add_child(_braid(mat, 6, 0.0, 0.06, -R * 0.92, 0.0, -0.052, -0.012, 0.042))
	return g

# 2 — Elven Topknot: sleek cap + high bun + thin tail
static func _hair_elven_topknot(mat: Material) -> Node3D:
	var g = Node3D.new()
	g.add_child(_cap(mat, 1.045))
	g.add_child(_sphere(mat, 0.06, 0.0, R * 1.12, -0.02))
	g.add_child(_braid(mat, 5, 0.0, R * 1.05, -0.07, 0.0, -0.045, -0.028, 0.026))
	return g

# 3 — Pompadour Undercut: flat cap + front swoosh volume
static func _hair_pompadour(mat: Material) -> Node3D:
	var g = Node3D.new()
	g.add_child(_cap(mat, 1.02, 0.92))
	var swoosh = _sphere(mat, 0.095, 0.0, R * 0.78, R * 0.5)
	swoosh.scale = Vector3(1.15, 0.78, 1.25)
	g.add_child(swoosh)
	return g

# 4 — Ash Spikes: short cap + 6 upward shards
static func _hair_ash_spikes(mat: Material) -> Node3D:
	var g = Node3D.new()
	g.add_child(_cap(mat, 1.05))
	for i in range(6):
		var a = (float(i) / 6.0) * PI * 2.0 + 0.3
		var spike = _cone(mat, 0.035, 0.13,
			cos(a) * R * 0.5,
			R * 0.95,
			sin(a) * R * 0.5 - 0.02)
		# Light outward tilt — use deterministic angles (no random for parity)
		var tilt_offset = float(i % 3 - 1) * 0.2
		spike.rotation.x = tilt_offset
		spike.rotation.z = float((i + 1) % 3 - 1) * 0.2
		g.add_child(spike)
	return g

# 5 — Curtain Long: cap + two side panels + back panel
static func _hair_curtain_long(mat: Material) -> Node3D:
	var g = Node3D.new()
	g.add_child(_cap(mat, 1.06))
	var panel_l = _box(mat, 0.07, 0.34, 0.045, R * 0.82, -0.13, 0.015, 0.0, 0.0, 0.08)
	var panel_r = _box(mat, 0.07, 0.34, 0.045, -R * 0.82, -0.13, 0.015, 0.0, 0.0, -0.08)
	var back = _box(mat, 0.22, 0.36, 0.06, 0.0, -0.1, -R * 0.85)
	g.add_child(panel_l)
	g.add_child(panel_r)
	g.add_child(back)
	return g

# 6 — War Mohawk: tight cap + 5 center fin cones
static func _hair_war_mohawk(mat: Material) -> Node3D:
	var g = Node3D.new()
	g.add_child(_cap(mat, 1.015, 0.9))
	for i in range(5):
		var z = R * 0.7 - float(i) * 0.07
		var h = 0.17 - float(i) * 0.012
		g.add_child(_cone(mat, 0.032, h, 0.0, R * 0.92 + 0.02, z))
	return g

# 7 — Twin Tails: cap + two long braided tails
static func _hair_twin_tails(mat: Material) -> Node3D:
	var g = Node3D.new()
	g.add_child(_cap(mat, 1.05))
	g.add_child(_braid(mat, 7, R * 0.95, 0.02, -0.03, 0.012, -0.055, -0.01, 0.04))
	g.add_child(_braid(mat, 7, -R * 0.95, 0.02, -0.03, -0.012, -0.055, -0.01, 0.04))
	return g

# 8 — Shorn Scout: tight buzz cap only
static func _hair_shorn_scout(mat: Material) -> Node3D:
	var g = Node3D.new()
	g.add_child(_cap(mat, 1.012, 0.96))
	return g

# 9 — Drake Dreads: cap + 7 hanging cylinder ropes
static func _hair_drake_dreads(mat: Material) -> Node3D:
	var g = Node3D.new()
	g.add_child(_cap(mat, 1.07))
	for i in range(7):
		var a = PI * (0.6 + (float(i) / 6.0) * 0.8)
		var x = cos(a) * R * 0.85
		var z = sin(a) * -R * 0.85
		# JS: CylinderGeometry(0.022, 0.016, 0.3, 6) with rx=0.12, rz=x*0.6
		var dread = _cylinder(mat, 0.022, 0.016, 0.3, x, -0.1, z, 0.12, 0.0, x * 0.6)
		g.add_child(dread)
	return g

# ---- beard builders ----

# 1 — Stubble: translucent jaw shell approximated as a flattened sphere
static func _beard_stubble(mat: Material) -> Node3D:
	var g = Node3D.new()
	var shell_mat = mat.duplicate()
	# ShaderMaterial does not have transparency toggle; use a StandardMaterial overlay
	var stub_mat = StandardMaterial3D.new()
	stub_mat.albedo_color = Color(mat.get_shader_parameter("albedo_color")) if mat is ShaderMaterial else Color(0.1, 0.1, 0.1)
	stub_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	stub_mat.albedo_color.a = 0.45
	stub_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	# Low-poly flattened hemisphere over the jaw area
	var shell = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = R * 0.92
	mesh.height = R * 0.92 * 2.0
	mesh.rings = 5
	mesh.radial_segments = 14
	shell.mesh = mesh
	shell.material_override = stub_mat
	shell.position = Vector3(0.0, -0.035, 0.012)
	shell.scale = Vector3(0.5, 0.34, 0.4)  # flatten to jaw shape
	g.add_child(shell)
	return g

# 2 — Braided Jarl: chin mass sphere + hanging braid
static func _beard_braided_jarl(mat: Material) -> Node3D:
	var g = Node3D.new()
	var chin = _sphere(mat, 0.075, 0.0, -R * 0.78, R * 0.5)
	chin.scale = Vector3(1.25, 0.9, 0.9)
	g.add_child(chin)
	g.add_child(_braid(mat, 4, 0.0, -R * 1.05, R * 0.55, 0.0, -0.045, -0.008, 0.034))
	return g

# 3 — Goatee: sharp downward cone
static func _beard_goatee(mat: Material) -> Node3D:
	var g = Node3D.new()
	# JS: ConeGeometry(0.04, 0.09, 6) at (0, -R*0.95, R*0.55), rotation.x = PI
	# CylinderMesh with top_radius=0, rotated PI on X to point down
	g.add_child(_cone(mat, 0.04, 0.09, 0.0, -R * 0.95, R * 0.55, PI, 0.0, 0.0))
	return g
