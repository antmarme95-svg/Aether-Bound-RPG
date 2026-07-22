# player_controller.gd — Third-person player controller.
# Port of src/gameplay/PlayerController.js — all constants preserved exactly.
#
# Y-AXIS PARITY NOTE: This controller drives Y analytically from scene.get_height()
# (same approach as the JS). CharacterBody3D / move_and_slide() is NOT used for
# terrain following — that would add physics overhead and change the feel. The
# capsule CollisionShape3D is kept for future physics layers (push-back vs. walls
# already handled by clamp_position per-scene). This matches the JS exactly and
# is the documented deviation.
#
# PRD-003: locomotion is now delegated to LocomotionStateMachine (LSM).
# The WALK/SPRINT/CROUCH consts are kept as FALLBACK values only; Config drives
# the actual values at runtime.
class_name PlayerController extends CharacterBody3D

const _LSM = preload("res://gameplay/locomotion_state_machine.gd")

# ---- PRD-006 alcance 1: los 4 componentes canónicos (Combate §A) ----
# Instanciados en TODO personaje (jugador y enemigos, sin scripts
# especiales). El combate viejo (try_attack) sigue intacto y NADA nuevo lo
# llama (anti-objetivo del PRD); el kit Duelist los usa en el alcance 2.
const _CombatC   = preload("res://combat/combat_component.gd")
const _GuardC    = preload("res://combat/guard_component.gd")
const _EnergyC   = preload("res://combat/energy_component.gd")
const _PushPullC = preload("res://combat/push_pull_component.gd")
const _WeaponD   = preload("res://combat/weapon_data.gd")

# ---- movement constants (JS exactly) — FALLBACK only, Config drives runtime ----
const WALK    := 3.3
const SPRINT  := 6.6
const CROUCH  := 1.9
const GRAVITY := 24.0
const JUMP_V  := 8.4
# C4 frente 2: mitad del ancho de stance (mismo offset lateral que
# `character_rig.gd` usa para `leg.position.x = side * 0.09`) — dónde
# medir el terreno para el foot IK; épsilon de muestreo para la normal.
const FOOT_STANCE := 0.09
const FOOT_NORMAL_EPS := 0.15
# PRD-007 alcance 2: Seismic Springboard T1. Un salto DENTRO de la onda de Dagna
# (ventana abierta) no usa el jump_force normal (8.4 → ~1.47 m): se amplifica a
# este impulso vertical (→ ~6 m, altura "imposible" para alcanzar cornisas). El
# air control se conserva por el path aéreo normal (no-leap), que integra input.
const SPRINGBOARD_LAUNCH_VEL := 17.0
# PRD-007 alcance 2b: Springboard DIRIGIDO. `RMB` (mantener) apunta un punto en el
# suelo (raycast cámara→suelo, decal teal) clampeado a este rango; `R` con el
# apuntado activo ordena a Dagna viajar ahí y golpear. El lanzamiento desde una
# onda COMANDADA suma este pequeño empuje horizontal hacia el punto (sobre el
# `_air_vel` del alcance 2) — asegura el arco aunque la entrada sea imperfecta.
const DESIGNATE_RANGE     := 11.0   # rango máx de la orden dirigida (m)
const SPRINGBOARD_DIRECT_PUSH := 3.0   # empuje horizontal hacia el punto (m/s), tunable

# ---- camera constants ----
const CAM_DIST_DEFAULT  := 4.4
const CAM_DIST_MIN      := 2.4
const CAM_DIST_MAX      := 8.0
const CAM_PITCH_MIN     := -0.25
const CAM_PITCH_MAX     :=  1.25
const CAM_SHOULDER      :=  0.8    # right-shoulder offset in world units

# ---- deps (set via setup()) ----
var stats: Stats       = null
var passives: Passives = null
var save: SaveState    = null
var rig: CharacterRig  = null

# ---- PRD-006: componentes de combate (ver preloads arriba) ----
var combat = null      # CombatComponent
var guard = null       # GuardComponent (Equilibrio)
var energy = null      # EnergyComponent (Aether)
var push_pull = null   # PushPullComponent

# ---- scene ref ----
var scene: Node3D = null   # any scene that has get_height / clamp_position / etc.
var enemies: Array = []
# PRD-007 alcance 2: zonas de onda activas del Springboard (el director las posee
# y muta en su lugar; acá se leen por referencia — mismo patrón que `enemies`).
var springboard_waves: Array = []
var interactables: Array = []   # scene.interactables alias
var triggers: Array = []        # scene.triggers alias

# ---- camera node ----
var cam: Camera3D = null
var _spring: SpringArm3D = null   # optional — we use manual orbit math like JS

# ---- player state (mirrors JS) ----
var cam_yaw: float   = PI
var cam_pitch: float = 0.32
var cam_dist: float  = CAM_DIST_DEFAULT
var facing: float    = PI
var vel_y: float     = 0.0
var grounded: bool   = true
var crouching: bool  = false
var sprinting: bool  = false
var move_speed_norm: float = 0.0
var attack_cooldown: float = 0.0
var projectiles: Array     = []

# ---- PRD-003: locomotion state (exposed for HUD/rig) ----
var loco_state: String = "IDLE"

# ---- PRD-003: slide direction tracking ----
var _slide_dir: Vector3       = Vector3.ZERO
var _slide_entry_dir: Vector3 = Vector3.ZERO
var _was_sliding: bool        = false   # edge-detect slide end (auto-stand from crouch toggle)

# ---- Sprint L2: leap (slide→jump) state ----
var _air_vel: Vector3  = Vector3.ZERO   # horizontal velocity carried from leap launch
var _leaping: bool     = false          # true while airborne from a slide→jump leap
var _cam_thump: float  = 0.0           # camera thump timer for landing feel (seconds)

# ---- PRD-003: cam_yaw last-frame tracker (for cam_yaw_changed) ----
var _last_cam_yaw: float = PI

var _enabled: bool = false

# ---- mouse sensitivity ----
var sens_x: float = 1.0
var sens_y: float = 1.0

# ---- input state ----
var _keys_down: Dictionary = {}   # keyed by event physical_keycode
var _mouse_captured: bool  = false

# ---- locomotion state machine ----
var _lsm: RefCounted = null   # LocomotionStateMachine instance

# ---- FOV baseline (used for lerp target before LSM is ready) ----
var _fov_target: float = 50.0

# ---- ADS (aim-down-sights) state ----
var _ads_held: bool        = false
# ---- PRD-006 alcance 2: guardia del kit melee (botón lateral trasero — antes
# RMB; PRD-007 2b mudó RMB al apuntado del Springboard dirigido) ----
var _guard_held: bool      = false
# ---- PRD-007 alcance 2b: apuntado del Springboard dirigido (RMB mantener) ----
var _designating: bool       = false
var designate_point: Vector3 = Vector3.ZERO   # punto objetivo (ya clampeado a rango)
var designate_valid: bool    = false          # hay un punto ordenable bajo el crosshair
var _designate_decal: MeshInstance3D = null   # anillo teal en el suelo (dónde caerá la onda)
var _designate_mat: StandardMaterial3D = null
# ---- Sprint L3: attack interrupt pulse ----
var _attack_pulse: float   = 0.0
var _cam_dist_eff: float   = CAM_DIST_DEFAULT
var _shoulder_eff: float   = CAM_SHOULDER
var _ads_fov: float        = 36.0
var _ads_cam_dist: float   = 2.9
var _ads_shoulder: float   = 0.55
var _ads_sens_mult: float  = 0.6

# ----------------------------------------------------------------
func _ready() -> void:
	# Capsule collider — matches rig size (height ~1.8, radius 0.32)
	var col := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.32
	cap.height = 1.16   # inner height (total = 1.8)
	col.shape  = cap
	col.position.y = 0.9
	add_child(col)

	# Create and configure LSM.
	# Config may not be available in headless unit-test context, so guard it.
	_lsm = _LSM.new()
	_lsm_configure()

func _lsm_configure() -> void:
	if _lsm == null:
		return
	# Config is an autoload Node — access via the scene tree if available.
	# Falls back to built-in LSM defaults if Config is not yet ready (headless tests).
	var loco: Dictionary = {}
	var cmult: Dictionary = {}
	var cfg_node = _get_config_node()
	if cfg_node != null:
		loco  = cfg_node.locomotion()
		# Determine origin_id and class_id from save
		var origin_id: String = save.origin_id if save != null else ""
		var class_id: String  = save.class_id  if save != null else ""
		cmult = cfg_node.class_mult(
			origin_id if origin_id != "" else "aetherborn",
			class_id  if class_id  != "" else "warrior"
		)
	_lsm.configure(loco, cmult)
	# Prime fov_target from fovBase (fallback 50.0 if not yet loaded)
	if loco.has("fovBase"):
		_fov_target = float(loco["fovBase"])
	else:
		_fov_target = 50.0
	# Prime ADS tunables from loco config (fall back to built-in constants)
	if loco.has("adsFov"):       _ads_fov        = float(loco["adsFov"])
	if loco.has("adsCamDist"):   _ads_cam_dist   = float(loco["adsCamDist"])
	if loco.has("adsShoulder"):  _ads_shoulder   = float(loco["adsShoulder"])
	if loco.has("adsSensMult"):  _ads_sens_mult  = float(loco["adsSensMult"])

func _get_config_node() -> Node:
	# In-game: Config is an autoload — use get_node on the root tree.
	# In headless unit tests this node won't exist; return null gracefully.
	if get_tree() == null:
		return null
	var root = get_tree().root
	if root == null:
		return null
	return root.get_node_or_null("/root/Config")

func setup(p_rig: CharacterRig, p_stats: Stats, p_passives: Passives, p_save: SaveState, p_cam: Camera3D) -> void:
	rig      = p_rig
	stats    = p_stats
	passives = p_passives
	save     = p_save
	cam      = p_cam
	# Re-configure LSM now that save is set (class_id is now known).
	_lsm_configure()
	_combat_configure()

# ---- PRD-006: instanciar los 4 componentes canónicos ----
# La masa sale del perfil de clase (massMult, mismo dato que la LSM §B.3).
func _combat_configure() -> void:
	var mass: float = 1.0
	var cfg_node = _get_config_node()
	if cfg_node != null and save != null:
		var cmult: Dictionary = cfg_node.class_mult(
			save.origin_id if save.origin_id != "" else "aetherborn",
			save.class_id  if save.class_id  != "" else "warrior")
		mass = float(cmult.get("massMult", 1.0))
	combat = _CombatC.new()
	combat.equip(_WeaponD.get_weapon("duelist_blade"), mass)
	guard = _GuardC.new()
	guard.setup(mass)
	energy = _EnergyC.new()
	energy.setup(100.0)
	push_pull = _PushPullC.new()

var enabled: bool:
	get: return _enabled
	set(v):
		_enabled = v
		if not v:
			_set_ads(false)
			if _mouse_captured:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				_mouse_captured = false

func recapture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_mouse_captured = true

func is_sneaking() -> bool:
	return crouching

# ---- set_scene — called each time a new scene activates ----
func set_scene(new_scene: Node3D) -> void:
	# Remove rig from previous scene
	if rig.get_parent() != null:
		rig.get_parent().remove_child(rig)
	# Clear projectiles
	for p in projectiles:
		if is_instance_valid(p["node"]) and p["node"].get_parent() != null:
			p["node"].get_parent().remove_child(p["node"])
	projectiles.clear()
	enemies.clear()

	scene = new_scene
	new_scene.add_child(rig)

	var spawn: Dictionary = new_scene.player_spawn
	var sp: Vector3 = spawn.get("position", Vector3.ZERO)
	position = sp
	vel_y    = 0.0
	facing   = spawn.get("yaw", PI)
	cam_yaw  = facing + PI
	_last_cam_yaw = cam_yaw
	cam_pitch = 0.3
	rig.global_position = sp
	rig.rotation.y      = facing

	# Wire alias arrays
	interactables = new_scene.interactables if new_scene.get("interactables") != null else []
	triggers      = new_scene.triggers      if new_scene.get("triggers")      != null else []

	# Re-configure LSM with class (scene change may coincide with class selection)
	_lsm_configure()

	_sync_camera(1.0)

# ----------------------------------------------------------------
# Input handling — _unhandled_input for keyboard/mouse (no action map needed)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			if not _mouse_captured:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				_mouse_captured = true
			elif _enabled:
				# PRD-006 alcance 2: el input real usa el kit nuevo si la
				# clase es melee; try_attack() viejo queda SOLO para los
				# autotests históricos (anti-objetivo del PRD).
				if _melee_style():
					duelist_attack()
				else:
					try_attack()
		elif mb.button_index == MOUSE_BUTTON_RIGHT and _enabled and _mouse_captured:
			# PRD-007 alcance 2b: RMB contextual — melee = APUNTAR el Springboard
			# dirigido (mantener → decal en el suelo; suelta sin R = cancela);
			# ranged = ADS. (La guardia melee se mudó al botón lateral trasero.)
			if _melee_style():
				_set_designating(mb.pressed)
			else:
				_set_ads(mb.pressed)
		elif mb.button_index == MOUSE_BUTTON_XBUTTON1 and _enabled and _mouse_captured:
			# PRD-007 alcance 2b: guardia/parry en el botón lateral TRASERO del
			# mouse (hold bloquea, tap abre la ventana de parry Roba §B.4). RMB
			# pasó a apuntar el Springboard dirigido. Solo aplica a melee.
			if _melee_style():
				_set_guard(mb.pressed)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN and _enabled:
			cam_dist = clampf(cam_dist + 0.0035 * 40.0, CAM_DIST_MIN, CAM_DIST_MAX)
		elif mb.button_index == MOUSE_BUTTON_WHEEL_UP and _enabled:
			cam_dist = clampf(cam_dist - 0.0035 * 40.0, CAM_DIST_MIN, CAM_DIST_MAX)

	elif event is InputEventMouseMotion and _mouse_captured and _enabled:
		var mm := event as InputEventMouseMotion
		var s: float = _ads_sens_mult if _ads_held else 1.0
		cam_yaw   -= mm.relative.x * 0.0052 * sens_x * s
		cam_pitch  = clampf(cam_pitch + mm.relative.y * 0.0045 * sens_y * s, CAM_PITCH_MIN, CAM_PITCH_MAX)

	elif event is InputEventKey:
		var ke := event as InputEventKey
		var kc: int = ke.physical_keycode
		if ke.pressed and not ke.echo:
			_keys_down[kc] = true
			if not _enabled:
				return
			if kc == KEY_C:
				crouching = not crouching
				_crouch_just_pressed_this_frame = true   # slide-intent edge — fires on every C press (toggle-direction agnostic)
			elif kc == KEY_N:
				passives.toggle_night_vision()
			elif kc == KEY_F:
				if _melee_style():
					duelist_attack()
				else:
					try_attack()
			elif kc == KEY_M:
				EventBus.emit_event("minimap:toggled", {})
			elif kc == KEY_T:
				# A/B del pose stepping ([[Benchmark Biomecánico]]) — cicla:
				# 2s + pop de cuerpo → 2s solo extremidades → suave 60
				if rig != null:
					var mode: String
					if rig.animation_on_twos and rig.body_pop_on_twos:
						rig.body_pop_on_twos = false
						mode = "Anim: EN 2s (solo extremidades)"
					elif rig.animation_on_twos:
						rig.animation_on_twos = false
						mode = "Anim: suave (60 fps)"
					else:
						rig.animation_on_twos = true
						rig.body_pop_on_twos = true
						mode = "Anim: EN 2s + pop cuerpo (24 Hz)"
					EventBus.emit_event("quest:toast", {"text": mode})
			elif kc == KEY_ESCAPE:
				EventBus.emit_event("player:pause_toggled", {})
		elif not ke.pressed:
			_keys_down.erase(kc)

func _has_key(kc: int) -> bool:
	return _keys_down.get(kc, false)

func _set_ads(on: bool) -> void:
	if _ads_held == on:
		return
	_ads_held = on
	EventBus.emit_event("player:ads_changed", {"active": on})

# ================================================================
# PRD-006 alcance 2 — kit Humano Duelist (Combate §4.2 sobre los 4
# componentes canónicos). El combate viejo (try_attack) queda intacto
# más abajo; SOLO los autotests históricos lo llaman (anti-objetivo).
# ================================================================

const DUELIST_STAMINA_PER_SWING: float = 10.0

func _melee_style() -> bool:
	if save == null:
		return false
	var cls: Dictionary = save.get_char_class()
	return String(cls.get("combat", {}).get("style", "melee")) == "melee"

## Guardia del Duelist: hold = bloqueo; el PRESS abre la ventana de parry
## Roba (§B.4). Ventana estricta (B15b: el input temprano no se perdona —
## la ventana corre desde el press, sin refresh por hold).
func _set_guard(on: bool) -> void:
	if _guard_held == on:
		return
	_guard_held = on
	# El cuerpo ahora COMUNICA la guardia: pose de bloqueo sostenida (feedback
	# del director 2026-07-08 — antes la guardia era invisible).
	if rig != null and rig.has_method("set_guard"):
		rig.set_guard(on)
	if guard == null:
		return
	if on:
		guard.try_parry()
		guard.start_block()
	else:
		guard.end_block()

## Ataque del kit: arranca el combo ×4 o bufferea la cadena (el sello del
## Duelist es el buffer generoso — CombatComponent decide, §4.3: las
## ventanas son las fases biomecánicas del golpe, nunca timers).
func duelist_attack() -> void:
	if not _enabled or combat == null or _guard_held:
		return
	var was_striking: bool = combat.is_striking()
	if was_striking:
		combat.try_attack()   # buffer de cadena; el coste se cobra al disparar
		return
	if not stats.spend_stamina(DUELIST_STAMINA_PER_SWING):
		return
	if combat.try_attack():
		_on_duelist_swing_started()

## Arranque de UN golpe de la cadena (0 o encadenado): anim del rig con la
## dur del paso + ley sprint↔arma (§B.5: atacar cancela sprint/slide el
## mismo tick — la LSM lee "attacking" este mismo frame).
## El momentum se CAPTURA acá: el golpe trae el peso con el que arrancó
## (slide/sprint), aunque la ley §B.5 frene el cuerpo durante el swing.
var _swing_speed: float = 0.0
var _prev_swing_phase: String = ""   # Capa 3: detecta la transición a "active" (estela 1×/golpe)

# ---- Canal 3 (GFB): combat framing + soft-aim (sin lock-on duro) ----
const COMBAT_FOV_BOOST: float = 4.0
const COMBAT_HEAT_T: float = 2.0          # histéresis: vuelve solo al explorar
const COMBAT_CAM_LIFT: float = 0.12       # la cámara "sube levemente"
const SOFT_AIM_HALF_DEG: float = 15.0     # cono de 30° total (canon literal)
const SOFT_AIM_RANGE_MULT: float = 1.3    # alcance del arma ×1.3
var _combat_heat: float = 0.0
var _combat_lift: float = 0.0

func _on_duelist_swing_started() -> void:
	_attack_pulse = 0.12
	_swing_speed = move_speed_norm
	_combat_heat = COMBAT_HEAT_T
	_soft_aim()
	var step: Dictionary = _WeaponD.combo_step(combat.weapon, combat.chain_index)
	rig.play_strike(float(step.get("dur", 0.4)))

## Soft-aim (GFB canal 3): el ataque magnetiza el facing hacia el enemigo
## más cercano dentro del cono de 30° — asiste, no encierra (nada de
## lock-on duro: pelearía contra la locomoción de momentum).
func _soft_aim() -> void:
	var fwd := Vector3(sin(facing), 0.0, cos(facing))
	var cos_half: float = cos(deg_to_rad(SOFT_AIM_HALF_DEG))
	var best_d: float = 2.6 * SOFT_AIM_RANGE_MULT
	var best_to := Vector3.ZERO
	for enemy in enemies:
		if enemy.dead:
			continue
		var to: Vector3 = enemy.position - position
		to.y = 0.0
		var d: float = to.length()
		if d < 0.001 or d > best_d:
			continue
		if to.normalized().dot(fwd) < cos_half:
			continue
		best_d = d
		best_to = to
	if best_to.length_squared() > 0.0001:
		facing = atan2(best_to.x, best_to.z)

## Resolución del golpe en fase ACTIVE: momentum→daño es física corporal
## (masa × velocidad al conectar, §4.3) — move_speed_norm >1 saliendo del
## slide/leap, y eso YA escala el payload dentro de consume_hit().
func _duelist_try_hit() -> void:
	if combat == null or combat.phase() != "active":
		return
	var fwd := Vector3(sin(facing), 0.0, cos(facing))
	var payload = combat.consume_hit(_swing_speed, fwd)
	if payload == null:
		return
	var range_m: float = 2.6
	var cos_arc: float = cos(110.0 * PI / 360.0)
	var landed: bool = false
	for enemy in enemies:
		if enemy.dead:
			continue
		var to: Vector3 = (enemy.position - position)
		to.y = 0.0
		var d: float = to.length()
		if d > range_m:
			continue
		to = to.normalized()
		if to.dot(fwd) < cos_arc and d > 0.7:
			continue
		# Alcance 3: el golpe viaja como HitPayload y lo resuelve el
		# GuardComponent del enemigo (flinch/stagger/posture break CON
		# cuerpo). El multiplicador de stats viaja en el payload.
		if enemy.has_method("receive_strike"):
			payload.damage *= stats.damage_mult
			enemy.receive_strike(payload, self)
			payload.damage /= stats.damage_mult   # restaurar para el resto del arco
			landed = true
		else:
			enemy.hit(payload.scaled_damage() * stats.damage_mult, self)
			landed = true
	# Alcance 4 (GFB canal 1–2): el contacto congela el frame GLOBAL
	# (2f/3f por masa de arma; ×1.5 si fue el último enemigo) y aporta
	# trauma. Un solo request por swing aunque el arco pegue a varios.
	if landed:
		_combat_heat = COMBAT_HEAT_T
		Feel.hit_landed(payload.weapon_mass, _all_enemies_down())

func _all_enemies_down() -> bool:
	for enemy in enemies:
		if not enemy.dead and enemy.health > 0.0:
			return false
	return true

## Entrada de daño enemigo por el GuardComponent (bloqueo/parry/reacción).
## El atacante construye el payload; acá se resuelve y se aplica.
## Devuelve el resultado para que el atacante reaccione (parried→stun).
func receive_hit(payload: RefCounted) -> Dictionary:
	if guard == null:
		return { "reaction": "hit", "damage": 0.0 }
	var res: Dictionary = guard.receive(payload)
	var reaction: String = String(res.get("reaction", ""))
	var blocked: bool = reaction == "blocked"
	var dmg: float = float(res.get("damage", 0.0))
	if dmg > 0.0:
		# `blocked` viaja al HUD: golpe bloqueado = destello acero, no rojo.
		stats.take_damage(dmg, true, blocked)
	if blocked:
		_spawn_guard_spark()
	var f: Vector3 = res.get("force", Vector3.ZERO)
	if f.length_squared() > 0.0001 and push_pull != null:
		push_pull.apply_impulse(f)
	# Alcance 3 (B15e #4): el golpe se REGISTRA en el cuerpo — flinch del
	# rig el mismo tick. El tinte de pantalla es acento, no el mensaje.
	if rig != null and rig.has_method("play_flinch"):
		match String(res.get("reaction", "")):
			"hit":           rig.play_flinch(1.0)
			"flinch":        rig.play_flinch(1.0)
			"blocked":       rig.play_flinch(0.35)
			"stagger":       rig.play_flinch(1.4)
			"posture_break": rig.play_flinch(1.8)
	# Alcance 4 (GFB canal 1): el parry paga con el freeze más gordo +
	# dilation + sting; recibir daño congela al 50% del arma enemiga.
	_combat_heat = COMBAT_HEAT_T
	if reaction == "parried":
		Feel.parry()
		# Capa 2 (feedback del director 2026-07-08): el parry ahora se VE del
		# lado del jugador — deflexión seca del arma + flash de robo. Antes
		# solo se leía por el stun del enemigo.
		if rig != null and rig.has_method("play_parry"):
			rig.play_parry()
		_spawn_parry_flash()
		EventBus.emit_event("quest:toast", {"text": "¡Parry! Roba"})
	else:
		Feel.hit_received(payload.weapon_mass)
	return res

# ----------------------------------------------------------------
# try_attack — JS PlayerController.tryAttack()
func try_attack() -> void:
	if not _enabled or attack_cooldown > 0.0:
		return
	if save == null:
		return
	var cls: Dictionary = save.get_char_class()
	var combat: Dictionary = cls.get("combat", {})
	if combat.is_empty():
		return

	var style: String = combat.get("style", "melee")
	if style == "bolt":
		if not stats.spend_magicka(float(combat.get("magickaCost", 14))):
			return
		attack_cooldown = float(combat.get("cooldown", 0.55)) * passives.cast_cooldown_mult()
		_attack_pulse = 0.12   # Sprint L3: briefly interrupt sprint/slide
		rig.play_attack("bolt")
		_spawn_projectile(combat, Color("#7adfff"), 0.13, false)
	elif style == "arrow":
		if not stats.spend_stamina(float(combat.get("staminaCost", 8))):
			return
		attack_cooldown = float(combat.get("cooldown", 0.45))
		_attack_pulse = 0.12   # Sprint L3: briefly interrupt sprint/slide
		rig.play_attack("melee")
		_spawn_projectile(combat, Color("#d8e8c8"), 0.05, true)
	else:  # melee
		if not stats.spend_stamina(float(combat.get("staminaCost", 12))):
			return
		attack_cooldown = float(combat.get("cooldown", 0.65)) * passives.attack_cooldown_mult()
		_attack_pulse = 0.12   # Sprint L3: briefly interrupt sprint/slide
		# PRD-006: la ANIMACIÓN visible es el strike biomecánico (hip-first,
		# curvas trifásicas) — la resolución de daño sigue siendo la vieja
		# hasta el alcance 2 (anti-objetivo: lógica intacta, solo se ve).
		rig.play_strike(0.55)
		_melee_hit(combat)

func _attack_damage(combat: Dictionary) -> float:
	var key_skill: String = combat.get("keySkill", "")
	return float(combat.get("damage", 10)) * stats.skill_bonus(key_skill) * stats.damage_mult

func _melee_hit(combat: Dictionary) -> void:
	var fwd := Vector3(sin(facing), 0.0, cos(facing))
	var arc_deg: float = float(combat.get("arcDeg", 110))
	var cos_arc: float = cos(arc_deg * PI / 360.0)
	var range_m: float = float(combat.get("range", 2.6))
	for enemy in enemies:
		if enemy.dead:
			continue
		var to: Vector3 = (enemy.position - position)
		to.y = 0.0
		var d: float = to.length()
		if d > range_m:
			continue
		to = to.normalized()
		if to.dot(fwd) < cos_arc and d > 0.7:
			continue
		enemy.hit(_attack_damage(combat), self)

func _spawn_projectile(combat: Dictionary, color: Color, size: float, is_arrow: bool) -> void:
	var fwd := Vector3(
		-sin(cam_yaw),
		-sin(cam_pitch) * 0.35,
		-cos(cam_yaw)
	).normalized()
	facing = atan2(fwd.x, fwd.z)

	# ---- Duelist (thief) origin-specific VFX branch ----
	# Only applies when class is thief (arrow style). Non-thief paths are unaffected.
	if is_arrow and save != null and save.class_id == "thief":
		_spawn_duelist_projectile(combat, fwd)
		return

	var mi := MeshInstance3D.new()
	if is_arrow:
		var cm := CylinderMesh.new()
		cm.top_radius    = 0.018
		cm.bottom_radius = 0.018
		cm.height        = 0.55
		mi.mesh = cm
		mi.quaternion = Quaternion(Vector3.UP, fwd)
	else:
		var sm := SphereMesh.new()
		sm.radius = size
		sm.height = size * 2.0
		mi.mesh = sm
	mi.material_override = ToonMaterials.glow_mat(color, 1.3)
	mi.position = position + Vector3(0.0, 1.35, 0.0) + fwd * 0.6
	scene.add_child(mi)

	projectiles.append({
		"node":        mi,
		"vel":         fwd * float(combat.get("projectileSpeed", 26)),
		"life":        2.4,
		"damage":      _attack_damage(combat),
		"combat":      combat,
		"sneak_shot":  crouching,
	})

# ----------------------------------------------------------------
# _spawn_duelist_projectile — Duelist (thief) origin-specific attack VFX.
# Called only when save.class_id == "thief". Branches on save.origin_id.
# Three cells (PRD-001 §6):
#   aetherborn  → Spell-Blade:    aetherial dagger mesh + teal GPUParticles3D trail
#   ironblooded → Scrap-Slinger:  muzzle flash + fast tracer + impact spark flag
#   miststalker → Shadow-Stalker: dark projectile + blink afterimage flash on player
# ----------------------------------------------------------------
func _spawn_duelist_projectile(combat: Dictionary, fwd: Vector3) -> void:
	var origin: String = save.origin_id if save != null else ""
	var spawn_pos: Vector3 = position + Vector3(0.0, 1.35, 0.0) + fwd * 0.6
	var speed: float = float(combat.get("projectileSpeed", 26))
	var dmg: float   = _attack_damage(combat)

	match origin:
		"aetherborn":
			# ---- Spell-Blade: aetherial dagger + teal trail ----
			# Dagger: elongated box mesh oriented along travel direction
			var mi := MeshInstance3D.new()
			var bm  := BoxMesh.new()
			bm.size = Vector3(0.04, 0.04, 0.52)   # thin elongated blade shape
			mi.mesh = bm
			# Align box z-axis → forward direction
			mi.quaternion = Quaternion(Vector3(0.0, 0.0, 1.0), fwd)
			mi.material_override = ToonMaterials.glow_mat(Color("#00e8d8"), 2.2)  # bright teal
			mi.position = spawn_pos
			scene.add_child(mi)

			# Teal GPUParticles3D trail parented to the projectile node
			var trail := GPUParticles3D.new()
			trail.emitting      = true
			trail.amount        = 12
			trail.lifetime      = 0.22
			trail.explosiveness = 0.0
			trail.randomness    = 0.15
			trail.one_shot      = false
			trail.local_coords  = false
			# ProcessMaterial for trail
			var pm := ParticleProcessMaterial.new()
			pm.direction          = Vector3(0.0, 0.0, 0.0)
			pm.spread             = 14.0
			pm.initial_velocity_min = 0.4
			pm.initial_velocity_max = 0.9
			pm.gravity            = Vector3(0.0, -0.5, 0.0)
			pm.scale_min          = 0.06
			pm.scale_max          = 0.12
			pm.color              = Color(0.0, 0.91, 0.85, 0.85)
			# Fade out over lifetime
			var grad := Gradient.new()
			grad.set_color(0, Color(0.0, 0.91, 0.85, 0.85))
			grad.set_color(1, Color(0.0, 0.5, 0.5, 0.0))
			var gtex := GradientTexture1D.new()
			gtex.gradient = grad
			pm.color_ramp = gtex
			trail.process_material = pm
			# Draw: small sphere particle
			var sm := SphereMesh.new()
			sm.radius = 0.045
			sm.height = 0.09
			var tm_mat := ToonMaterials.glow_mat(Color("#00e8d8"), 1.6)
			tm_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			sm.surface_set_material(0, tm_mat)
			trail.draw_pass_1 = sm
			mi.add_child(trail)

			projectiles.append({
				"node":       mi,
				"vel":        fwd * speed,
				"life":       2.4,
				"damage":     dmg,
				"combat":     combat,
				"sneak_shot": crouching,
				"vfx_tag":    "spellblade",
			})

		"ironblooded":
			# ---- Scrap-Slinger: muzzle flash + fast tracer + impact spark flag ----
			# (A) Muzzle flash: short-lived bright orange emissive sphere at hand/muzzle
			var flash := MeshInstance3D.new()
			var fsm   := SphereMesh.new()
			fsm.radius = 0.18
			fsm.height = 0.36
			flash.mesh = fsm
			flash.material_override = ToonMaterials.glow_mat(Color("#ff8c00"), 3.5)
			flash.position = position + Vector3(0.0, 1.3, 0.0) + fwd * 0.55
			scene.add_child(flash)
			# Auto-free the muzzle flash after ~0.06s via a one-shot timer node
			var flash_timer := Timer.new()
			flash_timer.wait_time  = 0.06
			flash_timer.one_shot   = true
			flash_timer.autostart  = true
			flash.add_child(flash_timer)
			flash_timer.timeout.connect(func() -> void:
				if is_instance_valid(flash) and flash.get_parent() != null:
					flash.get_parent().remove_child(flash)
					flash.queue_free()
			)

			# (B) Tracer: thin fast cylinder
			var mi := MeshInstance3D.new()
			var cm  := CylinderMesh.new()
			cm.top_radius    = 0.008
			cm.bottom_radius = 0.008
			cm.height        = 0.80        # longer/thinner than default arrow
			mi.mesh = cm
			mi.quaternion = Quaternion(Vector3.UP, fwd)
			mi.material_override = ToonMaterials.glow_mat(Color("#ffcc44"), 3.0)  # bright orange-yellow
			mi.position = spawn_pos
			scene.add_child(mi)

			projectiles.append({
				"node":        mi,
				"vel":         fwd * speed * 1.45,   # faster than default
				"life":        2.4,
				"damage":      dmg,
				"combat":      combat,
				"sneak_shot":  crouching,
				"vfx_tag":     "scrapslinger",  # signals impact spark in _update_projectiles
			})

		"miststalker":
			# ---- Shadow-Stalker: dark projectile + player blink afterimage flash ----
			# (A) Dark shadow projectile
			var mi := MeshInstance3D.new()
			var cm  := CylinderMesh.new()
			cm.top_radius    = 0.016
			cm.bottom_radius = 0.016
			cm.height        = 0.48
			mi.mesh = cm
			mi.quaternion = Quaternion(Vector3.UP, fwd)
			# Very dark purple/black with slight glow — reads as "shadow" against any bg
			mi.material_override = ToonMaterials.glow_mat(Color("#220033"), 1.0)
			mi.position = spawn_pos
			scene.add_child(mi)

			# (B) Blink afterimage flash ON THE PLAYER: a subtle low-alpha flicker —
			#     hugs the body silhouette (radius 0.22), alpha ~0.22, gone in ~0.08s
			#     so it reads as a quick step flicker rather than a big purple pill.
			var blink := MeshInstance3D.new()
			var bsm   := CapsuleMesh.new()
			bsm.radius = 0.22   # was 0.34 — tighter body hug
			bsm.height = 1.60   # was 1.82 — slightly shorter
			blink.mesh = bsm
			var blink_mat := ToonMaterials.glow_mat(Color("#6600aa"), 0.8)
			blink_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			blink_mat.albedo_color = Color(0.4, 0.0, 0.67, 0.22)   # was 0.72 alpha
			blink.material_override = blink_mat
			blink.position = position + Vector3(0.0, 0.80, 0.0)
			scene.add_child(blink)
			# Short timer — gone in 0.08s (was 0.12s) for a fast flicker feel
			var blink_timer := Timer.new()
			blink_timer.wait_time = 0.08
			blink_timer.one_shot  = true
			blink_timer.autostart = true
			blink.add_child(blink_timer)
			blink_timer.timeout.connect(func() -> void:
				if is_instance_valid(blink) and blink.get_parent() != null:
					blink.get_parent().remove_child(blink)
					blink.queue_free()
			)

			projectiles.append({
				"node":       mi,
				"vel":        fwd * speed,
				"life":       2.4,
				"damage":     dmg,
				"combat":     combat,
				"sneak_shot": crouching,
				"vfx_tag":    "shadowstalker",
			})

		_:
			# Unknown origin — fall back to default arrow visual (no VFX branch)
			var mi := MeshInstance3D.new()
			var cm  := CylinderMesh.new()
			cm.top_radius    = 0.018
			cm.bottom_radius = 0.018
			cm.height        = 0.55
			mi.mesh = cm
			mi.quaternion = Quaternion(Vector3.UP, fwd)
			mi.material_override = ToonMaterials.glow_mat(Color("#d8e8c8"), 1.3)
			mi.position = spawn_pos
			scene.add_child(mi)
			projectiles.append({
				"node":       mi,
				"vel":        fwd * speed,
				"life":       2.4,
				"damage":     dmg,
				"combat":     combat,
				"sneak_shot": crouching,
			})

func _update_projectiles(dt: float) -> void:
	for i in range(projectiles.size() - 1, -1, -1):
		var p: Dictionary = projectiles[i]
		p["life"] -= dt
		var node: MeshInstance3D = p["node"]
		node.position += p["vel"] * dt
		var kill: bool = p["life"] <= 0.0
		if not kill and scene.has_method("get_height"):
			var gh: float = scene.get_height(node.position.x, node.position.z)
			if node.position.y < gh:
				kill = true
		if not kill:
			for enemy in enemies:
				if enemy.dead:
					continue
				var dxz: float = Vector2(enemy.position.x - node.position.x, enemy.position.z - node.position.z).length()
				var dy: float  = abs(enemy.position.y + 0.55 - node.position.y)
				if dxz < 0.95 and dy < 1.5:
					var dmg: float = p["damage"]
					if p["sneak_shot"] and not enemy.aggro:
						var sneak_mult: float = float(p["combat"].get("sneakMultiplier", 1.0))
						dmg *= sneak_mult
						EventBus.emit_event("quest:toast", {"text": "Sneak strike!"})
					enemy.hit(dmg, self)
					kill = true
					break
		if kill:
			# Scrap-Slinger: spawn impact spark at hit/death position
			if p.get("vfx_tag", "") == "scrapslinger" and is_instance_valid(node):
				_spawn_impact_spark(node.position)
			if is_instance_valid(node) and node.get_parent() != null:
				node.get_parent().remove_child(node)
			projectiles.remove_at(i)

# _spawn_impact_spark — Scrap-Slinger hit impact: bright burst GPUParticles3D
# one-shot at impact position; auto-frees after emission completes (~0.3s).
func _spawn_impact_spark(hit_pos: Vector3) -> void:
	if scene == null:
		return
	var sparks := GPUParticles3D.new()
	sparks.emitting      = true
	sparks.amount        = 14
	sparks.lifetime      = 0.28
	sparks.explosiveness = 0.92    # burst-like
	sparks.randomness    = 0.5
	sparks.one_shot      = true
	sparks.local_coords  = false
	sparks.position      = hit_pos
	var pm := ParticleProcessMaterial.new()
	pm.direction             = Vector3(0.0, 1.0, 0.0)
	pm.spread                = 85.0
	pm.initial_velocity_min  = 2.2
	pm.initial_velocity_max  = 5.5
	pm.gravity               = Vector3(0.0, -9.8, 0.0)
	pm.scale_min             = 0.05
	pm.scale_max             = 0.13
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 0.65, 0.1, 1.0))   # bright orange
	grad.set_color(1, Color(1.0, 0.3, 0.0, 0.0))    # fade to transparent red
	var gtex := GradientTexture1D.new()
	gtex.gradient = grad
	pm.color_ramp = gtex
	sparks.process_material = pm
	var sm := SphereMesh.new()
	sm.radius = 0.05
	sm.height = 0.10
	var smat := ToonMaterials.glow_mat(Color("#ff8c00"), 2.5)
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.surface_set_material(0, smat)
	sparks.draw_pass_1 = sm
	scene.add_child(sparks)
	# Auto-free after one-shot emission completes (lifetime + small buffer)
	var t := Timer.new()
	t.wait_time = 0.55
	t.one_shot  = true
	t.autostart = true
	sparks.add_child(t)
	t.timeout.connect(func() -> void:
		if is_instance_valid(sparks) and sparks.get_parent() != null:
			sparks.get_parent().remove_child(sparks)
			sparks.queue_free()
	)

# _spawn_guard_spark — feedback del director (2026-07-08): un golpe BLOQUEADO
# suelta un destello de acero corto al frente del pecho (deflexión). Cheap:
# GPUParticles3D one-shot auto-liberado (~0.3 s), color acero.
func _spawn_guard_spark() -> void:
	if scene == null:
		return
	var fwd := Vector3(sin(facing), 0.0, cos(facing))
	var pos := position + Vector3(0.0, 1.25, 0.0) + fwd * 0.55
	var sparks := GPUParticles3D.new()
	sparks.emitting      = true
	sparks.amount        = 10
	sparks.lifetime      = 0.22
	sparks.explosiveness = 0.95
	sparks.randomness    = 0.5
	sparks.one_shot      = true
	sparks.local_coords  = false
	sparks.position      = pos
	var pm := ParticleProcessMaterial.new()
	pm.direction            = fwd
	pm.spread               = 70.0
	pm.initial_velocity_min = 1.8
	pm.initial_velocity_max = 4.2
	pm.gravity              = Vector3(0.0, -6.0, 0.0)
	pm.scale_min            = 0.03
	pm.scale_max            = 0.08
	var grad := Gradient.new()
	grad.set_color(0, Color(0.85, 0.92, 1.0, 1.0))    # acero brillante
	grad.set_color(1, Color(0.6, 0.72, 0.9, 0.0))     # se apaga
	var gtex := GradientTexture1D.new()
	gtex.gradient = grad
	pm.color_ramp = gtex
	sparks.process_material = pm
	var sm := SphereMesh.new()
	sm.radius = 0.04
	sm.height = 0.08
	var smat := ToonMaterials.glow_mat(Color("#c8dcf0"), 2.4)
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.surface_set_material(0, smat)
	sparks.draw_pass_1 = sm
	scene.add_child(sparks)
	var t := Timer.new()
	t.wait_time = 0.5
	t.one_shot  = true
	t.autostart = true
	sparks.add_child(t)
	t.timeout.connect(func() -> void:
		if is_instance_valid(sparks) and sparks.get_parent() != null:
			sparks.get_parent().remove_child(sparks)
			sparks.queue_free()
	)

# _spawn_parry_flash — Capa 2 (feedback del director): el parry Roba es el
# evento más brillante del intercambio. Un POP emisivo cian-oro + burst de
# chispas al frente del arma (más grande/brillante que el destello de bloqueo).
# Cheap: pop auto-liberado (~0.12 s) + GPUParticles one-shot (~0.4 s).
func _spawn_parry_flash() -> void:
	if scene == null:
		return
	var fwd := Vector3(sin(facing), 0.0, cos(facing))
	var pos := position + Vector3(0.0, 1.3, 0.0) + fwd * 0.75

	# (A) Pop emisivo brillante — el "clang" del robo.
	var pop := MeshInstance3D.new()
	var psm := SphereMesh.new()
	psm.radius = 0.22
	psm.height = 0.44
	pop.mesh = psm
	pop.material_override = ToonMaterials.glow_mat(Color("#8ff0ff"), 4.0)
	pop.position = pos
	scene.add_child(pop)
	var pt := Timer.new()
	pt.wait_time = 0.12
	pt.one_shot  = true
	pt.autostart = true
	pop.add_child(pt)
	pt.timeout.connect(func() -> void:
		if is_instance_valid(pop) and pop.get_parent() != null:
			pop.get_parent().remove_child(pop)
			pop.queue_free()
	)

	# (B) Burst de chispas cian-oro que salen hacia afuera (el golpe robado).
	var sparks := GPUParticles3D.new()
	sparks.emitting      = true
	sparks.amount        = 18
	sparks.lifetime      = 0.30
	sparks.explosiveness = 1.0
	sparks.randomness    = 0.6
	sparks.one_shot      = true
	sparks.local_coords  = false
	sparks.position      = pos
	var pm := ParticleProcessMaterial.new()
	pm.direction            = fwd
	pm.spread               = 95.0
	pm.initial_velocity_min = 3.0
	pm.initial_velocity_max = 6.5
	pm.gravity              = Vector3(0.0, -5.0, 0.0)
	pm.scale_min            = 0.04
	pm.scale_max            = 0.10
	var grad := Gradient.new()
	grad.set_color(0, Color(0.6, 0.98, 1.0, 1.0))   # cian brillante
	grad.set_color(1, Color(1.0, 0.85, 0.4, 0.0))   # se apaga a oro
	var gtex := GradientTexture1D.new()
	gtex.gradient = grad
	pm.color_ramp = gtex
	sparks.process_material = pm
	var sm := SphereMesh.new()
	sm.radius = 0.05
	sm.height = 0.10
	var smat := ToonMaterials.glow_mat(Color("#aef2ff"), 3.0)
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.surface_set_material(0, smat)
	sparks.draw_pass_1 = sm
	scene.add_child(sparks)
	var t := Timer.new()
	t.wait_time = 0.55
	t.one_shot  = true
	t.autostart = true
	sparks.add_child(t)
	t.timeout.connect(func() -> void:
		if is_instance_valid(sparks) and sparks.get_parent() != null:
			sparks.get_parent().remove_child(sparks)
			sparks.queue_free()
	)

# _spawn_swing_arc — Capa 3 (feedback del director): estela del filo. Un arco
# emisivo (banda de crescent) barrido en diagonal frente al jugador que aparece
# al entrar la fase active y se desvanece en ~0.16 s. Da legibilidad al swing
# sin tocar la pose ratificada. Additivo (BLEND_ADD) para que sea "luz de filo".
func _spawn_swing_arc() -> void:
	if scene == null:
		return
	var arc := MeshInstance3D.new()
	arc.mesh = _build_swing_arc_mesh()
	var mat := StandardMaterial3D.new()
	mat.shading_mode   = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.transparency   = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.blend_mode     = BaseMaterial3D.BLEND_MODE_ADD
	mat.cull_mode      = BaseMaterial3D.CULL_DISABLED
	mat.vertex_color_use_as_albedo = true          # el taper del filo vive en los vértices
	mat.albedo_color   = Color(0.62, 0.86, 1.0, 0.55)  # blanco-azul translúcido
	arc.material_override = mat
	# En FRENTE del jugador a la altura del pecho; plano tilteado en diagonal.
	var fwd := Vector3(sin(facing), 0.0, cos(facing))
	arc.position = position + fwd * 0.45 + Vector3(0.0, 1.15, 0.0)
	arc.rotation.y = facing
	arc.rotation.z = deg_to_rad(-52.0)   # casi vertical: slash diagonal frente al pecho
	arc.rotation.x = deg_to_rad(4.0)
	scene.add_child(arc)
	# Desvanecer (albedo→transparente) y liberar. Tween: el nodo ya está vivo.
	var tw := arc.create_tween()
	tw.tween_property(mat, "albedo_color", Color(0.62, 0.86, 1.0, 0.0), 0.16)
	tw.tween_callback(func() -> void:
		if is_instance_valid(arc):
			arc.queue_free())

# _build_swing_arc_mesh — crescent fino (fan ~120°) en el plano XZ local, con
# TAPER por vertex-color: el borde de ataque brilla, la cola se apaga (rastro).
func _build_swing_arc_mesh() -> Mesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var segs := 16
	var a0 := deg_to_rad(-60.0)
	var a1 := deg_to_rad(60.0)
	var r_in := 0.5
	var r_out := 0.95
	for i in range(segs):
		var f0: float = float(i) / float(segs)
		var f1: float = float(i + 1) / float(segs)
		var t0: float = a0 + (a1 - a0) * f0
		var t1: float = a0 + (a1 - a0) * f1
		# Taper: el borde de ataque (f=1) brilla; la cola (f=0) casi negra →
		# con additivo la cola desaparece = rastro del filo.
		var b0: float = lerp(0.10, 1.0, f0)
		var b1: float = lerp(0.10, 1.0, f1)
		var c0 := Color(b0, b0, b0, 1.0)
		var c1 := Color(b1, b1, b1, 1.0)
		var pi0 := Vector3(sin(t0) * r_in,  0.0, cos(t0) * r_in)
		var po0 := Vector3(sin(t0) * r_out, 0.0, cos(t0) * r_out)
		var pi1 := Vector3(sin(t1) * r_in,  0.0, cos(t1) * r_in)
		var po1 := Vector3(sin(t1) * r_out, 0.0, cos(t1) * r_out)
		st.set_color(c0); st.set_normal(Vector3.UP); st.add_vertex(pi0)
		st.set_color(c0); st.set_normal(Vector3.UP); st.add_vertex(po0)
		st.set_color(c1); st.set_normal(Vector3.UP); st.add_vertex(po1)
		st.set_color(c0); st.set_normal(Vector3.UP); st.add_vertex(pi0)
		st.set_color(c1); st.set_normal(Vector3.UP); st.add_vertex(po1)
		st.set_color(c1); st.set_normal(Vector3.UP); st.add_vertex(pi1)
	return st.commit()

# ----------------------------------------------------------------
# PRD-007 alcance 2: ¿está `pos` dentro de alguna onda del Springboard con la
# ventana aún abierta? El director expira las ondas (su `t` se agota), así que
# basta la distancia planar al centro < radio.
func _wave_at(pos: Vector3) -> bool:
	return not _active_wave_at(pos).is_empty()

# _active_wave_at — la onda (dict) que cubre `pos`, o {} si ninguna. El dict
# lleva `directed` (PRD-007 2b): una onda COMANDADA suma el empuje al lanzar.
func _active_wave_at(pos: Vector3) -> Dictionary:
	for w in springboard_waves:
		var wp: Vector3 = w.get("position", Vector3.ZERO)
		var r: float    = w.get("radius", 0.0)
		if Vector2(wp.x - pos.x, wp.z - pos.z).length() <= r:
			return w
	return {}

# springboard_ready — para el tell de HUD: hay ventana abierta Y estás parado en
# ella (el momento de "salta AHORA"). Solo cuenta en suelo (el cue es de despegue).
func springboard_ready() -> bool:
	return grounded and _wave_at(position)

# ================================================================
# PRD-007 alcance 2b — apuntado del Springboard dirigido.
# `RMB` mantener proyecta el crosshair al suelo (raycast cámara→suelo), clampea
# el punto al rango de orden y pinta un decal teal. El director lee
# `designate_point`/`designate_valid` cuando el jugador confirma con `R`.
# ================================================================
func is_designating() -> bool:
	return _designating

func _set_designating(on: bool) -> void:
	if _designating == on:
		return
	_designating = on
	if not on:
		designate_valid = false
		_hide_designate_decal()

# _update_designation — por frame mientras se apunta (melee). Proyecta el centro
# del viewport al suelo y coloca el decal en el punto clampeado a rango.
func _update_designation() -> void:
	if not _designating or cam == null or not _melee_style():
		if _designate_decal != null and _designate_decal.visible:
			_hide_designate_decal()
		return
	var vp := cam.get_viewport()
	if vp == null:
		return
	var center: Vector2 = vp.get_visible_rect().size * 0.5
	var ro: Vector3 = cam.project_ray_origin(center)
	var rn: Vector3 = cam.project_ray_normal(center)
	var hit: Dictionary = _ray_ground(ro, rn)
	if not hit.get("hit", false):
		designate_valid = false
		_hide_designate_decal()
		return
	var c: Dictionary = _clamp_designate(hit["point"])
	designate_point = c["point"]
	designate_valid = true   # ordenable siempre (clampeado al borde si excede el rango)
	_show_designate_decal(designate_point, c["in_range"])

# _clamp_designate — recorta un punto crudo del suelo al rango planar de orden
# alrededor del jugador. Devuelve { point, in_range }. Pura (testeable sin cámara).
func _clamp_designate(raw: Vector3) -> Dictionary:
	var to := Vector3(raw.x - position.x, 0.0, raw.z - position.z)
	var d: float = to.length()
	if d <= DESIGNATE_RANGE or d < 0.001:
		return {"point": raw, "in_range": true}
	var edge := to / d * DESIGNATE_RANGE
	return {"point": Vector3(position.x + edge.x, raw.y, position.z + edge.z), "in_range": false}

# _ray_ground — marcha un rayo hasta cruzar el suelo analítico (scene.get_height).
# Refina linealmente en el cruce. Devuelve { hit, point }.
func _ray_ground(ro: Vector3, rn: Vector3) -> Dictionary:
	if scene == null or not scene.has_method("get_height"):
		return {"hit": false}
	if rn.y >= 0.0:
		return {"hit": false}   # el rayo no baja hacia el suelo
	var step: float = 0.5
	var max_t: float = 90.0
	var t: float = 0.0
	var prev_above: float = ro.y - scene.get_height(ro.x, ro.z)
	while t < max_t:
		t += step
		var p: Vector3 = ro + rn * t
		var above: float = p.y - scene.get_height(p.x, p.z)
		if above <= 0.0:
			var frac: float = prev_above / maxf(0.0001, prev_above - above)
			var pt: Vector3 = ro + rn * (t - step + step * frac)
			pt.y = scene.get_height(pt.x, pt.z)
			return {"hit": true, "point": pt}
		prev_above = above
	return {"hit": false}

# ---- C4 frente 2: normal del terreno bajo (x,z) por diferencias finitas ----
# Terreno plano (get_height constante) da (0,1,0) — el foot IK no corrige
# nada ahí, comportamiento idéntico al de antes de C4.
func _terrain_normal(x: float, z: float) -> Vector3:
	if scene == null or not scene.has_method("get_height"):
		return Vector3.UP
	var eps: float = FOOT_NORMAL_EPS
	var hl: float = scene.get_height(x - eps, z)
	var hr: float = scene.get_height(x + eps, z)
	var hd: float = scene.get_height(x, z - eps)
	var hu: float = scene.get_height(x, z + eps)
	var tx := Vector3(2.0 * eps, hr - hl, 0.0)
	var tz := Vector3(0.0, hu - hd, 2.0 * eps)
	var n: Vector3 = tz.cross(tx)
	if n.length() < 0.0001:
		return Vector3.UP
	return n.normalized()

# ---- decal teal del apuntado (anillo plano en el suelo) ----
func _show_designate_decal(pos: Vector3, in_range: bool) -> void:
	if scene == null:
		return
	if _designate_decal == null:
		_designate_decal = MeshInstance3D.new()
		var tm := TorusMesh.new()      # yace en XZ (plano al suelo), como los anillos del pound
		tm.inner_radius = 1.0
		tm.outer_radius = 1.25
		_designate_decal.mesh = tm
		_designate_mat = StandardMaterial3D.new()
		_designate_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_designate_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		_designate_mat.blend_mode   = BaseMaterial3D.BLEND_MODE_ADD
		_designate_decal.material_override = _designate_mat
		scene.add_child(_designate_decal)
	elif _designate_decal.get_parent() != scene:
		# Cambió la escena bajo el decal: re-parent.
		if _designate_decal.get_parent() != null:
			_designate_decal.get_parent().remove_child(_designate_decal)
		scene.add_child(_designate_decal)
	# Teal en rango; ámbar apagado si el punto se clampeó al borde ("fuera de alcance").
	_designate_mat.albedo_color = Color(0.5, 0.95, 0.9, 0.85) if in_range else Color(0.95, 0.7, 0.35, 0.6)
	_designate_decal.position = pos + Vector3(0.0, 0.04, 0.0)
	# Pulso sutil de escala para leerse vivo.
	var s: float = 1.0 + 0.06 * sin(float(Time.get_ticks_msec()) * 0.006)
	_designate_decal.scale = Vector3(s, 1.0, s)
	_designate_decal.visible = true

func _hide_designate_decal() -> void:
	if _designate_decal != null:
		_designate_decal.visible = false

# VFX del despegue: estela teal ascendente en el jugador (la lámina Seismic).
func _spawn_springboard_vfx() -> void:
	if scene == null:
		return
	var streak := GPUParticles3D.new()
	streak.emitting      = true
	streak.amount        = 20
	streak.lifetime      = 0.5
	streak.explosiveness = 0.85
	streak.one_shot      = true
	streak.local_coords  = false
	streak.position      = position + Vector3(0.0, 0.4, 0.0)
	var pm := ParticleProcessMaterial.new()
	pm.direction            = Vector3(0.0, 1.0, 0.0)
	pm.spread               = 18.0
	pm.initial_velocity_min = 6.0
	pm.initial_velocity_max = 11.0
	pm.gravity              = Vector3(0.0, -4.0, 0.0)
	pm.scale_min            = 0.05
	pm.scale_max            = 0.13
	var grad := Gradient.new()
	grad.set_color(0, Color(0.55, 1.0, 0.95, 1.0))   # teal brillante (misma familia que la onda)
	grad.set_color(1, Color(0.2, 0.7, 0.7, 0.0))
	var gtex := GradientTexture1D.new()
	gtex.gradient = grad
	pm.color_ramp = gtex
	streak.process_material = pm
	var sm := SphereMesh.new()
	sm.radius = 0.05
	sm.height = 0.10
	var smat := ToonMaterials.glow_mat(Color("#8ff5e6"), 2.8)
	smat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	sm.surface_set_material(0, smat)
	streak.draw_pass_1 = sm
	scene.add_child(streak)
	var t := Timer.new()
	t.wait_time = 0.8
	t.one_shot  = true
	t.autostart = true
	streak.add_child(t)
	t.timeout.connect(func() -> void:
		if is_instance_valid(streak):
			streak.queue_free())

# ----------------------------------------------------------------
# nearest_interactable — planar distance (JS PlayerController.nearestInteractable)
func nearest_interactable() -> Dictionary:
	var best: Dictionary = {}
	var best_d: float = INF
	for it in interactables:
		if not it.get("enabled", false):
			continue
		var it_pos: Vector3 = it.get("position", Vector3.ZERO)
		var r: float        = it.get("radius", 1.0)
		var d: float = Vector2(it_pos.x - position.x, it_pos.z - position.z).length() - r
		if d < 0.0 and d < best_d:
			best_d = d
			best   = it
	return best

# check_triggers — JS PlayerController.checkTriggers
func check_triggers() -> Dictionary:
	for tr in triggers:
		if tr.get("fired", true):
			continue
		var tr_pos: Vector3 = tr.get("position", Vector3.ZERO)
		var r: float        = tr.get("radius", 1.0)
		if position.distance_to(tr_pos) < r:
			tr["fired"] = true
			return tr
	return {}

# ----------------------------------------------------------------
# update — called from GameDirector._gameplay_update(dt)
func update(dt: float) -> void:
	if scene == null:
		return
	# PRD-007 alcance 4: Y de inicio de frame — el step-block de cliffs decide si
	# una celda elevada es piso (llegaste desde arriba) o muro (la caminaste).
	var _frame_start := position
	attack_cooldown = maxf(0.0, attack_cooldown - dt)
	_attack_pulse   = maxf(0.0, _attack_pulse - dt)   # Sprint L3: decay attack interrupt pulse

	# ---- PRD-006 alcance 2: tick de componentes (relojes de gameplay,
	# cada frame — NUNCA se escalonan; ver Lecciones/pose stepping) ----
	if combat != null:
		var cev: Dictionary = combat.tick(dt)
		if cev.get("chained", false):
			# La cadena disparó al cerrar el recovery: cobrar el paso y
			# animar; sin stamina la cadena se corta limpia en el windup.
			if stats.spend_stamina(DUELIST_STAMINA_PER_SWING):
				_on_duelist_swing_started()
			else:
				combat.cancel()
		_duelist_try_hit()
		# Capa 3 (feedback del director 2026-07-08): estela de arco al ENTRAR
		# en la fase active — el swing se leía poco del lado del jugador. Una
		# vez por golpe (detecta la transición a active). No toca la pose
		# (biomecánica ratificada), solo añade legibilidad.
		var ph: String = combat.phase()
		if ph == "active" and _prev_swing_phase != "active":
			_spawn_swing_arc()
		_prev_swing_phase = ph
		guard.tick(dt)
		energy.tick(dt)
		if push_pull.is_active():
			position += push_pull.tick(dt)

	# ---- planar input ----
	var ix: float = 0.0
	var iz: float = 0.0
	if _enabled:
		if _has_key(KEY_W) or _has_key(KEY_UP):    iz -= 1.0
		if _has_key(KEY_S) or _has_key(KEY_DOWN):   iz += 1.0
		if _has_key(KEY_A) or _has_key(KEY_LEFT):   ix -= 1.0
		if _has_key(KEY_D) or _has_key(KEY_RIGHT):  ix += 1.0
	var moving: bool = ix != 0.0 or iz != 0.0
	var want_sprint: bool = _has_key(KEY_SHIFT)

	# ---- stamina drain for sprint (only while upright; no sprint in crouch) ----
	var stamina_ok_for_sprint: bool = false
	if moving and want_sprint and not crouching and grounded:
		stamina_ok_for_sprint = stats.drain_stamina(8.0, dt)   # ~15s sprint on a 120 pool

	# ---- detect edge inputs ----
	var crouch_just_pressed: bool = false
	# C key is toggled in _unhandled_input; detect the frame crouching just flipped on
	# We track this via a shadow bool that resets each frame.
	crouch_just_pressed = _crouch_just_pressed_this_frame
	_crouch_just_pressed_this_frame = false

	var cam_yaw_changed: bool = (cam_yaw != _last_cam_yaw)
	_last_cam_yaw = cam_yaw

	# ---- grass speed modifier ----
	var in_grass: bool = false
	if scene.has_method("is_in_grass"):
		in_grass = scene.is_in_grass(position)
	var grass_mult: float = passives.grass_speed_mult(in_grass)

	# ---- jump edge detect: consume SPACE once per press ----
	var jump_pressed: bool = false
	if _enabled and grounded and _has_key(KEY_SPACE) and stats.spend_stamina(4.0):
		jump_pressed = true
		_keys_down.erase(KEY_SPACE)

	# ---- Sprint L3: interrupt flags ----
	var forward_held: bool = _has_key(KEY_W) or _has_key(KEY_UP)

	# ---- build LSM input ----
	var lsm_inp: Dictionary = {
		"moving":               moving,
		"ix":                   ix,
		"iz":                   iz,
		"want_sprint":          want_sprint,
		"crouch":               crouching,
		"grounded":             grounded,
		"vel_y":                vel_y,
		"horiz_speed":          _horiz_speed,
		"jump_pressed":         jump_pressed,
		"stamina_ok_for_sprint": stamina_ok_for_sprint,
		"crouch_just_pressed":  crouch_just_pressed,
		"cam_yaw_changed":      cam_yaw_changed,
		"position_y":           position.y,
		"attacking":            _attack_pulse > 0.0,
		"ads_held":             _ads_held,
		"forward_held":         forward_held,
	}

	var lsm_out: Dictionary = _lsm.tick(lsm_inp, dt)
	loco_state = lsm_out["state"]
	var planar_speed: float  = lsm_out["planar_speed"]
	var air_control:  float  = lsm_out["air_control"]
	var sliding:      bool   = lsm_out["sliding"]
	var slide_speed:  float  = lsm_out["slide_speed"]
	var lock_horiz:   bool   = lsm_out["lock_horizontal"]
	_fov_target               = lsm_out["fov_target"]
	if _ads_held: _fov_target = _ads_fov
	# Canal 3 (GFB): combat framing — FOV +4° mientras hay calor de combate
	# (histéresis 2 s); se SUMA al canal vivo, nunca lo reemplaza.
	if _combat_heat > 0.0:
		_combat_heat = maxf(0.0, _combat_heat - dt)
		if not _ads_held:
			_fov_target += COMBAT_FOV_BOOST
	var jump_vel:     float  = lsm_out["jump_velocity"]
	var launch_speed: float  = lsm_out.get("launch_speed", 0.0)

	# Sprint L2: detect leap launch (slide→jump) — carry horizontal momentum as air velocity.
	if launch_speed > 0.0:
		# _slide_dir holds the slide direction at the time of jump (cleared a few lines below).
		# Use the current slide dir if set; fall back to facing direction.
		var leap_dir: Vector3 = _slide_dir if _slide_dir.length_squared() > 0.001 else Vector3(sin(facing), 0.0, cos(facing))
		_air_vel = leap_dir * launch_speed
		_leaping = true

	# Update sprinting flag (for rig/passives)
	sprinting = (loco_state == "SPRINT")

	# Apply grass multiplier to planar speed
	planar_speed *= grass_mult

	# ---- aetherborn overclock ----
	passives.set_overclock(_enabled and _has_key(KEY_Q), dt)

	# ---- horizontal movement ----
	if not lock_horiz:
		if sliding:
			# Slide commits to the entry (sprint) direction — travels straight, no steering
			# or curve, so it keeps the exact heading the player had under W+Shift.
			position.x += _slide_dir.x * slide_speed * dt
			position.z += _slide_dir.z * slide_speed * dt
		elif _leaping and not grounded:
			# Sprint L2: leap air-movement — integrate carried horizontal velocity,
			# with input-steered blending scaled by the profile's air control.
			if ix != 0.0 or iz != 0.0:
				var len: float = sqrt(ix * ix + iz * iz)
				var nix: float = ix / len
				var niz: float = iz / len
				var sin_y: float = sin(cam_yaw)
				var cos_y: float = cos(cam_yaw)
				var wx: float = niz * sin_y + nix * cos_y
				var wz: float = niz * cos_y - nix * sin_y
				var desired: Vector3 = Vector3(wx, 0.0, wz).normalized()
				# Blend _air_vel toward desired direction at a rate scaled by air_control.
				# Light (0.75) → responsive sweep; Heavy (0.20) → mostly committed vault.
				var blend: float = clampf(air_control * dt * 3.0, 0.0, 1.0)
				_air_vel = _air_vel.lerp(desired * _air_vel.length(), blend)
			# Turn facing into air velocity direction.
			if _air_vel.length_squared() > 0.001:
				facing = atan2(_air_vel.x, _air_vel.z)
			position.x += _air_vel.x * dt
			position.z += _air_vel.z * dt
		elif moving and planar_speed > 0.0 and not _leaping:
			var len: float = sqrt(ix * ix + iz * iz)
			ix /= len
			iz /= len
			var sin_y: float = sin(cam_yaw)
			var cos_y: float = cos(cam_yaw)
			# Camera-relative (matches JS)
			var wx: float = iz * sin_y + ix * cos_y
			var wz: float = iz * cos_y - ix * sin_y
			# Air-momentum damp: a normal (non-leap) jump shouldn't broad-jump across the
			# map. Full speed on the ground; reduced horizontal carry while airborne.
			# The deliberate slide→leap (handled above via _air_vel) keeps its full reach.
			var air_damp: float = 1.0 if grounded else 0.55
			position.x += wx * planar_speed * air_control * air_damp * dt
			position.z += wz * planar_speed * air_control * air_damp * dt
			var target_facing: float = atan2(wx, wz)
			var d: float = target_facing - facing
			while d > PI:  d -= PI * 2.0
			while d < -PI: d += PI * 2.0
			facing += d * minf(1.0, dt * 14.0)

	# Update horizontal speed tracker for next LSM tick's horiz_speed
	_horiz_speed = Vector2(
		(position.x - _prev_position.x) / dt if dt > 0.0 else 0.0,
		(position.z - _prev_position.z) / dt if dt > 0.0 else 0.0
	).length()
	_prev_position = position

	# ---- move_speed_norm for rig (normalize by SPRINT fallback) ----
	move_speed_norm = (planar_speed / SPRINT) if (moving or sliding) else 0.0

	# ---- vertical (jump + gravity, analytic terrain Y) ----
	# PRD-007 alcance 4: cliffs blockout. Una celda elevada a la que NO llegaste
	# desde arriba (subida > step máx respecto a la Y de inicio de frame) es un
	# MURO: revierte el paso horizontal para no treparla a pie. Aterrizar desde el
	# Springboard (descendiendo, from_y ≈ tapa) no dispara el muro → aterrizas.
	# Gateado por el método de escena → cero efecto en escenas sin cliffs.
	if scene.has_method("is_cliff_wall") and scene.is_cliff_wall(_frame_start.y, position.x, position.z):
		position.x = _frame_start.x
		position.z = _frame_start.z

	var ground_y: float = 0.0
	if scene.has_method("get_height"):
		ground_y = scene.get_height(position.x, position.z)

	if jump_vel > 0.0:
		# PRD-007 alcance 2: si el salto arranca DENTRO de una onda de Dagna, se
		# amplifica a un lanzamiento vertical (Seismic Springboard T1). Fuera de
		# la onda → salto normal. Ley de leap del PRD-005: sembramos `_air_vel`
		# con el momentum horizontal ACTUAL y activamos `_leaping`, para que el
		# path aéreo del leap conserve y DIRIJA la inercia (air control escalado
		# por el perfil) — así el lanzamiento alcanza cornisas arriba-y-adelante.
		# Llegas corriendo → cargas momentum; saltas parado → subes recto.
		var wave: Dictionary = _active_wave_at(position)
		if not wave.is_empty():
			vel_y = SPRINGBOARD_LAUNCH_VEL
			_air_vel = Vector3(sin(facing), 0.0, cos(facing)) * _horiz_speed
			# PRD-007 2b: si la onda fue COMANDADA (modo dirigido), suma un empuje
			# horizontal pequeño hacia el punto de la onda — asegura el arco hacia
			# el objetivo aunque el sprint de entrada venga algo desalineado.
			if wave.get("directed", false):
				var wp: Vector3 = wave.get("position", position)
				var toward := Vector3(wp.x - position.x, 0.0, wp.z - position.z)
				if toward.length() > 0.5:
					_air_vel += toward.normalized() * SPRINGBOARD_DIRECT_PUSH
			_leaping = true
			_spawn_springboard_vfx()
			Feel.springboard_launch()
			EventBus.emit_event("springboard:launch", {"position": position})
		else:
			vel_y = jump_vel
		grounded = false
	vel_y     -= GRAVITY * dt
	position.y += vel_y * dt
	# PRD-007 alcance 4: el suelo solo ATRAPA descendiendo (vel_y ≤ 0). Antes, al
	# subir contra el labio de una cornisa, entrar al footprint por debajo de la
	# tapa clavaba al jugador ahí y MATABA el impulso vertical → "el salto se corta
	# a la altura de la cornisa". Con esto el arco del Springboard completa: subes
	# al ápice y aterrizas cayendo (en llano nunca subes hacia el suelo, sin cambio).
	if position.y <= ground_y and vel_y <= 0.0:
		position.y = ground_y
		vel_y      = 0.0
		var was_airborne: bool = not grounded
		grounded   = true

		# Sprint L2: leap landing resolution.
		if _leaping and was_airborne:
			# ---- Vanguard-only landing impact (warrior archetype) ----
			if save != null and save.class_id == "warrior":
				const LEAP_IMPACT_DMG: float = 18.0
				for enemy in enemies:
					if enemy.dead:
						continue
					var dxz: float = Vector2(enemy.position.x - position.x, enemy.position.z - position.z).length()
					if dxz <= 2.5:
						enemy.hit(LEAP_IMPACT_DMG, self)
			# ---- Camera thump feel (all archetypes) ----
			var mass_scale: float = 1.0
			if _lsm != null:
				# _mass_mult is an internal LSM field; approximate from air_control: heavier = lower ac.
				# Use a simple constant thump — mass scaling derived from air_control (inverted: heavy=low ac).
				mass_scale = clampf(1.0 + (0.5 - air_control) * 0.6, 0.7, 1.4)
			_cam_thump = 0.18 * mass_scale
			# Clear leap state.
			_air_vel = Vector3.ZERO
			_leaping = false

	# Capture slide direction on slide entry from the EXACT sprint heading (camera-relative
	# input world-dir), not the lagging `facing`, so the slide travels the same direction
	# and sense the player had under W+Shift. Snap facing to it too.
	if sliding and _slide_dir == Vector3.ZERO:
		if ix != 0.0 or iz != 0.0:
			var l: float = sqrt(ix * ix + iz * iz)
			var sy: float = sin(cam_yaw)
			var cy: float = cos(cam_yaw)
			var wx: float = (iz / l) * sy + (ix / l) * cy
			var wz: float = (iz / l) * cy - (ix / l) * sy
			_slide_dir = Vector3(wx, 0.0, wz).normalized()
		else:
			_slide_dir = Vector3(sin(facing), 0.0, cos(facing))
		_slide_entry_dir = _slide_dir
		facing = atan2(_slide_dir.x, _slide_dir.z)
	elif not sliding:
		if _was_sliding:
			# Slide just ended — auto-stand so the crouch toggle never leaves the player
			# stuck in a crouch pose while sprinting. (Normal crouch-walk is unaffected:
			# it never enters SLIDE, so _was_sliding stays false.)
			crouching = false
		_slide_dir       = Vector3.ZERO
		_slide_entry_dir = Vector3.ZERO
	_was_sliding = sliding

	# ---- bounds ----
	if scene.has_method("clamp_position"):
		position = scene.clamp_position(position)

	# ---- rig + camera ----
	rig.global_position = position
	rig.rotation.y      = facing
	rig.set_motion(move_speed_norm, crouching, sliding)
	# rig._process is called automatically by Godot each frame

	# ---- C4 frente 2 (2026-07-21): foot IK — "pies plantados en pendiente" ----
	# Reusa el contrato get_height() ya existente (PRD-007 alcance 4): el rig
	# no sabe de terreno, el controller mide bajo cada pie y le pasa el dato.
	# Escenas sin get_height (o terreno plano) quedan sin cambio de
	# comportamiento — apply_foot_ik nunca se llama.
	if scene.has_method("get_height") and rig.has_method("apply_foot_ik"):
		var right := Vector3(cos(facing), 0.0, -sin(facing))
		var l_xz := position + right * -FOOT_STANCE
		var r_xz := position + right * FOOT_STANCE
		var l_h: float = scene.get_height(l_xz.x, l_xz.z)
		var r_h: float = scene.get_height(r_xz.x, r_xz.z)
		rig.apply_foot_ik(l_h, r_h,
				_terrain_normal(l_xz.x, l_xz.z), _terrain_normal(r_xz.x, r_xz.z))

	_update_projectiles(dt)
	stats.update(dt)
	# Sprint L2: decrement camera thump timer each frame.
	if _cam_thump > 0.0:
		_cam_thump = maxf(0.0, _cam_thump - dt)
	_sync_camera(minf(1.0, dt * 7.0))

	# PRD-007 alcance 2b: apuntado del Springboard dirigido (usa la cámara recién
	# sincronizada). Proyecta el crosshair al suelo y coloca/actualiza el decal.
	_update_designation()

	# ---- FOV kick (lerp toward target) ----
	if cam != null:
		cam.fov = lerp(cam.fov, _fov_target, minf(1.0, dt * 8.0))

# ---- Helpers for horizontal-speed tracking (PRD-003) ----
var _horiz_speed: float   = 0.0
var _prev_position: Vector3 = Vector3.ZERO

# ---- crouch-just-pressed edge detector ----
# Set to true in _unhandled_input when C is pressed; cleared each update tick.
var _crouch_just_pressed_this_frame: bool = false

# ---- sync_camera (JS PlayerController.syncCamera) ----
func _sync_camera(blend: float) -> void:
	if cam == null:
		return
	# Smoothly lerp effective camera distance and shoulder offset toward ADS or normal targets.
	var dist_goal: float     = _ads_cam_dist if _ads_held else cam_dist
	var shoulder_goal: float = _ads_shoulder if _ads_held else CAM_SHOULDER
	_cam_dist_eff = lerp(_cam_dist_eff, dist_goal, blend)
	_shoulder_eff = lerp(_shoulder_eff, shoulder_goal, blend)
	var head_y: float = 1.5 * rig.scale.y
	# Sprint L2: camera thump — transient downward dip on leap landing (subtle, self-canceling).
	var thump_offset: float = 0.0
	if _cam_thump > 0.0:
		# Sine curve over timer: peaks at t=thump_max/2, returns to 0 at t=0.
		# We advance the timer in the update loop; here we compute the current dip from remaining time.
		# Use a simple ramp-down: full dip at start, zero at end. Max dip ~0.12 m.
		thump_offset = -0.12 * (_cam_thump / 0.18)
	# Canal 3 (GFB): en combate la cámara sube levemente; vuelve sola con
	# la histéresis del calor de combate.
	_combat_lift = lerp(_combat_lift, COMBAT_CAM_LIFT if _combat_heat > 0.0 else 0.0, blend)
	var target := position + Vector3(0.0, head_y + thump_offset + _combat_lift, 0.0)
	var cp: float = cos(cam_pitch)
	var sp: float = sin(cam_pitch)
	# Camera-right vector perpendicular to yaw (horizontal plane).
	# Camera sits over the character's RIGHT shoulder; both the camera position
	# AND the look target shift by `shoulder`, so the view truly pans sideways and
	# the character ends up framed slightly left (centered crosshair = clear sight).
	var right := Vector3(cos(cam_yaw), 0.0, -sin(cam_yaw))
	var shoulder := right * _shoulder_eff
	var desired := Vector3(
		target.x + sin(cam_yaw) * cp * _cam_dist_eff,
		target.y + sp * _cam_dist_eff,
		target.z + cos(cam_yaw) * cp * _cam_dist_eff
	) + shoulder
	# Camera-terrain collision: march from the player toward the orbit point and
	# pull the camera in to just before the first terrain hit, so the lens never
	# enters a hill. A camera inside terrain back-face-culls the slope, making the
	# hill look "see-through" (trees behind it become visible).
	if scene != null and scene.has_method("get_height"):
		var steps := 16
		var safe_t := 1.0
		for i in range(1, steps + 1):
			var t: float = float(i) / float(steps)
			var p := target.lerp(desired, t)
			if p.y < scene.get_height(p.x, p.z) + 0.6:
				safe_t = float(i - 1) / float(steps)
				break
		desired = target.lerp(desired, safe_t)
	# Clamp inline — scene.clamp_camera passes Vector3 by value so it can't modify desired
	if scene != null and scene.has_method("get_bounds"):
		var bounds: Dictionary = scene.get_bounds()
		desired.x = clamp(desired.x, bounds.get("x_min", -999.0), bounds.get("x_max", 999.0))
		desired.z = clamp(desired.z, bounds.get("z_min", -999.0), bounds.get("z_max", 999.0))
		desired.y = clamp(desired.y, bounds.get("y_min", 0.35),   bounds.get("y_max", 999.0))
	cam.position = cam.position.lerp(desired, blend)
	# Hard floor after the blend so a fast tween never dips the lens into the ground.
	if scene != null and scene.has_method("get_height"):
		var floor_y: float = scene.get_height(cam.position.x, cam.position.z) + 0.4
		if cam.position.y < floor_y:
			cam.position.y = floor_y
	cam.look_at(target + shoulder)
	# Canal 2 (GFB): shake trauma² — offset Perlin + roll, aplicado DESPUÉS
	# de posicionar/mirar para que el frame componga y luego tiemble.
	var shake_off: Vector3 = Feel.shake_offset()
	if shake_off.length_squared() > 0.0:
		cam.position += shake_off
		cam.rotation.z += Feel.shake_roll()
