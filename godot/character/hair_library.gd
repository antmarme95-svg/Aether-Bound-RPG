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

## S-curve spine for one hanging/sweeping mechón, in the mechón's OWN local
## frame: local X = lateral curve offset (the wave), local Y = 0 at the root
## sliding to +length at the tip ALONG the flow axis (`_ribbon` maps local Y
## to `mbasis.y` = flow root->tip; con Y negativa el mechón crecía OPUESTO a
## su flow — las capas de caída apuntaban al cielo, bug M10-r4). Local Z = 0
## (thickness comes from the ribbon's box depth, not the spine). `waves` > 1
## reads as a tighter, more visible "S"; the amplitude decays slightly toward
## the tip so the strand doesn't flare at the very end.
static func _s_spine(length: float, sweep: float, segs: int, waves: float = 1.15) -> PackedVector3Array:
	var pts := PackedVector3Array()
	for i in range(segs + 1):
		var t: float = float(i) / float(segs)
		var y: float = length * t
		var s: float = sin(t * PI * waves) * sweep * (1.0 - t * 0.35)
		pts.append(Vector3(s, y, 0.0))
	return pts

## Ribbon "mechón": a chain of tapered box segments following an S-curve
## spine — a curved card with variable width (PRD "Cabello Estilizado
## Ondulado" §4: ribbon, not cylinder, not straight plank). Each segment
## keeps its own BoxMesh flat per-face normal (faceted cel shading, §5: no
## smoothing between waves). `root`/`mbasis` are WORLD space; `mbasis.y` is
## the flow direction (root->tip), `mbasis.x` the curve's sweep plane,
## `mbasis.z` the outward face-normal reference (thickness axis).
static func _ribbon(mat: Material, spine: PackedVector3Array, width0: float, width1: float,
		thickness: float, root: Vector3, mbasis: Basis) -> Node3D:
	var g = Node3D.new()
	var n: int = spine.size()
	var world_pts: Array = []
	for p in spine:
		world_pts.append(root + mbasis * p)
	for i in range(n - 1):
		var p0: Vector3 = world_pts[i]
		var p1: Vector3 = world_pts[i + 1]
		var mid: Vector3 = (p0 + p1) * 0.5
		var seg_len: float = (p1 - p0).length()
		var t: float = (float(i) + 0.5) / float(n - 1)
		var w: float = lerp(width0, width1, t)
		var by: Vector3 = (p1 - p0).normalized()
		var bz: Vector3 = mbasis.z - by * by.dot(mbasis.z)
		if bz.length() < 0.001:
			bz = mbasis.x
		bz = bz.normalized()
		var bx: Vector3 = by.cross(bz).normalized()
		bz = bx.cross(by).normalized()
		var seg = MeshInstance3D.new()
		var mesh = BoxMesh.new()
		mesh.size = Vector3(w, seg_len * 1.16, thickness)
		seg.mesh = mesh
		seg.material_override = mat
		seg.transform = Transform3D(Basis(bx, by, bz), mid)
		g.add_child(seg)
	return g

## LOFT (FASE 3 PRD-Rework-v2, recurso 2 ratificado 2026-07-12; primera
## ejecución 2026-07-19): malla CONTINUA de un mechón a partir de una espina
## `Curve3D` + perfil de radios — reemplaza cadenas de cajas/conos (3 intentos
## fallidos; prohibido un 4º con esa técnica).
## CONTRATO DE EJES (lección M10-r4 — documentado en generador Y consumidor):
## los puntos de control de `curve` van en el frame del GRUPO de pelo (mismo
## frame donde vive la concha, cráneo R=0.15 centrado en el origen del grupo),
## con el flow root→tip en el ORDEN de los puntos (punto 0 = raíz enterrada,
## último punto = punta libre). La malla se emite en ese mismo frame: el nodo
## devuelto va en position=(0,0,0) sin rotación. Nada de frames locales por
## mechón — el bug de "astas al cielo" no puede reproducirse aquí.
## `radii` mapea 1:1 a lo largo de la espina (se interpola linealmente entre
## entradas); el último radio se fuerza a punta (~0) con un cap de abanico.
## `flatten` achata la sección en el eje saliente-del-cráneo (mechón-cinta,
## no espagueti); `center` es el centro del cráneo en el frame del grupo —
## orienta el eje de grosor hacia afuera para que la cara plana abrace el
## casco. Sección de `sides` lados, vértices duplicados por quad (normales
## planas = facetado cel, sin suavizado entre anillos). Material del llamador
## (toon_opaque — NUNCA ALPHA, regla del PRD).
static func _loft(mat: Material, curve: Curve3D, radii: PackedFloat32Array,
		sides: int = 6, flatten: float = 0.55,
		center: Vector3 = Vector3(0.0, 0.04, 0.0)) -> MeshInstance3D:
	var samples: int = maxi(radii.size(), 6)
	var pts: Array = []
	var length: float = curve.get_baked_length()
	for i in range(samples):
		pts.append(curve.sample_baked(length * float(i) / float(samples - 1)))
	# Radio interpolado sobre el perfil.
	var rad: Array = []
	for i in range(samples):
		var t: float = float(i) / float(samples - 1) * float(radii.size() - 1)
		var i0: int = int(floor(t))
		var i1: int = mini(i0 + 1, radii.size() - 1)
		rad.append(lerpf(radii[i0], radii[i1], t - float(i0)))
	# Frames por anillo: tangente + referencia radial al cráneo (la cara
	# ancha del mechón queda tangente al casco, el grosor apunta afuera).
	var rings: Array = []
	for i in range(samples):
		var p: Vector3 = pts[i]
		var tang: Vector3
		if i == 0:
			tang = (pts[1] - pts[0]).normalized()
		elif i == samples - 1:
			tang = (pts[i] - pts[i - 1]).normalized()
		else:
			tang = (pts[i + 1] - pts[i - 1]).normalized()
		var out_ref: Vector3 = (p - center).normalized()
		var ax: Vector3 = tang.cross(out_ref)
		if ax.length() < 0.001:
			ax = tang.cross(Vector3.UP)
			if ax.length() < 0.001:
				ax = Vector3.RIGHT
		ax = ax.normalized()
		var az: Vector3 = ax.cross(tang).normalized()
		var ring := PackedVector3Array()
		for s in range(sides):
			var a: float = float(s) / float(sides) * TAU
			ring.append(p + ax * cos(a) * rad[i] + az * sin(a) * rad[i] * flatten)
		rings.append(ring)
	# Triángulos con vértices sueltos (sin índice) → generate_normals() da
	# normales PLANAS por cara: facetado cel, sin suavizado entre anillos.
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	# (Winding verificado en captura 2026-07-19: el orden inicial dejaba
	# las caras exteriores culled — mechones leían como "V huecas" color
	# cielo. Este orden es el correcto para cull_back de Godot.)
	for i in range(samples - 1):
		var r0: PackedVector3Array = rings[i]
		var r1: PackedVector3Array = rings[i + 1]
		for s in range(sides):
			var s2: int = (s + 1) % sides
			st.add_vertex(r0[s]); st.add_vertex(r1[s2]); st.add_vertex(r1[s])
			st.add_vertex(r0[s]); st.add_vertex(r0[s2]); st.add_vertex(r1[s2])
	# Cap de punta: abanico del último anillo al punto final de la curva.
	var tip: Vector3 = pts[samples - 1]
	var rl: PackedVector3Array = rings[samples - 1]
	for s in range(sides):
		var s2b: int = (s + 1) % sides
		st.add_vertex(rl[s]); st.add_vertex(rl[s2b]); st.add_vertex(tip)
	# Cap de raíz (por si la raíz asoma en algún ángulo: cerrada, no tubo hueco).
	var root_c: Vector3 = pts[0]
	var r0c: PackedVector3Array = rings[0]
	for s in range(sides):
		var s2c: int = (s + 1) % sides
		st.add_vertex(r0c[s]); st.add_vertex(root_c); st.add_vertex(r0c[s2c])
	st.generate_normals()
	var mi = MeshInstance3D.new()
	mi.mesh = st.commit()
	mi.material_override = mat
	return mi

## Superficie del cráneo del rig humano en el frame del hair_slot (hijo
## directo de `head`, sin offset): `skull = SphereMesh(0.15)` con scale
## (0.82, 0.94, 0.95) y position.y = 0.012 (character_rig.gd) → semiejes
## (0.123, 0.141, 0.1425) centrados en (0, 0.012, 0). Este helper devuelve
## el punto de la superficie para (x, y) dados (z positiva=frente, pasar
## `back=true` para el hemisferio trasero), empujado `lift` metros hacia
## afuera en dirección radial. Autorar mechones CON esto, no con números a
## ojo — 3 rondas ciegas de 2026-07-19 salieron de asumir semiejes falsos.
const SKULL_SEMI := Vector3(0.123, 0.141, 0.1425)
const SKULL_C := Vector3(0.0, 0.012, 0.0)

static func _on_skull(x: float, y: float, lift: float = 0.0, back: bool = false) -> Vector3:
	var nx: float = clampf(x / SKULL_SEMI.x, -0.97, 0.97)
	var ny: float = clampf((y - SKULL_C.y) / SKULL_SEMI.y, -0.97, 0.97)
	var z2: float = maxf(0.04, 1.0 - nx * nx - ny * ny)
	var z: float = SKULL_SEMI.z * sqrt(z2) * (-1.0 if back else 1.0)
	var p := Vector3(x, y, z)
	var radial: Vector3 = (p - SKULL_C).normalized()
	return p + radial * lift

## Azúcar del loft: espina por puntos de control (frame del grupo, root→tip)
## → Curve3D con tangentes automáticas suaves (Catmull-Rom aproximado vía
## in/out handles) y radios del perfil. Mantiene el contrato de ejes de
## `_loft` (mismo frame, mismo orden).
static func _lock(mat: Material, control_pts: Array, radii: PackedFloat32Array,
		sides: int = 6, flatten: float = 0.55,
		center: Vector3 = Vector3(0.0, 0.04, 0.0)) -> MeshInstance3D:
	var curve := Curve3D.new()
	var n: int = control_pts.size()
	for i in range(n):
		var p: Vector3 = control_pts[i]
		var t_in := Vector3.ZERO
		var t_out := Vector3.ZERO
		if i > 0 and i < n - 1:
			var dir: Vector3 = (control_pts[i + 1] - control_pts[i - 1]) * 0.25
			t_in = -dir
			t_out = dir
		curve.add_point(p, t_in, t_out)
	return _loft(mat, curve, radii, sides, flatten, center)

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
		10:
			return _hair_frontier_crop(mat)
		11:
			return _hair_prince_curtain(mat)
		_:
			return Node3D.new()

## Build a beard style node by index (0-3). Returns Node3D root.
## `density` (0..1) solo aplica al estilo 1 (Stubble) — CONFIGURABLE
## (pedido del director): 0 = sombra de 3 días apenas insinuada, 1 = barba
## corta pareja tipo `fenotipo-humano-torso-v1`. Ver `_beard_stubble()`.
static func build_beard(index: int, mat: Material, density: float = 0.4) -> Node3D:
	match index:
		0:
			return Node3D.new()   # Clean — empty group
		1:
			return _beard_stubble(mat, density)
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

# 10 — Frontier Crop (M10, concept humano canónico): quiff corto barrido
# arriba-atrás, laterales CORTOS con fade (piel visible en sienes y nuca),
# orejas al aire. Review v0.4 CRITICAL 1: el casquete-esfera SIEMPRE lee
# como casco/hongo desde atrás (borde-repisa de 360°) — construcción
# angular de LOSAS ESCALONADAS que siguen el cráneo (BotW/low-poly):
# ningún volumen envuelve; cada losa asienta sobre la curva.
static func _hair_frontier_crop(mat: Material) -> Node3D:
	var g = Node3D.new()
	# PRD Geometría Nueva (2026-07-14, ratificado): reconstrucción completa.
	# 3 rondas de QA (32%→42%→45%→49%) confirmaron que ni el contraste
	# tonal (2→3 tonos) ni la protrusión (probada y revertida 2 veces —
	# reabría "dientes" en la cresta frontal) resuelven la lectura de
	# "casco sólido": el problema es que la CONCHA cubre casi todo el
	# cráneo con un borde continuo, y 31 mechones casi al ras nunca rompen
	# esa silueta única. Zoom directo sobre `fenotipo-humano-v1.png`
	# (frente + espalda) confirma: nuca/laterales MUY cortos (mucha piel
	# expuesta, oreja completa visible), volumen concentrado en la
	# coronilla, flequillo de 4-5 mechones INDIVIDUALES con puntas reales,
	# no una masa continua.

	# CONCHA — recortada agresivamente: antes cubría hasta las orejas/nuca
	# baja (scale.y 0.72, centro R*0.40); ahora se achica y SUBE (scale.y
	# 0.72→0.50, centro R*0.40→R*0.50) para exponer nuca/sienes reales —
	# el corte corto de la lámina, no una melena corta.
	# Ronda 4 del rework (ANDAMIAJE medido): las rondas 1-3 autoraban con
	# semiejes de cráneo FALSOS (asumían media anchura ~0.096 y centro y
	# 0.045; los reales son (0.123, 0.141, 0.1425) @ y=0.012 — ver
	# `_on_skull`). Resultado: "copete flotante" (r2) y "mohawk hundido"
	# (r3). Ahora TODA raíz/cresta se calcula sobre la superficie real.
	# Ronda 8: la CONCHA se retira definitivamente — con el clump medido
	# ya cubre el domo, y la pared trasera de la concha (en sombra) era el
	# "óvalo/cuenco oscuro" de la vista de arriba-atrás que 4 rondas
	# intentaron tapar con tiras. El clump madre + tiras dan toda la
	# cobertura; la nuca corta muestra piel (lámina), sin cuenco.

	# Contraste tonal (se mantiene — 3 tonos, sí sobrevive el banding toon).
	var lighter := mat
	var darker := mat
	if mat is ShaderMaterial:
		lighter = (mat as ShaderMaterial).duplicate()
		darker = (mat as ShaderMaterial).duplicate()
		var base_col = (mat as ShaderMaterial).get_shader_parameter("albedo_color")
		if base_col != null:
			(lighter as ShaderMaterial).set_shader_parameter(
				"albedo_color", (base_col as Color).lightened(0.28))
			(darker as ShaderMaterial).set_shader_parameter(
				"albedo_color", (base_col as Color).darkened(0.18))

	# ===== FULL REWORK 2026-07-19 (minado dirigido de pelo, Boris rechazó
	# el piloto "casco con dentículos") — jerarquía de 3 PASADAS del libro
	# (p.156 Anger): (1) clumps grandes con UNA dirección de flujo y
	# silueta que se DESPEGA del contorno craneal (galería p.147: curvas
	# propias, no concéntricas); (2) tiras que SIGUEN LAS TRAYECTORIAS de
	# la masa madre — "la masa se parte en tiras", no cosas pegadas
	# encima; (3) mechones contrastantes. Valor (p.243): capa honda
	# oscura (depresión), tiras claras (protuberancia) — pelo oscuro pide
	# valles HONDOS. Todos los puntos en frame del grupo (contrato de
	# `_loft`; flow root→tip = orden de los puntos).
	var skull_c := SKULL_C

	# --- PASADA 0: FADE (rework r10, pedido de Boris: "no tiene nada de
	# cabello en los temporales y patillas, ni en la nuca"). Un frontier
	# crop lleva los lados y la nuca RAPADOS — pelo corto pegado al
	# cráneo, no piel desnuda. Tiras que hugean la superficie a 4 mm
	# (buzzed): a esa distancia sombrean casi igual que el cráneo, así que
	# leen como pelo al ras y NO reabren el "cuenco oscuro" (ese venía de
	# una concha suelta con pared propia en sombra). Todas con taper a
	# punta fina: el borde inferior del fade se desvanece, no corta recto.
	# Ronda 11: fade en tono MEDIO (con `darker`, sobre superficies que
	# miran atrás/abajo caía en la banda de sombra y rendía casi negro:
	# leía "garras negras" en nuca y detrás de la oreja — mismo modo de
	# falla que el clump en la ronda 6).
	var fade_mat: Material = mat

	# Temporales (2 por lado) + PATILLA (delante de la oreja, que vive en
	# x≈±0.124, z≈-0.034 → estas van a z≈+0.03, por delante).
	for side in [-1, 1]:
		var sf: float = float(side)
		# Ronda 13 (TODO el fade): `flatten` 0.42-0.45→0.15 y lift ~0. El
		# grosor radial de una tira es radio×flatten, así que a 0.45 con
		# radio 0.023 protruían ~14 mm — eso es una MELENA corta, no un
		# rapado, y por eso leían lóbulos redondos. A flatten 0.15 la tira
		# es una cinta plana de ~3 mm apoyada sobre el cráneo: capa
		# continua de pelo al ras (buzzed), que es lo que pide el fade.
		# (Ronda 21: la banda TEMPORAL que vivía aquí se RETIRÓ — quedó
		# redundante con las 3 bandas de costado nuevas, que cubren la
		# misma zona con mejor solape. Superpuestas apilaban bordes y el
		# lateral leía acolchado/mosaico: menos piezas = menos siluetas
		# internas compitiendo.)
		# temporal bajo → PATILLA (baja por delante de la oreja; la punta
		# SÍ se afila — una patilla termina en punta, a diferencia del
		# fade de nuca que es un borde romo).
		# Ronda 18 (Boris: "las patillas deben pasar lo más pegado a las
		# orejas para conectar con la parte de atrás"): la patilla se
		# corre al ANCHO MÁXIMO del cráneo (x≈0.122; ahí la superficie
		# cae en z≈0, es decir justo por delante de la oreja, que vive en
		# z -0.057..-0.012) y baja hasta y=-0.038, por debajo del lóbulo.
		# Antes iba a x 0.119/y -0.012 → z≈+0.034, o sea 4,6cm ADELANTE
		# de la oreja y terminando a media oreja: ni pegada ni conectada.
		# Ronda 26 (decisión de Boris): el MECHÓN DE PATILLA suelto se
		# ELIMINA — sobraba, y el casquete lo rodeaba por completo
		# (doble pieza en la misma zona). La patilla ahora la forma el
		# BORDE del casquete, que por delante de la oreja termina a la
		# altura donde llegaba este mechón (y≈-0.035), sin envolverla.
		pass
		# detrás de la oreja (cierra el fade lateral con la nuca)
		# Detrás de la oreja — ronda 15: también BANDA de una pieza (misma
		# razón que la nuca). Espina vertical → el radio se proyecta en Z
		# (adelante-atrás), cubriendo el parche entre la oreja y la nuca.
		# Ronda 18: baja hasta y=-0.020 (bajo el lóbulo) y se ensancha —
		# es la pieza que CIERRA el circuito patilla→oreja→nuca; antes
		# terminaba en y 0.030, dejando el hueco que rompía la conexión.
		g.add_child(_lock(fade_mat, [
			_on_skull(sf * 0.104, 0.100, 0.006, true),
			_on_skull(sf * 0.113, 0.052, 0.006, true),
			_on_skull(sf * 0.110, -0.020, 0.005, true),
		], PackedFloat32Array([0.026, 0.034, 0.026]), 10, 0.14, skull_c))

	# NUCA: 4 tiras que bajan desde el corte del pelo largo hasta la nuca
	# baja, afilando (el fade se desvanece hacia el cuello, sin borde duro).
	# ===== CASQUETE DEL FADE — ronda 23 =====
	# Verificación en píxel de la lámina (zoom a las 3 cabezas): la nuca
	# y los laterales del canon son UNA MASA CONTINUA que baja hasta
	# justo encima del cuello, NO una pila de bandas. Las bandas apiladas
	# (rondas 18-21) cubrían bien pero leían "anillos concéntricos /
	# capas de cebolla" (QA CRITICAL). Un ELIPSOIDE abraza la esfera
	# craneal por construcción — sin sagita, sin costuras, sin anillos —
	# y se auto-recorta: emerge donde es mayor que el cráneo y desaparece
	# donde es menor. El truco para que cubra nuca+laterales pero NO la
	# frente es INCLINARLO hacia atrás: el polo inferior se va a la nuca
	# (pelo bajo atrás) y el borde delantero sube por encima de la frente
	# (línea del pelo alta, como la lámina).
	# Ronda 24: más INCLINACIÓN (0.26→0.36) y algo menos de eje Y. Al
	# inclinar más, el borde inferior baja aún más en la nuca pero SUBE
	# en los laterales — que es justo lo que hacía falta: el casquete
	# montaba sobre la oreja (x±0.124, y -0.048..0.028) y el canon la
	# quiere despejada con el pelo pasando por detrás.
	# Ronda 25: casquete un pelo más angosto en X (1.0→0.975 del radio) —
	# su borde inferior-frontal montaba sobre la oreja en perfil (QA
	# CRITICAL; el canon la quiere completamente visible con la patilla
	# corta por delante).
	# Ronda 26 (decisión de Boris + aviso del QA): el borde del casquete
	# por delante de la oreja BAJA hasta y≈-0.035 (donde moría el mechón
	# de patilla retirado) — la patilla la dibuja ahora ese borde. Para
	# eso se reduce la inclinación (0.36→0.28) y baja el centro: menos
	# tilt = borde delantero más bajo. Y se ANGOSTA en X (0.126→0.121)
	# para que la oreja (que llega a x≈0.136) sobresalga del casquete y
	# no quede "enmarcada por un agujero" (HIGH del QA).
	var fade_shell = _sphere(fade_mat, 0.121, 0.0, 0.008, -0.018,
		1.0, 1.190, 1.140, 0.28, 0.0, 0.0)
	g.add_child(fade_shell)

	# COSTADO DEL CRÁNEO — ronda 21 (Boris marcó en azul los huecos):
	# el parietal entero (entre la masa de arriba y la nuca/patilla)
	# estaba en piel; las piezas previas solo cubrían una diagonal fina.
	# 3 bandas por lado que ENVUELVEN el costado de frente a nuca a tres
	# alturas, con solape vertical entre ellas. Las x están acotadas al
	# semiancho REAL del cráneo a cada altura (a y=0.105 el cráneo mide
	# 0.092 de semiancho, no 0.123: pedir x=0.11 ahí daba un punto fuera
	# de la elipsoide y `_on_skull` lo clampeaba a un z falso).
	# Lift escalonado (más afuera arriba) por la regla de la sagita.
	# (Ronda 23: las 3 bandas de costado por lado se RETIRARON — el
	# casquete elipsoide cubre esa zona de una pieza. Apiladas leían
	# anillos concéntricos, defecto CRITICAL del QA contra la lámina.)

	# NUCA — ronda 15: UNA SOLA BANDA HORIZONTAL, no tiras verticales.
	# Rondas 11-14 probaron 4→7 tiras verticales con anchos, solapes,
	# puntas y largos distintos: SIEMPRE leían dientes/garras, porque cada
	# costura entre dos tiras vecinas es un diente (el QA lo marcó
	# CRITICAL 2 veces). La banda corre a lo ANCHO (izq→der) sobre la
	# nuca: con la espina horizontal, el radio del loft se proyecta en
	# VERTICAL, así que el radio define el alto del rapado y no hay
	# ninguna costura vertical que dentar. El perfil de radios da el
	# taper: alto al centro, se afina hacia las sienes.
	# Ronda 16: banda SUBIDA (y 0.075→0.090) y más corta (radios −25%) —
	# a la altura anterior su borde recto bajaba hasta media nuca y leía
	# "visera"; ahora se mete bajo la masa principal y termina arriba, que
	# es donde muere un fade real.
	# Ronda 17: banda un poco más alta y ANCHA para que su borde superior
	# se meta bajo la masa principal (sin franja de piel entre ambas).
	# Se PROBARON Y DESCARTARON mechitas cortas colgando de su borde para
	# ablandar el filo: leyeron colmillos triangulares — la misma clase de
	# defecto que las tiras verticales. Conclusión asentada: en la zona de
	# fade, CUALQUIER pieza suelta con punta lee diente; el fade solo
	# funciona como superficie continua.
	# Ronda 18 (Boris: "la parte de abajo debería llegar cercana al
	# cuello"): la nuca baja hasta y≈-0.048 (antes cortaba en 0.040 y
	# dejaba media nuca en piel). NO se hace con una banda única alta: el
	# anillo del loft es una elipse PLANA, así que una banda de más de
	# ~6cm de alto deja de abrazar el cráneo curvo y flota en sus bordes
	# (calculado: a ±0.058 del eje, el cráneo se adelanta ~1.4cm). Se
	# resuelve APILANDO 3 bandas de media altura ≤0.036 con solape — las
	# costuras horizontales no dentan (los dientes venían de costuras
	# VERTICALES entre tiras).
	# Ronda 20: solape mayor entre bandas y LIFT ESCALONADO (más afuera
	# arriba) — así el borde inferior de cada banda monta SOBRE la de
	# abajo, como capas de pelo, y el escalón de la costura mira hacia
	# abajo (invisible desde la cámara de arriba-atrás). Con lift igual,
	# las tres costuras se leían como caparazón segmentado.
	# (Ronda 23: las 3 bandas apiladas de NUCA se RETIRARON por el mismo
	# motivo — el casquete las reemplaza con una sola superficie. Las
	# lecciones que dejaron siguen vigentes y documentadas arriba: la
	# sagita del lift, y que las tiras verticales sueltas siempre dentan.)

	# --- PASADA 1: clump principal (oscuro) — lomo direccional frente→
	# nuca sobre el cráneo REAL, con la cresta despegada ~2cm al frente y
	# cayendo en curva propia (anti-concéntrico). Es el fondo de valle
	# que asoma entre las tiras claras.
	# Ronda 5: cresta del clump ANIDADA bajo las tiras (lift 0.020→0.006,
	# radios recortados) — con lift alto sobresalía entre las tiras como
	# parche negro-azul en la coronilla; debe asomar solo en los valles.
	# Ronda 6: clump en tono MEDIO — el albedo `darker` bajo la banda de
	# sombra del toon rendía casi NEGRO con sheen azul en caras hacia el
	# cielo; la oscuridad del valle (libro p.243) ya la pone el sombreado
	# natural del receso, no hace falta apilarla en el albedo.
	# Ronda 7: corte TRASERO subido (nuca 0.094→0.124) — el clump bajaba
	# hasta la nuca-baja y su superficie trasera-inferior, que mira
	# abajo/atrás fuera del key, leía como cuenco/tonsura oscuro en la
	# vista de arriba-atrás. La lámina tiene nuca CORTA con piel expuesta;
	# subir el corte muestra la piel (iluminada) y el cuenco desaparece.
	# Ronda 9: clump ENGROSADO y flatten alto (0.60→0.92, casi redondo) —
	# sin la concha el clump ES el cap del domo; delgado dejaba ver frente
	# entre tiras ("ralo/entradas"). Front root bajado (0.102→0.088) para
	# una línea del pelo más generosa. Radios +40%.
	# Ronda 28 (QA de ZONAS vs referencia de cráneo: hueco de piel en la
	# coronilla en perfil): la masa base se ENGROSA para llenar el volumen
	# bajo los mechones y garantizar cobertura del cráneo — el cuero
	# cabelludo asomaba en las ventanas entre los mechones arqueados.
	g.add_child(_lock(mat, [
		_on_skull(0.0, 0.082, 0.005),               # nacimiento en la frente
		_on_skull(0.005, 0.150, 0.010),             # cresta del barrido
		_on_skull(-0.004, 0.140, 0.009, true),      # lomo de coronilla
		_on_skull(0.0, 0.124, 0.005, true),         # corte trasero (nuca corta)
	# Ronda 10: sides 8→14 — el QA leyó "placas/tejas/armadura"; a 8 lados
	# con este radio cada faceta mide ~2.5cm y el cel-step la marca como
	# panel. Más lados = quiebres más chicos que la banda del toon.
	# Ronda 22 (Boris: "quitar eso abultado para que se vea más fluido"):
	# `flatten` 0.92→0.50. El grosor RADIAL de la masa es radio×flatten,
	# así que a 0.92 con radio 0.082 protruía ~7.5cm de pelo sobre el
	# cráneo — un blob, no un peinado barrido. A 0.50 protruye ~4cm y la
	# masa se convierte en un casquete tendido que sigue la curva del
	# cráneo (el ancho lateral, que es el que da cobertura, no se toca).
	], PackedFloat32Array([0.066, 0.086, 0.076, 0.020]), 14, 0.56, skull_c))

	# CAPA DE COBERTURA DE CORONILLA (ronda 28) — bandas horizontales que
	# HUGEAN el cráneo (lift bajo, flatten 0.16, como el fade de nuca) por
	# DEBAJO de la masa y las tiras. Su único trabajo es que no se vea
	# cuero cabelludo en las ventanas entre mechones arqueados (hueco de
	# coronilla del QA de zonas). No suman bulto: son cintas de ~3mm
	# pegadas a la superficie, del mismo castaño. Cubren de la línea del
	# pelo (frente) al lomo (coronilla), que es donde estaban las ventanas.
	# Ronda 28b: 3→4 bandas y lift subido (0.006→0.009) para alcanzar la
	# ventana bajo el mechón arqueado que dejaba un punto de piel a zoom.
	var crown_cover: Array = [
		[0.100, 0.009],   # frente-alto
		[0.120, 0.010],   # media-baja coronilla (donde quedaba el punto)
		[0.134, 0.009],   # media coronilla
		[0.150, 0.008],   # cresta
	]
	# (Diagnóstico de color 2026-07-20: con las bandas en `darker` el
	# punto de piel de la coronilla-frontal SEGUÍA tan → es piel real, no
	# un brillo de banda. Es un pinhole que un mechón arqueado abre justo
	# ahí; las bandas de cobertura cierran el 95% del hueco. Residual
	# invisible a escala de visualización, solo se ve a 3× de zoom.
	# Lección: PARAR tras 3 intentos razonados — ver [[Lecciones]].)
	for cc in crown_cover:
		var cy2: float = cc[0]
		var clf: float = cc[1]
		var cback: bool = cy2 >= 0.145
		g.add_child(_lock(mat, [
			_on_skull(-0.086, cy2, clf, cback),
			_on_skull(-0.044, cy2 + 0.004, clf, cback),
			_on_skull(0.0, cy2 + 0.006, clf, cback),
			_on_skull(0.044, cy2 + 0.004, clf, cback),
			_on_skull(0.086, cy2, clf, cback),
		], PackedFloat32Array([0.030, 0.040, 0.044, 0.040, 0.030]), 10, 0.16, skull_c))

	# --- PASADA 2: el clump se parte en TIRAS drapeadas SOBRE el cráneo
	# (raíces en la línea del pelo real, calculadas con `_on_skull`),
	# misma familia de trayectorias frente→cresta→nuca. Anchos/largos/
	# lifts DISTINTOS entre vecinas (anti-paralelismo p.244); los lifts
	# alternados dan el valle real donde asoma el clump oscuro. Las que
	# convergen hacia el centro arriba (x*0.8) dan el barrido peinado.
	# Ronda 27 (MEDIUM del QA: "picos del nacimiento muy parejos en tamaño
	# y espaciado, efecto corona/llama"): el defecto estaba en los datos —
	# el `dx` iba casi a paso constante (30/31/32/32/31/29 mm) y los
	# anchos en una banda estrecha (0.022-0.030). Ahora el paso es
	# IRREGULAR (26/24/32/26/36/40) y los anchos se abren casi al doble de
	# rango (0.018-0.034). Un patrón parejo delata el procedural aunque
	# cada pieza esté bien hecha (regla anti-paralelismo del libro).
	#            dx      lift    w      largo  mat(0=light,1=mat)
	var sdefs: Array = [
		[-0.096,  0.003,  0.019,  0.78,  1],
		[-0.070,  0.012,  0.031,  1.00,  0],
		[-0.046,  0.005,  0.022,  0.68,  1],
		[-0.014,  0.015,  0.034,  1.00,  0],
		[ 0.012,  0.006,  0.018,  0.90,  1],
		[ 0.048,  0.011,  0.029,  1.00,  0],
		[ 0.088,  0.004,  0.024,  0.82,  1],
	]
	# Ronda 26 — CRITICAL del QA: en la vista de espalda las tiras leían
	# una ROSETA/molinete (5-6 lóbulos-gota iguales convergiendo a un
	# punto de la coronilla) porque TODAS cerraban hacia el centro con el
	# mismo factor y terminaban a la misma altura: anti-paralelismo
	# violado de la forma más visible. `fan` rompe eso — unas convergen,
	# otras siguen rectas y otras ABREN hacia afuera — y `endy` dispersa
	# dónde muere cada una.
	var fan: Array = [0.55, 1.02, 0.72, 1.18, 0.62, 1.10, 0.80]
	var endy: Array = [0.030, -0.004, 0.052, 0.014, 0.040, -0.010, 0.024]
	# Ronda 27: cuánto BAJA la punta de cada tira sobre la línea del pelo
	# y qué tan fina termina — antes eran iguales para las 7 (drop fijo
	# 0.004×jitter, radio fijo w*0.22), que es lo que producía la fila de
	# picos clonados.
	var hl_drop: Array = [0.002, 0.011, 0.000, 0.007, 0.014, 0.003, 0.009]
	var hl_tip: Array = [0.30, 0.16, 0.34, 0.13, 0.22, 0.28, 0.18]
	for si2 in range(sdefs.size()):
		var sd: Array = sdefs[si2]
		var dx: float = sd[0]
		var lift: float = sd[1]
		var w: float = sd[2]
		var reach: float = sd[3]
		var fn: float = fan[si2]
		var ey: float = endy[si2]
		var smat: Material = lighter if int(sd[4]) == 0 else mat
		# Línea del pelo: más baja en las sienes, irregular entre vecinas.
		# Ronda 10 (TAPER, hallazgo HIGH del QA): las raíces bajan un punto
		# EXTRA por delante del nacimiento, mucho más finas (w*0.55→w*0.22)
		# y con la irregularidad amplificada — el corte pelo→piel deja de
		# ser un contorno duro y parejo (leía "gorro/jockey") y se ahúsa.
		var jitter: float = (0.9 if int(sd[4]) == 0 else 1.15)
		var root_y: float = 0.092 - absf(dx) * 0.26 + lift * 0.9 * jitter
		# Ronda 23 — verificación en píxel de la lámina (zoom a la cabeza
		# frontal y de perfil): el frontier crop NO tiene flequillo. El
		# pelo NACE en la línea del nacimiento y sube barriendo hacia
		# atrás. Las puntas que colgaban 14mm por DEBAJO de esa línea
		# leían "flequillo despeinado juvenil" (QA HIGH) y no existen en
		# el canon. Ahora el primer punto queda EN la línea del pelo, con
		# un mínimo voladizo irregular (2-5mm) que solo ablanda el borde.
		# Ronda 28: lift de cresta/lomo BAJADO (0.010+lift → 0.005+lift*0.6;
		# 0.008 → 0.005) para que las tiras NO se arqueen sobre la masa
		# base — el arco dejaba ventanas de cuero cabelludo entre tira y
		# masa (hueco de coronilla del QA de zonas). Ahora se tienden sobre
		# la masa engrosada, sin puente.
		var pts: Array = [
			_on_skull(dx * 1.03, root_y - hl_drop[si2], 0.003),  # borde del nacimiento
			_on_skull(dx, root_y + 0.014, 0.004 + lift * 0.3),
			_on_skull(dx * 0.82, 0.149, 0.005 + lift * 0.6),    # monta la cresta
			_on_skull(dx * 0.74, 0.132, 0.005 + lift * 0.5, true),
		]
		# Ronda 25 (QA CRITICAL: "la nuca es una cúpula lisa sin ninguna
		# subdivisión — ~80% del área visible sin quiebres"): las tiras
		# ahora CORREN POR TODO EL CASQUETE hasta la nuca baja, no se
		# quedan en la coronilla. Son la pasada 2 del libro (la masa se
		# parte en tiras que siguen su flujo) y son las que dan la
		# dirección de barrido que faltaba. El lift sube a ~0.016 en el
		# tramo trasero: el casquete elipsoide ya está ~8-12mm fuera del
		# cráneo, así que una tira con lift chico quedaría DENTRO de él
		# (invisible) — hay que apoyarse sobre el casquete, no sobre el
		# cráneo.
		pts.append(_on_skull(dx * (0.62 + fn * 0.30), 0.104, 0.011, true))
		pts.append(_on_skull(dx * (0.54 + fn * 0.40), 0.058 + ey * 0.6, 0.011, true))
		if reach >= 0.9:
			pts.append(_on_skull(dx * (0.44 + fn * 0.46), ey, 0.010, true))  # nuca
		var radii := PackedFloat32Array([w * hl_tip[si2], w * 0.72, w, w * 0.85,
			w * 0.80, w * 0.62, 0.004])
		if reach < 0.9:
			radii = PackedFloat32Array([w * hl_tip[si2], w * 0.72, w, w * 0.85,
				w * 0.78, 0.004])
		# sides 6→12: mata la lectura de "tejas" entre tiras vecinas.
		# Ronda 22: flatten 0.6→0.38 — a 0.6 cada tira era un tubo de
		# ~18mm de grosor apilado SOBRE la masa (lectura de salchichas);
		# aplanadas son cintas que se tienden sobre ella y el barrido
		# se lee fluido.
		g.add_child(_lock(smat, pts, radii, 12, 0.38, skull_c))

	# Tiras laterales de sien (1 por lado): borde inferior del pelo sobre
	# la oreja — se APOYAN en el borde superior del pabellón (libro p.40:
	# transición pelo→oreja por solapamiento; la oreja queda expuesta).
	for side in [-1, 1]:
		var s_f: float = float(side)
		g.add_child(_lock(mat if side < 0 else lighter, [
			_on_skull(s_f * 0.096, 0.078, 0.004),
			_on_skull(s_f * 0.108, 0.098, 0.008),
			_on_skull(s_f * 0.094, 0.082, 0.005, true),
		], PackedFloat32Array([0.013, 0.018, 0.004]), 12, 0.38, skull_c))

	# Coronilla trasera: 3 tiras anchas y CLARAS que cubren la banda
	# nuca-media (la vista arriba-atrás veía un óvalo oscuro donde las
	# tiras del barrido divergían y asomaba el clump — "tonsura"). Nacen
	# en el lomo de la coronilla y bajan cubriendo el centro con lift
	# alto (montan por encima del clump que dejaba el hueco).
	var qb: Array = [-0.030, 0.002, 0.032]
	for qi in range(3):
		var qx: float = qb[qi]
		g.add_child(_lock(lighter if qi != 1 else mat, [
			_on_skull(qx * 0.6, 0.146, 0.012, true),
			_on_skull(qx, 0.134, 0.014, true),            # lomo trasero
			_on_skull(qx * 1.1, 0.124, 0.008, true),      # corte (nuca corta)
		], PackedFloat32Array([0.026, 0.024, 0.006]), 12, 0.40, skull_c))

	# NUCA BAJA — ronda 27 (CRITICAL del QA: "el tercio inferior de la
	# masa es una superficie continua sin ningún quiebre de valor, justo
	# donde el libro pide valles hondos para pelo oscuro"). Las tiras de
	# la pasada 2 mueren alrededor de y≈0.0 y por debajo el casquete
	# quedaba liso. Estas 5 corren SOBRE el casquete (lift 0.013 — apoyar
	# en el cráneo las dejaría enterradas dentro de él) y son anchas,
	# solapadas y de puntas romas: sobre una MASA leen como separación de
	# mechones, no como dientes (los dientes salían de piezas puntiagudas
	# sobre PIEL desnuda, ver corolario en Principios de Anatomía 3D).
	# Largos, anchos y desplazamientos irregulares entre vecinas.
	#              x0      x1      y0      y1      w      mat
	var lower_nape: Array = [
		[-0.078, -0.066,  0.030, -0.030,  0.026,  1],
		[-0.040, -0.048,  0.014, -0.052,  0.030,  0],
		[-0.004,  0.010,  0.026, -0.038,  0.024,  1],
		[ 0.038,  0.030,  0.010, -0.056,  0.031,  0],
		[ 0.074,  0.064,  0.032, -0.026,  0.025,  1],
	]
	for ln in lower_nape:
		var lmat: Material = lighter if int(ln[5]) == 0 else mat
		g.add_child(_lock(lmat, [
			_on_skull(ln[0], ln[2], 0.013, true),
			_on_skull((ln[0] + ln[1]) * 0.5, (ln[2] + ln[3]) * 0.5, 0.012, true),
			_on_skull(ln[1], ln[3], 0.010, true),
		], PackedFloat32Array([ln[4], ln[4] * 0.92, ln[4] * 0.60]),
			10, 0.18, skull_c))   # flatten bajo: cintas tendidas, no parches

	# --- PASADA 3: mechones CONTRASTANTES (pocos, rompen el patrón).
	# Uno cae del flequillo contra el barrido; uno se alza en la cresta;
	# uno escapa hacia la sien derecha cruzando el flow.
	g.add_child(_lock(lighter, [
		_on_skull(-0.018, 0.098, 0.006),
		_on_skull(-0.034, 0.070, 0.009),            # cae sobre la frente
	], PackedFloat32Array([0.013, 0.003]), 10, 0.55, skull_c))
	g.add_child(_lock(mat, [
		_on_skull(0.016, 0.150, 0.016),
		_on_skull(0.046, 0.152, 0.034),             # se alza sobre la cresta
		_on_skull(0.066, 0.148, 0.030, true),
	], PackedFloat32Array([0.011, 0.008, 0.003]), 10, 0.6, skull_c))
	g.add_child(_lock(darker, [
		_on_skull(0.052, 0.128, 0.008),
		_on_skull(0.090, 0.100, 0.008),             # cruza el flow hacia la sien
		_on_skull(0.100, 0.076, 0.004, true),
	], PackedFloat32Array([0.011, 0.008, 0.003]), 10, 0.5, skull_c))
	return g

# 11 — Prince Curtain (M10-r4, PRD "Cabello Estilizado Ondulado — Estilo
# Príncipe de Cuento"): reconstrucción por CAPAS de mechones-cinta (ribbon),
# no cilindros ni tablones rectos. r3b (150 tablillas rectas al radio
# exterior) leía como orejeras de casco de frente y borde-repisa plano de
# nuca por detrás — exactamente el defecto que el PRD señala evitar (§5).
# Capas (PRD §3): 1 base craneal (concha ajustada) + 7 flequillo/coronilla
# (define la raya y el barrido arriba-atrás) + 8 laterales sien/oreja
# (4 por lado) + 6 mechones sueltos que rompen la silueta — dos enmarcan
# el rostro, dos rompen el canto lateral, dos cubren la nuca con largos
# IRREGULARES para que no quede un borde recto. 22 mechones totales
# (rango recomendado 20-26). Cada mechón es una cinta curva en "S" con
# ancho variable (raíz ancha, punta fina) — PRD §4.
static func _hair_prince_curtain(mat: Material) -> Node3D:
	var g = Node3D.new()
	var shell_c := Vector3(0.0, R * 0.40, -R * 0.06)
	# Base craneal: la concha ajustada auto-recorta contra el cráneo
	# (misma técnica del frontier crop — Lección: cajas no abrazan esferas,
	# una elipse contra otra sí).
	var shell = _sphere(mat, R * 1.02, shell_c.x, shell_c.y, shell_c.z)
	shell.scale = Vector3(0.85, 0.72, 0.98)
	g.add_child(shell)
	# La CONCHA sola es un crop: para una MELENA la masa debe bajar. Dos
	# lóbulos más de la misma técnica (elipse contra elipse, auto-recorte):
	# (a) masa OCCIPITAL — cubre el occipucio hasta la línea de la nuca
	# (los ribbons van ENCIMA como textura, no son la única cobertura — con
	# 24 cintas quedaban parches de piel); semieje X menor que el cráneo →
	# se hunde a la vertical de las orejas (orejas visibles, review v0.5).
	var nape = _sphere(mat, R * 0.98, 0.0, R * 0.08, -R * 0.26)
	nape.scale = Vector3(0.84, 0.92, 0.80)
	g.add_child(nape)
	# (b) banda de FLEQUILLO frontal baja — de frente la concha sola leía
	# cúpula calva (hairline inexistente); esta banda pone la línea de
	# nacimiento y el arranque del barrido hacia atrás.
	# (Lecciones, margen REAL fuera de la superficie: la v1 de esta banda
	# llegaba a z=0.82R con el frontal del cráneo en ~0.97R — enterrada
	# entera. Esta alcanza z≈1.04R: emerge ~10 mm.)
	var fringe = _sphere(mat, R * 0.62, 0.0, R * 0.52, R * 0.28)
	fringe.scale = Vector3(1.04, 0.60, 1.22)
	fringe.rotation.x = 0.25
	g.add_child(fringe)
	# (c) REWORK de la capa corona (2026-07-12, feedback del director: "el
	# nacimiento parte desde la parte más alta y genera una curva para que el
	# cabello CAIGA" — leía Miguel Hidalgo, tonsura). Tres rondas de cintas
	# largas ancladas cerca del polo de LA CONCHA GRANDE fallaron siempre por
	# la misma causa: una cuerda recta viajando lejos desde cerca de un polo
	# convexo se reentierra sin importar el offset ni la dirección exacta
	# (enterrado / antena flotante / starburst horizontal — mismo problema,
	# tres síntomas). Rework, no parche: un lóbulo de VOLUMEN nuevo
	# (`crown_drape`, misma técnica elipse-contra-elipse que nape/fringe) que
	# por sí solo rompe la cúpula lisa con un bulto visible en la coronilla
	# real — sin matemática de cuerda-sobre-domo. Las cintas de textura de
	# abajo son CORTAS y anclan sobre ESTE lóbulo chico/achatado (no la concha
	# grande), lejos de SU propio polo — el mismo patrón de la capa lateral
	# que ya funciona, pero con radios pequeños donde los márgenes chicos
	# alcanzan de verdad.
	var crown_c := Vector3(0.0, R * 0.95, -R * 0.10)
	var crown_drape = _sphere(mat, R * 0.55, crown_c.x, crown_c.y, crown_c.z)
	crown_drape.scale = Vector3(0.85, 0.51, 1.05)
	crown_drape.rotation.x = -0.30
	g.add_child(crown_drape)

	# Tono alterno (+8% claro) para profundidad cel — un mechón entero es
	# un solo tono (no por segmento), así cada cinta lee como un plano de
	# luz/sombra distinto de su vecina (PRD §5, normal facetada).
	var lighter := mat
	if mat is ShaderMaterial:
		lighter = (mat as ShaderMaterial).duplicate()
		var base_col = (mat as ShaderMaterial).get_shader_parameter("albedo_color")
		if base_col != null:
			(lighter as ShaderMaterial).set_shader_parameter(
				"albedo_color", (base_col as Color).lightened(0.08))

	var mi: int = 0

	# ---- Capa CORONA: textura corta SOBRE `crown_drape` (no sobre la concha
	# grande — ver el comentario del lóbulo arriba). Anclas a solo ~35% del
	# semieje vertical del lóbulo chico (R*0.10 de R*0.28), lejos de SU propio
	# polo: el `normal` ahí ya trae suficiente componente horizontal real para
	# que `Vector3(0,-1,back) + normal*k` no degenere. Cintas CORTAS (4
	# segmentos, no 5) — si el margen no fuera perfecto, no alcanzan a viajar
	# lo bastante para reenterrarse en la concha grande de abajo.
	var CROWN := 9
	for i in range(CROWN):
		var a: float = lerp(-1.3, 1.3, (float(i) + 0.5) / float(CROWN))
		var ring_y: float = R * 0.10
		var ring_r: float = R * 0.30
		var anchor := crown_c + Vector3(sin(a) * ring_r, ring_y, cos(a) * ring_r)
		var normal := (anchor - crown_c).normalized()
		# Frontalidad ∈ [0,1]: 1 al frente (a≈0), 0 en los flancos. Los
		# frontales suman barrido atrás (para no tapar la cara) y acortan.
		var frontality: float = clampf(cos(a), 0.0, 1.0)
		var back_bias: float = -0.5 * frontality
		var flow := (Vector3(0.0, -1.0, back_bias) + normal * 0.40).normalized()
		var side := flow.cross(normal)
		if side.length() < 0.01:
			side = Vector3(1, 0, 0)
		var mbasis := Basis(side.normalized(), flow, normal)
		var v: float = 0.92 + 0.22 * float((i * 5) % 4) / 3.0
		# más corto al frente (no cae sobre los ojos), más largo a los flancos
		var length: float = R * (0.55 + 0.35 * (1.0 - frontality)) * v
		var sweep: float = R * 0.12 * (1.0 if i % 2 == 0 else -1.0)
		var spine := _s_spine(length, sweep, 4)
		var root: Vector3 = anchor + normal * R * 0.06
		var tone = mat if mi % 3 != 1 else lighter
		g.add_child(_ribbon(tone, spine, R * 0.22, R * 0.09, R * 0.07, root, mbasis))
		mi += 1

	# ---- Capa media: laterales, cubren sien + oreja (4 por lado = 8) ----
	for side_sign in [1.0, -1.0]:
		for i in range(4):
			var a: float = side_sign * lerp(0.60, 1.72, (float(i) + 0.5) / 4.0)
			var ring_y: float = R * 0.52
			var ring_r: float = R * 0.94
			var anchor := Vector3(sin(a) * ring_r, ring_y, cos(a) * ring_r - R * 0.06)
			var normal := (anchor - shell_c).normalized()
			var flow := (Vector3(0.0, -1.0, 0.0) + normal * 0.30).normalized()
			var side := flow.cross(normal)
			if side.length() < 0.01:
				side = Vector3(1, 0, 0)
			var mbasis := Basis(side.normalized(), flow, normal)
			var v: float = 0.88 + 0.28 * float((i * 7 + int(side_sign)) % 5) / 4.0
			var length: float = R * 1.02 * v
			var sweep: float = R * 0.13 * (0.5 if i % 2 == 0 else -0.5)
			var spine := _s_spine(length, sweep, 5)
			var root: Vector3 = anchor + normal * R * 0.04
			var tone = mat if mi % 3 != 1 else lighter
			g.add_child(_ribbon(tone, spine, R * 0.19, R * 0.08, R * 0.07, root, mbasis))
			mi += 1

	# ---- Capa externa: mechones sueltos que rompen silueta (6) ----
	# 2 enmarcan el rostro (más largos, delante) + 2 rompen el canto
	# lateral + 2 cubren la nuca con largos IRREGULARES (evita el
	# borde-repisa recto que la review v0.4 marcó como defecto).
	var loose_defs: Array = [
		# [a, ring_y, ring_r, length_mult, sweep_mult]
		[0.85, R * 0.50, R * 0.86, 1.18, 0.9],
		[-0.85, R * 0.50, R * 0.86, 1.12, -0.9],
		[1.95, R * 0.42, R * 0.90, 1.05, 1.1],
		[-1.95, R * 0.42, R * 0.90, 0.96, -1.1],
		[2.55, R * 0.38, R * 0.80, 1.10, 0.8],
		[-2.55, R * 0.38, R * 0.80, 0.92, -0.8],
		[2.95, R * 0.40, R * 0.80, 1.02, 0.6],
		[-2.95, R * 0.40, R * 0.80, 0.94, -0.6],
		[PI, R * 0.44, R * 0.78, 0.98, 0.5],
	]
	for def in loose_defs:
		var a: float = def[0]
		var ring_y: float = def[1]
		var ring_r: float = def[2]
		var anchor := Vector3(sin(a) * ring_r, ring_y, cos(a) * ring_r - R * 0.06)
		var normal := (anchor - shell_c).normalized()
		var flow := (Vector3(0.0, -1.0, 0.0) + normal * 0.45).normalized()
		var side := flow.cross(normal)
		if side.length() < 0.01:
			side = Vector3(1, 0, 0)
		var mbasis := Basis(side.normalized(), flow, normal)
		var length: float = R * 1.0 * float(def[3])
		var sweep: float = R * 0.20 * float(def[4])
		var spine := _s_spine(length, sweep, 5, 1.5)
		var root: Vector3 = anchor + normal * R * 0.05
		var tone = mat if mi % 3 != 1 else lighter
		g.add_child(_ribbon(tone, spine, R * 0.20, R * 0.07, R * 0.065, root, mbasis))
		mi += 1

	return g
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

# 1 — Stubble: FASE C paso 6 (luz verde director). La v1 usaba un shell
# translúcido (ALPHA) sobre TODA la mandíbula — pitfall del toon: el shader
# `toon_opaque` no escribe ALPHA (banding/artefactos, ver Lecciones). r6a
# (opaca única, revertida): tapaba la boca entera, leía "máscara". r6b/r6c/
# r6d/r6e (cadena de esferas en fila, overlap creciente): pasó de "perilla"
# a "collar de cuentas" a "masa sólida oscura" — cualquier fila 1D con
# suficiente overlap para fundirse en un contorno único termina leyendo
# como barba SÓLIDA pareja, no como sombra de vello de 3 días (que es
# ruidosa/parcial por naturaleza, no una silueta lisa).
# r6f (post-QA Ronda 2 + feedback del director): dispersión 2D de motas
# chicas con RNG determinista. r6g (post-QA Ronda 8, DESEMPATE — confirmado
# leyendo el código, no solo impresión): la primitiva elegida (N esferas
# aisladas, radio 0.007-0.011) NO PUEDE leer como masa continua a ninguna
# densidad razonable — a esta escala de low-poly toon, cualquier separación
# entre esferas se ve como "collar de cuentas/granos de café" sin importar
# cuántas se agreguen. El problema era de VOCABULARIO, no de tuning.
# Reemplazado por BLOQUE SÓLIDO CONTINUO (ref. `fenotipo-humano-torso-
# v1.png`, pedido directo del director): dos masas fundidas por overlap
# real (mismo truco que jaw/cheek) — bigote chico sobre el labio superior
# + una masa de mandíbula+mentón que sigue el contorno de `jaw_mesh` sin
# subir a la mejilla ni cruzar la línea de la boca. CONFIGURABLE: `density`
# (0..1) sigue existiendo, ahora escala el TAMAÑO de ambas masas (0 = sombra
# apenas insinuada y chica, 1 = barba corta pareja y más llena, tipo la
# lámina de torso) en vez de la cantidad de motas.
static func _beard_stubble(mat: Material, density: float = 0.4) -> Node3D:
	var g = Node3D.new()
	var stub_mat: Material = mat
	if mat is ShaderMaterial:
		var base_c = mat.get_shader_parameter("albedo_color")
		if base_c != null:
			stub_mat = mat.duplicate()
			stub_mat.set_shader_parameter("albedo_color", Color(base_c).darkened(0.12))

	var d: float = clamp(density, 0.0, 1.0)

	# bigote: masa chica y fina sobre el labio superior, sin tapar la boca.
	var m_scale: float = lerp(0.7, 1.05, d)
	g.add_child(_sphere(stub_mat, 0.020, 0.0, -0.053, 0.132, 1.5 * m_scale, 0.40 * m_scale, 0.42))

	# mandíbula + mentón: UNA masa continua (no esferas sueltas) siguiendo
	# el contorno del jaw, hundida por overlap real — sin subir a la
	# mejilla ni cruzar la línea de la boca (labio inferior en y=-0.087).
	# r6g-v2: el primer intento (sy=0.62) se extendía por debajo del mentón
	# real (jaw tip y=-0.149) hasta invadir el cuello. r6g-v3: SEGUÍA
	# leyendo como collar — la causa real era ANCHO, no largo: a la altura
	# y=-0.125 el `jaw_mesh` real ya mide solo ~6cm de semi-ancho (se angosta
	# hacia el mentón), y el disco de 7cm de semi-ancho sobresalía por los
	# COSTADOS del propio contorno de la mandíbula, leyendo como un aro
	# ancho. Achicado en X e Y para quedar DENTRO de la silueta del jaw en
	# toda su altura, no solo en el punto más ancho.
	# r6g-v4 (desempate): a y=-0.115 el `jaw_mesh` real todavía proyecta
	# hasta z≈0.110 — con semi-Z de solo ~1cm y z=0.075 la masa quedaba
	# DETRÁS de esa superficie = invisible, embebida. r6g-v5 (desempate de
	# nuevo): adelantarla 1.5cm SÍ la hizo visible, pero una ESFERA de ese
	# tamaño cae casi entera en la banda oscura del toon (curvatura
	# continua en todas direcciones) → leía como "bulto/tumor negro", no
	# vello. Mismo aprendizaje que `chin_boss` (Ronda 3, character_rig.gd
	# ~L809: "una esfera NUNCA da un borde recto") — CAJA en vez de esfera,
	# protrusión recortada (1.5cm→0.7cm) y menos alto (semi 2.3cm→1.6cm).
	# r6g-v6 (desempate, tercera vuelta): la caja ÚNICA de lados paralelos
	# no sigue la conicidad real de `jaw_mesh` (trapecio: ancho arriba,
	# angosto en el mentón) — leía "ladrillo pegado", con un borde inferior
	# recto cortando de golpe contra el cuello. Reemplazada por 3 cajas
	# ESCALONADAS (angostan Y retroceden en Z de arriba a abajo, siguiendo
	# la curva real del jaw en esa zona — ver comentario debajo con los
	# z_surface medidos en cada altura), con overlap real entre capas
	# consecutivas para fundirse en un contorno cónico, no un bloque recto.
	var jaw_scale: float = lerp(0.75, 1.05, d)
	# AJUSTE FINO post-QA (pulido MEDIUM, confirmado por el desempate):
	# quedaba un escalón de 90° visible en el costado (poco overlap Y entre
	# capas) y un borde inferior recto contra el cuello. Pasos de ancho más
	# chicos + más overlap vertical (h subida) suavizan el costado; una
	# esfera chica al final redondea la punta en vez de terminar en una
	# arista de caja.
	# L1 arriba (más ancha, jaw_surface≈0.126 a esa altura)
	g.add_child(_box(stub_mat, 0.086 * jaw_scale, 0.024 * jaw_scale, 0.017 * jaw_scale, 0.0, -0.102, 0.126))
	# L2 medio (jaw_surface≈0.110)
	g.add_child(_box(stub_mat, 0.074 * jaw_scale, 0.024 * jaw_scale, 0.016 * jaw_scale, 0.0, -0.114, 0.110))
	# L3 abajo (más angosta y con menos protrusión — jaw_surface≈0.100)
	g.add_child(_box(stub_mat, 0.060 * jaw_scale, 0.020 * jaw_scale, 0.012 * jaw_scale, 0.0, -0.124, 0.102))
	# remate redondeado: esfera chica en la punta, funde el borde inferior
	# de L3 en vez de terminar en arista recta contra el cuello.
	g.add_child(_sphere(stub_mat, 0.014 * jaw_scale, 0.0, -0.133, 0.096, 1.4, 0.6, 0.6))
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
