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
	# CONCHA AJUSTADA (r4c): elipsoide que se AUTO-RECORTA contra el
	# cráneo — dimensionado para emerger ~7 mm en parietales, coronilla y
	# occipucio, y HUNDIRSE bajo la superficie a la altura de las orejas y
	# la nuca baja. La línea del pelo SUBE sola en las sienes (fade, sin
	# borde-repisa) y orejas/nuca quedan de piel. Las cajas no pueden
	# abrazar una esfera (r4a tablones, r4b occipucio enterrado); una
	# elipse contra otra sí.
	var shell = _sphere(mat, R * 1.02, 0.0, R * 0.40, -R * 0.06)
	shell.scale = Vector3(0.85, 0.72, 0.98)
	g.add_child(shell)
	# QUIFF (v0.5 C1: CERO caras planas horizontales — las cajas coronaban
	# como birrete): masa REDONDEADA-angular de esferas escaladas, curva
	# superior ASIMÉTRICA más alta al frente, vector adelante-arriba-atrás.
	var quiff = _sphere(mat, R * 0.60, 0.0, R * 0.78, R * 0.22)
	quiff.scale = Vector3(1.02, 0.78, 1.30)
	quiff.rotation.x = -0.38
	g.add_child(quiff)
	# Cola del barrido: masa menor que decae hacia la coronilla-atrás
	var sweep = _sphere(mat, R * 0.48, 0.0, R * 0.86, -R * 0.28)
	sweep.scale = Vector3(0.92, 0.60, 1.25)
	sweep.rotation.x = -0.15
	g.add_child(sweep)

	# MECHONES (M10-r2, director: ~25–35): textura direccional de la
	# lámina — cuñas angulares en filas sobre la concha/quiff, TODAS
	# fluyendo hacia atrás, hundidas a media profundidad (el Sobel entinta
	# sus aristas como trazos de pelo en close-up; a distancia se funden).
	# Colocación DETERMINISTA (paridad CLI, cero random): 4 filas de
	# latitud × columnas, tamaño en cascada (frente grande → nuca chico),
	# tono alternado (base / +10% claro = profundidad cel de dos valores).
	var lighter := mat
	if mat is ShaderMaterial:
		lighter = (mat as ShaderMaterial).duplicate()
		var base_col = (mat as ShaderMaterial).get_shader_parameter("albedo_color")
		if base_col != null:
			(lighter as ShaderMaterial).set_shader_parameter(
				"albedo_color", (base_col as Color).lightened(0.10))
	# filas: [altura y, radio del anillo, nº mechones, escala, excluir_frente]
	# (r2b: las filas medias EXCLUYEN el sector frontal — ahí la masa la
	# ponen las esferas del quiff; mechones frontales leían como RULOS)
	var rows: Array = [
		[R * 0.96, R * 0.40, 7, 1.00, false],  # cresta del quiff
		[R * 0.80, R * 0.68, 9, 0.85, true],   # corona (sin frente)
		[R * 0.58, R * 0.88, 9, 0.70, true],   # parietales (sin frente)
		[R * 0.34, R * 0.96, 6, 0.55, true],   # baja trasera
	]
	var idx: int = 0
	for row in rows:
		var ry: float = row[0]
		var rr: float = row[1]
		var n: int = row[2]
		var s: float = row[3]
		var skip_front: bool = row[4]
		for i in range(n):
			var a0: float = -PI * 0.78
			var a1: float = PI * 0.78
			if ry >= R * 0.9:
				# cresta: arco ACOTADO a la corona (r2e — sus extremos
				# laterales asomaban como dientes en la silueta frontal)
				a0 = -PI * 0.55
				a1 = PI * 0.55
			if ry < R * 0.4:
				a0 = PI * 0.35
				a1 = PI * 1.65
			var a: float = a0 + (a1 - a0) * (float(i) + 0.5) / float(n)
			# filas marcadas: solo el sector TRASERO real, >104° (r2e — a
			# 90° exactos los mechones del borde eran los dientes de las
			# sienes; frente y corona ya los texturizan quiff + cresta)
			if skip_front and cos(a) > -0.25 and ry >= R * 0.4:
				continue
			var cx: float = sin(a) * rr
			var cz: float = cos(a) * rr - R * 0.06
			# variación determinista de tamaño/ángulo por índice
			var v: float = 0.85 + 0.3 * float((idx * 7) % 5) / 4.0
			# más DELGADOS (0.11) y hundidos: el sink CRECE hacia los
			# costados (r2c: los laterales asomaban como taquitos en la
			# silueta frontal) — y caen más pegados al casco
			var sink: float = 0.93 - 0.06 * absf(sin(a))
			var clump = _box(mat if idx % 3 != 1 else lighter,
				R * 0.30 * s * v, R * 0.11 * s, R * 0.46 * s * v,
				cx * sink, ry, cz * sink)
			# orientación: tangente al casco + barrido hacia ATRÁS
			clump.rotation.y = atan2(cx, cz + R * 0.5) * 0.55
			clump.rotation.x = -0.42 + ry / R * 0.28   # arriba más plano
			clump.rotation.z = sin(a) * -0.45          # acostado a los lados
			g.add_child(clump)
			idx += 1
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
