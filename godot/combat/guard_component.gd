# guard_component.gd — PRD-006 alcance 1 (Combate §A): bloqueo, parry y la
# barra de EQUILIBRIO. Canon aplicado:
#   §B.3 — el Equilibrio NACE DE LA MASA: heavy = torre de postura,
#          light = frágil pero difícil de golpear.
#   §B.4 — parry humano "Roba": usa el VectorFuerza del rival — roba
#          DañoEquilibrio y DESARMA (los sabores elfo/enano llegan con sus
#          celdas; la dilation 0.2×0.35 s + sting son del canal TimeFeel,
#          alcance 4).
# Reacciones por Equilibrio (PRD-006): flinch → stagger → posture break
# (ventana de castigo abierta).
#
# Lógica pura (RefCounted, headless-safe); el dueño la tickea.
# Loaded via preload (never class_name — see Lecciones).
extends RefCounted

# ---- tuning (primer saque; el feel fino es del alcance 4 contra la Bible) ----
const BALANCE_PER_MASS: float = 55.0     # max_balance = mass × esto (§B.3)
const REGEN_PER_S: float = 9.0           # regen de Equilibrio fuera de golpe
const REGEN_DELAY: float = 1.1           # espera tras recibir balance dmg
const STAGGER_FRACTION: float = 0.30     # bajo este % de barra: stagger
const BLOCK_DAMAGE_FACTOR: float = 0.25  # daño que atraviesa el bloqueo
const PARRY_WINDOW: float = 0.18         # ventana activa tras try_parry()
const PARRY_STEAL_FACTOR: float = 0.8    # % del DañoEquilibrio robado (§B.4)
const FLINCH_TIME: float = 0.25
const STAGGER_TIME: float = 0.70
const BREAK_TIME: float = 1.60           # ventana de castigo (posture break)

var mass: float = 1.0
var max_balance: float = BALANCE_PER_MASS
var balance: float = BALANCE_PER_MASS

# state: "solid" | "flinch" | "stagger" | "broken"
var state: String = "solid"
var _state_t: float = 0.0
var _regen_hold: float = 0.0
var blocking: bool = false
var _parry_t: float = 0.0
var disarmed: bool = false

func setup(p_mass: float) -> void:
	mass = maxf(p_mass, 0.1)
	max_balance = BALANCE_PER_MASS * mass
	balance = max_balance

func tick(delta: float) -> void:
	if _parry_t > 0.0:
		_parry_t -= delta
	if _state_t > 0.0:
		_state_t -= delta
		if _state_t <= 0.0:
			if state == "broken":
				balance = max_balance * 0.5   # vuelve a medio tanque
			state = "solid"
	if _regen_hold > 0.0:
		_regen_hold -= delta
	elif state == "solid" and balance < max_balance:
		balance = minf(balance + REGEN_PER_S * delta, max_balance)

func start_block() -> void:
	blocking = true

func end_block() -> void:
	blocking = false

func try_parry() -> void:
	_parry_t = PARRY_WINDOW

func is_parry_open() -> bool:
	return _parry_t > 0.0

func is_punishable() -> bool:
	return state == "broken"

## Resuelve un HitPayload entrante. Devuelve el resultado para que el dueño
## anime/aplique: { reaction, damage, force: Vector3, disarm_attacker: bool,
## stolen_balance: float }.
func receive(payload: RefCounted) -> Dictionary:
	var res := {
		"reaction": "hit", "damage": 0.0, "force": Vector3.ZERO,
		"disarm_attacker": false, "stolen_balance": 0.0,
	}
	if payload == null:
		return res

	# ---- Parry "Roba" (§B.4): el VectorFuerza del rival se usa en su
	# contra — roba Equilibrio, desarma, cero daño. ----
	if is_parry_open():
		var stolen: float = payload.scaled_balance_damage() * PARRY_STEAL_FACTOR
		balance = minf(balance + stolen, max_balance)
		res["reaction"] = "parried"
		res["stolen_balance"] = stolen
		res["disarm_attacker"] = true
		_parry_t = 0.0
		return res

	# ---- Bloqueo: el Equilibrio absorbe; el daño casi no pasa. ----
	var dmg: float = payload.scaled_damage()
	if blocking:
		dmg *= BLOCK_DAMAGE_FACTOR
		res["reaction"] = "blocked"
	res["damage"] = dmg

	balance -= payload.scaled_balance_damage()
	_regen_hold = REGEN_DELAY

	# ---- Reacciones por Equilibrio: flinch → stagger → posture break ----
	if balance <= 0.0:
		balance = 0.0
		state = "broken"
		_state_t = BREAK_TIME
		res["reaction"] = "posture_break"
		res["force"] = payload.force / mass   # knockback por VectorFuerza
	elif not blocking:
		if balance < max_balance * STAGGER_FRACTION:
			state = "stagger"
			_state_t = STAGGER_TIME
			res["reaction"] = "stagger"
			res["force"] = payload.force * 0.5 / mass
		elif payload.interrupt or state == "flinch":
			state = "flinch"
			_state_t = FLINCH_TIME
			res["reaction"] = "flinch"
	return res
