extends SceneTree

## Spike ADR-003: mide el foot IK contra el estandar del Benchmark
## Biomecanico (§v2, fila HZD: "foot IK contra el terreno cada frame --
## pies creibles en terreno"; y el canon de Sable: raiz continua).
##
## "Pie creible en pendiente" no es una opinion: son tres cosas medibles.
##
##   1. PENETRACION -- que parte del pie queda POR DEBAJO de la superficie.
##      Se mide la altura con signo del tobillo y del dedo sobre el suelo
##      real (raycast vertical en su propio XZ). Negativo = atraviesa.
##   2. ANGULO DE PLANTA -- angulo entre el vector tobillo->dedo y el plano
##      del terreno. 0 = la planta acompana la pendiente. Positivo = punta
##      levantada; negativo = punta clavada en el suelo.
##   3. RAIZ CONTINUA -- el Benchmark (Sable, medido frame a frame) exige
##      que la raiz avance suave TODOS los frames. Se mide la dispersion
##      del avance por frame.
##
## El equivalente de Unity vive en
## unity/Assets/_Spike/Editor/SpikeFootIKBenchmark.cs y usa las mismas
## tres metricas, para que los numeros se puedan poner uno al lado del otro.

const SAMPLES := 24
const RAMP_Z := 8.0
const ROOT_FRAMES := 180

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
	var skel: Skeleton3D = _find(dagna, "Skeleton3D")
	var ap: AnimationPlayer = _find(dagna, "AnimationPlayer")

	# Los propios personajes son cuerpos de colision: sin excluirlos, el
	# rayo vertical le pega a la CAPSULA de Dagna antes que al suelo y la
	# "penetracion" sale de -1.9 m, que es la altura de la capsula, no un
	# defecto del IK.
	for n in ["Dagna_Placeholder", "PlayerArmature"]:
		var b: CollisionObject3D = root.find_child(n, true, false)
		if b:
			_exclude.append(b.get_rid())

	# --- Parte A: raiz continua, durante la caminata real ---
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
	print("RAIZ  avance medio por frame = %.4f m  desvio = %.4f m  (%.1f%% del avance)" % [mean, sd, 100.0 * sd / maxf(mean, 0.0001)])

	# --- Pie, medido en DOS lugares ---
	# El angulo absoluto tobillo->dedo no dice nada: depende de como esta
	# armado el rig, no del IK. Lo que si dice algo es cuanto CAMBIA ese
	# angulo al pasar de piso plano a una pendiente de 21.8 grados: un foot
	# IK que adapta la planta deberia girarla ~21.8; uno que no adapta, ~0.
	# Con `-- --noik` se apaga el foot IK: da la linea base de lo que hace
	# la animacion sola, que es contra lo que hay que comparar el IK para
	# saber si aporta o si solo esta hundiendo el pie.
	if "--noik" in OS.get_cmdline_user_args():
		var ikn: Node = dagna.find_child("SpikeFootIK", true, false)
		if ikn:
			ikn.set_physics_process(false)
		for c in skel.get_children():
			if c is SkeletonIK3D:
				(c as SkeletonIK3D).stop()
		print(">>> FOOT IK APAGADO (linea base de la animacion sola)")

	dagna.set("walk_speed", 0.0)
	var flat := await _measure(dagna, skel, ap, -5.0, "PLANO")
	var ramp := await _measure(dagna, skel, ap, RAMP_Z, "RAMPA 21.8 grados")
	print("")
	print("ADAPTACION A LA PENDIENTE = %.2f grados  (ideal 21.80; 0 = la planta no se entera)" % absf(ramp["ang"] - flat["ang"]))
	quit(0)

func _measure(dagna: Node3D, skel: Skeleton3D, ap: AnimationPlayer, z: float, label: String) -> Dictionary:
	dagna.set_physics_process(true)
	dagna.global_position = Vector3(0.0, 8.0, z)
	dagna.global_transform.basis = Basis.looking_at(Vector3(0, 0, 1), Vector3.UP)
	for i in range(600):
		await physics_frame
		if dagna.is_on_floor():
			break
	dagna.set_physics_process(false)
	ap.play("walk")
	var anim: Animation = ap.get_animation("walk")

	var rows: Array = []
	for side in ["Left", "Right"]:
		var ankle := skel.find_bone(side + "Foot")
		var toe := skel.find_bone(side + "Toes")
		if ankle < 0 or toe < 0:
			continue
		for i in range(SAMPLES):
			ap.seek(anim.length * i / float(SAMPLES), true)
			await physics_frame
			await physics_frame
			var a: Vector3 = _world(skel, ankle)
			var d: Vector3 = _world(skel, toe)
			var ga := _ground(a)
			var gd := _ground(d)
			if ga.is_empty() or gd.is_empty():
				continue
			var v: Vector3 = d - a
			var ang := 0.0
			if v.length() > 0.0001:
				ang = 90.0 - rad_to_deg(acos(clampf(v.normalized().dot(ga["normal"]), -1.0, 1.0)))
			rows.append({"h_toe": d.y - (gd["pos"] as Vector3).y, "h_ankle": a.y - (ga["pos"] as Vector3).y, "ang": ang})

	# Apoyo = el 40% de muestras con el dedo mas bajo.
	rows.sort_custom(func(x, y): return x["h_toe"] < y["h_toe"])
	var stance: Array = rows.slice(0, maxi(1, int(rows.size() * 0.4)))
	var min_toe := INF
	var sum_toe := 0.0
	var min_ankle := INF
	var sum_ang := 0.0
	for r in stance:
		min_toe = minf(min_toe, r["h_toe"])
		sum_toe += r["h_toe"]
		min_ankle = minf(min_ankle, r["h_ankle"])
		sum_ang += r["ang"]
	var mean_ang: float = sum_ang / float(stance.size())
	print("")
	print("%s  (%d muestras en apoyo de %d)" % [label, stance.size(), rows.size()])
	print("   penetracion del DEDO     media %+.4f m   peor %+.4f m   (negativo = atraviesa)" % [sum_toe / float(stance.size()), min_toe])
	print("   penetracion del TOBILLO  peor  %+.4f m" % min_ankle)
	print("   angulo de planta         %.2f grados" % mean_ang)
	return {"ang": mean_ang, "min_toe": min_toe}

var _exclude: Array[RID] = []

func _ground(p: Vector3) -> Dictionary:
	var space := root.get_world_3d().direct_space_state
	var q := PhysicsRayQueryParameters3D.create(p + Vector3.UP * 2.0, p + Vector3.DOWN * 2.0)
	q.exclude = _exclude
	var r := space.intersect_ray(q)
	if r:
		return {"pos": r.position, "normal": r.normal}
	return {}

func _world(skel: Skeleton3D, idx: int) -> Vector3:
	return (skel.global_transform * skel.get_bone_global_pose(idx)).origin

func _find(n: Node, t: String) -> Node:
	for c in n.get_children():
		if c.is_class(t):
			return c
		var x := _find(c, t)
		if x:
			return x
	return null
