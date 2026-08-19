extends Node
class_name BondDriver

## Driver del boton de Bond para el Protocolo A (test gris).
##
## Hace tres cosas y ninguna mas:
##   1. Traduce el input en un impulso hacia arriba mientras el boton vive.
##   2. Mata el boton al minuto 5 exacto, SIN feedback de ningun tipo.
##   3. Registra CADA pulsacion en el hook de telemetria, viva o muerta.
##
## Lo del punto 2 es la parte fragil del test y por eso esta en codigo y no
## en la mano del facilitador: el documento (§1) exige que al morir el boton
## no haya aviso, ni animacion de fallo, ni sonido, ni mensaje. Cualquier
## feedback -- incluido un cambio de icono en la UI -- convierte "el jugador
## insiste" en "el jugador vio que se apago", que es otra medicion.

signal button_died

const TelemetryScript = preload("res://scripts/telemetry.gd")

## Fases del protocolo, en milisegundos. Editables para poder correr el test
## automatizado sin esperar 5 minutos reales.
@export var con_phase_ms: int = 5 * 60 * 1000
@export var sin_phase_ms: int = 5 * 60 * 1000
@export var impulse: float = 6.0
@export var action_name: String = "bond"
@export var scene_id: String = ""
@export var player_path: NodePath
@export var telemetry_path: NodePath
## Si es false, el driver no lee input por su cuenta; se lo maneja llamando
## a `press()`. Lo usa el test.
@export var read_input: bool = true

var button_alive: bool = true
## Ancla de reloj REAL, no acumulador de deltas. Ver la nota en `_process`.
var _begin_ms: int = 0
var _started: bool = false
var _ended: bool = false
var _player: Node3D = null
var _telemetry: Object = null


func _ready() -> void:
	set_process(false)


func begin() -> void:
	_started = true
	_ended = false
	button_alive = true
	_begin_ms = Time.get_ticks_msec()
	var t = _resolve_telemetry()
	if t != null:
		t.set_phase(TelemetryScript.PHASE_CON)
	set_process(true)


## El tiempo se lee del reloj monotonico, NO se acumula sumando deltas.
##
## La version anterior hacia `_elapsed_ms += int(round(delta * 1000.0))` y
## eso rompio las dos primeras sesiones reales: con la escena gris vacia y el
## FPS sin tope, delta ronda los 0.7 ms y redondea a 1, asi que el contador
## corria ~45% rapido y el boton murio a los 3.5 minutos en vez de a los 5.
## El error dependia del FPS de la maquina, o sea que cada tester habria
## recibido un test distinto -- y el minuto 5 es el experimento entero.
##
## Time.get_ticks_msec() es ademas la MISMA base de tiempo que estampa la
## telemetria, asi que el corte y el CSV no pueden desincronizarse.
func _process(_delta: float) -> void:
	if not _started or _ended:
		return
	var elapsed: int = Time.get_ticks_msec() - _begin_ms

	if button_alive and elapsed >= con_phase_ms:
		_kill_button()

	if elapsed >= con_phase_ms + sin_phase_ms:
		_finish()


func _unhandled_input(event: InputEvent) -> void:
	if not read_input or not _started or _ended:
		return
	if not InputMap.has_action(action_name):
		return
	if event.is_action_pressed(action_name, false):
		press()


## Una pulsacion. Se registra SIEMPRE, viva o muerta, dentro o fuera de la
## zona: el filtrado es del derivador, no del hook.
func press() -> void:
	var pos: Vector3 = Vector3.ZERO
	var p := _resolve_player()
	if p != null:
		pos = p.global_position

	var t = _resolve_telemetry()
	if t != null:
		t.bond_press(button_alive, pos, scene_id)

	if button_alive:
		_apply_impulse(p)


## El impulso puede no aplicarse (por ejemplo, con el jugador en el aire) y
## eso NO cambia lo que se registra: `button_alive` describe el estado del
## boton, no si produjo efecto. Una pulsacion en el aire durante la fase CON
## es una pulsacion con el boton vivo.
func _apply_impulse(p: Node3D) -> void:
	if p == null:
		return
	if p.has_method("can_bond") and not p.call("can_bond"):
		return
	if p is CharacterBody3D:
		var cb := p as CharacterBody3D
		cb.velocity.y = impulse
	elif p.has_method("bond_impulse"):
		p.call("bond_impulse", impulse)


## Muere en silencio. Ningun efecto, ningun sonido, ninguna senal hacia la UI.
## `button_died` existe para la telemetria y el test, no para el jugador.
func _kill_button() -> void:
	button_alive = false
	var t = _resolve_telemetry()
	if t != null:
		t.set_phase(TelemetryScript.PHASE_SIN)
	button_died.emit()


func _finish() -> void:
	_ended = true
	set_process(false)
	var t = _resolve_telemetry()
	if t != null:
		t.end_session(TelemetryScript.REASON_COMPLETA)


## Corte por fallo tecnico o incomodidad del tester (§3.3). La sesion queda
## marcada en el CSV y el derivador la descarta sola.
func abort(reason: String = TelemetryScript.REASON_FALLO) -> void:
	_ended = true
	set_process(false)
	var t = _resolve_telemetry()
	if t != null:
		t.end_session(reason)


func _resolve_player() -> Node3D:
	if _player == null and player_path != NodePath():
		_player = get_node_or_null(player_path) as Node3D
	if _player == null:
		_player = get_tree().get_first_node_in_group("player") as Node3D
	return _player


func _resolve_telemetry() -> Object:
	if _telemetry == null and telemetry_path != NodePath():
		_telemetry = get_node_or_null(telemetry_path)
	if _telemetry == null:
		_telemetry = get_tree().get_first_node_in_group("bond_telemetry")
	return _telemetry
