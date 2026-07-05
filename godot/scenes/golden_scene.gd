# golden_scene.gd — "Golden scene" diorama (B11, Art Bible test bed).
# A tiny postcard clearing chasing the ratified keyframes
# (90-Raw/concept/keyframe-wilds-{dawn,dusk}-v1.png). Deliberately NOT built
# from the_wilds.gd — only look-agnostic tech is inherited (toon shader file,
# procedural mesh patterns). All look decisions come from the keyframes.
#
# Usage:
#   var gs = GoldenScene.new()
#   root.add_child(gs)
#   gs.apply_time_preset("dawn")   # or "dusk"
#   gs.attach_post(camera)         # fullscreen 4-layer pass
extends Node3D
class_name GoldenScene

const _TOON := preload("res://rendering/toon_golden.gdshader")
const _POST := preload("res://rendering/melancolia_post.gdshader")

# ---- keyframe palettes (sampled from the ratified concept art) ----
const PRESETS := {
	"dawn": {
		"sky_top": Color("#b4d7e8"), "sky_horizon": Color("#f2cd96"),
		"ground_horizon": Color("#ecd2a2"), "ground_bottom": Color("#aab883"),
		"sun_color": Color("#ffe9c0"), "sun_energy": 1.35,
		"sun_elev_deg": -12.0, "sun_azim_deg": 190.0,
		"ambient": Color("#e8dcc0"), "ambient_energy": 1.15,
		"shadow_opacity": 0.42,
		"rim": Color("#f2e6c8"), "rim_strength": 0.08,
		"aerial": Color("#c4d2da"), "glow": Color("#ffe9bd"), "glow_strength": 0.38,
		"ray_color": Color("#ffe2ac"), "ray_strength": 0.55,
		"grass": Color("#b4c184"), "grass_lush": Color("#9fb476"),
		"path": Color("#dccda4"),
		"foliage": Color("#94aa6e"), "foliage_dark": Color("#7e9a62"),
		"trunk": Color("#8a6f52"),
		"forest_mass": Color("#92aa80"),
		"mountain": Color("#b9cbd9"), "mountain_far": Color("#c9d7e2"),
		"island": Color("#c3d2de"),
		"core_albedo": Color("#a8182e"), "core_glow": Color("#c81f3a"),
		"core_emission": 1.7,
	},
	"dusk": {
		"sky_top": Color("#3f4677"), "sky_horizon": Color("#a98fb4"),
		"ground_horizon": Color("#767693"), "ground_bottom": Color("#4b544e"),
		"sun_color": Color("#b8a4d8"), "sun_energy": 0.5,
		"sun_elev_deg": -8.0, "sun_azim_deg": 200.0,
		"ambient": Color("#5d6284"), "ambient_energy": 0.78,
		"shadow_opacity": 0.75,
		"rim": Color("#8a95b5"), "rim_strength": 0.03,
		"aerial": Color("#6b7799"), "glow": Color("#4de0d8"), "glow_strength": 0.30,
		"ray_color": Color("#b39ad0"), "ray_strength": 0.12,
		"grass": Color("#49544f"), "grass_lush": Color("#3f4a45"),
		"path": Color("#5d5d6c"),
		"foliage": Color("#3f4c59"), "foliage_dark": Color("#36424e"),
		"trunk": Color("#3f3f4b"),
		"forest_mass": Color("#43506b"),
		"mountain": Color("#6b7a9e"), "mountain_far": Color("#828db0"),
		"island": Color("#828db0"),
		"core_albedo": Color("#c01528"), "core_glow": Color("#e01a35"),
		"core_emission": 3.0,
	},
}

var _env: WorldEnvironment = null
var _sun: DirectionalLight3D = null
var _post_mat: ShaderMaterial = null
var _mats: Dictionary = {}      # name -> ShaderMaterial (toon, re-tinted per preset)
var _flat_mats: Dictionary = {} # name -> StandardMaterial3D (unshaded cutouts)
var _core_mat: StandardMaterial3D = null
var _core_light: OmniLight3D = null
var _cam_ref: Camera3D = null

func _ready() -> void:
	_build_environment()
	_build_terrain()
	_build_hero_trees()
	_build_mid_forest()
	_build_far_planes()
	_build_core()
	_build_traveler()
	apply_time_preset("dawn")

# ================= materials =================
func _toon_mat(mat_name: String) -> ShaderMaterial:
	if _mats.has(mat_name):
		return _mats[mat_name]
	var m := ShaderMaterial.new()
	m.shader = _TOON
	m.set_shader_parameter("toon_ramp", load("res://rendering/toon_ramp.tres"))
	m.set_shader_parameter("ambient_lift", 0.16)
	m.set_shader_parameter("rim_strength", 0.10)
	_mats[mat_name] = m
	return m

func _flat_mat(mat_name: String) -> StandardMaterial3D:
	if _flat_mats.has(mat_name):
		return _flat_mats[mat_name]
	var m := StandardMaterial3D.new()
	m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_flat_mats[mat_name] = m
	return m

# ================= environment =================
func _build_environment() -> void:
	_env = WorldEnvironment.new()
	var env := Environment.new()
	var sky := Sky.new()
	sky.sky_material = ProceduralSkyMaterial.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.glow_enabled = true
	env.glow_intensity = 0.45
	env.glow_bloom = 0.05
	_env.environment = env
	add_child(_env)

	_sun = DirectionalLight3D.new()
	_sun.shadow_enabled = true
	add_child(_sun)

# ================= terrain =================
static func terrain_h(x: float, z: float) -> float:
	# rolling clearing: swale along the trail, flanking mounds, back rise
	var h := 1.6 * sin(x * 0.045 + 1.3) * cos(z * 0.035)
	h += 4.6 * exp(-pow((z + 95.0) / 55.0, 2.0))   # back rise toward mid forest
	h += 1.1 * sin(x * 0.10 + 0.7) * sin(z * 0.085) # medium undulation
	h += 0.35 * sin(x * 0.21) * sin(z * 0.17)       # small detail
	# flanking mounds that grow with distance (frame the valley)
	h += 2.0 * exp(-pow((x + 42.0) / 26.0, 2.0)) * clampf(-z / 60.0, 0.0, 1.5)
	h += 1.6 * exp(-pow((x - 38.0) / 24.0, 2.0)) * clampf(-z / 70.0, 0.0, 1.5)
	# the trail runs in a soft swale (reads as a carved path, not a decal)
	h -= 1.0 * exp(-pow(_path_dist(x, z) / 7.0, 2.0)) * clampf((z + 80.0) / 100.0, 0.0, 1.0)
	return h

static func _path_dist(x: float, z: float) -> float:
	var px := sin(z * 0.030) * 5.0  # winding trail toward -z
	return absf(x - px)

func _build_terrain() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var size := 240.0
	var steps := 104
	var half := size * 0.5
	for iz in range(steps):
		for ix in range(steps):
			var x0 := -half + size * float(ix) / steps
			var x1 := -half + size * float(ix + 1) / steps
			var z0 := -half + size * float(iz) / steps
			var z1 := -half + size * float(iz + 1) / steps
			var quad := [
				Vector3(x0, terrain_h(x0, z0), z0), Vector3(x1, terrain_h(x1, z0), z0),
				Vector3(x1, terrain_h(x1, z1), z1), Vector3(x0, terrain_h(x0, z1), z1)]
			for idx in [0, 1, 2, 0, 2, 3]:
				var v: Vector3 = quad[idx]
				st.set_color(_terrain_color(v.x, v.z))
				st.set_uv(Vector2(v.x / size + 0.5, v.z / size + 0.5))
				st.add_vertex(v)
	st.generate_normals()
	var mi := MeshInstance3D.new()
	mi.name = "Terrain"
	mi.mesh = st.commit()
	var m := _toon_mat("terrain")
	m.set_shader_parameter("use_vertex_color", true)
	m.set_shader_parameter("albedo_color", Color.WHITE)
	mi.material_override = m
	add_child(mi)

func _terrain_color(x: float, z: float) -> Color:
	# vertex color keys: R meaning handled at preset time is impossible for
	# baked vertices, so encode zones as neutral tints multiplied by the
	# preset albedo. Use white for grass, warm for path, slightly dark lush.
	var pd := _path_dist(x, z)
	if pd < 2.2 and z > -70.0:
		return Color(1.18, 1.10, 0.92)  # sandy trail (multiplies grass albedo)
	var n := sin(x * 0.13 + z * 0.07) * 0.5 + 0.5
	return Color(1.0, 1.0, 1.0).lerp(Color(0.86, 0.92, 0.84), n * 0.7)

# ================= trees =================
func _tree(pos: Vector3, s: float, foliage_key: String) -> void:
	var root := Node3D.new()
	root.position = pos
	add_child(root)
	# single tapered trunk (no stack seams) with a gentle lean + knotted branches
	var trunk_m := _toon_mat("trunk")
	var lean := Vector3(randf_range(-0.06, 0.06), 0, randf_range(-0.04, 0.04))
	var seg_h := 2.2 * s
	var trunk_h := seg_h * 3.0
	var c := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.26 * s
	cyl.bottom_radius = 0.62 * s
	cyl.height = trunk_h
	c.mesh = cyl
	c.material_override = trunk_m
	c.position = Vector3(lean.x * trunk_h * 0.5, trunk_h * 0.5, lean.z * trunk_h * 0.5)
	c.rotation = Vector3(lean.z * 0.9, 0.0, -lean.x * 0.9)
	root.add_child(c)
	for bi in range(2):
		var br := MeshInstance3D.new()
		var bm := CylinderMesh.new()
		bm.bottom_radius = 0.15 * s
		bm.top_radius = 0.04 * s
		bm.height = 2.8 * s
		br.mesh = bm
		br.material_override = trunk_m
		var ba := TAU * (float(bi) + randf() * 0.4) / 2.0
		br.position = Vector3(cos(ba) * 0.9 * s, trunk_h * 0.82, sin(ba) * 0.9 * s)
		br.rotation = Vector3(deg_to_rad(randf_range(28.0, 48.0)), -ba, 0)
		root.add_child(br)
	# root flare: tapered spurs (ink-drawn roots, no bubble caps)
	for a in range(7):
		var r := MeshInstance3D.new()
		var rm := CylinderMesh.new()
		rm.bottom_radius = randf_range(0.14, 0.22) * s
		rm.top_radius = 0.03 * s
		rm.height = randf_range(1.5, 2.3) * s
		r.mesh = rm
		r.material_override = trunk_m
		var ang := TAU * a / 7.0 + randf() * 0.4
		r.position = Vector3(cos(ang) * 0.9 * s, 0.10 * s, sin(ang) * 0.9 * s)
		r.rotation = Vector3(deg_to_rad(randf_range(84.0, 97.0)), -ang, 0)
		root.add_child(r)
	# branch stubs (knots read as cut limbs, not floating ovals)
	for k in range(3):
		var kn := MeshInstance3D.new()
		var ks := CylinderMesh.new()
		ks.bottom_radius = randf_range(0.09, 0.13) * s
		ks.top_radius = 0.03 * s
		ks.height = randf_range(0.5, 0.8) * s
		kn.mesh = ks
		kn.material_override = trunk_m
		var ka := randf() * TAU
		var kh := randf_range(0.30, 0.60) * trunk_h
		var kw := lerpf(0.55, 0.28, kh / trunk_h) * s
		kn.position = Vector3(cos(ka) * kw + lean.x * kh, kh, sin(ka) * kw + lean.z * kh)
		kn.rotation = Vector3(deg_to_rad(randf_range(55.0, 75.0)), -ka, 0)
		root.add_child(kn)
	# clumped canopy: 5 branch directions, each carrying 2-4 small leaf
	# clusters with gaps between clumps (the ink outlines each clump — the
	# anti-"plastoso" rule: many small silhouettes, not one big blob)
	var fol_m := _toon_mat(foliage_key)
	var fol_low := _toon_mat("foliage_dark")
	var crown_y := seg_h * 3.1
	var crown_c := Vector3(lean.x * 3.0 * seg_h, 0, lean.z * 3.0 * seg_h)
	for ci in range(6):
		var ca := TAU * ci / 6.0 + randf() * 0.6
		var cr := randf_range(1.2, 3.0) * s
		var ch := crown_y + randf_range(-1.2, 1.6) * s
		var center := crown_c + Vector3(cos(ca) * cr, ch, sin(ca) * cr * 0.8)
		var tone := fol_low if ch < crown_y + 0.4 * s else fol_m
		for b in range(randi_range(3, 5)):
			var f := MeshInstance3D.new()
			var sm := SphereMesh.new()
			var rr := randf_range(1.0, 1.9) * s
			sm.radius = rr
			sm.height = rr * 1.15
			f.mesh = sm
			f.material_override = tone
			f.position = center + Vector3(
				randf_range(-1.1, 1.1) * s,
				randf_range(-0.6, 0.7) * s,
				randf_range(-1.0, 1.0) * s)
			root.add_child(f)
	# hero trees: one guaranteed low bough over the valley side (framing read)
	if s >= 2.0:
		var bough_y := trunk_h * 0.62
		var bough_c := Vector3(randf_range(-0.6, 0.6) * s, bough_y, -1.8 * s)
		var arm := MeshInstance3D.new()
		var am := CylinderMesh.new()
		am.bottom_radius = 0.16 * s
		am.top_radius = 0.05 * s
		am.height = 2.6 * s
		arm.mesh = am
		arm.material_override = trunk_m
		arm.position = Vector3(bough_c.x * 0.5, bough_y + 0.6 * s, bough_c.z * 0.5)
		arm.rotation = Vector3(deg_to_rad(112.0), 0, 0)
		root.add_child(arm)
		for b in range(3):
			var f := MeshInstance3D.new()
			var sm := SphereMesh.new()
			var rr := randf_range(1.2, 1.7) * s
			sm.radius = rr
			sm.height = rr * 1.15
			f.mesh = sm
			f.material_override = fol_low
			f.position = bough_c + Vector3(
				randf_range(-1.0, 1.0) * s,
				randf_range(-0.3, 0.5) * s,
				randf_range(-0.7, 0.7) * s)
			root.add_child(f)
	# small crown cap (keeps the dome read from afar)
	var cap := MeshInstance3D.new()
	var cs := SphereMesh.new()
	cs.radius = 1.7 * s
	cs.height = 1.9 * s
	cap.mesh = cs
	cap.material_override = fol_m
	cap.position = crown_c + Vector3(0, crown_y + 2.2 * s, 0)
	root.add_child(cap)

func _build_hero_trees() -> void:
	seed(7)
	# two enormous framing trees (keyframe: foreground left cluster + right)
	_tree(Vector3(-13, terrain_h(-13, 14), 14), 2.6, "foliage")
	_tree(Vector3(-19, terrain_h(-19, 8), 8), 2.0, "foliage_dark")
	_tree(Vector3(14, terrain_h(14, 10), 10), 2.9, "foliage")
	# a few mid-clearing trees
	_tree(Vector3(-9, terrain_h(-9, -30), -30), 1.1, "foliage_dark")
	_tree(Vector3(11, terrain_h(11, -38), -38), 1.3, "foliage")
	_tree(Vector3(20, terrain_h(20, -55), -55), 1.0, "foliage_dark")

func _build_mid_forest() -> void:
	# rolling forest masses: big soft blobs, single mid tone (ink already greys there)
	seed(21)
	var m := _toon_mat("forest_mass")
	for i in range(26):
		var f := MeshInstance3D.new()
		var sm := SphereMesh.new()
		var rr := randf_range(6.0, 14.0)
		sm.radius = rr
		sm.height = rr * 1.35
		f.mesh = sm
		f.material_override = m
		var x := randf_range(-100.0, 100.0)
		var z := randf_range(-140.0, -70.0)
		f.position = Vector3(x, terrain_h(x, z) + rr * 0.25, z)
		add_child(f)

static func _ridge_h(x: float, h: float, peaks: int) -> float:
	# deterministic gaussian ridge line (flat pastel cutout silhouette)
	var v := 0.0
	for i in range(peaks):
		var fi := float(i)
		var cx := -200.0 + 400.0 * (fi + 0.5) / float(peaks) + sin(fi * 7.3) * 30.0
		var ph := h * (0.6 + 0.4 * absf(sin(fi * 3.7 + 1.0)))
		var w := 55.0 + 20.0 * sin(fi * 2.1)
		v = max(v, ph * exp(-pow((x - cx) / w, 2.0)))
	v += 2.0 * sin(x * 0.05)
	return max(v, 2.0)

func _build_far_planes() -> void:
	# flat pastel cutout mountains (unshaded — pure aerial silhouette)
	var ridges := [
		{"key": "mountain", "z": -190.0, "h": 46.0, "peaks": 5, "seed": 3},
		{"key": "mountain_far", "z": -240.0, "h": 62.0, "peaks": 4, "seed": 9},
	]
	for r in ridges:
		var st := SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		seed(r["seed"])
		var w := 460.0
		var n: int = 64
		for i in range(n):
			var x0 := -w * 0.5 + w * float(i) / n
			var x1 := -w * 0.5 + w * float(i + 1) / n
			var y0: float = _ridge_h(x0, r["h"], r["peaks"])
			var y1: float = _ridge_h(x1, r["h"], r["peaks"])
			for v in [Vector3(x0, -4, 0), Vector3(x0, y0, 0), Vector3(x1, y1, 0),
					Vector3(x0, -4, 0), Vector3(x1, y1, 0), Vector3(x1, -4, 0)]:
				st.add_vertex(v)
		var mi := MeshInstance3D.new()
		mi.mesh = st.commit()
		mi.material_override = _flat_mat(r["key"])
		mi.position = Vector3(0, 0, r["z"])
		add_child(mi)
	# faint floating islands in the haze
	seed(5)
	for i in range(3):
		var isl := MeshInstance3D.new()
		var cone := CylinderMesh.new()
		cone.top_radius = randf_range(3.0, 5.0)
		cone.bottom_radius = 0.4
		cone.height = randf_range(4.0, 7.0)
		isl.mesh = cone
		isl.material_override = _flat_mat("island")
		isl.position = Vector3(randf_range(-90, 40), randf_range(48, 70), -165.0 - i * 12.0)
		add_child(isl)
		var tuft := MeshInstance3D.new()
		var ts := SphereMesh.new()
		ts.radius = cone.top_radius * 0.8
		ts.height = ts.radius
		tuft.mesh = ts
		tuft.material_override = _flat_mat("island")
		tuft.position = isl.position + Vector3(0, cone.height * 0.55, 0)
		add_child(tuft)

# ================= god-core =================
func _build_core() -> void:
	var root := Node3D.new()
	root.name = "GodCore"
	var cx := 24.0
	var cz := -44.0
	root.position = Vector3(cx, terrain_h(cx, cz), cz)
	add_child(root)
	_core_mat = StandardMaterial3D.new()
	_core_mat.albedo_color = Color("#c22138")
	_core_mat.emission_enabled = true
	_core_mat.emission = Color("#e0304a")
	_core_mat.emission_energy_multiplier = 1.6
	seed(13)
	# crystal cluster: tall spikes center, shorter tilted-outward ring (keyframe geometry)
	for i in range(9):
		var shard := MeshInstance3D.new()
		var prism := PrismMesh.new()
		var rad := randf_range(0.2, 2.4)
		var s := clampf(3.4 - rad * 1.0, 0.9, 3.4) * randf_range(0.8, 1.1)
		prism.size = Vector3(0.5 * s, 3.4 * s, 0.5 * s)
		shard.mesh = prism
		shard.material_override = _core_mat
		var ang := TAU * i / 9.0 + randf() * 0.4
		var tilt := rad * 0.30 + randf_range(-0.08, 0.08)
		var tangent := Vector3(-sin(ang), 0, cos(ang))
		shard.transform.basis = Basis(tangent, tilt)
		shard.position = Vector3(cos(ang) * rad, 1.05 * s, sin(ang) * rad)
		root.add_child(shard)
	# fallen shard + stained ground
	var fallen := MeshInstance3D.new()
	var fp := PrismMesh.new()
	fp.size = Vector3(0.5, 2.2, 0.5)
	fallen.mesh = fp
	fallen.material_override = _core_mat
	fallen.position = Vector3(-2.8, 0.35, 1.2)
	fallen.rotation = Vector3(0, 0.7, deg_to_rad(102.0))
	root.add_child(fallen)
	var disc := MeshInstance3D.new()
	var dm := CylinderMesh.new()
	dm.top_radius = 5.0
	dm.bottom_radius = 5.0
	dm.height = 0.08
	disc.mesh = dm
	var stain := StandardMaterial3D.new()
	stain.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	stain.albedo_color = Color("#8a3440")
	disc.material_override = stain
	disc.position = Vector3(0, 0.05, 0)
	root.add_child(disc)
	_core_light = OmniLight3D.new()
	_core_light.light_color = Color("#ff2440")
	_core_light.omni_range = 14.0
	_core_light.light_energy = 2.2
	_core_light.position = Vector3(0, 2.0, 0)
	root.add_child(_core_light)

# ================= traveler =================
func _build_traveler() -> void:
	# tiny dark figure on the trail — pure scale device, near-silhouette
	var m := _flat_mat("traveler")
	m.albedo_color = Color("#3c3a40")
	var z := -34.0
	var x := sin(z * 0.030) * 5.0
	var body := MeshInstance3D.new()
	var cap := CapsuleMesh.new()
	cap.radius = 0.28
	cap.height = 1.5
	body.mesh = cap
	body.material_override = m
	body.position = Vector3(x, terrain_h(x, z) + 0.85, z)
	add_child(body)
	var head := MeshInstance3D.new()
	var hs := SphereMesh.new()
	hs.radius = 0.19
	hs.height = 0.38
	head.mesh = hs
	head.material_override = m
	head.position = body.position + Vector3(0, 0.95, 0)
	add_child(head)

# ================= post pass =================
func attach_post(cam: Camera3D) -> void:
	var quad := MeshInstance3D.new()
	quad.name = "MelancoliaPost"
	var qm := QuadMesh.new()
	qm.size = Vector2(2, 2)
	quad.mesh = qm
	_post_mat = ShaderMaterial.new()
	_post_mat.shader = _POST
	quad.material_override = _post_mat
	quad.extra_cull_margin = 16384.0
	cam.add_child(quad)
	quad.position = Vector3(0, 0, -1)
	_cam_ref = cam

# ================= presets =================
func apply_time_preset(preset_name: String) -> void:
	var p: Dictionary = PRESETS[preset_name]
	# sky + ambient
	var sky_mat: ProceduralSkyMaterial = _env.environment.sky.sky_material
	sky_mat.sky_top_color = p["sky_top"]
	sky_mat.sky_horizon_color = p["sky_horizon"]
	sky_mat.ground_horizon_color = p["ground_horizon"]
	sky_mat.ground_bottom_color = p["ground_bottom"]
	_env.environment.ambient_light_color = p["ambient"]
	_env.environment.ambient_light_energy = p["ambient_energy"]
	# sun
	_sun.light_color = p["sun_color"]
	_sun.light_energy = p["sun_energy"]
	_sun.rotation_degrees = Vector3(p["sun_elev_deg"], p["sun_azim_deg"], 0)
	_sun.shadow_opacity = p["shadow_opacity"]
	# object palettes
	for key in ["terrain", "trunk", "foliage", "foliage_dark", "forest_mass"]:
		_toon_mat(key).set_shader_parameter("rim_color", p["rim"])
		_toon_mat(key).set_shader_parameter("rim_strength", p["rim_strength"])
	_toon_mat("terrain").set_shader_parameter("albedo_color", p["grass"])
	_toon_mat("trunk").set_shader_parameter("albedo_color", p["trunk"])
	_toon_mat("foliage").set_shader_parameter("albedo_color", p["foliage"])
	_toon_mat("foliage_dark").set_shader_parameter("albedo_color", p["foliage_dark"])
	_toon_mat("forest_mass").set_shader_parameter("albedo_color", p["forest_mass"])
	_flat_mat("mountain").albedo_color = p["mountain"]
	_flat_mat("mountain_far").albedo_color = p["mountain_far"]
	_flat_mat("island").albedo_color = p["island"]
	_core_mat.albedo_color = p["core_albedo"]
	_core_mat.emission = p["core_glow"]
	_core_mat.emission_energy_multiplier = p["core_emission"]
	_core_light.light_color = p["core_glow"]
	_core_light.light_energy = 1.2 + p["core_emission"]
	# post uniforms (layer 3 carries the hour: aerial + glow color)
	if _post_mat != null:
		_post_mat.set_shader_parameter("aerial_color", p["aerial"])
		_post_mat.set_shader_parameter("glow_color", p["glow"])
		_post_mat.set_shader_parameter("glow_strength", p["glow_strength"])
		# god rays: project the sun into screen space (static gate camera)
		if _cam_ref != null:
			var travel: Vector3 = -_sun.global_transform.basis.z
			var sun_pos: Vector3 = _cam_ref.global_position - travel * 400.0
			if _cam_ref.is_position_behind(sun_pos):
				_post_mat.set_shader_parameter("ray_strength", 0.0)
			else:
				var vp_size: Vector2 = _cam_ref.get_viewport().get_visible_rect().size
				var sp: Vector2 = _cam_ref.unproject_position(sun_pos) / vp_size
				_post_mat.set_shader_parameter("sun_screen", sp)
				_post_mat.set_shader_parameter("ray_color", p["ray_color"])
				_post_mat.set_shader_parameter("ray_strength", p["ray_strength"])
