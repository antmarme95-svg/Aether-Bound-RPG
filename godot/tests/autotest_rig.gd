## autotest_rig.gd — scripted acceptance test for CharacterRig.
## Run via: godot --path godot -- --autotest=res://tests/autotest_rig.gd
## Debug autoload instantiates this as a child; it builds a stage, applies
## each phenotype case, screenshots it, writes results JSON, then quits.
extends Node

var CASES: Array = [
	{
		"name": "aetherborn_default",
		"origin_id": "aetherborn",
		"phenotype_overrides": {},
	},
	{
		"name": "ironblooded_default",
		"origin_id": "ironblooded",
		"phenotype_overrides": {},
	},
	{
		"name": "miststalker_default",
		"origin_id": "miststalker",
		"phenotype_overrides": {},
	},
	{
		"name": "weight_max",
		"origin_id": "aetherborn",
		"phenotype_overrides": {"weight": 1.0},
	},
	{
		"name": "height_min",
		"origin_id": "aetherborn",
		"phenotype_overrides": {"height": 0.0},
	},
	{
		"name": "arcane_full",
		"origin_id": "aetherborn",
		"phenotype_overrides": {"arcaneMod": 1.0},
	},
	{
		"name": "hair_3",
		"origin_id": "aetherborn",
		"phenotype_overrides": {"hair": 3},
	},
	{
		"name": "hair_7",
		"origin_id": "aetherborn",
		"phenotype_overrides": {"hair": 7},
	},
	{
		"name": "beard_2",
		"origin_id": "ironblooded",
		"phenotype_overrides": {"beard": 2},
	},
	{
		"name": "warpaint_4",
		"origin_id": "aetherborn",
		"phenotype_overrides": {"warpaint": 4, "paintColor": 1},
		"camera_override": {"pos": Vector3(0.0, 1.75, 1.0), "target": Vector3(0.0, 1.72, 0.0)},
	},
	{
		"name": "miststalker_side",
		"origin_id": "miststalker",
		"phenotype_overrides": {},
		"camera_override": {"pos": Vector3(2.3, 1.25, 0.0), "target": Vector3(0.0, 0.95, 0.0)},
	},
]

var _rig: CharacterRig = null
var _results: Array = []
var _cam: Camera3D = null

func _ready() -> void:
	# Defer to the next frame so the scene tree is fully settled before we
	# start awaiting — required because _run_tests is async.
	_run_tests.call_deferred()

func _run_tests() -> void:
	# (a) Remove the placeholder main scene and wait one frame
	if get_tree().current_scene != null:
		get_tree().current_scene.queue_free()
	await get_tree().process_frame

	# (b) Build stage
	_build_stage()

	# (c) Instantiate rig
	_rig = CharacterRig.new()
	get_tree().root.add_child(_rig)
	_rig.position = Vector3(0.0, 0.0, 0.0)

	# Default camera position (used unless case_def has camera_override)
	var default_cam_pos: Vector3 = Vector3(0.0, 1.25, 2.3)
	var default_cam_target: Vector3 = Vector3(0.0, 0.95, 0.0)

	# (d) Run each case
	for case_def in CASES:
		var case_name: String = case_def["name"]
		var origin_id: String = case_def["origin_id"]
		var overrides: Dictionary = case_def["phenotype_overrides"]

		# Move camera: use per-case override or default
		var cam_pos: Vector3 = default_cam_pos
		var cam_target: Vector3 = default_cam_target
		if case_def.has("camera_override"):
			var co: Dictionary = case_def["camera_override"]
			cam_pos = co["pos"]
			cam_target = co["target"]
		_cam.position = cam_pos
		_cam.look_at_from_position(_cam.position, cam_target, Vector3.UP)

		var origin = OriginsData.get_origin(origin_id)
		var phenotype = PhenotypeData.default_phenotype()
		for key in overrides:
			phenotype[key] = overrides[key]

		_rig.apply_phenotype(phenotype, origin)

		# Wait 3 process frames for rendering to settle
		await get_tree().process_frame
		await get_tree().process_frame
		await get_tree().process_frame

		var out_path = "res://test_out/rig_" + case_name + ".png"
		await Debug.screenshot(out_path)
		_results.append({"case": case_name, "origin": origin_id, "screenshot": out_path, "ok": true})
		print("[autotest_rig] case done: ", case_name)

	# (e) Write results JSON and quit
	Debug.write_json("res://test_out/rig_results.json", {"cases": _results, "done": true})
	print("[autotest_rig] all cases complete, quitting")
	get_tree().quit(0)

func _build_stage() -> void:
	# WorldEnvironment: ACES tonemap, dark background
	var we = WorldEnvironment.new()
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#0c1622")
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.15
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#bfe8ff")
	env.ambient_light_energy = 0.35
	we.environment = env
	get_tree().root.add_child(we)

	# Key light (DirectionalLight3D — sun)
	var sun = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45.0, 30.0, 0.0)
	sun.light_energy = 1.2
	sun.light_color = Color("#fff4e0")
	sun.shadow_enabled = true
	get_tree().root.add_child(sun)

	# Soft fill light (second directional, low energy, cool)
	var fill = DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-20.0, -150.0, 0.0)
	fill.light_energy = 0.3
	fill.light_color = Color("#bfe8ff")
	fill.shadow_enabled = false
	get_tree().root.add_child(fill)

	# Camera: position (0, 1.25, 2.3) looking at (0, 0.95, 0) — fills ~70% of frame height
	_cam = Camera3D.new()
	_cam.position = Vector3(0.0, 1.25, 2.3)
	_cam.look_at_from_position(_cam.position, Vector3(0.0, 0.95, 0.0), Vector3.UP)
	get_tree().root.add_child(_cam)
