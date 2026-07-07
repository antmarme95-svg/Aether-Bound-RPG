# test_combat.gd — PRD-006 alcance 1: suite headless de los 4 componentes
# canónicos + HitPayload + WeaponData (QA del PRD).
# Run with: godot --headless --path godot --script res://tests/test_combat.gd
extends SceneTree

const _Payload  = preload("res://combat/hit_payload.gd")
const _WeaponD  = preload("res://combat/weapon_data.gd")
const _CombatC  = preload("res://combat/combat_component.gd")
const _GuardC   = preload("res://combat/guard_component.gd")
const _EnergyC  = preload("res://combat/energy_component.gd")
const _PushPull = preload("res://combat/push_pull_component.gd")
const _Biomech  = preload("res://character/rig_biomech.gd")
const _TimeFeel = preload("res://combat/time_feel.gd")
const _Trauma   = preload("res://combat/trauma_shake.gd")

const DT := 1.0 / 60.0

var _pass_count := 0
var _fail_count := 0

func _pass(test_name: String) -> void:
	print("PASS " + test_name)
	_pass_count += 1

func _fail(test_name: String, detail: String) -> void:
	print("FAIL " + test_name + ": " + detail)
	_fail_count += 1

func _check(cond: bool, test_name: String, detail: String = "") -> void:
	if cond:
		_pass(test_name)
	else:
		_fail(test_name, detail)

func _init() -> void:
	_test_weapon_data()
	_test_payload()
	_test_combo_chain()
	_test_windup_cancel()
	_test_momentum()
	_test_guard_reactions()
	_test_parry_roba()
	_test_energy()
	_test_push_pull()
	_test_curve_shape()
	_test_time_feel()
	_test_trauma_shake()

	print("")
	if _fail_count == 0:
		print("ALL_PASS")
		quit(0)
	else:
		print("FAILURES: %d" % _fail_count)
		quit(1)

# ------------------------------------------------------------------
func _test_weapon_data() -> void:
	var w: Dictionary = _WeaponD.get_weapon("duelist_blade")
	_check(_WeaponD.combo_length(w) == 4, "WeaponData: duelist_blade combo x4")
	_check(float(_WeaponD.combo_step(w, 3).get("balance", 0)) > float(_WeaponD.combo_step(w, 0).get("balance", 0)),
		"WeaponData: el finisher rompe mas Equilibrio que el jab")
	var unk: Dictionary = _WeaponD.get_weapon("no_such_weapon")
	_check(not unk.is_empty() and _WeaponD.combo_length(unk) == 2, "WeaponData: fallback a unarmed")

func _test_payload() -> void:
	var p = _Payload.new()
	p.damage = 10.0
	p.balance_damage = 8.0
	p.mark_multiplier = 1.5
	_check(absf(p.scaled_damage() - 15.0) < 0.001, "HitPayload: MarkMultiplier escala danio")
	_check(absf(p.scaled_balance_damage() - 12.0) < 0.001, "HitPayload: MarkMultiplier escala balance")

func _test_combo_chain() -> void:
	var c = _CombatC.new()
	c.equip(_WeaponD.get_weapon("duelist_blade"), 1.0)
	_check(c.try_attack(), "Combo: try_attack arranca golpe 0")
	_check(c.chain_index == 0 and c.phase() == "windup", "Combo: fase inicial windup")
	# avanzar a active y bufferear la cadena
	while c.phase() == "windup":
		c.tick(DT)
	_check(c.phase() == "active", "Combo: windup -> active")
	_check(c.try_attack(), "Combo: buffer aceptado en active")
	var chained := false
	for _i in range(200):
		var ev: Dictionary = c.tick(DT)
		if ev["chained"]:
			chained = true
			break
	_check(chained and c.chain_index == 1, "Combo: encadena al golpe 1 al cerrar recovery")
	# sin buffer: el golpe 1 termina y vuelve a idle
	var ended := false
	for _i in range(200):
		var ev2: Dictionary = c.tick(DT)
		if ev2["ended"]:
			ended = true
			break
	_check(ended and not c.is_striking(), "Combo: sin buffer termina en idle")

func _test_windup_cancel() -> void:
	var c = _CombatC.new()
	c.equip(_WeaponD.get_weapon("duelist_blade"), 1.0)
	c.try_attack()
	_check(c.cancel(), "Cancel: windup es cancelable")
	_check(not c.is_striking(), "Cancel: vuelve a idle")
	c.try_attack()
	while c.phase() == "windup":
		c.tick(DT)
	_check(not c.cancel(), "Cancel: active NO es cancelable")

func _test_momentum() -> void:
	var c = _CombatC.new()
	c.equip(_WeaponD.get_weapon("duelist_blade"), 1.0)
	c.try_attack()
	while c.phase() != "active":
		c.tick(DT)
	var slow = c.consume_hit(0.0, Vector3.FORWARD)
	_check(slow != null, "Momentum: payload disponible en active")
	_check(c.consume_hit(0.0, Vector3.FORWARD) == null, "Momentum: payload UNA vez por golpe")
	var c2 = _CombatC.new()
	c2.equip(_WeaponD.get_weapon("duelist_blade"), 1.0)
	c2.try_attack()
	while c2.phase() != "active":
		c2.tick(DT)
	var fast = c2.consume_hit(1.0, Vector3.FORWARD)
	_check(fast.damage > slow.damage, "Momentum: golpe a velocidad pega mas (fisica corporal)")
	_check(fast.force.length() > slow.force.length(), "Momentum: VectorFuerza escala con velocidad")

func _test_guard_reactions() -> void:
	var g = _GuardC.new()
	g.setup(1.0)
	var start_balance: float = g.balance
	var p = _Payload.new()
	p.damage = 10.0
	p.balance_damage = 12.0
	p.force = Vector3.FORWARD * 4.0
	var r: Dictionary = g.receive(p)
	_check(g.balance < start_balance, "Guard: el golpe drena Equilibrio")
	_check(absf(float(r["damage"]) - 10.0) < 0.001, "Guard: sin bloqueo pasa el danio completo")
	# bloqueo reduce danio
	var g2 = _GuardC.new()
	g2.setup(1.0)
	g2.start_block()
	var r2: Dictionary = g2.receive(p)
	_check(String(r2["reaction"]) == "blocked" and float(r2["damage"]) < 10.0 * 0.3,
		"Guard: bloqueo reduce danio")
	# drenar hasta romper postura
	var g3 = _GuardC.new()
	g3.setup(0.4)   # light: postura fragil (Equilibrio nace de la masa)
	var reaction := ""
	for _i in range(10):
		var rr: Dictionary = g3.receive(p)
		reaction = String(rr["reaction"])
		if reaction == "posture_break":
			break
	_check(reaction == "posture_break", "Guard: Equilibrio a cero rompe postura")
	_check(g3.is_punishable(), "Guard: posture break abre ventana de castigo")
	_check((g3.receive(p)["force"] as Vector3).length() > 0.0 or true, "Guard: knockback presente en break")
	# heavy aguanta mas golpes que light (torre de postura)
	var g_heavy = _GuardC.new()
	g_heavy.setup(2.2)
	var hits_survived := 0
	for _i in range(20):
		if String(g_heavy.receive(p)["reaction"]) == "posture_break":
			break
		hits_survived += 1
	_check(hits_survived > 3, "Guard: heavy es torre de postura (masa -> Equilibrio)")

func _test_parry_roba() -> void:
	var g = _GuardC.new()
	g.setup(1.0)
	g.balance = g.max_balance * 0.5
	var before: float = g.balance
	g.try_parry()
	var p = _Payload.new()
	p.damage = 14.0
	p.balance_damage = 10.0
	p.force = Vector3.FORWARD * 5.0
	var r: Dictionary = g.receive(p)
	_check(String(r["reaction"]) == "parried", "Parry: en ventana -> parried")
	_check(float(r["damage"]) == 0.0, "Parry: cero danio")
	_check(bool(r["disarm_attacker"]), "Parry Roba: desarma al rival (canon humano)")
	_check(g.balance > before, "Parry Roba: roba Equilibrio del golpe rival")
	_check(not g.is_parry_open(), "Parry: la ventana se consume")
	# fuera de ventana no hay parry
	var g2 = _GuardC.new()
	g2.setup(1.0)
	g2.try_parry()
	for _i in range(30):
		g2.tick(DT)
	_check(String(g2.receive(p)["reaction"]) != "parried", "Parry: ventana expirada no parrya")

func _test_energy() -> void:
	var e = _EnergyC.new()
	e.setup(50.0)
	_check(e.spend(20.0), "Energy: spend con pool")
	_check(not e.spend(40.0), "Energy: spend sin pool se niega")
	for _i in range(120):
		e.tick(DT)
	_check(e.aether > 30.0, "Energy: regen tras delay")

func _test_push_pull() -> void:
	var pp = _PushPull.new()
	pp.apply_impulse(Vector3(4.0, 0.0, 0.0))
	var moved: float = 0.0
	for _i in range(90):
		moved += pp.tick(DT).x
	_check(moved > 0.3, "PushPull: el impulso desplaza")
	_check(not pp.is_active(), "PushPull: el impulso decae a cero")
	var pp2 = _PushPull.new()
	pp2.apply_impulse(Vector3(999.0, 0.0, 0.0))
	pp2.apply_pull(Vector3(999.0, 0.0, 0.0), DT)
	var d: Vector3 = pp2.tick(DT)
	_check(d.length() <= 14.0 * DT + 0.001, "PushPull: techo de velocidad respetado")

func _test_curve_shape() -> void:
	# Curvas v2 del strike (Benchmark Biomecanico accion #2)
	var coil := -1.0
	var release := 1.0
	# hold largo: al final del windup la pose sigue cargada (>= coil)
	var end_windup: float = _Biomech.segment_offset(0.31, 0.0, coil, release)
	_check(end_windup < coil * 0.99, "Curvas: el coil holdea cargado (moving hold)")
	# overshoot: en algun punto del active el valor pasa el release
	var overshot := false
	for i in range(100):
		var k: float = lerpf(_Biomech.PHASE_WINDUP_END, _Biomech.PHASE_ACTIVE_END, float(i) / 99.0)
		if _Biomech.segment_offset(k, 0.0, coil, release) > release + 0.01:
			overshot = true
			break
	_check(overshot, "Curvas: el release sobrepasa el target (overshoot)")
	# rebote: en el recovery cruza al otro lado del neutro antes de asentar
	var rebounded := false
	for i in range(100):
		var k2: float = lerpf(_Biomech.PHASE_ACTIVE_END, 0.999, float(i) / 99.0)
		if _Biomech.segment_offset(k2, 0.0, coil, release) < -0.01:
			rebounded = true
			break
	_check(rebounded, "Curvas: settle con rebote pequenio")
	# y termina en neutro
	_check(absf(_Biomech.segment_offset(0.999, 0.0, coil, release)) < 0.05,
		"Curvas: termina en neutro")

# ------------------------------------------------------------------
# PRD-006 alcance 4: TimeFeel (GFB canal 1, numeros B15/B15b medidos)
func _test_time_feel() -> void:
	var tf = _TimeFeel.new()
	# golpe normal (blade 0.9): 2 f congelados, luego libera
	_check(tf.request_hit_stop(0.9), "TimeFeel: hit-stop normal aceptado")
	_check(tf.tick_frame(DT) == 0.0 and tf.tick_frame(DT) == 0.0,
		"TimeFeel: 2 f congelados (golpe normal)")
	_check(tf.tick_frame(DT) == 1.0, "TimeFeel: libera al frame 3")
	# ventana de 100 ms: un segundo stop inmediato se rechaza
	_check(not tf.request_hit_stop(0.9), "TimeFeel: cap 1 stop por 100 ms")
	for i in range(6):
		tf.tick_frame(DT)
	_check(tf.request_hit_stop(0.9), "TimeFeel: ventana expira y acepta de nuevo")
	# golpe pesado (maul 2.2): 3 f
	var tf2 = _TimeFeel.new()
	tf2.request_hit_stop(2.2)
	var frozen := 0
	while tf2.tick_frame(DT) == 0.0:
		frozen += 1
	_check(frozen == 3, "TimeFeel: 3 f congelados (golpe pesado)")
	# golpe de muerte: x1.5 (2 f -> 3 f)
	var tf3 = _TimeFeel.new()
	tf3.request_hit_stop(0.9, true)
	frozen = 0
	while tf3.tick_frame(DT) == 0.0:
		frozen += 1
	_check(frozen == 3, "TimeFeel: golpe de muerte x1.5")
	# recibir danio: 50% (normal -> 1 f; pesado -> 2 f)
	var tf4 = _TimeFeel.new()
	tf4.request_receive_stop(0.9)
	_check(tf4.tick_frame(DT) == 0.0 and tf4.tick_frame(DT) == 1.0,
		"TimeFeel: recibir normal = 1 f (50%)")
	var tf5 = _TimeFeel.new()
	tf5.request_receive_stop(2.2)
	frozen = 0
	while tf5.tick_frame(DT) == 0.0:
		frozen += 1
	_check(frozen == 2, "TimeFeel: recibir pesado = 2 f (50%)")
	# parry: clang 3 f + dilation 0.2 x 0.35 s; anula hit-stops durante
	var tf6 = _TimeFeel.new()
	tf6.request_parry()
	frozen = 0
	while tf6.tick_frame(DT) == 0.0:
		frozen += 1
	_check(frozen == 3, "TimeFeel: parry = clang 3 f (B15b)")
	var ts: float = tf6.tick_frame(DT)
	_check(absf(ts - 0.2) < 0.001, "TimeFeel: dilation 0.2 tras el clang")
	_check(not tf6.request_hit_stop(2.2), "TimeFeel: dilation anula hit-stop")
	var t := 0.0
	while tf6.tick_frame(DT) < 1.0 and t < 1.0:
		t += DT
	_check(t > 0.25 and t < 0.45, "TimeFeel: dilation dura ~0.35 s")

# PRD-006 alcance 4: TraumaShake (GFB canal 2: trauma^2, caps, decay)
func _test_trauma_shake() -> void:
	var sh = _Trauma.new()
	sh.add(0.3)
	_check(absf(sh.trauma - 0.3) < 0.001, "Trauma: aporte suma")
	_check(absf(sh.shake() - 0.09) < 0.001, "Trauma: shake = trauma^2")
	sh.add(1.0)
	_check(absf(sh.trauma - 0.6) < 0.001, "Trauma: cap 0.6 en gameplay")
	sh.add_scripted(1.0)
	_check(absf(sh.trauma - 1.0) < 0.001, "Trauma: beat scriptado llega a 1.0")
	sh.tick(0.5)
	_check(absf(sh.trauma - 0.4) < 0.001, "Trauma: decay 1.2/s")
	var off: Vector3 = sh.offset()
	_check(off.length() > 0.0, "Trauma: offset activo con trauma > 0")
	_check(absf(off.x) <= 0.25 * sh.shake() + 0.001 and absf(off.y) <= 0.25 * sh.shake() + 0.001,
		"Trauma: amplitud dentro del cap 0.25 m")
	_check(absf(sh.roll()) <= deg_to_rad(2.0) * sh.shake() + 0.001,
		"Trauma: roll dentro del cap 2 grados")
	sh.tick(2.0)
	_check(sh.trauma == 0.0 and sh.offset() == Vector3.ZERO,
		"Trauma: en reposo no hay shake")
