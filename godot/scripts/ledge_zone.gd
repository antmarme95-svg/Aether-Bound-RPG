extends Area3D
class_name LedgeZone

## Volumen de disparo delante de la cornisa (Protocolo de Playtest §4.1).
##
## Definicion textual del documento: "caja delante de la cornisa, del ancho
## de la cornisa y ~3 m de profundidad, a la altura del suelo desde el que se
## saltaria". `in_ledge_zone` es simplemente "el jugador esta adentro".
##
## Deliberadamente NO se filtra por orientacion de camara ni por distancia al
## borde: el protocolo promete conteo, no criterio.

@export var ledge_id: String = "cornisa_01"
## Ancho de la cornisa. La caja se construye centrada en el nodo.
@export var zone_width: float = 4.0
@export var zone_depth: float = 3.0
@export var zone_height: float = 3.0
## Si esta vacio, se busca el nodo del grupo "bond_telemetry".
@export var telemetry_path: NodePath

var _telemetry: Object = null
var _bodies_inside: int = 0

func _ready() -> void:
	_ensure_shape()
	monitoring = true
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _resolve_telemetry() -> Object:
	if _telemetry != null:
		return _telemetry
	if telemetry_path != NodePath():
		_telemetry = get_node_or_null(telemetry_path)
	if _telemetry == null:
		_telemetry = get_tree().get_first_node_in_group("bond_telemetry")
	return _telemetry


func _ensure_shape() -> void:
	for c in get_children():
		if c is CollisionShape3D:
			return
	var cs := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(zone_width, zone_height, zone_depth)
	cs.shape = box
	# El origen del nodo queda al ras del suelo; la caja sube desde ahi.
	cs.position = Vector3(0.0, zone_height * 0.5, 0.0)
	add_child(cs)


func _on_body_entered(body: Node3D) -> void:
	if not _is_player(body):
		return
	_bodies_inside += 1
	if _bodies_inside != 1:
		return
	var t = _resolve_telemetry()
	if t != null:
		t.ledge_zone_enter(ledge_id)


func _on_body_exited(body: Node3D) -> void:
	if not _is_player(body):
		return
	_bodies_inside = maxi(0, _bodies_inside - 1)
	if _bodies_inside != 0:
		return
	var t = _resolve_telemetry()
	if t != null:
		t.ledge_zone_exit(ledge_id)


func _is_player(body: Node3D) -> bool:
	return body.is_in_group("player")
