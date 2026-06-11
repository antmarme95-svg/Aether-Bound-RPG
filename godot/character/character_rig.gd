## CharacterRig — parametric anime humanoid, direct port of CharacterRig.js.
## All JS numeric constants are preserved exactly (positions, scales, thresholds).
## Pivots: body > hips/spine > head > sub-meshes, arms, legs — same hierarchy.
class_name CharacterRig extends Node3D

# ---- lerp helper ----
static func _lerp(a: float, b: float, t: float) -> float:
	return a + (b - a) * t

# ---- capsule helper ----
static func _capsule_mesh(r: float, len: float, mat: Material) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var mesh = CapsuleMesh.new()
	mesh.radius = r
	mesh.height = len + r * 2.0
	mi.mesh = mesh
	mi.material_override = mat
	return mi

# ---- box helper ----
static func _box_mesh(w: float, h: float, d: float, mat: Material) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(w, h, d)
	mi.mesh = mesh
	mi.material_override = mat
	return mi

# ---- sphere helper ----
static func _sphere_mesh(r: float, mat: Material) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var mesh = SphereMesh.new()
	mesh.radius = r
	mesh.height = r * 2.0
	mi.mesh = mesh
	mi.material_override = mat
	return mi

# ---- cylinder helper ----
static func _cylinder_mesh(top_r: float, bot_r: float, height: float, mat: Material) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.top_radius = top_r
	mesh.bottom_radius = bot_r
	mesh.height = height
	mi.mesh = mesh
	mi.material_override = mat
	return mi

# ---- disc (circle) helper (for iris/pupil — flat cylinder) ----
static func _disc_mesh(r: float, mat: Material) -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	var mesh = CylinderMesh.new()
	mesh.top_radius = r
	mesh.bottom_radius = r
	mesh.height = 0.002
	mi.mesh = mesh
	mi.material_override = mat
	return mi

# ----------------------------------------------------------------
# Scene nodes (mirrors JS property names where possible)
# ----------------------------------------------------------------
var body: Node3D
var hips: Node3D
var spine: Node3D
var head: Node3D
var hair_slot: Node3D
var beard_slot: Node3D
var feature_slot: Node3D
var tail_slot: Node3D

var pelvis: MeshInstance3D
var torso: MeshInstance3D
var jerkin: MeshInstance3D
var strap: MeshInstance3D
var goggles: Node3D
var skull: MeshInstance3D
var jaw_mesh: MeshInstance3D  # renamed from "jaw" to avoid shadowing Node3D.get_name
var cheeks: Array = []
var eyes: Array = []
var brows: Array = []
var legs: Array = []
var arms: Array = []
var prosthetic: Node3D
var veins: Array = []

# ---- materials (per-rig so colors are independent) ----
var skin_mat: ShaderMaterial
var head_mat: ShaderMaterial
var hair_mat: ShaderMaterial
var leather_mat: ShaderMaterial
var dark_leather_mat: ShaderMaterial
var metal_mat: ShaderMaterial
var accent_glow_mat: StandardMaterial3D
var vein_mat: StandardMaterial3D
var eye_white_mat: StandardMaterial3D
var iris_mat: StandardMaterial3D
var pupil_mat: StandardMaterial3D

var accent: Color = Color("#46e6ff")

# Motion / animation state
var _t: float = 0.0
var _phase: float = 0.0
var _motion_speed: float = 0.0
var _motion_crouch: bool = false
var _attack_timer: float = 0.0
var _attack_style: String = "melee"

# Cache keys to avoid redundant texture/hair rebuilds
var _head_tex_key: String = ""
var _hair_key: String = ""
var _beard_key: String = ""
var _origin_id: String = ""

# ----------------------------------------------------------------
func _ready() -> void:
	_init_materials()
	_build()
	# Apply default outline to body group (thickness 0.06, matches JS addOutline)
	_apply_outline_to_children(self, Color("#1c1d24"), 0.02)

func _init_materials() -> void:
	skin_mat = ToonMaterials.toon_mat(Color("#f2b186"))
	head_mat = ToonMaterials.toon_mat(Color("#ffffff"))
	hair_mat = ToonMaterials.toon_mat(Color("#b8451f"))
	leather_mat = ToonMaterials.toon_mat(Color("#5b4632"))
	dark_leather_mat = ToonMaterials.toon_mat(Color("#3a2d22"))
	metal_mat = ToonMaterials.toon_mat(Color("#6f7a88"))
	accent_glow_mat = ToonMaterials.glow_mat(accent, 1.2)
	vein_mat = ToonMaterials.glow_mat(accent, 0.8)

	eye_white_mat = StandardMaterial3D.new()
	eye_white_mat.albedo_color = Color("#f8f6f2")
	eye_white_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	iris_mat = StandardMaterial3D.new()
	iris_mat.albedo_color = accent
	iris_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	pupil_mat = StandardMaterial3D.new()
	pupil_mat.albedo_color = Color("#10131a")
	pupil_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

# ----------------------------------------------------------------
func _build() -> void:
	body = Node3D.new()
	body.name = "body"
	add_child(body)

	# ---------- legs ----------
	hips = Node3D.new()
	hips.name = "hips"
	hips.position.y = 0.95
	body.add_child(hips)

	pelvis = _box_mesh(0.27, 0.15, 0.17, dark_leather_mat)
	pelvis.name = "pelvis"
	pelvis.position.y = -0.02
	hips.add_child(pelvis)
	_add_outline_pass(pelvis, Color("#3a2d22"))

	var belt = _box_mesh(0.3, 0.05, 0.2, leather_mat)
	belt.position.y = 0.05
	hips.add_child(belt)
	_add_outline_pass(belt, Color("#5b4632"))

	var buckle = _box_mesh(0.06, 0.04, 0.02, accent_glow_mat)
	buckle.position = Vector3(0.05, 0.05, 0.105)
	buckle.name = "buckle_glow"
	hips.add_child(buckle)  # no outline on glow parts

	for side in [-1, 1]:
		var leg = Node3D.new()
		leg.name = "leg_" + ("l" if side == -1 else "r")
		leg.position = Vector3(side * 0.09, 0.0, 0.0)
		hips.add_child(leg)

		var thigh = _capsule_mesh(0.067, 0.27, dark_leather_mat)
		thigh.position.y = -0.21
		leg.add_child(thigh)
		_add_outline_pass(thigh, Color("#3a2d22"))

		var knee = Node3D.new()
		knee.name = "knee"
		knee.position.y = -0.45
		leg.add_child(knee)

		var shin = _capsule_mesh(0.055, 0.26, dark_leather_mat)
		shin.position.y = -0.2
		knee.add_child(shin)
		_add_outline_pass(shin, Color("#3a2d22"))

		var boot = _box_mesh(0.1, 0.08, 0.17, leather_mat)
		boot.position = Vector3(0.0, -0.45, 0.03)
		knee.add_child(boot)
		_add_outline_pass(boot, Color("#5b4632"))

		# Store sub-nodes in metadata (mirrors JS leg.userData)
		leg.set_meta("knee", knee)
		leg.set_meta("thigh", thigh)
		leg.set_meta("shin", shin)
		legs.append(leg)

	# ---------- torso ----------
	spine = Node3D.new()
	spine.name = "spine"
	spine.position.y = 1.0
	body.add_child(spine)

	torso = _capsule_mesh(0.16, 0.3, skin_mat)
	torso.position.y = 0.26
	spine.add_child(torso)
	_add_outline_pass(torso, Color("#f2b186"))

	jerkin = _capsule_mesh(0.165, 0.18, leather_mat)
	jerkin.position.y = 0.18
	spine.add_child(jerkin)
	_add_outline_pass(jerkin, Color("#5b4632"))

	strap = _box_mesh(0.07, 0.5, 0.02, dark_leather_mat)
	strap.position = Vector3(0.02, 0.28, 0.155)
	strap.rotation.z = 0.62
	spine.add_child(strap)
	_add_outline_pass(strap, Color("#3a2d22"))

	# Pauldron is built AFTER arms loop so arm_r (arms[1], side==1) exists.
	# It will be added to arm_r after that loop runs — placeholder here.

	# ---------- arms ----------
	for side in [-1, 1]:
		var arm = Node3D.new()
		arm.name = "arm_" + ("l" if side == -1 else "r")
		# JS: arm.position.set(side * 0.222, 0.45, 0)
		arm.position = Vector3(side * 0.222, 0.45, 0.0)
		spine.add_child(arm)

		var upper = _capsule_mesh(0.054, 0.2, skin_mat)
		upper.position.y = -0.14
		arm.add_child(upper)
		_add_outline_pass(upper, Color("#f2b186"))

		var elbow = Node3D.new()
		elbow.name = "elbow"
		elbow.position.y = -0.3
		arm.add_child(elbow)

		var fore = _capsule_mesh(0.047, 0.18, skin_mat)
		fore.position.y = -0.12
		elbow.add_child(fore)
		_add_outline_pass(fore, Color("#f2b186"))

		var hand = _sphere_mesh(0.052, skin_mat)
		hand.position.y = -0.26
		elbow.add_child(hand)
		_add_outline_pass(hand, Color("#f2b186"))

		arm.set_meta("elbow", elbow)
		arm.set_meta("upper", upper)
		arm.set_meta("fore", fore)
		arm.set_meta("hand", hand)
		arm.set_meta("side", side)
		arms.append(arm)

	# ---------- pauldron (right shoulder armor) ----------
	# Parent to arm_r (arms[1], side==1) so it sits on the shoulder joint and follows arm swing.
	# Local position (0, 0.03, 0) = just above the arm root = top of shoulder cap.
	var arm_r: Node3D = arms[1]
	var pauldron = Node3D.new()
	pauldron.position = Vector3(0.0, 0.03, 0.0)
	pauldron.rotation.z = -0.12
	var plate_a = _box_mesh(0.13, 0.035, 0.14, metal_mat)
	_add_outline_pass(plate_a, Color("#6f7a88"))
	var plate_b = _box_mesh(0.10, 0.03, 0.11, metal_mat)
	plate_b.position.y = 0.04
	_add_outline_pass(plate_b, Color("#6f7a88"))
	var stud = _box_mesh(0.035, 0.02, 0.035, accent_glow_mat)
	stud.position.y = 0.065
	pauldron.add_child(plate_a)
	pauldron.add_child(plate_b)
	pauldron.add_child(stud)  # stud = glow, no outline
	arm_r.add_child(pauldron)

	# Prosthetic aether forearm (left arm [0], shown at high arcaneMod)
	var left_elbow: Node3D = arms[0].get_meta("elbow")
	prosthetic = Node3D.new()
	prosthetic.name = "prosthetic"

	var proseg = _box_mesh(0.075, 0.2, 0.075, metal_mat)
	proseg.position.y = -0.12
	_add_outline_pass(proseg, Color("#6f7a88"))

	var seam1 = _box_mesh(0.012, 0.18, 0.078, vein_mat)
	seam1.position = Vector3(0.034, -0.12, 0.0)
	# seam1 = glow, no outline

	var fist = _box_mesh(0.085, 0.07, 0.08, metal_mat)
	fist.position.y = -0.26
	_add_outline_pass(fist, Color("#6f7a88"))

	var knuckle = _box_mesh(0.087, 0.018, 0.082, vein_mat)
	knuckle.position.y = -0.235
	# knuckle = glow, no outline

	prosthetic.add_child(proseg)
	prosthetic.add_child(seam1)
	prosthetic.add_child(fist)
	prosthetic.add_child(knuckle)
	prosthetic.visible = false
	left_elbow.add_child(prosthetic)

	# ---------- head ----------
	var neck = _capsule_mesh(0.05, 0.07, skin_mat)
	neck.position.y = 0.58
	spine.add_child(neck)
	_add_outline_pass(neck, Color("#f2b186"))

	head = Node3D.new()
	head.name = "head"
	head.position.y = 0.7
	spine.add_child(head)

	skull = _sphere_mesh(0.15, head_mat)
	skull.name = "skull"
	skull.scale.y = 1.07
	# Godot SphereMesh: seam at -Z, so u=0.5 (face strip) faces +Z by default.
	# No Y rotation needed — camera at +Z sees the face strip directly.
	skull.rotation.y = 0.0
	head.add_child(skull)
	_add_outline_pass(skull, Color("#f2b186"))

	jaw_mesh = _box_mesh(0.165, 0.075, 0.13, head_mat)
	jaw_mesh.name = "jaw"
	jaw_mesh.position = Vector3(0.0, -0.105, 0.062)
	head.add_child(jaw_mesh)
	_add_outline_pass(jaw_mesh, Color("#f2b186"))

	cheeks = []
	for side in [-1, 1]:
		var cheek = _sphere_mesh(0.036, head_mat)
		cheek.position = Vector3(side * 0.088, -0.018, 0.108)
		head.add_child(cheek)
		_add_outline_pass(cheek, Color("#f2b186"))
		cheeks.append(cheek)

	eyes = []
	brows = []
	for side in [-1, 1]:
		var eye_group = Node3D.new()
		eye_group.name = "eye_" + ("l" if side == -1 else "r")
		# JS: eye.position.set(side * 0.058, 0.018, 0.136)
		eye_group.position = Vector3(side * 0.058, 0.018, 0.136)

		var white = _sphere_mesh(0.034, eye_white_mat)
		white.scale.z = 0.55
		eye_group.add_child(white)

		var iris = _disc_mesh(0.0185, iris_mat)
		iris.rotation.x = PI / 2.0
		iris.position.z = 0.0195
		eye_group.add_child(iris)

		var pupil = _disc_mesh(0.009, pupil_mat)
		pupil.rotation.x = PI / 2.0
		pupil.position.z = 0.0205
		eye_group.add_child(pupil)

		var glint = _disc_mesh(0.0045, eye_white_mat)
		glint.rotation.x = PI / 2.0
		glint.position = Vector3(0.006, 0.007, 0.021)
		eye_group.add_child(glint)

		eye_group.set_meta("side", side)
		head.add_child(eye_group)
		eyes.append(eye_group)

		# JS: brow.position.set(side * 0.058, 0.07, 0.146)
		var brow = _box_mesh(0.055, 0.012, 0.012, pupil_mat)
		brow.position = Vector3(side * 0.058, 0.07, 0.146)
		head.add_child(brow)
		brows.append(brow)

	# Technomagic goggles (visible at mid arcaneMod > 0.38)
	goggles = Node3D.new()
	goggles.name = "goggles"
	var band = _box_mesh(0.31, 0.03, 0.03, dark_leather_mat)
	band.position = Vector3(0.0, 0.095, 0.0)
	_add_outline_pass(band, Color("#3a2d22"))
	goggles.add_child(band)

	var lens_l = _cylinder_mesh(0.035, 0.035, 0.03, metal_mat)
	lens_l.rotation.x = PI / 2.0
	lens_l.position = Vector3(-0.055, 0.095, 0.125)
	_add_outline_pass(lens_l, Color("#6f7a88"))
	goggles.add_child(lens_l)

	var lens_r = _cylinder_mesh(0.035, 0.035, 0.03, metal_mat)
	lens_r.rotation.x = PI / 2.0
	lens_r.position = Vector3(0.055, 0.095, 0.125)
	_add_outline_pass(lens_r, Color("#6f7a88"))
	goggles.add_child(lens_r)

	var lens_glow_l = _disc_mesh(0.026, accent_glow_mat)
	lens_glow_l.rotation.x = PI / 2.0
	lens_glow_l.position = Vector3(-0.055, 0.095, 0.142)
	goggles.add_child(lens_glow_l)

	var lens_glow_r = _disc_mesh(0.026, accent_glow_mat)
	lens_glow_r.rotation.x = PI / 2.0
	lens_glow_r.position = Vector3(0.055, 0.095, 0.142)
	goggles.add_child(lens_glow_r)

	goggles.visible = false
	head.add_child(goggles)

	# Hair / beard slots
	hair_slot = Node3D.new()
	hair_slot.name = "hair_slot"
	beard_slot = Node3D.new()
	beard_slot.name = "beard_slot"
	head.add_child(hair_slot)
	head.add_child(beard_slot)

	# Origin feature slot (ears, etc.) attached to head; tail to hips
	feature_slot = Node3D.new()
	feature_slot.name = "feature_slot"
	head.add_child(feature_slot)

	tail_slot = Node3D.new()
	tail_slot.name = "tail_slot"
	hips.add_child(tail_slot)

	# Glowing mana veins (visible when arcaneMod > 0.06)
	# JS veinDefs: [parent, x, y, z, w, h]
	var vein_defs: Array = [
		[arms[1],                                    0.045,  -0.1,   0.02,  0.012, 0.16],  # right upper arm
		[arms[1].get_meta("elbow"),                  0.04,   -0.1,   0.015, 0.01,  0.13],  # right forearm
		[spine,                                      0.1,     0.32,  0.145, 0.014, 0.2 ],  # chest line
		[spine,                                     -0.06,    0.5,   0.12,  0.01,  0.09],  # neck side
		[legs[0].get_meta("knee"),                  -0.04,  -0.16,   0.045, 0.01,  0.14],  # left shin
	]
	veins = []
	for def in vein_defs:
		var parent_node: Node3D = def[0]
		var vein = _box_mesh(def[4], def[5], def[4], vein_mat)
		vein.position = Vector3(def[1], def[2], def[3])
		vein.rotation.z = 0.18
		vein.visible = false
		parent_node.add_child(vein)
		veins.append(vein)

# ---- helper: attach outline next_pass to a MeshInstance3D ----
func _add_outline_pass(mi: MeshInstance3D, base_color: Color, thickness: float = 0.02) -> void:
	if mi.material_override != null:
		ToonMaterials.add_outline(mi.material_override, base_color, thickness)

# ---- helper: recurse node tree and add outlines ----
func _apply_outline_to_children(node: Node, base_color: Color, thickness: float) -> void:
	if node is MeshInstance3D:
		var mi = node as MeshInstance3D
		if mi.material_override != null and not (mi.material_override is StandardMaterial3D and (mi.material_override as StandardMaterial3D).emission_enabled):
			_add_outline_pass(mi, base_color, thickness)
	for child in node.get_children():
		_apply_outline_to_children(child, base_color, thickness)

# ================================================================
# apply_phenotype — live-update all sliders. Mirrors JS applyPhenotype exactly.
# p: Dictionary with same keys as PhenotypeData.default_phenotype()
# origin: Dictionary from OriginsData.get_origin(id)
# ================================================================
func apply_phenotype(p: Dictionary, origin: Dictionary) -> void:
	# ---- body & tech ----
	var w: float = p.get("weight", 0.5)
	var limb: float = _lerp(0.82, 1.42, w)

	torso.scale = Vector3(_lerp(0.84, 1.34, w), 1.0, _lerp(0.86, 1.26, w))
	jerkin.scale = Vector3(_lerp(0.86, 1.36, w), 1.0, _lerp(0.88, 1.28, w))
	pelvis.scale = Vector3(_lerp(0.88, 1.25, w), 1.0, 1.0)

	for arm in arms:
		var upper: MeshInstance3D = arm.get_meta("upper")
		var fore: MeshInstance3D = arm.get_meta("fore")
		upper.scale = Vector3(limb, 1.0, limb)
		fore.scale = Vector3(limb, 1.0, limb)

	for leg in legs:
		var thigh: MeshInstance3D = leg.get_meta("thigh")
		var shin: MeshInstance3D = leg.get_meta("shin")
		thigh.scale = Vector3(limb, 1.0, limb)
		shin.scale = Vector3(limb, 1.0, limb)

	# Height: uniform root scale within origin heightRange
	var range_arr: Array = origin.get("heightRange", [0.94, 1.1])
	scale = Vector3.ONE * _lerp(float(range_arr[0]), float(range_arr[1]), p.get("height", 0.5))

	# Arcane modification thresholds (JS: >0.06, >0.38, >0.68)
	var mod: float = p.get("arcaneMod", 0.0)
	for vein in veins:
		vein.visible = mod > 0.06
	# Vein color: JS: veinMat.color.copy(accent).multiplyScalar(0.35 + mod * 1.8)
	var vein_brightness: float = 0.35 + mod * 1.8
	vein_mat.albedo_color = accent * vein_brightness
	vein_mat.emission = accent * vein_brightness

	goggles.visible = mod > 0.38

	var prosthetic_on: bool = mod > 0.68
	prosthetic.visible = prosthetic_on
	var left_fore: MeshInstance3D = arms[0].get_meta("fore")
	var left_hand: MeshInstance3D = arms[0].get_meta("hand")
	left_fore.visible = not prosthetic_on
	left_hand.visible = not prosthetic_on

	# ---- face structure ----
	# JS jaw.scale: lerp(0.72..1.28, 0.85..1.18, 0.8..1.22)
	var jaw_v: float = p.get("jaw", 0.5)
	jaw_mesh.scale = Vector3(
		_lerp(0.72, 1.28, jaw_v),
		_lerp(0.85, 1.18, jaw_v),
		_lerp(0.8, 1.22, jaw_v)
	)

	# JS cheek.position.y = lerp(-0.045, 0.012, cheek), scale lerp(0.75..1.3)
	var cheek_v: float = p.get("cheek", 0.5)
	for cheek in cheeks:
		cheek.position.y = _lerp(-0.045, 0.012, cheek_v)
		var cheek_s: float = _lerp(0.75, 1.3, cheek_v)
		cheek.scale = Vector3(cheek_s, cheek_s, cheek_s)

	# JS eyes: rotation.z = side * lerp(-0.32, 0.26, eyeTilt), scale.y = lerp(0.5, 1.3, eyeShape)
	# JS brows: rotation.z = side * lerp(-0.4, 0.18, eyeTilt)
	var eye_tilt: float = p.get("eyeTilt", 0.5)
	var eye_shape: float = p.get("eyeShape", 0.5)
	for i in range(eyes.size()):
		var eye = eyes[i]
		var side: int = eye.get_meta("side")
		eye.rotation.z = float(side) * _lerp(-0.32, 0.26, eye_tilt)
		eye.scale.y = _lerp(0.5, 1.3, eye_shape)
		brows[i].rotation.z = float(side) * _lerp(-0.4, 0.18, eye_tilt)

	# ---- colors ----
	var skin_tones: Array = PaletteData.SKIN_TONES
	var hair_colors: Array = PaletteData.HAIR_COLORS
	var paint_colors: Array = PaletteData.PAINT_COLORS

	var skin_idx: int = int(p.get("skinTone", 1))
	var hair_idx: int = int(p.get("hairColor", 0))
	var paint_idx: int = int(p.get("paintColor", 0))

	var skin_color: Color = skin_tones[clamp(skin_idx, 0, skin_tones.size() - 1)]
	var hair_color: Color = hair_colors[clamp(hair_idx, 0, hair_colors.size() - 1)]
	var paint_color: Color = paint_colors[clamp(paint_idx, 0, paint_colors.size() - 1)]

	skin_mat.set_shader_parameter("albedo_color", skin_color)
	hair_mat.set_shader_parameter("albedo_color", hair_color)

	# Head texture (warpaint atlas)
	var warpaint_idx: int = int(p.get("warpaint", 0))
	var tex_key = skin_color.to_html() + "|" + str(warpaint_idx) + "|" + paint_color.to_html()
	if tex_key != _head_tex_key:
		_head_tex_key = tex_key
		var new_tex = WarpaintAtlas.build_head_texture(skin_color, warpaint_idx, paint_color)
		head_mat = ToonMaterials.toon_mat_textured(new_tex)
		skull.material_override = head_mat
		jaw_mesh.material_override = head_mat
		for cheek in cheeks:
			cheek.material_override = head_mat

	# ---- hair swap ----
	var hair_style: int = int(p.get("hair", 0))
	var hair_k = str(hair_style)
	if hair_k != _hair_key:
		_hair_key = hair_k
		for child in hair_slot.get_children():
			hair_slot.remove_child(child)
			child.queue_free()
		var built = HairLibrary.build_hair(hair_style, hair_mat)
		if built != null:
			_apply_outline_to_children(built, hair_color, 0.025)
			hair_slot.add_child(built)

	# ---- beard swap ----
	var beard_style: int = int(p.get("beard", 0))
	var beard_k = str(beard_style)
	if beard_k != _beard_key:
		_beard_key = beard_k
		for child in beard_slot.get_children():
			beard_slot.remove_child(child)
			child.queue_free()
		var built_b = HairLibrary.build_beard(beard_style, hair_mat)
		if built_b != null and built_b.get_child_count() > 0:
			_apply_outline_to_children(built_b, hair_color, 0.025)
			beard_slot.add_child(built_b)

	# ---- origin features (ears, tail, accent) ----
	var origin_id: String = origin.get("id", "")
	if origin_id != _origin_id:
		_origin_id = origin_id
		var theme: Dictionary = origin.get("theme", {})
		var accent_hex: String = theme.get("accent", "#46e6ff")
		accent = Color(accent_hex)
		iris_mat.albedo_color = accent
		accent_glow_mat.albedo_color = accent * 1.2
		accent_glow_mat.emission = accent * 1.2
		_build_origin_features(origin)

func _build_origin_features(origin: Dictionary) -> void:
	for child in feature_slot.get_children():
		feature_slot.remove_child(child)
		child.queue_free()
	for child in tail_slot.get_children():
		tail_slot.remove_child(child)
		child.queue_free()

	var id: String = origin.get("id", "")

	if id == "aetherborn":
		# Long pointed elven ears (ConeGeometry(0.026, 0.14, 6))
		for side in [-1, 1]:
			var ear = MeshInstance3D.new()
			var mesh = CylinderMesh.new()
			mesh.top_radius = 0.001
			mesh.bottom_radius = 0.026
			mesh.height = 0.14
			ear.mesh = mesh
			ear.material_override = skin_mat
			# JS: ear.position.set(side*0.155, 0.02, -0.01), rotation.z = side*-1.95, rotation.x = -0.25
			# Nudge z to 0.0 so the cone tip clears the skull silhouette from front view
			ear.position = Vector3(side * 0.155, 0.02, 0.0)
			ear.rotation = Vector3(-0.25, 0.0, float(side) * -1.95)
			_add_outline_pass(ear, Color("#f2b186"), 0.02)
			feature_slot.add_child(ear)

	elif id == "miststalker":
		# Beastfolk ears (ConeGeometry(0.045, 0.11, 5)) using hair color
		for side in [-1, 1]:
			var ear = MeshInstance3D.new()
			var mesh = CylinderMesh.new()
			mesh.top_radius = 0.001
			mesh.bottom_radius = 0.045
			mesh.height = 0.11
			ear.mesh = mesh
			ear.material_override = hair_mat
			# JS: ear.position.set(side*0.082, 0.15, -0.02), rotation.z = side*-0.35
			# Nudge z to 0.0 so ear base sits at skull equator and is visible from front
			ear.position = Vector3(side * 0.082, 0.15, 0.0)
			ear.rotation.z = float(side) * -0.35
			_add_outline_pass(ear, Color("#b8451f"), 0.02)
			feature_slot.add_child(ear)

		# Tail: 6 sphere segments tapering from hips (attached to tail_slot on hips)
		var tail = Node3D.new()
		var r: float = 0.035
		for i in range(6):
			var seg = MeshInstance3D.new()
			var smesh = SphereMesh.new()
			smesh.radius = r
			smesh.height = r * 2.0
			seg.mesh = smesh
			seg.material_override = hair_mat
			# JS: seg.position.set(0, -0.05 - i*0.012, -0.12 - i*0.07)
			seg.position = Vector3(0.0, -0.05 - float(i) * 0.012, -0.12 - float(i) * 0.07)
			_add_outline_pass(seg, Color("#b8451f"), 0.02)
			tail.add_child(seg)
			r *= 0.92
		tail_slot.add_child(tail)

	else:
		# Ironblooded: compact round ears (SphereGeometry(0.032))
		for side in [-1, 1]:
			var ear = MeshInstance3D.new()
			var smesh = SphereMesh.new()
			smesh.radius = 0.032
			smesh.height = 0.064
			ear.mesh = smesh
			ear.material_override = skin_mat
			# JS: ear.position.set(side*0.148, 0.0, 0.0)
			ear.position = Vector3(side * 0.148, 0.0, 0.0)
			_add_outline_pass(ear, Color("#f2b186"), 0.02)
			feature_slot.add_child(ear)

# ================================================================
# Motion API — mirrors JS setMotion / playAttack / update
# ================================================================

## Set locomotion parameters (speed 0..1, crouch bool).
func set_motion(speed_norm: float, crouch: bool) -> void:
	_motion_speed = speed_norm
	_motion_crouch = crouch

## Trigger an attack animation. kind = "melee" or "bolt".
func play_attack(kind: String) -> void:
	_attack_style = kind
	_attack_timer = 0.38

func _process(delta: float) -> void:
	_t += delta
	var speed: float = _motion_speed
	var crouch: bool = _motion_crouch

	# Locomotion phase advance (JS: phase += dt * (6.5 + 7.5*speed))
	if speed > 0.02:
		_phase += delta * (6.5 + 7.5 * speed)

	var amp: float = min(speed, 1.0) * 0.62
	var swing: float = sin(_phase) * amp

	# Leg swing (JS direct port)
	if legs.size() >= 2:
		legs[0].rotation.x = swing
		legs[1].rotation.x = -swing
		var knee0: Node3D = legs[0].get_meta("knee")
		var knee1: Node3D = legs[1].get_meta("knee")
		knee0.rotation.x = max(0.0, -sin(_phase)) * amp * 1.1
		knee1.rotation.x = max(0.0, sin(_phase)) * amp * 1.1

	# Arm swing (JS: armSwing = swing * 0.75)
	var arm_swing: float = swing * 0.75
	if _attack_timer <= 0.0 and arms.size() >= 2:
		arms[0].rotation.x = -arm_swing
		arms[1].rotation.x = arm_swing
		arms[0].rotation.z = 0.1
		arms[1].rotation.z = -0.1
		var e0: Node3D = arms[0].get_meta("elbow")
		var e1: Node3D = arms[1].get_meta("elbow")
		e0.rotation.x = -0.25 - max(0.0, arm_swing) * 0.6
		e1.rotation.x = -0.25 - max(0.0, -arm_swing) * 0.6

	# Attack envelope (JS: wind-up then snap)
	if _attack_timer > 0.0:
		_attack_timer -= delta
		var k: float = 1.0 - max(_attack_timer, 0.0) / 0.38  # 0→1
		var snap: float
		if k < 0.35:
			snap = -1.0 - k * 2.2
		else:
			snap = _lerp(-1.8, 0.4, (k - 0.35) / 0.65)

		if arms.size() >= 2:
			if _attack_style == "bolt":
				arms[0].rotation.x = snap * 0.8
				arms[1].rotation.x = snap
				arms[1].get_meta("elbow").rotation.x = -0.1
			else:
				arms[1].rotation.x = snap
				arms[1].rotation.z = -0.35
				arms[1].get_meta("elbow").rotation.x = -0.15

	# Crouch / breathe (JS: body.position.y lerp toward crouchY, spine.rotation.x lerp)
	var crouch_y: float = -0.17 if crouch else 0.0
	body.position.y += (crouch_y - body.position.y) * min(1.0, delta * 10.0)
	var lean: float = 0.24 if crouch else 0.0
	spine.rotation.x += (lean - spine.rotation.x) * min(1.0, delta * 10.0)

	# Idle breathe (JS: torso.scale.y = 1 + sin(t*2.1)*0.012)
	torso.scale.y = 1.0 + sin(_t * 2.1) * 0.012

	# Beast tail sway (JS: tailSlot.rotation.y = sin(t*1.7)*0.25 + swing*0.3)
	if tail_slot.get_child_count() > 0:
		tail_slot.rotation.y = sin(_t * 1.7) * 0.25 + swing * 0.3
