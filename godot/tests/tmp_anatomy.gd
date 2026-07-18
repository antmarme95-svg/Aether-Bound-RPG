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
	# Fenotipo del CONCEPT humano canónico (review v0.2: piel porcelana,
	# pelo corto castaño claro barrido atrás, scout marks verdes).
	var pheno: Dictionary = _Pheno.default_phenotype()
	pheno["skinTone"] = 0     # porcelain (concept: tez pálida/fría)
	pheno["hair"] = 10        # frontier crop (PRD Rework Fenotipo pt.2: canon del fenotipo humano)
	pheno["hairColor"] = 4    # chestnut (base; tinte exacto abajo)
	pheno["warpaint"] = 6     # Scout Marks: patrón 6 vacío A PROPÓSITO en warpaint_atlas.gd (la marca real es geometría en _face_mark) — el PRD Rework Fenotipo lo daba por "índice inválido" (WARPAINTS de la UI solo llega a 5) pero SÍ es válido para el atlas/gating; corregido tras verificar visualmente que 1-5 pintan patrones legacy superpuestos
	pheno["paintColor"] = 4   # wyld green
	_rig.apply_phenotype(pheno, BASELINE_ORIGIN)
	# Castaño CLARO exacto del concept (patrón Dagna: tinte post-paleta).
	_rig.hair_mat.set_shader_parameter("albedo_color", Color("#8a6b48"))
	# Iris café legible (el accent papel del banco lo dejaba blanco-sobre-
	# blanco = mirada de susto; en juego el iris es el accent del origen).
	_rig.iris_mat.albedo_color = Color("#4f3b28")
	# Sin pauldron en el banco de anatomía (review v0.2 LOW 8: leía como
	# "prop sin referencia" — es armadura de hombro, se juzga con vestuario).
	# PRD Rework Fenotipo pt.14 (2026-07-14): buscarlo por NOMBRE, no por
	# "último hijo de arm_r" — ese hack quedó roto por las venas de mana
	# (ver `character_rig.gd _build()`), dejaba el pauldron VISIBLE por
	# accidente en cada render del banco (confirmado por QA visual: objeto
	# gris/azul flotando en el hombro en todas las capturas).
	var arm_r: Node3D = _rig.arms[1]
	var _pauldron := arm_r.find_child("pauldron", false, false)
	if _pauldron != null:
		(_pauldron as Node3D).visible = false
	_rig.set_motion(0.0, false)
	# DIAG_AXIS=1 (R0 reescritura): dos "lanzas" delgadas apuntando al +Z
	# local — azul en `_rig.head`, roja en `_holder`. En el perfil (cámara a
	# +X) ambas deben verse horizontales a máxima longitud apuntando a la
	# izquierda; si divergen entre sí, hay yaw acumulado en la cadena
	# body/spine/head; si se acortan, la cámara no está a 90° reales.
	if OS.get_environment("DIAG_AXIS") == "1":
		_add_axis_spear(_rig.head, Color(0.1, 0.3, 1.0))
		var holder_anchor := Node3D.new()
		_holder.add_child(holder_anchor)
		holder_anchor.position = Vector3(0.0, 1.90, 0.0)
		_add_axis_spear(holder_anchor, Color(1.0, 0.1, 0.1))
	# Dump del atlas de warpaint generado (posicionar slashes VIENDO el strip)
	var head_tex = _rig.head_mat.get_shader_parameter("albedo_texture")
	if head_tex is Texture2D:
		(head_tex as Texture2D).get_image().save_png("res://test_out/warpaint_atlas.png")
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
	for probe_name in ["arm_paint_stripe", "face_paint_mark"]:
		var found = _rig.find_child(probe_name, true, false)
		if found != null:
			print("[TmpAnatomy] %s: EXISTE, global=%s visible=%s" % [probe_name, str((found as Node3D).global_position), str((found as Node3D).visible)])
		else:
			print("[TmpAnatomy] %s: NO EXISTE en el árbol" % probe_name)

	# ---- post Melancolía: el rig ya es opaco/sin outline de fábrica (C6a) ----
	# PRD Rework Fenotipo pt.11 (2026-07-14): diagnóstico hecho comentando
	# esta línea — SIN post la piel lee cálida/rosada (confirma que
	# skin_mat/SKIN_TONES[0] NO es el problema); el post/LUT dawn también
	# resulta ser el responsable del ENTINTADO toon completo (sin post no
	# hay outline ni cel-shading, no solo el tinte de piel). Es global — no
	# se toca sin aprobación explícita de Boris (ver Current-State).
	_gs.attach_post(_cam)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)

	# ---- regla de cabezas junto al rig (marcas cada head_h desde el suelo) ----
	_build_ruler(m)

	# ---- capturas: cerca / media / lejos + frente / perfil ----
	_frame_close()
	await _wait(0.15)
	await Debug.screenshot("res://test_out/anatomy_close.png")

	# TURNAROUND de cabeza (review v0.3: frente / ¾ / perfil / espalda
	# son obligatorios para aprobar)
	var face_t: Vector3 = _holder.global_position + Vector3(0.0, 1.80, 0.0)
	_cam.look_at_from_position(face_t + _key_offset(Vector3(0.0, 0.02, 0.62)), face_t, Vector3.UP)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)
	await Debug.screenshot("res://test_out/anatomy_face.png")
	_cam.look_at_from_position(face_t + Vector3(0.42, 0.04, 0.48), face_t, Vector3.UP)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)
	await Debug.screenshot("res://test_out/anatomy_face_34.png")
	_cam.look_at_from_position(face_t + Vector3(0.62, 0.02, 0.0), face_t, Vector3.UP)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)
	await Debug.screenshot("res://test_out/anatomy_face_profile.png")
	_cam.look_at_from_position(face_t + Vector3(0.0, 0.04, -0.62), face_t, Vector3.UP)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)
	await Debug.screenshot("res://test_out/anatomy_face_back.png")

	# CLOSE-UPS de uniones (R0 reescritura, lección 2026-07-17: un hueco de
	# fusión geométrica se camufla en el render completo a 1280×720 — el
	# zoom a la unión exacta deja de ser un recorte manual de PowerShell y
	# queda institucionalizado como captura del banco).
	# (a) mentón/cuello en 3/4 — la zona del ex-CRITICAL "cardboard collar".
	var chin_t: Vector3 = _holder.global_position + Vector3(0.0, 1.66, 0.0)
	_cam.look_at_from_position(chin_t + Vector3(0.22, 0.02, 0.26), chin_t, Vector3.UP)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)
	await Debug.screenshot("res://test_out/anatomy_closeup_chin.png")
	# (b) unión cuello→trapecio/hombro (seam reportado por QA 2026-07-17).
	var neck_t: Vector3 = _holder.global_position + Vector3(0.0, 1.56, 0.0)
	_cam.look_at_from_position(neck_t + Vector3(0.32, 0.08, 0.18), neck_t, Vector3.UP)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)
	await Debug.screenshot("res://test_out/anatomy_closeup_neckshoulder.png")
	# (c) mentón/boca de FRENTE cerca (donde el QA vio el "rectángulo").
	_cam.look_at_from_position(chin_t + _key_offset(Vector3(0.0, 0.03, 0.32)), chin_t, Vector3.UP)
	_gs.apply_time_preset("dawn")
	await _wait(0.15)
	await Debug.screenshot("res://test_out/anatomy_closeup_chin_front.png")

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
	if not bool(ProjectSettings.get_setting("beckett/hold_anatomy_bench", false)):
		get_tree().quit(0)

func _wait(secs: float) -> void:
	var t := 0.0
	while t < secs:
		await get_tree().process_frame
		t += get_process_delta_time()

# Ángulo de cámara "casi-frente" (Fase 0 diagnóstico, 2026-07-16): el sol de
# "dawn" (golden_scene.gd sun_azim_deg=190) queda ~alineado con el eje +Z del
# personaje (su frente). Una cámara EXACTAMENTE de frente (offset X=0) queda
# co-lineal con la luz -> superficie uniformemente iluminada, sin banding
# visible pese a que el pipeline funciona bien (confirmado: el perfil SÍ
# muestra banding fuerte, el frente puro no — mismo shader, mismo post,
# distinto ángulo). Rotar el offset de cámara ~15° alrededor de Y rompe esa
# alineación sin dejar de leer como vista de frente (bastante menor que el
# 3/4 existente, ~41°). Mantiene la distancia a cámara igual (solo rota el
# offset), así el encuadre/zoom no cambia.
const KEY_ANGLE_DEG: float = 15.0

func _key_offset(base: Vector3) -> Vector3:
	return base.rotated(Vector3.UP, deg_to_rad(KEY_ANGLE_DEG))

# ================= diagnóstico de ejes (DIAG_AXIS) =================
# Caja delgada de 0.30 m que nace en el origen del padre y corre por su +Z
# local. Material unshaded: el color debe leerse puro, sin toon/sombra.
func _add_axis_spear(parent: Node3D, color: Color) -> void:
	var spear := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.012, 0.012, 0.30)
	spear.mesh = bm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	spear.material_override = mat
	spear.position = Vector3(0.0, 0.0, 0.15)
	parent.add_child(spear)

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
		# R2: a -0.55 la regla proyectaba su SOMBRA sobre el pecho con el sol
		# de dawn — leía como "correa diagonal" (falso CRITICAL de QA).
		rung.position = Vector3(-1.05, (m["ground_y"] - _holder.global_position.y) + m["head_h"] * float(i), 0.0)
		_holder.add_child(rung)

# ================= encuadres =================
func _frame_close() -> void:
	var target: Vector3 = _holder.global_position + Vector3(0.0, 1.45, 0.0)
	_cam.look_at_from_position(target + _key_offset(Vector3(0.0, 0.05, 2.0)), target, Vector3.UP)
	_gs.apply_time_preset("dawn")

func _frame_full_front(dist: float) -> void:
	var target: Vector3 = _holder.global_position + Vector3(0.0, 0.95, 0.0)
	var eye_h: float = 1.35 + (dist - 4.0) * 0.06   # se eleva un poco al alejarse
	_cam.look_at_from_position(target + _key_offset(Vector3(0.0, eye_h - 0.95, dist)), target, Vector3.UP)
	_gs.apply_time_preset("dawn")
