# tmp_anatomy.gd — banco de revisión ANATÓMICA (ventana C6/C4).
# El cuerpo base se juzga bajo la línea del Art Bible: Sobel del pase
# Melancolía Gráfica ("tinta nítida de cerca; grisácea a media distancia;
# ausente en el horizonte") — decisión del director 2026-07-10: el rig deja
# de fabricar su outline (casco invertido); la tinta la pone el post.
# Emite: medidas numéricas (alto total, cabeza, ratio en cabezas, hombros)
# + capturas a 3 distancias y 2 vistas, con regla de cabezas en escena.
# Boot: --autotest=res://tests/tmp_anatomy.gd  (windowed)
extends Node

const _GOLDEN      = preload("res://scenes/golden_scene.gd")
const _Pheno       = preload("res://data/phenotype_data.gd")
const _TOON_GOLDEN = preload("res://rendering/toon_golden.gdshader")

# Origin NEUTRO: sin piezas de origen (fallback limpio de _build_origin_features),
# escala 1.0 exacta — el cuerpo parametrico desnudo.
const BASELINE_ORIGIN: Dictionary = {
	"id": "anatomy_baseline",
	"heightRange": [1.0, 1.0],
	# Accent papel cálido (no teal): el rim con accent neón contamina la
	# lectura de silueta — aquí se juzga ANATOMÍA, no identidad de origen.
	"theme": {"accent": "#f2e6c8"},
}

var _rig: CharacterRig
var _holder: Node3D
var _cam: Camera3D
var _gs = null

func _ready() -> void:
	_run.call_deferred()

func _run() -> void:
	if get_tree().current_scene != null:
		get_tree().current_scene.queue_free()
	await get_tree().process_frame

	_cam = Camera3D.new()
	_cam.fov = 55.0
	get_tree().root.add_child(_cam)
	_cam.make_current()

	_gs = _GOLDEN.new()
	get_tree().root.add_child(_gs)
	await get_tree().process_frame
	await get_tree().process_frame
	_gs.apply_time_preset("dawn")
	await get_tree().process_frame

	# ---- rig humano neutro en el sendero ----
	var z := 0.0
	var x: float = sin(z * 0.03) * 5.0
	_holder = Node3D.new()
	get_tree().root.add_child(_holder)
	_holder.position = Vector3(x, _GOLDEN.terrain_h(x, z), z)
	_rig = CharacterRig.new()
	_holder.add_child(_rig)
	_rig.apply_phenotype(_Pheno.default_phenotype(), BASELINE_ORIGIN)
	_rig.set_motion(0.0, false)
	# Settle: > POSE_STEP (lección: capturas en 2s esperan un tick de pose)
	await _wait(0.25)

	# ---- medidas (la pose idle ya asentó) ----
	var m: Dictionary = _measure()
	print("[TmpAnatomy] ==== MEDIDAS DEL CUERPO ====")
	print("[TmpAnatomy] estatura    = %.3f m (suelo→coronilla; AABB c/pelo %.3f)" % [m["stature"], m["total_h"]])
	print("[TmpAnatomy] alto_cabeza = %.3f m (menton→coronilla)" % m["head_h"])
	print("[TmpAnatomy] CABEZAS     = %.2f  (canon lamina humano: 7.5)" % m["heads"])
	print("[TmpAnatomy] hombros_w   = %.3f m (%.2f cabezas; canon atleta ~2)" % [m["shoulder_w"], m["shoulder_heads"]])
	print("[TmpAnatomy] pierna      = %.3f m (%.1f%% del alto; canon atleta ~50%%)" % [m["leg_len"], m["leg_pct"]])

	# (diagnóstico disponible: _dump_tree(_rig, "") — identifica malla/color)

	# ---- post Melancolía: el rig ya es opaco/sin outline de fábrica (C6a) ----
	_gs.attach_post(_cam)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)

	# ---- regla de cabezas junto al rig (marcas cada head_h desde el suelo) ----
	_build_ruler(m)

	# ---- capturas: cerca / media / lejos + frente / perfil ----
	_frame_close()
	await _wait(0.15)
	await Debug.screenshot("res://test_out/anatomy_close.png")

	# detalle de MANO derecha (r5: palma + masas de dedos + pulgar)
	var hand_t: Vector3 = _holder.global_position + Vector3(0.28, 0.92, 0.0)
	_cam.look_at_from_position(hand_t + Vector3(0.25, 0.10, 0.85), hand_t, Vector3.UP)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)
	await Debug.screenshot("res://test_out/anatomy_hands.png")

	_frame_full_front(4.0)
	await _wait(0.15)
	await Debug.screenshot("res://test_out/anatomy_full_front.png")

	_holder.rotation.y = PI * 0.5
	await _wait(0.15)
	await Debug.screenshot("res://test_out/anatomy_full_side.png")
	_holder.rotation.y = 0.0

	_frame_full_front(8.0)
	await _wait(0.15)
	await Debug.screenshot("res://test_out/anatomy_medium.png")

	_frame_full_front(30.0)
	await _wait(0.15)
	await Debug.screenshot("res://test_out/anatomy_far.png")

	print("[TmpAnatomy] DONE")
	get_tree().quit(0)

func _wait(secs: float) -> void:
	var t := 0.0
	while t < secs:
		await get_tree().process_frame
		t += get_process_delta_time()

# ================= medidas =================
# Merged AABB mundial de las mallas del rig (sin glow/ojos: solo toon skin/
# leather; suficiente para alto total). Cabeza: skull (coronilla) + jaw (mentón).
func _measure() -> Dictionary:
	var lo := Vector3.INF
	var hi := -Vector3.INF
	for mi in _collect_meshes(_rig):
		var aabb: AABB = mi.get_aabb()
		for i in range(8):
			var p: Vector3 = mi.global_transform * aabb.get_endpoint(i)
			lo = lo.min(p)
			hi = hi.max(p)
	var total_h: float = hi.y - lo.y

	var skull_aabb: AABB = _rig.skull.get_aabb()
	var crown: float = -INF
	for i in range(8):
		crown = maxf(crown, (_rig.skull.global_transform * skull_aabb.get_endpoint(i)).y)
	var jaw_aabb: AABB = _rig.jaw_mesh.get_aabb()
	var chin: float = INF
	for i in range(8):
		chin = minf(chin, (_rig.jaw_mesh.global_transform * jaw_aabb.get_endpoint(i)).y)
	var head_h: float = crown - chin

	# hombros: distancia entre raíces de brazos + 2 radios de deltoide (0.068)
	var shoulder_w: float = absf(_rig.arms[1].global_position.x - _rig.arms[0].global_position.x) + 2.0 * 0.068
	# pierna: raíz de cadera → suelo (lo.y)
	var leg_len: float = _rig.hips.global_position.y - lo.y

	# Canon: las "cabezas" se cuentan suelo→CORONILLA del cráneo (el pelo
	# suma al AABB pero no cuenta — la lámina mide hueso, no copete).
	var stature: float = crown - lo.y
	return {
		"total_h": total_h,
		"stature": stature,
		"head_h": head_h,
		"heads": stature / maxf(head_h, 0.001),
		"shoulder_w": shoulder_w,
		"shoulder_heads": shoulder_w / maxf(head_h, 0.001),
		"leg_len": leg_len,
		"leg_pct": 100.0 * leg_len / maxf(total_h, 0.001),
		"ground_y": lo.y,
		"crown_y": crown,
	}

func _collect_meshes(node: Node) -> Array:
	var out: Array = []
	if node is MeshInstance3D and (node as MeshInstance3D).visible:
		var mo = (node as MeshInstance3D).material_override
		if mo is ShaderMaterial:   # toon skin/leather/metal — cuerpo real
			out.append(node)
	for c in node.get_children():
		out += _collect_meshes(c)
	return out

# ================= Sobel-only =================
# Todo material toon (ALPHA → invisible al post) pasa a toon_golden OPACO y
# pierde su next_pass: la línea de tinta la pone el Sobel del post, no el rig.
func _strip_to_sobel(node: Node) -> void:
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		var mat = mi.material_override
		if mat is ShaderMaterial:
			var sh: Shader = (mat as ShaderMaterial).shader
			if sh != null and sh.resource_path.ends_with("/toon.gdshader"):
				var g := ShaderMaterial.new()
				g.shader = _TOON_GOLDEN
				g.set_shader_parameter("toon_ramp", load("res://rendering/toon_ramp.tres"))
				var alb = mat.get_shader_parameter("albedo_color")
				var textured = mat.get_shader_parameter("use_texture")
				if textured != null and bool(textured):
					alb = Color("#e0a878")   # toon_golden no muestrea textura
				if alb == null:
					alb = Color.WHITE
				g.set_shader_parameter("albedo_color", alb)
				g.set_shader_parameter("rim_color", Color("#f2e6c8"))
				g.set_shader_parameter("rim_strength", 0.10)
				g.set_shader_parameter("ambient_lift", 0.18)
				g.next_pass = null   # SIN casco invertido: Sobel-only
				mi.material_override = g
			elif mat is ShaderMaterial and (mat as ShaderMaterial).next_pass != null:
				(mat as ShaderMaterial).next_pass = null
	for c in node.get_children():
		_strip_to_sobel(c)

# ================= dump =================
func _dump_tree(node: Node, indent: String) -> void:
	var extra := ""
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		if not mi.visible:
			extra = " [HIDDEN]"
		var mo = mi.material_override
		if mo is ShaderMaterial:
			var alb = (mo as ShaderMaterial).get_shader_parameter("albedo_color")
			var ems = (mo as ShaderMaterial).get_shader_parameter("emission_strength")
			extra += " shader alb=%s ems=%s" % [str(alb), str(ems)]
		elif mo is StandardMaterial3D:
			extra += " std alb=%s emis=%s" % [str((mo as StandardMaterial3D).albedo_color), str((mo as StandardMaterial3D).emission_enabled)]
		print("[Dump] %s%s (%s) pos=%s%s" % [indent, node.name, node.get_class(), str((node as Node3D).position), extra])
	for c in node.get_children():
		_dump_tree(c, indent + "  ")

# ================= regla de cabezas =================
# Peldaños horizontales cada head_h desde el suelo, a un costado del rig —
# en las capturas se cuenta a ojo cuántas cabezas mide el cuerpo.
func _build_ruler(m: Dictionary) -> void:
	var ink := StandardMaterial3D.new()
	ink.albedo_color = Color("#2a2620")
	ink.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	var n_rungs: int = int(ceil(m["total_h"] / m["head_h"])) + 1
	for i in range(n_rungs):
		var rung := MeshInstance3D.new()
		var bm := BoxMesh.new()
		# el peldaño de cada cabeza completa es más largo; medios = cortos
		bm.size = Vector3(0.36 if i % 1 == 0 else 0.2, 0.008, 0.008)
		rung.mesh = bm
		rung.material_override = ink
		rung.position = Vector3(-0.55, (m["ground_y"] - _holder.global_position.y) + m["head_h"] * float(i), 0.0)
		_holder.add_child(rung)

# ================= encuadres =================
func _frame_close() -> void:
	var target: Vector3 = _holder.global_position + Vector3(0.0, 1.45, 0.0)
	_cam.look_at_from_position(target + Vector3(0.15, 0.05, 2.0), target, Vector3.UP)
	_gs.apply_time_preset("dawn")

func _frame_full_front(dist: float) -> void:
	var target: Vector3 = _holder.global_position + Vector3(0.0, 0.95, 0.0)
	var eye_h: float = 1.35 + (dist - 4.0) * 0.06   # se eleva un poco al alejarse
	_cam.look_at_from_position(target + Vector3(0.0, eye_h - 0.95, dist), target, Vector3.UP)
	_gs.apply_time_preset("dawn")
