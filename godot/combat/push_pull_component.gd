# push_pull_component.gd — PRD-006 alcance 1 (Combate §A): impulsos y
# tracciones vectoriales. Canon §B.2: los LINKS SON PushPull — un solo
# sistema físico para combate (knockback), links del Pivote y traversal.
# En Fase 1 lo consume el knockback por VectorFuerza; PRD-007 (Dagna,
# Springboard) reutiliza esta misma pieza.
#
# Modelo: velocidad externa acumulada con decaimiento exponencial; el
# dueño suma el desplazamiento devuelto por tick() a su posición (la
# colisión/clamp de escena es responsabilidad del dueño).
#
# Loaded via preload (never class_name — see Lecciones).
extends RefCounted

const DECAY: float = 6.0        # 1/s — el impulso muere en ~0.5 s
const MAX_SPEED: float = 14.0   # techo de velocidad externa (sanidad)

var _vel: Vector3 = Vector3.ZERO

## Impulso instantáneo (VectorFuerza / masa ya resuelto por Guard, o
## fuerza cruda / masa si se llama directo).
func apply_impulse(impulse: Vector3) -> void:
	_vel += impulse
	if _vel.length() > MAX_SPEED:
		_vel = _vel.normalized() * MAX_SPEED

## Tracción continua (links de Pivote §B.2): fuerza sostenida este tick.
func apply_pull(force: Vector3, delta: float) -> void:
	_vel += force * delta
	if _vel.length() > MAX_SPEED:
		_vel = _vel.normalized() * MAX_SPEED

func is_active() -> bool:
	return _vel.length_squared() > 0.0004

## Devuelve el DESPLAZAMIENTO de este tick y decae la velocidad.
func tick(delta: float) -> Vector3:
	if not is_active():
		_vel = Vector3.ZERO
		return Vector3.ZERO
	var d: Vector3 = _vel * delta
	_vel *= exp(-DECAY * delta)
	return d
