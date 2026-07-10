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

# ---- Ground-pound (PRD-007 alcance 1): su golpe de suelo crea la onda ----
const POUND_TOTAL := 0.9       # duración total del pound (plant → slam → recover)
const POUND_WINDUP := 0.35     # telegraph antes del impacto
const WAVE_RADIUS := 4.2       # radio de la zona de onda (el springboard vive aquí)
const WAVE_WINDOW := 0.6       # ventana para saltar-en-onda (alcance 2 la consume)

# ---- Springboard DIRIGIDO (PRD-007 alcance 2b) ----
# Una orden dirigida hace que Dagna VIAJE al punto designado (abandona su slot de
# guardia — costo táctico) y golpee ahí. Estados: idle/follow → traveling →
# pounding → (cooldown lo maneja el director). Solo una orden en vuelo a la vez.
const POUND_ARRIVE_DIST := 0.45   # llegó al punto → golpea

# ---- IA de combate mínima (PRD-007 alcance 3): pelea a tu lado ----
# Pound AUTÓNOMO en contexto (además del Bond/dirigido) + muralla-block cuando
# un enemigo se le mete + defensa propia (acusa golpes; NUNCA cae — su pérdida es
# la coda del slice, fuera de alcance). "Companion AI rica" queda descartada.
const AI_POUND_CD := 7.0          # rima del pound autónomo (evita spam)
const POUND_SENSE := 3.8          # enemigos a este radio → vale la pena golpear (⊂ WAVE_RADIUS)
const GUARD_BLOCK_RANGE := 2.6    # enemigo a este alcance → sube la muralla
const HEALTH_FLOOR := 1.0         # piso de vida: Dagna acusa pero no muere (PRD)

var rig = null
var combat = null
var guard = null
var energy = null
var push_pull = null

var facing: float = 0.0
var dead: bool = false          # parity/futuro (no muere en alcance 0)
var _scene: Node3D = null
var _pound_t: float = 0.0       # >0 mientras hace ground-pound
var _pound_fired: bool = false  # el impacto (VFX + onda) se dispara una vez
var _travel_target = null       # Vector3 mientras viaja a un punto comandado, o null
var _pending_directed: bool = false  # el próximo pound nace de una orden dirigida
var _pound_directed: bool = false    # el pound EN CURSO es dirigido (marca la onda)

# ---- IA de combate (alcance 3) ----
var health: float = 120.0       # tank enano; NUNCA baja de HEALTH_FLOOR (no muere)
var max_health: float = 120.0
var _ai_pound_cd: float = 0.0   # cooldown del pound autónomo
var _guard_ai_on: bool = false  # la muralla la sube/baja la IA (no el jugador)

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
func update_ally(dt: float, controller, enemies: Array = []) -> void:
	if dead:
		return
	combat.tick(dt)
	guard.tick(dt)
	energy.tick(dt)
	if _ai_pound_cd > 0.0:
		_ai_pound_cd -= dt
	if push_pull.is_active():
		position += push_pull.tick(dt)

	# Ground-pound en curso: se planta (no sigue) hasta terminar. Baja la muralla
	# (el slam ES su ataque; no bloquea mientras golpea).
	if _pound_t > 0.0:
		_set_guard_ai(false)
		_update_pound(dt, controller)
		_ground_snap()
		return

	# PRD-007 2b: viaje comandado — Dagna deja su slot y va al punto designado.
	if _travel_target != null:
		_set_guard_ai(false)
		_update_travel(dt)
		_ground_snap()
		return

	# PRD-007 alcance 3: IA de combate — decide muralla-block y pound autónomo.
	# (Puede disparar `ground_pound()`, que toma efecto el frame siguiente.)
	_update_combat_ai(enemies)

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

	_ground_snap()

func _ground_snap() -> void:
	# El rig es hijo y hereda la transform.
	if _scene != null and _scene.has_method("get_height"):
		position.y = _scene.get_height(position.x, position.z)
	rotation.y = facing

# ================================================================
# Ground-pound (PRD-007 alcance 1): plant → slam → recover. En el impacto
# spawnea la ZONA DE ONDA (VFX + evento springboard:wave) — la fuente del
# Seismic Springboard. Triggers: Bond (alcance 2) e IA (alcance 3).
# ================================================================
func ground_pound() -> void:
	if _pound_t > 0.0:
		return                     # ya está golpeando
	_pound_t = POUND_TOTAL
	_pound_fired = false
	_pound_directed = _pending_directed   # ¿esta onda nace de una orden dirigida?
	_pending_directed = false

## travel_and_pound — PRD-007 2b: orden dirigida. Dagna viaja al punto (línea
## directa + ground-snap, sin pathfinding rico) y golpea al llegar. La onda
## resultante queda MARCADA como dirigida (empuje del arco). Idempotente si ya
## está ocupada (golpeando o viajando) — una sola orden en vuelo.
func travel_and_pound(point: Vector3) -> void:
	if _pound_t > 0.0 or _travel_target != null:
		return
	_travel_target = point
	_pending_directed = true

func is_pounding() -> bool:
	return _pound_t > 0.0

func is_traveling() -> bool:
	return _travel_target != null

# ================================================================
# IA de combate mínima (PRD-007 alcance 3). Corre en el estado follow: sube la
# muralla si un enemigo se le mete y lanza el pound autónomo cuando hay un grupo
# a tiro (además del Bond/dirigido). Sin targeting rico: el enemigo más cercano.
# ================================================================
func _update_combat_ai(enemies: Array) -> void:
	var nearest = _nearest_enemy(enemies)
	var nd: float = INF
	if nearest != null:
		nd = Vector2(nearest.position.x - position.x, nearest.position.z - position.z).length()

	# Muralla-block: enemigo en la cara → torre de Equilibrio arriba.
	_set_guard_ai(nearest != null and nd <= GUARD_BLOCK_RANGE)

	# Pound autónomo en contexto: enemigos dentro del radio de onda y cooldown
	# libre → golpea (reactivo, en su posición). El daño lo aplica la onda.
	if _ai_pound_cd <= 0.0 and _count_enemies_within(enemies, POUND_SENSE) >= 1:
		ground_pound()
		_ai_pound_cd = AI_POUND_CD

func _set_guard_ai(on: bool) -> void:
	if _guard_ai_on == on:
		return
	_guard_ai_on = on
	if rig != null and rig.has_method("set_guard"):
		rig.set_guard(on)
	if on:
		guard.start_block()
	else:
		guard.end_block()

func _nearest_enemy(enemies: Array):
	var best = null
	var best_d: float = INF
	for e in enemies:
		if e == null or e.dead or e.get("state") == "dying":
			continue
		var d: float = Vector2(e.position.x - position.x, e.position.z - position.z).length()
		if d < best_d:
			best_d = d
			best = e
	return best

func _count_enemies_within(enemies: Array, radius: float) -> int:
	var n: int = 0
	for e in enemies:
		if e == null or e.dead or e.get("state") == "dying":
			continue
		if Vector2(e.position.x - position.x, e.position.z - position.z).length() <= radius:
			n += 1
	return n

## receive_hit — defensa propia (PRD-007 alcance 3). Mismo camino canónico que el
## jugador (guard.receive → reacción corporal + knockback), PERO Dagna NUNCA cae:
## la vida tiene piso (HEALTH_FLOOR). No hace parry (solo bloquea) → el enemigo no
## se stunnea contra ella. Devuelve el resultado para el atacante.
func receive_hit(payload: RefCounted) -> Dictionary:
	if guard == null or payload == null:
		return { "reaction": "hit", "damage": 0.0 }
	var res: Dictionary = guard.receive(payload)
	var dmg: float = float(res.get("damage", 0.0))
	health = maxf(HEALTH_FLOOR, health - dmg)   # acusa daño pero no muere
	if rig != null and rig.has_method("play_flinch"):
		match String(res.get("reaction", "")):
			"blocked":       rig.play_flinch(0.35)
			"stagger":       rig.play_flinch(1.4)
			"posture_break": rig.play_flinch(1.8)
			_:               rig.play_flinch(1.0)
	var f: Vector3 = res.get("force", Vector3.ZERO)
	if f.length_squared() > 0.0001:
		push_pull.apply_impulse(f)
	return res

# _update_travel — locomoción directa hacia el punto comandado. Al llegar,
# dispara el ground-pound EN el punto (la onda nace ahí, no en su slot).
func _update_travel(dt: float) -> void:
	var to: Vector3 = _travel_target - position
	to.y = 0.0
	var d: float = to.length()
	if d <= POUND_ARRIVE_DIST:
		_travel_target = null
		ground_pound()             # golpea en el punto (position ≈ target)
		return
	var dir: Vector3 = to / d
	position += dir * MOVE_SPEED_MAX * dt
	_face_dir(dir, dt, 8.0)
	rig.set_motion(1.0, false)

func _update_pound(dt: float, controller) -> void:
	_pound_t -= dt
	var elapsed: float = POUND_TOTAL - _pound_t
	# Encara al jugador mientras se planta (guardiana al lado).
	var to: Vector3 = controller.position - position
	to.y = 0.0
	if to.length() > 0.01:
		_face_dir(to.normalized(), dt, 4.0)
	if not _pound_fired and elapsed >= POUND_WINDUP:
		_pound_fired = true
		_do_impact()
	# Pose: plantada en el windup; DROP (crouch) en el slam; se re-yergue al final.
	var slammed: bool = _pound_fired and _pound_t > 0.2
	rig.set_motion(0.0, slammed)

func _do_impact() -> void:
	# La onda ES un ataque + la fuente del springboard. VFX local + evento
	# para que el director la registre (waves) y empuje enemigos.
	_spawn_pound_vfx()
	EventBus.emit_event("springboard:wave", {
		"position": position,
		"radius": WAVE_RADIUS,
		"window": WAVE_WINDOW,
		"directed": _pound_directed,   # PRD-007 2b: onda comandada → empuje del arco
	})

# ---- VFX teal (lámina Seismic Springboard): burst central + anillos ----
func _spawn_pound_vfx() -> void:
	if _scene == null:
		return
	var origin := position + Vector3(0.0, 0.06, 0.0)
	# (A) Burst de esquirlas teal hacia arriba (el suelo revienta).
	var burst := GPUParticles3D.new()
	burst.emitting      = true
	burst.amount        = 22
	burst.lifetime      = 0.45
	burst.explosiveness = 0.95
	burst.one_shot      = true
	burst.local_coords  = false
	burst.position      = origin
	var pm := ParticleProcessMaterial.new()
	pm.direction            = Vector3(0.0, 1.0, 0.0)
	pm.spread               = 55.0
	pm.initial_velocity_min = 3.5
	pm.initial_velocity_max = 7.5
	pm.gravity              = Vector3(0.0, -12.0, 0.0)
	pm.scale_min            = 0.05
	pm.scale_max            = 0.14
	var grad := Gradient.new()
	grad.set_color(0, Color(0.55, 1.0, 0.95, 1.0))   # teal brillante
	grad.set_color(1, Color(0.2, 0.7, 0.7, 0.0))
	var gtex := GradientTexture1D.new()
	gtex.gradient = grad
	pm.color_ramp = gtex
	burst.process_material = pm
	var sm := SphereMesh.new()
	sm.radius = 0.05
	sm.height = 0.10
	var smat := ToonMaterials.glow_mat(Color("#8ff5e6"), 2.6)
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.surface_set_material(0, smat)
	burst.draw_pass_1 = sm
	_scene.add_child(burst)
	_free_after(burst, 0.7)

	# (B) Dos anillos concéntricos que se expanden por el suelo (shockwave).
	_spawn_ring(origin, 0.0, WAVE_RADIUS)
	_spawn_ring(origin, 0.08, WAVE_RADIUS * 0.7)

func _spawn_ring(origin: Vector3, delay: float, max_r: float) -> void:
	var ring := MeshInstance3D.new()
	var tm := TorusMesh.new()          # el toro yace en el plano XZ (plano al suelo)
	tm.inner_radius = 0.85
	tm.outer_radius = 1.0
	ring.mesh = tm
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode   = BaseMaterial3D.BLEND_MODE_ADD
	mat.albedo_color = Color(0.5, 0.95, 0.9, 0.8)
	ring.material_override = mat
	ring.position = origin
	ring.scale = Vector3(0.3, 0.3, 0.3)
	_scene.add_child(ring)
	var tw := ring.create_tween()
	if delay > 0.0:
		tw.tween_interval(delay)
	tw.tween_property(ring, "scale", Vector3(max_r, 0.3, max_r), 0.5)
	tw.parallel().tween_property(mat, "albedo_color", Color(0.5, 0.95, 0.9, 0.0), 0.5)
	tw.tween_callback(func() -> void:
		if is_instance_valid(ring):
			ring.queue_free())

func _free_after(node: Node, secs: float) -> void:
	var t := Timer.new()
	t.wait_time = secs
	t.one_shot  = true
	t.autostart = true
	node.add_child(t)
	t.timeout.connect(func() -> void:
		if is_instance_valid(node) and node.get_parent() != null:
			node.get_parent().remove_child(node)
			node.queue_free())

func _face_dir(dir: Vector3, dt: float, rate: float) -> void:
	var target_y: float = atan2(dir.x, dir.z)
	var d: float = target_y - facing
	while d > PI:  d -= TAU
	while d < -PI: d += TAU
	facing += d * minf(1.0, dt * rate)
