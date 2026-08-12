extends SceneTree

## Spike ADR-003: tira de frames del ciclo de caminata de Dagna, para
## comparar cuadro a cuadro contra la misma tira generada del lado Unity
## (unity/Assets/_Spike/Editor/SpikeFrameStrip.cs).
##
## Para que la comparacion signifique algo, las dos tiras tienen que cumplir
## lo mismo:
##   - MISMO punto de la rampa (Dagna quieta ahi, walk_speed = 0), asi lo que
##     se compara es la animacion + el foot IK, no el timing del driver.
##   - MISMA cantidad de frames sobre UN ciclo completo.
##   - MISMA fase inicial: el contacto del talon izquierdo, detectado
##     midiendo el hueso, no elegido a ojo. Sin esto las dos tiras arrancan
##     en puntos arbitrarios del paso y las columnas no se pueden comparar.
##   - MISMA camara relativa al personaje y misma resolucion.

const FRAMES := 8
const OUT_DIR := "res://test_out/strip"
const SAMPLES := 120          # densidad del barrido para hallar el contacto
const RAMP_Z := 8.0           # punto de la rampa donde se planta
const CAM_SIDE := 4.2
const CAM_UP := 0.9
const LOOK_UP := 0.85
const CAM_FOV := 32.0

func _initialize() -> void:
	change_scene_to_file("res://scenes/spike_slope.tscn")
	_run()

func _run() -> void:
	await process_frame
	await process_frame

	var dagna: Node3D = root.find_child("Dagna_Placeholder", true, false)
	var skel: Skeleton3D = _find(dagna, "Skeleton3D")
	var ap: AnimationPlayer = _find(dagna, "AnimationPlayer")
	if dagna == null or skel == null or ap == null:
		printerr("frame_strip: falta Dagna / Skeleton3D / AnimationPlayer")
		quit(1)
		return

	# Plantada en la rampa, sin avanzar. Primero se la deja caer y asentarse
	# sobre la pendiente con el driver vivo...
	dagna.set("walk_speed", 0.0)
	dagna.global_position = Vector3(0.0, 6.0, RAMP_Z)
	# Mirando rampa arriba, que es como camina en la corrida real. Con
	# walk_speed = 0 el driver nunca la gira, y quedaba encarada rampa abajo.
	dagna.global_transform.basis = Basis.looking_at(Vector3(0, 0, 1), Vector3.UP)
	# OJO: hay que esperar frames de FISICA, no de render. En ventana el
	# render corre a cientos de fps y 60 frames de render son ~0.1s de
	# simulacion -- Dagna quedaba flotando en el aire a medio caer.
	var settled := false
	for i in range(600):
		await physics_frame
		if dagna.is_on_floor():
			settled = true
			break
	print("asentada=", settled, " en ", dagna.global_position)

	# ...y despues se apaga SpikeCompanionWalk. Si sigue corriendo, cada
	# physics frame ve speed == 0 y fuerza play("idle"), que pisa el seek()
	# de este script: el barrido devolvia siempre la misma pose estatica.
	# El foot IK vive en su propio nodo, asi que sigue funcionando.
	dagna.set_physics_process(false)
	ap.play("walk")

	var anim: Animation = ap.get_animation("walk")
	var lf := skel.find_bone("LeftFoot")

	# --- Fase 0 = contacto del talon izquierdo ---
	# El personaje mira a -Z local (convencion de Godot), asi que el pie mas
	# adelantado del ciclo es el de Z minimo en espacio de esqueleto.
	#
	# El foot IK se apaga mientras se busca: escribe la pose del pie cada
	# physics frame, y leerla con el IK activo devuelve el pie ya pegado al
	# suelo -- rango casi nulo y contacto indetectable. Se mide la animacion
	# pura y se vuelve a encender para capturar.
	# No alcanza con apagar el _physics_process del nodo SpikeFootIK: los
	# SkeletonIK3D que el creo resuelven por su cuenta, colgados del
	# Skeleton3D. Hay que pararlos a ellos.
	var ik: Node = dagna.find_child("SpikeFootIK", true, false)
	if ik:
		ik.set_physics_process(false)
	var ik_nodes: Array = []
	for c in skel.get_children():
		if c is SkeletonIK3D:
			ik_nodes.append(c)
			(c as SkeletonIK3D).stop()
	print("SkeletonIK3D encontrados: ", ik_nodes.size())

	var contact_t := 0.0
	var min_z := INF
	for i in range(SAMPLES):
		var t := anim.length * i / float(SAMPLES)
		ap.seek(t, true)
		await process_frame
		var z: float = skel.get_bone_global_pose(lf).origin.z
		if z < min_z:
			min_z = z
			contact_t = t
	print("contacto del talon izquierdo en t=%.3f (z=%.3f) de un ciclo de %.3fs" % [contact_t, min_z, anim.length])
	if ik:
		ik.set_physics_process(true)
	for c in ik_nodes:
		(c as SkeletonIK3D).start()

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))

	var cam := Camera3D.new()
	cam.name = "StripCam"
	root.add_child(cam)
	cam.current = true
	cam.fov = CAM_FOV

	for i in range(FRAMES):
		var t: float = fmod(contact_t + anim.length * i / float(FRAMES), anim.length)
		ap.seek(t, true)
		# Dos frames de fisica para que el foot IK reaccione al pose nuevo
		# antes de la captura -- si no, el pie va un frame atrasado.
		await process_frame
		await process_frame

		var focus: Vector3 = dagna.global_position + Vector3.UP * LOOK_UP
		var side: Vector3 = dagna.global_transform.basis.x.normalized()
		cam.global_position = focus + side * CAM_SIDE + Vector3.UP * CAM_UP
		cam.look_at(focus, Vector3.UP)
		await process_frame

		await RenderingServer.frame_post_draw
		var path := OUT_DIR + "/godot_%02d.png" % i
		root.get_texture().get_image().save_png(path)
		print("  frame %d/%d  t=%.3f  -> %s" % [i + 1, FRAMES, t, path])

	print("listo: ", FRAMES, " frames en ", OUT_DIR)
	quit(0)

func _find(n: Node, type_name: String) -> Node:
	for c in n.get_children():
		if c.is_class(type_name):
			return c
		var f := _find(c, type_name)
		if f:
			return f
	return null
