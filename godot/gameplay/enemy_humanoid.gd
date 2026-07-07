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
const PROFILES := {
	"light": {
		"mass": 0.7, "health": 40.0, "move_speed": 3.8,
		"weapon": "raider_saber", "attack_range": 2.2, "recover": 0.55,
		"detect": 12.0,
		"phenotype": { "weight": 0.12, "height": 0.95, "jaw": 0.3,
			"cheek": 0.6, "hair": 2, "beard": 0, "skinTone": 3, "warpaint": 3 },
	},
	"heavy": {
		"mass": 1.8, "health": 85.0, "move_speed": 1.9,
		"weapon": "heavy_maul", "attack_range": 2.4, "recover": 1.15,
		"detect": 10.0,
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

# ================================================================
func _init(p_kind: String, spawn_pos: Vector3, scene: Node3D) -> void:
	kind     = p_kind
	_profile = PROFILES.get(kind, PROFILES["light"])
	_scene   = scene
	position = spawn_pos
	facing   = randf() * TAU

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

	var to_player: Vector3 = controller.position - position
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
					var res: Dictionary = controller.receive_hit(payload)
					if String(res.get("reaction", "")) == "parried":
						# Parry Roba: desarmado y expuesto ~2 s (B15b).
						combat.cancel()
						_stun_t = PARRY_STUN
						rig.play_flinch(1.8)
						state   = "stunned"
						state_t = 0.0
			if not combat.is_striking():
				# El light encadena (arcos rápidos); el heavy respira.
				if kind == "light" and randf() < 0.6 and dist < float(_profile["attack_range"]) + 0.6:
					if combat.try_attack():
						var stp: Dictionary = _WeaponD.combo_step(combat.weapon, 0)
						rig.play_strike(float(stp.get("dur", 0.4)))
						state_t = 0.0
					else:
						state = "recover"; state_t = 0.0
				else:
					state = "recover"; state_t = 0.0

		"recover":
			rig.set_motion(0.0, false)
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
