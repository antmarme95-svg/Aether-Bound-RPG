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
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--tester="):
			_tester_id = a.substr(9)

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
