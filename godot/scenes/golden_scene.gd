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
		"sky_top": Color("#cfe6f0"), "sky_horizon": Color("#f3d9a8"),
		"ground_horizon": Color("#ecd9b0"), "ground_bottom": Color("#b9bd93"),
		"sun_color": Color("#ffe9c0"), "sun_energy": 1.25,
		"sun_elev_deg": -12.0, "sun_azim_deg": 190.0,
		"ambient": Color("#d8e2d8"), "ambient_energy": 1.05,
		"aerial": Color("#bcccd9"), "glow": Color("#ffe9bd"), "glow_strength": 0.38,
		"grass": Color("#b7bd8a"), "grass_lush": Color("#9fae7c"),
		"path": Color("#d9c9a2"),
		"foliage": Color("#93a678"), "foliage_dark": Color("#7d9268"),
		"trunk": Color("#7d6b58"),
		"forest_mass": Color("#8fa383"),
		"mountain": Color("#b9cbd9"), "mountain_far": Color("#c9d7e2"),
		"island": Color("#c3d2de"),
		"core_emission": 2.2,
	},
	"dusk": {
		"sky_top": Color("#3f4677"), "sky_horizon": Color("#a98fb4"),
		"ground_horizon": Color("#7d7a9c"), "ground_bottom": Color("#565f58"),
		"sun_color": Color("#b8a4d8"), "sun_energy": 0.55,
		"sun_elev_deg": -8.0, "sun_azim_deg": 200.0,
		"ambient": Color("#6a6f8e"), "ambient_energy": 0.9,
		"aerial": Color("#6b7799"), "glow": Color("#4de0d8"), "glow_strength": 0.32,
		"grass": Color("#5f6a63"), "grass_lush": Color("#525d57"),
		"path": Color("#6f6f7c"),
		"foliage": Color("#4d5a66"), "foliage_dark": Color("#414d58"),
		"trunk": Color("#4a4a56"),
		"forest_mass": Color("#4c5870"),
		"mountain": Color("#7482a4"), "mountain_far": Color("#8a95b5"),
		"island": Color("#8a95b5"),
		"core_emission": 4.0,
	},
}

var _env: WorldEnvironment = null
var _sun: DirectionalLight3D = null
var _post_mat: ShaderMaterial = null
var _mats: Dictionary = {}      # name -> ShaderMaterial (toon, re-tinted per preset)
var _flat_mats: Dictionary = {} # name -> StandardMaterial3D (unshaded cutouts)
var _core_mat: StandardMaterial3D = null
var _core_light: OmniLight3D = null

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
	# gentle clearing bowl rising toward the back
	var h := 0.9 * sin(x * 0.055 + 1.3) * cos(z * 0.045)
	h += 2.4 * exp(-pow((z + 95.0) / 60.0, 2.0))  # back rise toward mid forest
	h += 0.35 * sin(x * 0.21) * sin(z * 0.17)
	return h

static func _path_dist(x: float, z: float) -> float:
	var px := sin(z * 0.030) * 5.0  # winding trail toward -z
	return absf(x - px)

func _build_terrain() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var size := 240.0
	var steps := 72
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
	# tapered trunk: stacked cylinders with slight lean
	var trunk_m := _toon_mat("trunk")
	var lean := Vector3(randf_range(-0.06, 0.06), 0, randf_range(-0.04, 0.04))
	var seg_h := 2.2 * s
	for i in range(3):
		var c := MeshInstance3D.new()
		var cyl := CylinderMesh.new()
		cyl.top_radius = (0.42 - 0.11 * i) * s
		cyl.bottom_radius = (0.55 - 0.11 * i) * s
		cyl.height = seg_h
		c.mesh = cyl
		c.material_override = trunk_m
		c.position = Vector3(lean.x * i * seg_h, seg_h * (0.5 + i), lean.z * i * seg_h)
		root.add_child(c)
	# root flare
	for a in range(5):
		var r := MeshInstance3D.new()
		var rm := CapsuleMesh.new()
		rm.radius = 0.16 * s
		rm.height = 1.7 * s
		r.mesh = rm
		r.material_override = trunk_m
		var ang := TAU * a / 5.0 + randf() * 0.5
		r.position = Vector3(cos(ang) * 0.7 * s, 0.18 * s, sin(ang) * 0.7 * s)
		r.rotation = Vector3(deg_to_rad(80), -ang, 0)
		root.add_child(r)
	# foliage blobs
	var fol_m := _toon_mat(foliage_key)
	var crown_y := seg_h * 3.1
	for b in range(6):
		var f := MeshInstance3D.new()
		var sm := SphereMesh.new()
		var rr := randf_range(2.2, 3.4) * s
		sm.radius = rr
		sm.height = rr * 1.4
		f.mesh = sm
		f.material_override = fol_m
		var ang2 := TAU * b / 6.0
		f.position = Vector3(
			lean.x * 3.0 * seg_h + cos(ang2) * randf_range(1.0, 2.2) * s,
			crown_y + randf_range(-0.7, 1.4) * s,
			lean.z * 3.0 * seg_h + sin(ang2) * randf_range(0.8, 1.8) * s)
		root.add_child(f)

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
	for i in range(7):
		var shard := MeshInstance3D.new()
		var prism := PrismMesh.new()
		var s := randf_range(1.2, 3.4)
		prism.size = Vector3(0.7 * s, 3.2 * s, 0.7 * s)
		shard.mesh = prism
		shard.material_override = _core_mat
		var ang := TAU * i / 7.0
		shard.position = Vector3(cos(ang) * randf_range(0.3, 1.6), 1.2 * s, sin(ang) * randf_range(0.3, 1.4))
		shard.rotation = Vector3(randf_range(-0.5, 0.5), ang, randf_range(-0.35, 0.35))
		root.add_child(shard)
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
	# object palettes
	_toon_mat("terrain").set_shader_parameter("albedo_color", p["grass"])
	_toon_mat("trunk").set_shader_parameter("albedo_color", p["trunk"])
	_toon_mat("foliage").set_shader_parameter("albedo_color", p["foliage"])
	_toon_mat("foliage_dark").set_shader_parameter("albedo_color", p["foliage_dark"])
	_toon_mat("forest_mass").set_shader_parameter("albedo_color", p["forest_mass"])
	_flat_mat("mountain").albedo_color = p["mountain"]
	_flat_mat("mountain_far").albedo_color = p["mountain_far"]
	_flat_mat("island").albedo_color = p["island"]
	_core_mat.emission_energy_multiplier = p["core_emission"]
	_core_light.light_energy = 1.4 + p["core_emission"]
	# post uniforms (layer 3 carries the hour: aerial + glow color)
	if _post_mat != null:
		_post_mat.set_shader_parameter("aerial_color", p["aerial"])
		_post_mat.set_shader_parameter("glow_color", p["glow"])
		_post_mat.set_shader_parameter("glow_strength", p["glow_strength"])
