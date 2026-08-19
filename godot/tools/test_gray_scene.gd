extends SceneTree

## Test de la escena gris (Protocolo A §1).
##
##   godot --headless --path godot --script res://tools/test_gray_scene.gd
##
## Lo que este test existe para probar NO es que el codigo corra: es que la
## afirmacion de diseno sea cierta. §1 dice "una cornisa alcanzable SOLO con
## el boton", y de eso depende que un P=0 al minuto 5 signifique algo. Si
## hubiera cualquier otra forma de subir, el tester subiria por ahi, P daria
## 0, y el rojo seria mentira.
##
## Por eso el bloque central camina contra la mesa desde OCHO direcciones y
## mide la altura maxima alcanzada. Es la clase de afirmacion que en este
## proyecto ya se dio por buena tres veces sin medirla.

const BUILD = preload("res://tools/build_gray_scene.gd")

var _fails: int = 0
var _checks: int = 0
var _scene_root: Node3D = null
var _player: CharacterBody3D = null
var _driver: Node = null
var _telemetry: Node = null


func _initialize() -> void:
	if not _load_scene():
		print("FAIL — no se pudo cargar res://scenes/gray_test.tscn")
		quit(1)
		return

	await _test_geometria_declarada()
	await _test_cornisa_inalcanzable_caminando()
	await _test_cornisa_alcanzable_con_boton()
	await _test_boton_muerto_no_sube()
	await _test_zona_de_cornisa()
	await _test_encadenado_al_mirador()
	await _test_no_se_cae_del_mundo()

	print("\n" + "=".repeat(66))
	if _fails == 0:
		print("ALL_PASS — %d verificaciones" % _checks)
	else:
		print("FAIL — %d de %d verificaciones" % [_fails, _checks])
	print("=".repeat(66))
	quit(1 if _fails > 0 else 0)


func _load_scene() -> bool:
	var ps: PackedScene = load("res://scenes/gray_test.tscn")
	if ps == null:
		return false
	_scene_root = ps.instantiate() as Node3D
	if _scene_root == null:
		return false
	# Se le saca el script de sesion: instanciar la escena tal cual arrancaria
	# una sesion de 10 minutos y cerraria el arbol al terminar. El test maneja
	# telemetria y driver a mano.
	_scene_root.set_script(null)
	root.add_child(_scene_root)

	_player = _scene_root.get_node_or_null("Player") as CharacterBody3D
	_driver = _scene_root.get_node_or_null("BondDriver")
	_telemetry = _scene_root.get_node_or_null("Telemetry")
	return _player != null and _driver != null and _telemetry != null


# ==========================================================================

func _test_geometria_declarada() -> void:
	print("\n--- geometria ---")
	_check(BUILD.ALTURA_MESA < BUILD.APICE,
		"la cornisa (%.2f m) esta bajo el apice del salto (%.2f m)"
		% [BUILD.ALTURA_MESA, BUILD.APICE])
	_check(BUILD.ALTURA_ESCALON > BUILD.APICE,
		"el escalon (%.2f m) NO se alcanza desde el piso" % BUILD.ALTURA_ESCALON)
	_check(BUILD.ALTURA_ESCALON < BUILD.ALTURA_MESA + BUILD.APICE,
		"el escalon si se alcanza desde la mesa")
	_check(BUILD.ALTURA_MIRADOR > BUILD.ALTURA_MESA + BUILD.APICE,
		"el mirador (%.2f m) NO se alcanza desde la mesa" % BUILD.ALTURA_MIRADOR)
	_check(BUILD.ALTURA_MIRADOR < BUILD.ALTURA_ESCALON + BUILD.APICE,
		"el mirador si se alcanza encadenando desde el escalon")
	_check(_scene_root.get_node_or_null("Mesa") != null, "existe la mesa")
	_check(_scene_root.get_node_or_null("LedgeZone") != null, "existe la zona de cornisa")
	await process_frame


## EL TEST QUE IMPORTA. Camina contra la mesa desde 8 direcciones, 2.5 s cada
## una, y mide la altura maxima. Si alguna supera el umbral, hay una via de
## subida que no es el boton y el Protocolo A no es valido como esta.
func _test_cornisa_inalcanzable_caminando() -> void:
	print("\n--- la mesa NO se sube caminando (8 direcciones) ---")
	var r: float = 16.0
	var dirs: Array = [
		["N", Vector3(0, 0, -1)], ["S", Vector3(0, 0, 1)],
		["E", Vector3(1, 0, 0)], ["O", Vector3(-1, 0, 0)],
		["NE", Vector3(1, 0, -1).normalized()], ["NO", Vector3(-1, 0, -1).normalized()],
		["SE", Vector3(1, 0, 1).normalized()], ["SO", Vector3(-1, 0, 1).normalized()],
	]
	var peor: float = -1.0
	var peor_dir: String = ""

	for d in dirs:
		var nombre: String = d[0]
		var fuera: Vector3 = d[1]
		# Se lo pone lejos, mirando al centro, y camina hacia adentro.
		var y_max: float = await _caminar(fuera * r, -fuera, 2.5, false)
		if y_max > peor:
			peor = y_max
			peor_dir = nombre

	_check(peor < 0.6,
		"altura maxima caminando: %.2f m (peor direccion: %s) — no hay via sin boton"
		% [peor, peor_dir])
	await process_frame


func _test_cornisa_alcanzable_con_boton() -> void:
	print("\n--- la cornisa SI se sube con el boton ---")
	var y_max: float = await _caminar(Vector3(0, 0.1, 9.0), Vector3(0, 0, -1), 2.5, true)
	_check(y_max >= BUILD.ALTURA_MESA,
		"con el boton se alcanza %.2f m (cornisa a %.2f m)" % [y_max, BUILD.ALTURA_MESA])
	# "Alcanzar la altura" no es "quedarse arriba". Se lo deja caer y asentar
	# sin tocar nada, y recien ahi se verifica que este PARADO en la mesa: de
	# lo contrario la afirmacion se cumpliria en pleno aire, de paso.
	_soltar_todo()
	for i in range(120):
		await physics_frame
	var y_final: float = _player.global_position.y
	_check(_player.is_on_floor() and absf(y_final - BUILD.ALTURA_MESA) < 0.25,
		"queda PARADO sobre la mesa tras asentarse: y=%.2f, on_floor=%s"
		% [y_final, _player.is_on_floor()])
	await process_frame


func _test_boton_muerto_no_sube() -> void:
	print("\n--- con el boton muerto no se sube ---")
	_driver.button_alive = false
	var y_max: float = await _caminar(Vector3(0, 0.1, 9.0), Vector3(0, 0, -1), 2.5, true)
	_check(y_max < 0.6,
		"con button_alive=false la altura maxima es %.2f m" % y_max)
	_driver.button_alive = true
	await process_frame


func _test_zona_de_cornisa() -> void:
	print("\n--- la zona de la cornisa ---")
	_telemetry.output_dir = "user://test_gray"
	_telemetry.start_session("geometria", "sesion-gray")
	_telemetry.set_phase("con")

	_player.velocity = Vector3.ZERO
	_player.global_position = Vector3(0, 0.1, 16)
	await physics_frame
	await physics_frame
	_check(not _telemetry.in_ledge_zone(), "a 16 m del frente esta fuera de la zona")

	# La zona rodea la mesa entera (decision del director, 2026-08-19), asi
	# que hay que verificar LAS CUATRO caras. Con la version de una sola cara
	# tres de cada cuatro aproximaciones caian fuera por construccion, y eso
	# es lo que hundio P en las corridas de prueba.
	var d: float = BUILD.MESA_LADO * 0.5 + 1.5
	for lado in [["sur", Vector3(0, 0.1, d)], ["norte", Vector3(0, 0.1, -d)],
			["este", Vector3(d, 0.1, 0)], ["oeste", Vector3(-d, 0.1, 0)]]:
		_player.velocity = Vector3.ZERO
		_player.global_position = lado[1]
		await physics_frame
		await physics_frame
		_check(_telemetry.in_ledge_zone(),
			"al pie de la cara %s esta dentro de la zona" % lado[0])

	# Y parado ARRIBA no cuenta: ya esta del otro lado de la cornisa.
	_player.velocity = Vector3.ZERO
	_player.global_position = Vector3(0, BUILD.ALTURA_MESA + 0.1, 3.0)
	for i in range(20):
		await physics_frame
	_check(not _telemetry.in_ledge_zone(),
		"parado ARRIBA de la mesa NO cuenta como estar frente a la cornisa")

	_player.velocity = Vector3.ZERO
	_player.global_position = Vector3(0, 0.1, 7.5)
	await physics_frame
	await physics_frame
	_check(_telemetry.in_ledge_zone(), "delante de la cornisa esta dentro de la zona")

	_driver.press()
	var rows: Array = []
	for r in _leer_csv(_telemetry.current_path()):
		if str(r.get("event", "")) == "bond_press":
			rows.append(r)
	_check(rows.size() == 1 and str(rows[0].get("in_ledge_zone", "")) == "true",
		"la pulsacion delante de la cornisa queda marcada in_ledge_zone")

	_telemetry.end_session("completa")
	await process_frame


## La torre esta sobre la mesa, asi que la cadena completa es
## piso → mesa → escalon → mirador. Cada peldano se prueba desde el anterior,
## y se prueba que NO se alcance desde el de mas abajo.
func _test_encadenado_al_mirador() -> void:
	print("\n--- la torre exige encadenar ---")
	var x_esc: float = BUILD.TORRE_LADO * 0.5

	# Parado en la mesa, al pie del escalon.
	var y1: float = await _caminar(
		Vector3(x_esc, BUILD.ALTURA_MESA + 0.2, 4.0), Vector3(0, 0, -1), 2.5, true)
	_check(y1 >= BUILD.ALTURA_ESCALON,
		"desde la mesa se alcanza el escalon (%.2f m >= %.2f m)"
		% [y1, BUILD.ALTURA_ESCALON])

	# "No se alcanza el mirador desde la mesa" es sobre UN salto, no sobre
	# 2.5 s de pulsaciones repetidas: encadenando por el escalon si se llega,
	# y ese es justamente el camino que el nivel quiere. Medirlo con la
	# ventana larga daba un falso rojo al bajar el airtime.
	var y_uno: float = await _un_salto(Vector3(0.0, BUILD.ALTURA_MESA + 0.2, 3.0), 2.0)
	# Las dos mitades: que el salto haya pasado de veras, y que no llegue.
	_check(y_uno >= BUILD.ALTURA_MESA + 1.0,
		"un salto desde la mesa despega de verdad (%.2f m)" % y_uno)
	_check(y_uno < BUILD.ALTURA_MIRADOR,
		"y NO alcanza el mirador (%.2f m < %.2f m)" % [y_uno, BUILD.ALTURA_MIRADOR])

	# Parado en el escalon, caminando hacia el mirador.
	var y2: float = await _caminar(
		Vector3(x_esc, BUILD.ALTURA_ESCALON + 0.2, -2.0), Vector3(-1, 0, 0), 2.5, true)
	_check(y2 >= BUILD.ALTURA_MIRADOR,
		"desde el escalon si se alcanza el mirador (%.2f m)" % y2)
	await process_frame


func _test_no_se_cae_del_mundo() -> void:
	print("\n--- los muros contienen ---")
	var y_min: float = 999.0
	for d in [Vector3(0, 0, -1), Vector3(0, 0, 1), Vector3(1, 0, 0), Vector3(-1, 0, 0)]:
		_player.velocity = Vector3.ZERO
		_player.global_position = d * 18.0 + Vector3(0, 0.1, 0)
		await _caminar(_player.global_position, d, 3.0, false)
		y_min = minf(y_min, _player.global_position.y)
	_check(y_min > -2.0, "caminando contra los cuatro muros no se cae (y min %.2f)" % y_min)
	await process_frame


# ==========================================================================

## Teletransporta, camina en `dir` durante `segundos` y devuelve la altura
## maxima alcanzada. Si `bond`, pulsa el boton cada 0.5 s.
func _caminar(desde: Vector3, dir: Vector3, segundos: float, bond: bool) -> float:
	_soltar_todo()
	_player.velocity = Vector3.ZERO
	_player.global_position = desde
	await physics_frame

	_presionar_direccion(dir)
	var y_max: float = _player.global_position.y
	var frames: int = int(segundos * 60.0)
	for i in range(frames):
		if bond and i % 30 == 0:
			_driver.press()
		await physics_frame
		y_max = maxf(y_max, _player.global_position.y)
	_soltar_todo()
	return y_max


## Una sola pulsacion, quieto, y la altura maxima del vuelo. Sirve para las
## afirmaciones que son sobre el ALCANCE de un salto y no sobre lo que se
## puede encadenar.
func _un_salto(desde: Vector3, segundos: float) -> float:
	_soltar_todo()
	_player.velocity = Vector3.ZERO
	_player.global_position = desde
	# ESPERAR EL SUELO ANTES DE PULSAR. El boton solo responde con los pies
	# apoyados; pulsar mientras todavia cae no hace nada y la altura maxima
	# sale por debajo del punto de partida -- un verde falso que parece un
	# salto corto. La primera version de este helper fallaba justo asi.
	var apoyado: bool = false
	for i in range(180):
		await physics_frame
		if _player.is_on_floor():
			apoyado = true
			break
	if not apoyado:
		push_error("_un_salto: el jugador nunca toco el suelo en %s" % desde)
		return -1.0

	var y_pie: float = _player.global_position.y
	_driver.press()
	var y_max: float = y_pie
	for i in range(int(segundos * 60.0)):
		await physics_frame
		y_max = maxf(y_max, _player.global_position.y)

	# Y verificar que el salto EXISTIO, no solo que no llego alto.
	if y_max - y_pie < 1.0:
		push_error("_un_salto: no despego (subio %.2f m)" % (y_max - y_pie))
	return y_max


## Con yaw = 0 la base del jugador es la identidad: move_forward es -Z,
## move_right es +X. No hace falta tocar la camara.
func _presionar_direccion(dir: Vector3) -> void:
	if dir.z < -0.3: Input.action_press("move_forward")
	if dir.z > 0.3: Input.action_press("move_back")
	if dir.x > 0.3: Input.action_press("move_right")
	if dir.x < -0.3: Input.action_press("move_left")


func _soltar_todo() -> void:
	for a in ["move_forward", "move_back", "move_left", "move_right"]:
		Input.action_release(a)


func _leer_csv(path: String) -> Array:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return []
	var header: PackedStringArray = PackedStringArray()
	var rows: Array = []
	while not f.eof_reached():
		var line: String = f.get_line()
		if line.strip_edges() == "":
			continue
		var cells: PackedStringArray = line.split(",")
		if header.is_empty():
			header = cells
			continue
		var d: Dictionary = {}
		for i in range(mini(header.size(), cells.size())):
			d[header[i]] = cells[i]
		rows.append(d)
	f.close()
	return rows


func _check(cond: bool, label: String) -> void:
	_checks += 1
	if cond:
		print("  ok   %s" % label)
	else:
		_fails += 1
		print("  FAIL %s" % label)
