# rig_biomech.gd — PRD-006 alcance 0: joint constraints anatómicos (ROM humano
# de referencia) + curvas de la cadena de transferencia de peso (hip-first).
#
# Canon: Movilidad Realista (GDD §4.3) — "nada rota donde un cuerpo no rota".
# El ROM humano es la referencia del rig; las variantes por raza (enano/elfo)
# se derivan de esta tabla en C4 completo.
#
# Loaded via preload (never class_name — see Lecciones: cross-script
# class_name load-order race in CLI runs).
extends RefCounted

# ----------------------------------------------------------------
# ROM table — radians, authored so the ACCEPTED prototype poses
# (gait / crouch-walk / slide, playtest-approved) sit inside limits.
# Sign conventions follow character_rig.gd:
#   leg.rotation.x    negative = hip flexion (thigh forward/up)
#   knee.rotation.x   positive = knee flexion (hinge; never negative)
#   arm.rotation.x    negative = shoulder flexion (arm forward/overhead)
#   elbow.rotation.x  negative = elbow flexion (hinge; never past ~0)
# ----------------------------------------------------------------
const ROM: Dictionary = {
	"hip_leg": {   # thigh at the hip joint
		"x": Vector2(-2.2, 0.7),    # flexion 126° / extension 40°
		"y": Vector2(-0.5, 0.5),
		"z": Vector2(-0.4, 0.4),    # ab/adduction
	},
	"knee": {      # pure hinge 1-DOF
		"x": Vector2(0.0, 2.4),     # 0 = straight (no hyperextension), 137° deep flex
		"y": Vector2(0.0, 0.0),
		"z": Vector2(0.0, 0.0),
	},
	"shoulder": {  # 3-DOF ball joint (human reference range)
		"x": Vector2(-3.0, 0.9),    # flexion overhead / extension behind
		"y": Vector2(-1.2, 1.2),
		# z is side-mirrored at clamp time: inner value = adduction across body
		"z": Vector2(-2.4, 0.45),   # authored for RIGHT arm; mirrored for left
	},
	"elbow": {     # pure hinge 1-DOF
		"x": Vector2(-2.65, 0.03),  # flexion 152°, no hyperextension past 2°
		"y": Vector2(0.0, 0.0),
		"z": Vector2(0.0, 0.0),
	},
	"spine": {     # single node today; total thoracolumbar ROM (segments in C4)
		"x": Vector2(-0.4, 0.95),   # extension back / flexion forward (slide 0.55 ok)
		"y": Vector2(-0.85, 0.85),  # axial rotation ~48°
		"z": Vector2(-0.3, 0.3),    # lateral bend
	},
	"hips_root": { # pelvis orientation relative to stance
		"x": Vector2(-0.3, 0.3),
		"y": Vector2(-0.45, 0.45),
		"z": Vector2(-0.25, 0.25),
	},
	"head": {
		"x": Vector2(-0.7, 0.6),
		"y": Vector2(-1.2, 1.2),
		"z": Vector2(-0.5, 0.5),
	},
}

const _EPS: float = 0.001

# ----------------------------------------------------------------
# clamp_node — clamp one joint's rotation to its ROM entry.
# `mirror_z` flips the z limits (left arm mirrors the right-arm table).
# Accumulates attempted violations into `report` (per joint label):
#   { "attempts": int, "max_over": float }  — max_over in radians past limit.
# Returns true if anything was clamped this call.
# ----------------------------------------------------------------
static func clamp_node(node: Node3D, joint: String, label: String,
		report: Dictionary, mirror_z: bool = false) -> bool:
	if node == null or not ROM.has(joint):
		return false
	var lim: Dictionary = ROM[joint]
	var clamped: bool = false
	var rot: Vector3 = node.rotation

	var axes: Array = ["x", "y", "z"]
	for i in range(3):
		var r: Vector2 = lim[axes[i]]
		if mirror_z and i == 2:
			r = Vector2(-r.y, -r.x)
		var v: float = rot[i]
		var over: float = 0.0
		if v < r.x - _EPS:
			over = r.x - v
			rot[i] = r.x
		elif v > r.y + _EPS:
			over = v - r.y
			rot[i] = r.y
		if over > 0.0:
			clamped = true
			if not report.has(label):
				report[label] = {"attempts": 0, "max_over": 0.0}
			report[label]["attempts"] = int(report[label]["attempts"]) + 1
			report[label]["max_over"] = maxf(float(report[label]["max_over"]), over)

	if clamped:
		node.rotation = rot
	return clamped

# ----------------------------------------------------------------
# Kinetic chain — the weight-transfer strike (hip-first).
# One normalized envelope per body segment, offset by CHAIN_LAG so the
# hips lead and the hand arrives last (cadera→torso→hombro→brazo).
#
# Phases over normalized k (these fractions ARE the combat windows —
# CombatComponent anchors cancel/hitbox/chain timing to them):
#   [0.00, 0.32)  WINDUP    — the coil; cancelable
#   [0.32, 0.58)  ACTIVE    — the chain releases; hitbox frames
#   [0.58, 1.00]  RECOVERY  — re-balance; chain-into-next window
# ----------------------------------------------------------------
const PHASE_WINDUP_END: float = 0.32
const PHASE_ACTIVE_END: float = 0.58

const CHAIN_LAG: Dictionary = {
	"hips":     0.00,
	"spine":    0.05,
	"shoulder": 0.10,
	"elbow":    0.14,
}

static func phase_name(k: float) -> String:
	if k < 0.0 or k >= 1.0:
		return ""
	if k < PHASE_WINDUP_END:
		return "windup"
	if k < PHASE_ACTIVE_END:
		return "active"
	return "recovery"

## segment_offset — evaluate one segment's rotation offset at strike
## progress k, given its coil (windup peak) and release (active peak)
## values. Lag shifts the segment's personal timeline so peaks arrive
## in hip→spine→shoulder→elbow order.
static func segment_offset(k: float, lag: float, coil: float, release: float) -> float:
	var kk: float = clampf((k - lag) / maxf(1.0 - lag, 0.01), 0.0, 1.0)
	if kk < PHASE_WINDUP_END:
		# ease into the coil
		var u: float = kk / PHASE_WINDUP_END
		return coil * _ease_in_out(u)
	elif kk < PHASE_ACTIVE_END:
		# whip: coil → release, ease-out (fast start, decelerating arrival)
		var u2: float = (kk - PHASE_WINDUP_END) / (PHASE_ACTIVE_END - PHASE_WINDUP_END)
		return lerpf(coil, release, _ease_out(u2))
	else:
		# recovery: release → neutral
		var u3: float = (kk - PHASE_ACTIVE_END) / (1.0 - PHASE_ACTIVE_END)
		return lerpf(release, 0.0, _ease_in_out(u3))

static func _ease_in_out(u: float) -> float:
	return u * u * (3.0 - 2.0 * u)

static func _ease_out(u: float) -> float:
	return 1.0 - (1.0 - u) * (1.0 - u)
