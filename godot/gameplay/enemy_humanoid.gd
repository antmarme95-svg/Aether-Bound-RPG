# enemy_humanoid.gd — PRD-006 alcance 3: los 2 enemigos del PRD sobre los
# MISMOS componentes y las MISMAS reglas de esqueleto que el jugador
# (Combate §A: "en todo personaje, sin scripts especiales").
#
#   light — palancas largas: arcos amplios y RÁPIDOS, postura frágil
#           (masa baja = poca torre de Equilibrio).
#   heavy — arcos bajos de cadera estilo enano: lento, telegraph enorme,
#           torre de Equilibrio (obliga a romper postura o parry-desarmar).
#
# El telegraph ES la biomecánica: el windup del strike es la MISMA curva
# hip-first del rig del jugador (rig_biomech) — se lee la carga de cadera
# del rival, no un flash de color.
#
# Loaded via preload (never class_name — see Lecciones).
extends Node3D

const _CombatC   = preload("res://combat/combat_component.gd")
const _GuardC    = preload("res://combat/guard_component.gd")
const _EnergyC   = preload("res://combat/energy_component.gd")
const _PushPullC = preload("res://combat/push_pull_component.gd")
const _WeaponD   = preload("res://combat/weapon_data.gd")
const _Payload   = preload("res://combat/hit_payload.gd")

const PUNISH_DAMAGE_MULT := 1.5   # ventana de castigo (posture break)
const PARRY_STUN := 2.0           # B15b: parry → ~2 s indefenso

# Perfiles de los 2 enemigos — el fenotipo ES el gameplay: las palancas
# del light y la base baja del heavy salen del MISMO rig paramétrico.
# Tuning de presión (B15g): `recover` = respiro entre golpes; `chain_prob`
# = probabilidad de encadenar otro golpe sin volver a chase; `strafe_speed`
# = velocidad del micro-paso lateral DURANTE el recover (el cuerpo sigue
# vivo entre golpes — mata el "YDIF plano" que se leía como pasividad).
const PROFILES := {
	"light": {
		"mass": 0.7, "health": 40.0, "move_speed": 3.8,
		"weapon": "raider_saber", "attack_range": 2.2, "recover": 0.42,
		"chain_prob": 0.72, "strafe_speed": 1.7, "detect": 12.0,
		"phenotype": { "weight": 0.12, "height": 0.95, "jaw": 0.3,
			"cheek": 0.6, "hair": 2, "beard": 0, "skinTone": 3, "warpaint": 3 },
	},
	"heavy": {
		"mass": 1.8, "health": 85.0, "move_speed": 1.9,
		"weapon": "heavy_maul", "attack_range": 2.4, "recover": 1.05,
		"chain_prob": 0.0, "strafe_speed": 0.85, "detect": 10.0,
		"phenotype": { "weight": 1.0, "height": 0.10, "jaw": 1.0,
			"cheek": 0.2, "hair": 0, "beard": 3, "skinTone": 5, "warpaint": 5 },
	},
}

var kind: String = "light"
var combat = null
var guard = null
var energy = null
var push_pull = null

var health: float = 40.0
var max_health: float = 40.0
var dead: bool = false
var aggro: bool = false

# FSM: idle | chase | strike | recover | stunned | dying
var state: String = "idle"
var state_t: float = 0.0
var facing: float = 0.0

var rig = null              # CharacterRig (autoload class del prototipo)
var _profile: Dictionary = {}
var _scene: Node3D = null
var _stun_t: float = 0.0
var _strafe_sign: float = 1.0   # sentido del circle-strafe (B15g)
# PRD-007 alcance 3: aggro por CERCANÍA. El director fija el blanco (el más
# cercano entre jugador y aliados) cada frame; null → cae al jugador. El blanco
# solo necesita `.position` y `.receive_hit(payload)` (jugador y Dagna cumplen).
var combat_target = null

func set_combat_target(t) -> void:
	combat_target = t

## _resolve_target — el blanco vigente para moverse y golpear. Cae al jugador si
## el asignado desapareció o murió (Dagna nunca muere; el jugador no expone `dead`).
func _resolve_target(controller):
	if combat_target != null and is_instance_valid(combat_target):
		var td = combat_target.get("dead")
		if td == null or td == false:
			return combat_target
	return controller

# ================================================================
func _init(p_kind: String, spawn_pos: Vector3, scene: Node3D) -> void:
	kind     = p_kind
	_profile = PROFILES.get(kind, PROFILES["light"])
	_scene   = scene
	position = spawn_pos
	facing   = randf() * TAU
	_strafe_sign = 1.0 if randf() < 0.5 else -1.0

	health     = float(_profile["health"])
	max_health = health

	combat = _CombatC.new()
	combat.equip(_WeaponD.get_weapon(String(_profile["weapon"])), float(_profile["mass"]))
	guard = _GuardC.new()
	guard.setup(float(_profile["mass"]))
	energy = _EnergyC.new()
	energy.setup(40.0)
	push_pull = _PushPullC.new()

func _ready() -> void:
	rig = CharacterRig.new()
	add_child(rig)
	var origin: Dictionary = OriginsData.get_origin("ironblooded")
	rig.apply_phenotype(_profile["phenotype"], origin)

# ================================================================
# Entradas de daño
# ================================================================

## Camino canónico (PRD-006): HitPayload → GuardComponent → reacción
## corporal. El rig humanoide acusa con play_flinch (head-snap + columna);
## stagger/broken además SUSPENDEN la FSM (ventana de castigo legible).
func receive_strike(payload: RefCounted, _controller) -> Dictionary:
	if dead or payload == null:
		return {}
	aggro = true
	var punish: bool = guard.is_punishable()
	var res: Dictionary = guard.receive(payload)
	var dmg: float = float(res.get("damage", 0.0))
	if punish:
		dmg *= PUNISH_DAMAGE_MULT
	health -= dmg

	if health <= 0.0:
		state   = "dying"
		state_t = 0.0
		return res

	match String(res.get("reaction", "hit")):
		"posture_break":
			rig.play_flinch(1.8)
		"stagger":
			rig.play_flinch(1.4)
		_:
			rig.play_flinch(1.0)

	# La reacción interrumpe el golpe en curso.
	if state == "strike":
		combat.cancel()
		state   = "recover"
		state_t = 0.0

	var force: Vector3 = res.get("force", Vector3.ZERO)
	if force.length_squared() > 0.0001:
		push_pull.apply_impulse(force)
	return res

## Compat con el camino del prototipo 0 (proyectiles / try_attack viejo).
func hit(dmg: float, controller) -> void:
	if dead:
		return
	aggro = true
	health -= dmg
	rig.play_flinch(1.0)
	if health <= 0.0:
		state   = "dying"
		state_t = 0.0

# ================================================================
# update — mismo contrato que MaddenedBeast.update_ai
# ================================================================
func update_ai(dt: float, controller, passives) -> void:
	if dead:
		return
	state_t += dt
	if _stun_t > 0.0:
		_stun_t -= dt

	combat.tick(dt)
	guard.tick(dt)
	energy.tick(dt)
	if push_pull.is_active():
		position += push_pull.tick(dt)

	# PRD-007 alcance 3: persigue/golpea al blanco por cercanía (jugador o Dagna).
	var tgt = _resolve_target(controller)
	var to_player: Vector3 = tgt.position - position
	to_player.y = 0.0
	var dist: float = to_player.length()

	# ---- Equilibrio manda: stagger/broken suspenden la FSM ----
	if state != "dying" and (guard.state == "stagger" or guard.state == "broken"):
		if state == "strike":
			combat.cancel()
		state   = "recover"
		state_t = 0.4
		rig.set_motion(0.0, guard.state == "broken")   # broken: el cuerpo CAE (crouch pose)
		_snap_and_face(dt, to_player, false)
		return

	match state:
		"idle":
			rig.set_motion(0.0, false)
			if aggro or dist < float(_profile["detect"]):
				aggro = true
				state = "chase"
				state_t = 0.0

		"chase":
			if _stun_t > 0.0:
				rig.set_motion(0.0, false)
			elif dist > float(_profile["attack_range"]) * 0.85:
				var dir: Vector3 = to_player.normalized()
				position += dir * float(_profile["move_speed"]) * dt
				_face_dir(dir, dt, 7.0)
				rig.set_motion(clampf(float(_profile["move_speed"]) / 5.2, 0.0, 1.0), false)
			else:
				# Al alcance: arranca el golpe — el windup hip-first ES el
				# telegraph (heavy: 0.8–1.0 s de carga de cadera legible).
				if combat.try_attack():
					var step: Dictionary = _WeaponD.combo_step(combat.weapon, 0)
					rig.play_strike(float(step.get("dur", 0.4)))
					state   = "strike"
					state_t = 0.0
					rig.set_motion(0.0, false)

		"strike":
			_face_dir(to_player.normalized(), dt, 3.0)   # gira lento: el golpe es esquivable
			# Hitbox solo en fase active, una vez por golpe.
			if combat.phase() == "active":
				var fwd := Vector3(sin(facing), 0.0, cos(facing))
				var payload = combat.consume_hit(0.0, fwd)
				if payload != null and dist < float(_profile["attack_range"]) + 0.4 \
						and to_player.normalized().dot(fwd) > 0.3:
					var res: Dictionary = tgt.receive_hit(payload)
					if String(res.get("reaction", "")) == "parried":
						# Parry Roba: desarmado y expuesto ~2 s (B15b).
						combat.cancel()
						_stun_t = PARRY_STUN
						rig.play_flinch(1.8)
						state   = "stunned"
						state_t = 0.0
			if not combat.is_striking():
				# El light encadena (arcos rápidos); el heavy respira
				# (chain_prob = 0). B15g: más cadena = más presión.
				if randf() < float(_profile.get("chain_prob", 0.0)) \
						and dist < float(_profile["attack_range"]) + 0.6:
					if combat.try_attack():
						var stp: Dictionary = _WeaponD.combo_step(combat.weapon, 0)
						rig.play_strike(float(stp.get("dur", 0.4)))
						state_t = 0.0
					else:
						_enter_recover()
				else:
					_enter_recover()

		"recover":
			# Presión (B15g): el cuerpo NO se congela entre golpes — hace
			# micro-strafe CIRCULAR alrededor del jugador manteniendo el
			# alcance y la cara. La cadencia se lee VIVA (adiós YDIF plano);
			# el heavy acecha lento, no se planta.
			_strafe_around(to_player, dist, dt)
			if state_t > float(_profile["recover"]):
				state = "chase"
				state_t = 0.0

		"stunned":
			rig.set_motion(0.0, true)   # postura caída: el castigo SE LEE
			if _stun_t <= 0.0:
				state = "recover"
				state_t = 0.0

		"dying":
			rotation.z += dt * 2.2
			position.y -= dt * 0.6
			if state_t > 0.8:
				dead = true
				visible = false
				EventBus.emit_event("combat:enemyDown", {})
			return

	_snap_and_face(dt, to_player, false)

## Entra en recover rompiendo a veces el sentido del círculo — el strafe
## monótono se lee robótico; alternar lo hace leer como "busca hueco".
func _enter_recover() -> void:
	state = "recover"
	state_t = 0.0
	if randf() < 0.35:
		_strafe_sign = -_strafe_sign

## Circle-strafe (B15g): componente lateral (tangente) + corrección radial
## suave para orbitar al jugador sin encimarse ni alejarse. El rig camina a
## paso lento (el cuerpo vive); mantiene la cara al jugador.
func _strafe_around(to_player: Vector3, dist: float, dt: float) -> void:
	if dist < 0.001:
		rig.set_motion(0.0, false)
		return
	var radial: Vector3 = to_player / dist
	var tangent := Vector3(-radial.z, 0.0, radial.x)   # perpendicular en el plano
	var strafe_speed: float = float(_profile.get("strafe_speed", 1.0))
	var step: Vector3 = tangent * _strafe_sign * strafe_speed * dt
	# Corrección radial suave: vuelve hacia el anillo ideal de ataque.
	var ideal: float = float(_profile["attack_range"]) * 0.9
	if dist > ideal + 0.3:
		step += radial * float(_profile["move_speed"]) * 0.45 * dt
	elif dist < ideal - 0.3:
		step -= radial * float(_profile["move_speed"]) * 0.45 * dt
	position += step
	_face_dir(radial, dt, 6.0)
	rig.set_motion(clampf(strafe_speed / 5.2, 0.12, 1.0), false)

func _snap_and_face(_dt: float, _to_player: Vector3, _unused: bool) -> void:
	if _scene != null and _scene.has_method("get_height"):
		position.y = _scene.get_height(position.x, position.z)
	rotation.y = facing

func _face_dir(dir: Vector3, dt: float, rate: float) -> void:
	var target_y: float = atan2(dir.x, dir.z)
	var d: float = target_y - facing
	while d > PI:  d -= PI * 2.0
	while d < -PI: d += PI * 2.0
	facing += d * minf(1.0, dt * rate)
