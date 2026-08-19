extends Node3D
class_name GraySession

## Arranque de una sesion del Protocolo A.
##
##   godot --path godot -- --tester=Diego
##
## No hay UI. Ni cronometro, ni contador, ni mensaje de fase, ni pantalla de
## fin. El documento (§1) exige que al morir el boton no haya aviso de ningun
## tipo, y cualquier elemento en pantalla que cambie al minuto 5 convierte
## "el jugador insiste" en "el jugador vio que se apago".
##
## El facilitador tampoco necesita UI: los cortes son por teclado y quedan en
## el CSV.
##   F10  corte por fallo tecnico del build      (§3.3, excepcion 1)
##   F11  corte por incomodidad fisica del tester (§3.3, excepcion 2)
## Las dos cierran la sesion con una razon que el derivador descarta sola.

@onready var _telemetry: Node = $Telemetry
@onready var _driver: Node = $BondDriver

var _tester_id: String = "sin_id"


func _ready() -> void:
	var gravedad: float = -1.0
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--tester="):
			_tester_id = a.substr(9)
		elif a.begins_with("--gravedad="):
			gravedad = a.substr(11).to_float()

	if gravedad > 0.0:
		_aplicar_gravedad(gravedad)

	if _tester_id == "sin_id":
		# No se aborta: una sesion sin id es recuperable a mano si el
		# facilitador anoto la hora (§4.2). Perder la sesion entera por un
		# argumento olvidado seria peor.
		push_warning("Sesion sin --tester=; el CSV queda con tester_id 'sin_id'")

	var path: String = _telemetry.start_session(_tester_id)
	print("[playtest] sesion iniciada: %s" % path)
	print("[playtest] hora de session_start: %s"
		% Time.get_datetime_string_from_system(false, true))
	_driver.begin()
	_telemetry.session_ended.connect(_on_session_ended)
	# Sin esto, el arbol se cierra solo al tocar la X y no hay margen para
	# escribir el cierre en el CSV.
	get_tree().set_auto_accept_quit(false)


## Cambia la gravedad SIN cambiar el alcance vertical del salto.
##
## El apice se deriva de lo que ya hay configurado (v^2 / 2g) y el impulso se
## recalcula para mantenerlo: v = sqrt(2 * g_nueva * apice). Asi el nivel
## sigue siendo valido en todas las variantes -- la mesa se alcanza igual, el
## escalon sigue fuera de alcance desde el piso, y las 18 verificaciones de
## tools/test_gray_scene.gd siguen valiendo. Lo unico que cambia es cuanto
## tiempo pasas en el aire, que es exactamente la pregunta de tacto.
func _aplicar_gravedad(g: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null or not player.has_method("set_gravity"):
		return
	var g_vieja: float = player.get_bond_gravity()
	var v_vieja: float = float(_driver.impulse)
	var apice: float = (v_vieja * v_vieja) / (2.0 * g_vieja)
	var v_nueva: float = sqrt(2.0 * g * apice)
	player.set_gravity(g)
	_driver.impulse = v_nueva
	print("[playtest] gravedad %.1f -> impulso %.2f | apice %.2f m | aire %.2f s"
		% [g, v_nueva, apice, 2.0 * v_nueva / g])


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event is InputEventKey:
		var k := event as InputEventKey
		match k.keycode:
			KEY_F10:
				print("[playtest] CORTE — fallo tecnico")
				_driver.abort("fallo_tecnico")
			KEY_F11:
				print("[playtest] CORTE — incomodidad del tester")
				_driver.abort("abortada")


## Cerrar la ventana termina la sesion como 'abortada', no como 'completa':
## el tester no llego al final de los 10 minutos. Queda registrado y el
## derivador decide -- pero los datos quedan en disco con su cierre.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("[playtest] ventana cerrada antes de terminar")
		if _driver != null:
			_driver.abort("abortada")
		else:
			get_tree().quit()


func _on_session_ended(reason: String) -> void:
	print("[playtest] sesion cerrada: %s" % reason)
	print("[playtest] CSV en: %s" % _telemetry.current_path())
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Un frame de gracia para que el ultimo flush llegue a disco.
	await get_tree().process_frame
	get_tree().quit()
