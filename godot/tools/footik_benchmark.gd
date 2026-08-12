extends SceneTree

## Spike ADR-003: mide el foot IK contra el estandar del Benchmark
## Biomecanico (§v2, fila de HZD: "foot IK contra el terreno cada frame --
## pies creibles en terreno"), mas el canon de Sable de raiz continua.
##
## SE MIDE SOBRE EL RENDER, y no es capricho: los getters de hueso
## (`get_bone_global_pose`, y `BoneAttachment3D`, que lee el mismo bufer)
## devuelven la pose ANTERIOR a los SkeletonModifier3D. Midiendo ahi, un
## foot IK que funciona perfecto se lee como un no-op -- paso el 2026-08-12
## y produjo una conclusion falsa. El unico canal que refleja la salida del
## modifier es la imagen. Ver Lecciones, seccion Godot 4.7.
##
## Metodo:
##   - Camara ORTOGRAFICA con su "arriba" en la normal del terreno y su eje
##     de vista DENTRO del plano del terreno: asi la superficie es una linea
##     horizontal exacta en la imagen.
##   - Se ocultan el otro personaje y las MALLAS del suelo (los cuerpos de
##     colision quedan, asi el IK sigue teniendo contra que tirar rayos), de
##     modo que cualquier pixel que no sea el fondo es Dagna.
##   - PENETRACION = distancia del pixel MAS BAJO de la silueta a la linea
##     del suelo, en metros. Negativa = el pie atraviesa el piso.
##
## Uso:  godot --path . --script tools/footik_benchmark.gd [-- --noik]
## Windowed a proposito: sin render no hay medicion.

const SAMPLES := 16
const FLAT_Z := -5.0
const RAMP_Z := 8.0
const ROOT_FRAMES := 180
const ORTHO_SIZE := 1.80
const FOCUS_UP := 0.55   # centro del encuadre sobre el suelo: deja ~0.35 m de margen ABAJO
const BG := Color(0.0, 0.6, 0.0)   # verde puro: no existe en el greybox

var _exclude: Array[RID] = []
var _cam: Camera3D
var _mpp: float = 0.0

func _initialize() -> void:
	change_scene_to_file("res://scenes/spike_slope.tscn")
	_run()

func _run() -> void:
	await process_frame
	await process_frame

	var dagna: Node3D = root.find_child("Dagna_Placeholder", true, false)
	if dagna == null:
		printerr("footik_benchmark: sin Dagna")
		quit(1)
		return
	var ap: AnimationPlayer = _find(dagna, "AnimationPlayer")

	for n in ["Dagna_Placeholder", "PlayerArmature"]:
		var b: CollisionObject3D = root.find_child(n, true, false)
		if b:
			_exclude.append(b.get_rid())

	if "--noik" in OS.get_cmdline_user_args():
		var ikn: Node = dagna.find_child("SpikeFootIK", true, false)
		if ikn:
			ikn.set_physics_process(false)
		var skel: Skeleton3D = _find(dagna, "Skeleton3D")
		for c in skel.get_children():
			if c is SkeletonModifier3D:
				(c as SkeletonModifier3D).active = false
		print(">>> FOOT IK APAGADO (linea base: la animacion sola)")
	else:
		print(">>> FOOT IK ACTIVO (TwoBoneIK3D)")

	# --- Raiz continua. Esto NO pasa por modifiers: es el transform del nodo,
	# asi que el getter es valido.
	var steps: Array[float] = []
	var prev: Vector3 = dagna.global_position
	for i in range(ROOT_FRAMES):
		await physics_frame
		var p: Vector3 = dagna.global_position
		steps.append((p - prev).length())
		prev = p
	var mean := 0.0
	for s in steps:
		mean += s
	mean /= float(steps.size())
	var sd := 0.0
	for s in steps:
		sd += (s - mean) * (s - mean)
	sd = sqrt(sd / float(steps.size()))
	print("RAIZ  avance medio %.4f m/frame  desvio %.4f m  (%.1f%%)" % [mean, sd, 100.0 * sd / maxf(mean, 0.0001)])

	_prepare_scene()

	var flat: Dictionary = await _measure(dagna, ap, FLAT_Z, "PLANO")
	var ramp: Dictionary = await _measure(dagna, ap, RAMP_Z, "RAMPA 21.8 grados")
	print("")
	print("PLANO -> RAMPA  = %+.4f m  (0 = el pie se apoya igual de bien en pendiente)" % (ramp["mean"] - flat["mean"]))
	quit(0)

func _prepare_scene() -> void:
	var other: Node3D = root.find_child("PlayerArmature", true, false)
	if other:
		other.visible = false
	var slope: Node3D = root.find_child("Slope_Root", true, false)
	if slope:
		for m in _meshes(slope):
			m.visible = false
	# El hacha cuelga POR DEBAJO de los pies: si se deja visible, el pixel
	# mas bajo de la silueta es el filo, no el pie, y la medicion mide el
	# arma. Se oculta.
	var dg: Node3D = root.find_child("Dagna_Placeholder", true, false)
	if dg:
		for m in _meshes(dg):
			if m.name.to_lower().contains("axe"):
				m.visible = false
	var we: WorldEnvironment = root.find_child("WorldEnvironment", true, false)
	if we and we.environment:
		we.environment.background_mode = Environment.BG_COLOR
		we.environment.background_color = BG

	_cam = Camera3D.new()
	_cam.name = "BenchCam"
	root.add_child(_cam)
	_cam.current = true
	_cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	_cam.size = ORTHO_SIZE
	_cam.near = 0.05
	_mpp = ORTHO_SIZE / float(root.size.y)

func _measure(dagna: Node3D, ap: AnimationPlayer, z: float, label: String) -> Dictionary:
	# Se la PLANTA por raycast en vez de dejarla caer: el bucle de caida
	# usaba is_on_floor(), que venia en true del tramo anterior y cortaba en
	# el primer frame con Dagna todavia a 4 m de altura.
	dagna.set_physics_process(false)
	dagna.global_transform.basis = Basis.looking_at(Vector3(0, 0, 1), Vector3.UP)
	var probe := _ground(Vector3(0.0, 12.0, z))
	if probe.is_empty():
		printerr("no hay terreno en z=", z)
		return {"mean": 0.0, "worst": 0.0}
	dagna.global_position = probe["pos"]
	await physics_frame
	ap.play("walk")
	var anim: Animation = ap.get_animation("walk")

	var p: Vector3 = probe["pos"]
	var n: Vector3 = probe["normal"]
	# Eje transversal a la pendiente: vive DENTRO del plano del terreno, asi
	# que mirando por ahi la superficie es una linea horizontal.
	var side: Vector3 = n.cross(Vector3(0, 0, 1)).normalized()

	var samples: Array[float] = []
	var clipped := 0
	for i in range(SAMPLES):
		ap.seek(anim.length * i / float(SAMPLES), true)
		await physics_frame
		await physics_frame

		var focus: Vector3 = p + n * FOCUS_UP
		_cam.global_position = focus + side * 3.0
		_cam.look_at(focus, n)
		await process_frame
		await RenderingServer.frame_post_draw

		var img: Image = root.get_texture().get_image()
		var low := _lowest_silhouette_row(img)
		if low < 0:
			continue
		# Si la silueta toca el borde inferior, la medicion esta recortada y
		# mentiria hacia arriba: se descarta en vez de publicarla.
		if low >= img.get_height() - 2:
			clipped += 1
			continue
		var ground_row: float = _cam.unproject_position(p).y
		samples.append((ground_row - float(low)) * _mpp)

	if samples.is_empty():
		printerr("no se pudo segmentar la silueta en ", label)
		return {"mean": 0.0, "worst": 0.0}

	samples.sort()
	# El pie de apoyo es el que llega mas abajo: 40% de muestras con mayor
	# penetracion, mismo criterio que la version por huesos.
	var stance := samples.slice(0, maxi(1, int(samples.size() * 0.4)))
	var sum := 0.0
	for v in stance:
		sum += v
	var mean_pen: float = sum / float(stance.size())
	print("")
	print("%s  (%d muestras utiles, %d en apoyo, %d descartadas por recorte)" % [label, samples.size(), stance.size(), clipped])
	print("   penetracion  media %+.4f m   peor %+.4f m   (negativo = atraviesa el piso)" % [mean_pen, stance[0]])
	return {"mean": mean_pen, "worst": stance[0]}

func _lowest_silhouette_row(img: Image) -> int:
	var h := img.get_height()
	var w := img.get_width()
	for y in range(h - 1, -1, -1):
		for x in range(0, w, 2):
			var c := img.get_pixel(x, y)
			if absf(c.r - BG.r) > 0.12 or absf(c.g - BG.g) > 0.12 or absf(c.b - BG.b) > 0.12:
				return y
	return -1

func _meshes(n: Node) -> Array:
	var out: Array = []
	if n is MeshInstance3D:
		out.append(n)
	for c in n.get_children():
		out.append_array(_meshes(c))
	return out

func _ground(p: Vector3) -> Dictionary:
	var space := root.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(p + Vector3.UP * 2.0, p + Vector3.DOWN * 40.0)
	q.exclude = _exclude
	var r := space.intersect_ray(q)
	if r:
		return {"pos": r.position, "normal": r.normal}
	return {}

func _find(n: Node, t: String) -> Node:
	for c in n.get_children():
		if c.is_class(t):
			return c
		var x := _find(c, t)
		if x:
			return x
	return null
