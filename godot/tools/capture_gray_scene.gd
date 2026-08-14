extends SceneTree

## Capturas de la escena gris, para revision del director.
##
##   godot --path godot --script res://tools/capture_gray_scene.gd
##   (SIN --headless: en headless no hay render y las PNG salen negras)
##
##   → godot/test_out/gray_*.png
##
## No es una herramienta de arte. Sirve para una sola pregunta, que es la que
## §0.4 pone en juego: ¿se LEE el nivel? Si un tester no distingue lo que se
## pisa de lo que no, o no ve que la mesa esta arriba, el rojo del test seria
## de legibilidad y no de reflejo.

const OUT_DIR := "res://test_out"

var _shots: Array = [
	# nombre, posicion de camara, hacia donde mira
	["01_llegada", Vector3(0, 3.0, 22.0), Vector3(0, 1.5, 0)],
	# Mirando a la CARA de la mesa (z=+6), no adentro de ella: la primera
	# version apuntaba a z=4, o sea al interior del volumen, y salia una
	# pared de gris sin informacion.
	["02_frente_cornisa", Vector3(0, 1.7, 12.0), Vector3(0, 2.2, 6.0)],
	["03_desde_la_mesa", Vector3(4.0, 3.4, 4.0), Vector3(-4.0, 5.0, -1.0)],
	["04_torre", Vector3(11.0, 3.0, 14.0), Vector3(0, 4.5, 0)],
	["05_general", Vector3(-20.0, 16.0, 24.0), Vector3(2, 1.0, 0)],
]

var _root: Node3D = null
var _cam: Camera3D = null


func _initialize() -> void:
	# Se llama SIN await, igual que tools/frame_strip.gd. Awaitear adentro de
	# _initialize con render activo cuelga el proceso sin imprimir nada
	# (probado 2026-08-13: 5 min sin una linea de salida).
	_run()


func _run() -> void:
	var ps: PackedScene = load("res://scenes/gray_test.tscn")
	if ps == null:
		push_error("no existe res://scenes/gray_test.tscn — correr build_gray_scene.gd")
		quit(1)
		return

	_root = ps.instantiate() as Node3D
	_root.set_script(null)          # sin arrancar sesion ni capturar el mouse
	root.add_child(_root)

	var player := _root.get_node_or_null("Player")
	if player != null:
		player.queue_free()          # la capsula tapa el encuadre general

	_cam = Camera3D.new()
	_cam.fov = 65.0
	_root.add_child(_cam)
	_cam.current = true

	# Un frame antes del primer encuadre: en `_initialize` los nodos recien
	# agregados todavia no estan "inside tree" y el primer `look_at` falla en
	# silencio, dejando la toma 01 apuntando a cualquier lado.
	await process_frame

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))

	for s in _shots:
		_cam.global_position = s[1]
		_cam.look_at(s[2], Vector3.UP)
		# Dos frames: uno para aplicar la transform, otro para que la sombra
		# direccional se resuelva antes de leer el buffer.
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw

		var img: Image = root.get_texture().get_image()
		var path: String = "%s/gray_%s.png" % [OUT_DIR, s[0]]
		var err: int = img.save_png(path)
		if err == OK:
			print("OK  %s" % path)
		else:
			push_error("no se pudo guardar %s (%d)" % [path, err])

	quit(0)
