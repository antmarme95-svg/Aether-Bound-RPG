# combat_component.gd — PRD-006 alcance 1 (Combate §A): combos, input
# buffer y ventanas ancladas a las FASES BIOMECÁNICAS del golpe — nunca
# timers arbitrarios (Movilidad Realista §4.3; rig_biomech define las
# fracciones canon windup/active/recovery).
#
# Semántica de la cadena (el sello del Humano Duelist es el buffer generoso):
#   - try_attack() en idle           → arranca el golpe 0.
#   - try_attack() durante active/recovery → BUFFEREA; la cadena dispara al
#     completar el recovery (ahí vive la ventana de encadenar, §4.3).
#   - cancel() durante windup        → aborta limpio (windup cancelable).
#   - El hitbox existe SOLO en active: consume_hit() entrega el HitPayload
#     una única vez por golpe (momentum §4.3: masa × velocidad al conectar).
#
# El componente es lógica pura (RefCounted, headless-safe); el dueño lo
# tickea y lee `strike_k` para animar el rig (rig.play_strike ya anima con
# las mismas fases).
#
# Loaded via preload (never class_name — see Lecciones).
extends RefCounted

const _Biomech = preload("res://character/rig_biomech.gd")
const _Payload = preload("res://combat/hit_payload.gd")
const _WeaponData = preload("res://combat/weapon_data.gd")

var weapon: Dictionary = {}
var body_mass: float = 1.0        # masa del perfil (9-cell) del dueño

var chain_index: int = -1         # -1 = idle; 0..n-1 = golpe en curso
var strike_k: float = 0.0         # progreso normalizado del golpe actual
var _dur: float = 0.0
var _buffered: bool = false
var _hit_consumed: bool = false

func equip(p_weapon: Dictionary, p_body_mass: float) -> void:
	weapon = p_weapon
	body_mass = p_body_mass

func is_striking() -> bool:
	return chain_index >= 0

func phase() -> String:
	if not is_striking():
		return ""
	return _Biomech.phase_name(minf(strike_k, 0.999))

## Intento de ataque. Devuelve true si arrancó un golpe o buffereó cadena.
func try_attack() -> bool:
	if weapon.is_empty():
		return false
	if not is_striking():
		_start_step(0)
		return true
	# Buffer generoso: se acepta desde ACTIVE en adelante; dispara al
	# cerrar el recovery. En windup no se bufferea (ahí se cancela o nada).
	if phase() != "windup" and chain_index < _WeaponData.combo_length(weapon) - 1:
		_buffered = true
		return true
	return false

## Cancelación: solo durante el windup (la carga es cancelable, canon).
func cancel() -> bool:
	if phase() == "windup":
		_reset()
		return true
	return false

## Avanza el golpe. Gameplay clock — corre TODOS los frames (nunca se
## escalona; ver Lecciones/pose stepping). Devuelve eventos del tick.
func tick(delta: float) -> Dictionary:
	var events := { "chained": false, "ended": false }
	if not is_striking() or _dur <= 0.0:
		return events
	strike_k += delta / _dur
	if strike_k >= 1.0:
		if _buffered and chain_index < _WeaponData.combo_length(weapon) - 1:
			_start_step(chain_index + 1)
			events["chained"] = true
		else:
			_reset()
			events["ended"] = true
	return events

## Entrega el HitPayload UNA vez por golpe, solo en fase active.
## `speed` = velocidad horizontal del cuerpo al conectar (normalizada 0..1+):
## el momentum es física corporal, no un multiplicador mágico (§4.3).
func consume_hit(speed: float, facing_dir: Vector3) -> RefCounted:
	if phase() != "active" or _hit_consumed:
		return null
	_hit_consumed = true
	var step: Dictionary = _WeaponData.combo_step(weapon, chain_index)
	var momentum: float = 1.0 + float(weapon.get("momentum_gain", 0.5)) \
		* body_mass * clampf(speed, 0.0, 1.5)
	var p = _Payload.new()
	p.damage = float(step.get("damage", 0.0)) * momentum
	p.balance_damage = float(step.get("balance", 0.0)) * momentum
	p.force = facing_dir.normalized() * float(step.get("force", 0.0)) * momentum
	p.interrupt = bool(step.get("interrupt", false))
	p.source_mass = body_mass
	p.source_speed = speed
	return p

func _start_step(index: int) -> void:
	chain_index = index
	strike_k = 0.0
	_dur = float(_WeaponData.combo_step(weapon, index).get("dur", 0.4))
	_buffered = false
	_hit_consumed = false

func _reset() -> void:
	chain_index = -1
	strike_k = 0.0
	_dur = 0.0
	_buffered = false
	_hit_consumed = false
