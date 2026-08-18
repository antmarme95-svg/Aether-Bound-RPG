extends CharacterBody3D
class_name GrayPlayer

## Jugador del test gris (Protocolo A §1): una capsula que se mueve y nada mas.
##
## Deliberadamente NO tiene salto propio. El encuadre que se le lee al tester
## dice "tienes dos cosas: moverte, y un boton que te impulsa hacia arriba"
## (§3.1), y de ahi depende que la cornisa sea alcanzable SOLO con el boton.
## Si hubiera salto, al minuto 5 el tester subiria igual y P daria 0 por un
## motivo que no tiene nada que ver con lo que el test quiere medir.
##
## Tampoco tiene dash, ni sprint, ni coyote time, ni aceleracion con curva.
## No es minimalismo por pereza: cada verbo extra es una explicacion
## alternativa para un resultado negativo.

@export var speed: float = 5.0
@export var mouse_sensitivity: float = 0.0025
@export var pitch_min_deg: float = -60.0
@export var pitch_max_deg: float = 35.0

var _yaw: float = 0.0
var _pitch: float = -12.0
var _gravity: float = 9.8

@onready var _pivot: Node3D = $CameraPivot


func _ready() -> void:
	add_to_group("player")
	_gravity = float(ProjectSettings.get_setting("physics/3d/default_gravity", 9.8))
	if not Engine.is_editor_hint() and DisplayServer.get_name() != "headless":
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	# ESC libera el mouse y un clic lo vuelve a capturar. Es control del
	# FACILITADOR, no del tester: sin esto el mouse queda atrapado y para
	# tocar cualquier cosa de la maquina hay que matar el proceso, que
	# ademas se llevaria el cierre limpio del CSV.
	if event is InputEventKey and event.pressed and (event as InputEventKey).keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if event is InputEventMouseButton and event.pressed and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mm := event as InputEventMouseMotion
		_yaw -= mm.relative.x * mouse_sensitivity
		_pitch = clampf(
			_pitch - rad_to_deg(mm.relative.y * mouse_sensitivity),
			pitch_min_deg, pitch_max_deg)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta

	var input := Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_back") - Input.get_action_strength("move_forward"))

	var basis_yaw := Basis(Vector3.UP, _yaw)
	var dir: Vector3 = (basis_yaw * Vector3(input.x, 0.0, input.y))
	if dir.length_squared() > 1.0:
		dir = dir.normalized()

	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	move_and_slide()

	if dir.length_squared() > 0.001:
		# La capsula mira hacia donde camina. Es lo minimo para que el tester
		# entienda su propia orientacion en tercera persona.
		var target := atan2(-dir.x, -dir.z)
		rotation.y = lerp_angle(rotation.y, target, 12.0 * delta)

	if _pivot != null:
		_pivot.global_rotation = Vector3(deg_to_rad(_pitch), _yaw, 0.0)


## Lo llama el BondDriver. Existe como metodo aparte para que el impulso no
## dependa de que el driver conozca el tipo del jugador.
func bond_impulse(amount: float) -> void:
	velocity.y = amount


## El boton solo responde con los pies en el suelo. Sin esto, encadenar
## pulsaciones en el aire daria altura infinita y las alturas del nivel
## dejarian de significar algo.
func can_bond() -> bool:
	return is_on_floor()
