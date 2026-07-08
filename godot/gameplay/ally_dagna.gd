# ally_dagna.gd — PRD-007 alcance 0: Dagna como ALIADA en el greybox.
#
# Montada por el pipeline de personajes (data/characters.gd config "dagna" +
# character_signature.gd) sobre los MISMOS 4 componentes canónicos que jugador
# y enemigos (Combate §A: sin scripts especiales). Kit Enano Vanguard reducido
# (neutro en el alcance 0 — el combate/muralla/ground-pound llegan en 1–3).
#
# Alcance 0 = solo SEGUIR: mantiene un slot al hombro del jugador, ground-snap,
# gait procedural. Loaded via preload (never class_name — ver Lecciones).
extends Node3D

const _CombatC   = preload("res://combat/combat_component.gd")
const _GuardC    = preload("res://combat/guard_component.gd")
const _EnergyC   = preload("res://combat/energy_component.gd")
const _PushPullC = preload("res://combat/push_pull_component.gd")
const _WeaponD   = preload("res://combat/weapon_data.gd")
const _Characters = preload("res://data/characters.gd")

const MASS := 1.8              # tank enano (torre de Equilibrio) — igual que el heavy
const FOLLOW_SLOT_BACK := 1.2  # más al lado que atrás (queda a la vista)…
const FOLLOW_SLOT_SIDE := 2.0  # …y al hombro IZQUIERDO (la cámara vive en el derecho)
const FOLLOW_DEADZONE := 0.5   # no correstea encima del slot
const MOVE_SPEED_MAX := 5.6    # alcanza al jugador si se aleja

var rig = null
var combat = null
var guard = null
var energy = null
var push_pull = null

var facing: float = 0.0
var dead: bool = false          # parity/futuro (no muere en alcance 0)
var _scene: Node3D = null

# ================================================================
func _init(spawn_pos: Vector3, scene: Node3D) -> void:
	_scene = scene
	position = spawn_pos
	facing = 0.0

	combat = _CombatC.new()
	combat.equip(_WeaponD.get_weapon("heavy_maul"), MASS)
	guard = _GuardC.new()
	guard.setup(MASS)
	energy = _EnergyC.new()
	energy.setup(40.0)
	push_pull = _PushPullC.new()

func _ready() -> void:
	rig = CharacterRig.new()
	add_child(rig)
	_Characters.apply_to_rig(rig, "dagna")   # look completo desde la config
	rig.set_motion(0.0, false)

# ================================================================
# update_ally — llamado por GameDirector._gameplay_update para cada aliado.
# Alcance 0: seguir un slot al hombro del jugador. Los relojes de componente
# corren cada frame (neutros aquí; listos para 1–3).
# ================================================================
func update_ally(dt: float, controller) -> void:
	if dead:
		return
	combat.tick(dt)
	guard.tick(dt)
	energy.tick(dt)

	var pf: float = controller.facing
	var pfwd := Vector3(sin(pf), 0.0, cos(pf))
	var pright := Vector3(cos(pf), 0.0, -sin(pf))
	# Slot de formación: al hombro IZQUIERDO del jugador (lejos de la cámara).
	var slot: Vector3 = controller.position - pfwd * FOLLOW_SLOT_BACK - pright * FOLLOW_SLOT_SIDE
	var to: Vector3 = slot - position
	to.y = 0.0
	var d: float = to.length()

	if d > FOLLOW_DEADZONE:
		# Ease: rápido si está lejos, suave al acercarse al slot.
		var sp: float = clampf(d / 2.0, 0.0, 1.0) * MOVE_SPEED_MAX
		var dir: Vector3 = to / d
		position += dir * sp * dt
		_face_dir(dir, dt, 8.0)
		rig.set_motion(clampf(sp / 5.2, 0.0, 1.0), false)
	else:
		# En el slot: encara hacia donde mira el jugador (guardia al lado).
		_face_dir(pfwd, dt, 5.0)
		rig.set_motion(0.0, false)

	# Ground-snap + orientación (el rig es hijo y hereda la transform).
	if _scene != null and _scene.has_method("get_height"):
		position.y = _scene.get_height(position.x, position.z)
	rotation.y = facing

func _face_dir(dir: Vector3, dt: float, rate: float) -> void:
	var target_y: float = atan2(dir.x, dir.z)
	var d: float = target_y - facing
	while d > PI:  d -= TAU
	while d < -PI: d += TAU
	facing += d * minf(1.0, dt * rate)
