# character_signature.gd — piezas FIRMA de personajes nombrados: los extras
# de lámina que NO cubren fenotipo/origen/clase (charms, tatuajes, arma de
# espalda, props de cinturón). Se cuelgan de un CharacterRig ya construido
# usando las MISMAS primitivas y materiales toon del rig — cero cambios al
# rig base, 100% aditivo y reversible.
#
# data/characters.gd declara qué piezas lleva cada personaje ("signature").
# Loaded via preload (never class_name — see Lecciones).
extends RefCounted

# ---- mini helpers (mismo estilo que character_rig.gd / hair_library.gd) ----

static func _box(mat: Material, w: float, h: float, d: float,
		pos: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var m := BoxMesh.new()
	m.size = Vector3(w, h, d)
	mi.mesh = m
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	return mi

static func _cyl(mat: Material, top_r: float, bot_r: float, h: float,
		pos: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var m := CylinderMesh.new()
	m.top_radius = top_r
	m.bottom_radius = bot_r
	m.height = h
	mi.mesh = m
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	return mi

static func _torus(mat: Material, inner_r: float, outer_r: float,
		pos: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var m := TorusMesh.new()
	m.inner_radius = inner_r
	m.outer_radius = outer_r
	m.rings = 12
	m.ring_segments = 8
	mi.mesh = m
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	return mi

## Cuña: prisma triangular plano. rot.z = PI la deja con la punta ABAJO.
static func _wedge(mat: Material, w: float, h: float, d: float,
		pos: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var m := PrismMesh.new()
	m.size = Vector3(w, h, d)
	mi.mesh = m
	mi.material_override = mat
	mi.position = pos
	mi.rotation = rot
	return mi

static func _outline(_rig, _mi: MeshInstance3D, _base_color: Color) -> void:
	# C6 (2026-07-10): sin casco invertido — la tinta la pone el Sobel del
	# post (igual que el rig base). Call sites conservados como documentación.
	pass

# ---- materiales compartidos de la pasada (uno por attach) ----
# C6: variante OPACA (post-safe) — mismas razones que _init_materials del rig.

static func _steel() -> ShaderMaterial:
	return ToonMaterials.toon_mat_opaque(Color("#8f96a2"))

static func _bright_steel() -> ShaderMaterial:
	# Acero claro con rescoldo de forja: garantiza que la cuña se LEA
	# a distancia de cámara (ficha de Dagna: quedó tímida en la lámina).
	var m := ToonMaterials.toon_mat_opaque(Color("#d4d8e0"))
	m.set_shader_parameter("emission_color", Color(1.0, 0.55, 0.18, 1.0))
	m.set_shader_parameter("emission_strength", 0.85)
	return m

static func _wood() -> ShaderMaterial:
	return ToonMaterials.toon_mat_opaque(Color("#6b4a2e"))

static func _ink() -> StandardMaterial3D:
	# Tinta de gremio: terracota oscura plana (unshaded, como venas/ojos).
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	m.albedo_color = Color("#8a4a26")
	return m

# ================================================================
# API
# ================================================================

static func attach(rig, sig: Dictionary) -> void:
	if sig.get("guardian_tunic", false):
		_attach_guardian_tunic(rig)
	if sig.get("gate_pauldrons", false):
		_attach_gate_pauldrons(rig)
	if sig.get("shin_plates", false):
		_attach_shin_plates(rig)
	if sig.get("braid_wedge", false):
		_attach_braid_wedge(rig)
	if sig.get("forearm_guild_tattoos", false):
		_attach_forearm_tattoos(rig)
	if sig.get("gate_hammer", false):
		_attach_gate_hammer(rig)
	if sig.get("tool_belt", false):
		_attach_tool_belt(rig)
	if sig.get("waist_skirt", false):
		_attach_waist_skirt(rig)

## Limpia (si existe) un grupo firma previo del mismo nombre — idempotente.
static func _fresh_group(parent: Node3D, group_name: String) -> Node3D:
	var old := parent.get_node_or_null(NodePath(group_name))
	if old != null:
		parent.remove_child(old)
		old.queue_free()
	var g := Node3D.new()
	g.name = group_name
	parent.add_child(g)
	return g

# ================================================================
# 0a. Túnica de guardiana: camisa olivo sobre el torso (en la lámina NO se
# ve piel en el tronco — camisa gris-verde bajo chaleco de cuero) + correa
# del martillo re-dibujada ENCIMA de la túnica + botonadura frontal.
# El torso base del rig es skin_mat: sin esto, weight 1.0 lee "desnuda".
# ================================================================
static func _attach_guardian_tunic(rig) -> void:
	var g := _fresh_group(rig.upper_spine, "sig_guardian_tunic")
	var olive := ToonMaterials.toon_mat(Color("#5f6549"))

	# Camisa: cápsula apenas mayor que el torso, siguiendo su escala real.
	var shirt := MeshInstance3D.new()
	var m := CapsuleMesh.new()
	m.radius = 0.166
	m.height = 0.60
	shirt.mesh = m
	shirt.material_override = olive
	shirt.position = Vector3(0.0, 0.045, 0.0)
	shirt.scale = Vector3(rig.torso.scale.x * 1.04, 1.0, rig.torso.scale.z * 1.04)
	_outline(rig, shirt, Color("#5f6549"))
	g.add_child(shirt)

	# Correa del martillo sobre la túnica (la base queda debajo, invisible).
	var z_front: float = 0.166 * rig.torso.scale.z * 1.04 + 0.012
	var strap := _box(rig.dark_leather_mat, 0.075, 0.52, 0.018,
		Vector3(0.02, 0.06, z_front), Vector3(0.0, 0.0, 0.62))
	g.add_child(strap)

	# Botonadura del chaleco (línea frontal con 3 remaches).
	var placket := _box(rig.leather_mat, 0.05, 0.30, 0.014,
		Vector3(-0.06, 0.02, z_front - 0.002))
	g.add_child(placket)
	var steel := _steel()
	for i in range(3):
		g.add_child(_box(steel, 0.018, 0.018, 0.012,
			Vector3(-0.06, 0.11 - float(i) * 0.09, z_front + 0.006)))

# ================================================================
# 0b. Hombreras de compuerta (ambos hombros): placas de guardiana
# dimensionadas al brazo REAL (weight 1.0 + clase tragan las del rig base).
# Parented al torácico: no tocan el lookup de pauldron de _apply_build.
# ================================================================
static func _attach_gate_pauldrons(rig) -> void:
	var g := _fresh_group(rig.upper_spine, "sig_gate_pauldrons")
	var steel := _steel()
	var arm_r: float = 0.054 * (rig.arms[0].get_meta("upper") as MeshInstance3D).scale.x
	var x_out: float = 0.222 + arm_r * 0.4

	for side in [-1, 1]:
		var s := float(side)
		var p := Node3D.new()
		p.position = Vector3(s * x_out, 0.30, 0.0)
		p.rotation.z = s * -0.14
		g.add_child(p)

		var plate_a := _box(steel, 0.20, 0.045, 0.20, Vector3(s * 0.02, 0.0, 0.0))
		_outline(rig, plate_a, Color("#8f96a2"))
		p.add_child(plate_a)
		var plate_b := _box(steel, 0.155, 0.042, 0.16, Vector3(s * 0.025, 0.045, 0.0))
		_outline(rig, plate_b, Color("#8f96a2"))
		p.add_child(plate_b)
		# Ribete inferior de cuero (asiento de la placa).
		var trim := _box(rig.dark_leather_mat, 0.205, 0.018, 0.205, Vector3(s * 0.02, -0.03, 0.0))
		p.add_child(trim)
		# Grabado de compuerta: arco oscuro sobre la placa superior.
		p.add_child(_box(rig.dark_leather_mat, 0.10, 0.012, 0.13, Vector3(s * 0.025, 0.070, 0.0)))

# ================================================================
# 0c. Espinilleras de compuerta: placas frontales en ambas canillas
# (las greaves del rig base quedan dentro de la pierna a weight alto).
# ================================================================
static func _attach_shin_plates(rig) -> void:
	var steel := _steel()
	for leg in rig.legs:
		var knee: Node3D = leg.get_meta("knee")
		var shin: MeshInstance3D = leg.get_meta("shin")
		var g := _fresh_group(knee, "sig_shin_plate")
		var z_out: float = 0.055 * shin.scale.x + 0.012

		var plate := _box(steel, 0.11, 0.22, 0.035, Vector3(0.0, -0.20, z_out), Vector3(-0.04, 0.0, 0.0))
		_outline(rig, plate, Color("#8f96a2"))
		g.add_child(plate)
		# Rodillera.
		var cop := _box(steel, 0.09, 0.06, 0.04, Vector3(0.0, -0.035, z_out - 0.005))
		_outline(rig, cop, Color("#8f96a2"))
		g.add_child(cop)
		# Grabado horizontal (línea de compuerta).
		g.add_child(_box(rig.dark_leather_mat, 0.112, 0.012, 0.03, Vector3(0.0, -0.16, z_out + 0.006)))

# ================================================================
# 1. Anillas de forja + CUÑA miniatura — trenza IZQUIERDA (head space).
# La trenza izq. de Norse Braids (hair 1) arranca en (-0.1275,-0.02,0.02)
# y baja con paso (-0.004,-0.05,-0.004) — las anillas la abrazan y la cuña
# cuelga del último eslabón. Es el plant del objeto firma (la Primera Cuña).
# ================================================================
static func _attach_braid_wedge(rig) -> void:
	var g := _fresh_group(rig.head, "sig_braid_wedge")
	# La trenza cuelga al COSTADO del cuello (borde izquierdo), por DEBAJO del
	# borde de la hombrera y fuera de la silueta de la cara: así se lee de
	# perfil (su mejor vista) sin cruzarse sobre el rostro de frente. Apenas
	# adelante (+z) para no esconderse tras el pelo. La ficha exige la cuña.
	g.position = Vector3(-0.05, -0.02, 0.03)
	var steel := _steel()
	var bright := _bright_steel()

	# Anillas de forja bajando por el costado del cuello (bajo la mandíbula).
	var rings: Array = [
		[Vector3(-0.120, -0.10, 0.0), 0.028, 0.051],
		[Vector3(-0.124, -0.16, 0.0), 0.026, 0.048],
		[Vector3(-0.128, -0.22, 0.0), 0.024, 0.045],
	]
	for r in rings:
		var ring := _torus(bright, r[1], r[2], r[0])
		_outline(rig, ring, Color("#c9ced8"))
		g.add_child(ring)

	# Eslabón + CUÑA miniatura (grande, punta abajo) colgando bajo las anillas,
	# ya despejada de la hombrera (que es una placa fina a la altura del hombro).
	var link := _cyl(steel, 0.008, 0.008, 0.04, Vector3(-0.128, -0.27, 0.0))
	g.add_child(link)
	var wedge := _wedge(bright, 0.10, 0.13, 0.038,
		Vector3(-0.128, -0.35, 0.0), Vector3(0.0, 0.0, PI))
	_outline(rig, wedge, Color("#c9ced8"))
	g.add_child(wedge)

# ================================================================
# 2. Tatuajes de gremio (motivo de la Puerta: ARCO sobre rombo + CUÑA) en
# ambos antebrazos. El warpaint atlas solo mapea la CARA, así que el motivo
# va como decals de primitivas pegados al hueso del codo (mismo patrón que
# las venas arcanas del rig). Plano a 45° frente-exterior: se lee de frente
# Y de perfil.
# ================================================================
static func _attach_forearm_tattoos(rig) -> void:
	var ink := _ink()
	for arm in rig.arms:
		var side: int = arm.get_meta("side")
		var elbow: Node3D = arm.get_meta("elbow")
		var fore: MeshInstance3D = arm.get_meta("fore")
		var g := _fresh_group(elbow, "sig_guild_tattoo")

		# Radio efectivo del antebrazo (la cápsula escala con weight/clase).
		var r_eff: float = 0.047 * fore.scale.x + 0.006
		g.position = Vector3(float(side) * r_eff * 0.7071, -0.12, r_eff * 0.7071)
		g.rotation.y = float(side) * PI * 0.25

		# Rombo (4 trazos) — half-diagonals a=0.030 / b=0.042.
		var seg_len := 0.058
		var ang := 0.62
		var diamond: Array = [
			[Vector3(0.015, 0.021, 0.0), ang],
			[Vector3(0.015, -0.021, 0.0), -ang],
			[Vector3(-0.015, -0.021, 0.0), ang],
			[Vector3(-0.015, 0.021, 0.0), -ang],
		]
		for d in diamond:
			g.add_child(_box(ink, 0.008, seg_len, 0.006, d[0], Vector3(0.0, 0.0, d[1])))

		# Cuña sólida al centro del rombo (punta abajo).
		g.add_child(_wedge(ink, 0.026, 0.028, 0.006,
			Vector3(0.0, -0.002, 0.003), Vector3(0.0, 0.0, PI)))

		# Arco de la Puerta sobre el rombo (3 trazos).
		g.add_child(_box(ink, 0.008, 0.026, 0.006, Vector3(-0.026, 0.049, 0.0), Vector3(0.0, 0.0, 0.5)))
		g.add_child(_box(ink, 0.022, 0.008, 0.006, Vector3(0.0, 0.06, 0.0)))
		g.add_child(_box(ink, 0.008, 0.026, 0.006, Vector3(0.026, 0.049, 0.0), Vector3(0.0, 0.0, -0.5)))

		# Dos bandas hacia la muñeca (hatch del gremio en la lámina).
		g.add_child(_box(ink, 0.040, 0.007, 0.006, Vector3(0.0, -0.058, 0.0)))
		g.add_child(_box(ink, 0.034, 0.007, 0.006, Vector3(0.0, -0.072, 0.0)))

# ================================================================
# 3. Martillo-maza de cabezal PLANO (cabeza de ariete de puerta, no de
# guerra) cruzado a la espalda en diagonal — cabezal sobre el hombro
# IZQUIERDO, como en la vista trasera de la lámina.
# ================================================================
static func _attach_gate_hammer(rig) -> void:
	var g := _fresh_group(rig.upper_spine, "sig_gate_hammer")
	var steel := _steel()
	var wood := _wood()

	var z_back: float = -(0.16 * rig.torso.scale.z + 0.12)
	g.position = Vector3(0.0, 0.10, z_back)
	# Diagonal como en la vista trasera de la lámina: cabezal arriba sobre el
	# hombro DERECHO, mango bajando a la cadera izquierda.
	g.rotation.z = -0.55

	# Mango + grip envuelto.
	var handle := _cyl(wood, 0.016, 0.016, 0.62, Vector3.ZERO)
	_outline(rig, handle, Color("#6b4a2e"))
	g.add_child(handle)
	var grip := _cyl(rig.dark_leather_mat, 0.019, 0.019, 0.15, Vector3(0.0, -0.19, 0.0))
	g.add_child(grip)

	# Collar + cabezal de ariete: bloque plano con placa de golpe más ancha.
	var collar := _cyl(steel, 0.030, 0.030, 0.05, Vector3(0.0, 0.21, 0.0))
	g.add_child(collar)
	var head := _box(steel, 0.19, 0.10, 0.10, Vector3(0.0, 0.28, 0.0))
	_outline(rig, head, Color("#8f96a2"))
	g.add_child(head)
	var face := _box(steel, 0.024, 0.12, 0.12, Vector3(-0.105, 0.28, 0.0))
	_outline(rig, face, Color("#8f96a2"))
	g.add_child(face)
	# Grabado de compuerta en el costado del cabezal (línea de arco).
	var etch := _box(rig.dark_leather_mat, 0.14, 0.012, 0.104, Vector3(0.005, 0.30, 0.0))
	g.add_child(etch)

# ================================================================
# 4. Cinturón de guardiana: bolsas, martillito de mantenimiento y una cuña
# de repuesto colgando — la franja media ATAREADA que firma la lámina.
# ================================================================
static func _attach_tool_belt(rig) -> void:
	var g := _fresh_group(rig.hips, "sig_tool_belt")
	var steel := _steel()
	var hw: float = 0.135 * rig.pelvis.scale.x   # half-width real de la pelvis

	# Bolsa frontal izquierda (grande) y bolsa lateral derecha.
	var pouch_l := _box(rig.leather_mat, 0.09, 0.11, 0.05,
		Vector3(-hw * 0.75, -0.085, 0.105), Vector3(0.0, 0.12, 0.0))
	_outline(rig, pouch_l, Color("#6e3a1f"))
	g.add_child(pouch_l)
	var flap_l := _box(rig.dark_leather_mat, 0.095, 0.035, 0.055,
		Vector3(-hw * 0.75, -0.035, 0.105), Vector3(0.0, 0.12, 0.0))
	g.add_child(flap_l)
	var pouch_r := _box(rig.dark_leather_mat, 0.07, 0.09, 0.05,
		Vector3(hw + 0.02, -0.075, 0.03), Vector3(0.0, -0.5, 0.0))
	_outline(rig, pouch_r, Color("#3a1d10"))
	g.add_child(pouch_r)

	# Martillito de mantenimiento colgado (cabeza en el cinto, mango abajo).
	g.add_child(_box(steel, 0.055, 0.026, 0.026, Vector3(hw * 0.5, -0.05, 0.115)))
	g.add_child(_cyl(_wood(), 0.008, 0.008, 0.12, Vector3(hw * 0.5, -0.125, 0.115)))

	# Cuña de repuesto (eco del objeto firma) al frente-izquierda.
	var spare := _wedge(steel, 0.045, 0.05, 0.02,
		Vector3(-hw * 0.3, -0.105, 0.12), Vector3(0.0, 0.0, PI))
	_outline(rig, spare, Color("#8f96a2"))
	g.add_child(spare)

# ================================================================
# 5. Faldón de cuero a la rodilla (panel frontal + trasero): cierra la
# silueta acampanada de la lámina bajo el cinturón.
# ================================================================
static func _attach_waist_skirt(rig) -> void:
	var g := _fresh_group(rig.hips, "sig_waist_skirt")
	var w: float = 0.27 * rig.pelvis.scale.x * 0.95

	var front := _box(rig.leather_mat, w, 0.32, 0.02,
		Vector3(0.0, -0.225, 0.105), Vector3(0.10, 0.0, 0.0))
	_outline(rig, front, Color("#6e3a1f"))
	g.add_child(front)
	var back := _box(rig.leather_mat, w * 1.05, 0.34, 0.02,
		Vector3(0.0, -0.22, -0.095), Vector3(-0.10, 0.0, 0.0))
	_outline(rig, back, Color("#6e3a1f"))
	g.add_child(back)
	# Ribete inferior oscuro (lee el borde del fieltro).
	g.add_child(_box(rig.dark_leather_mat, w + 0.004, 0.03, 0.022,
		Vector3(0.0, -0.375, 0.12)))
	g.add_child(_box(rig.dark_leather_mat, w * 1.05 + 0.004, 0.03, 0.022,
		Vector3(0.0, -0.38, -0.11)))
