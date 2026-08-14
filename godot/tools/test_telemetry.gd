extends SceneTree

## Test del hook de telemetria (Protocolo de Playtest §4.1).
##
##   godot --headless --path godot --script res://tools/test_telemetry.gd
##
## Tres bloques, por una razon de diseno del test y no de comodidad:
##
##   A. El GRABADOR contra un CSV real. Es el unico que puede fallar durante
##      una sesion con un tester enfrente, asi que se verifica que cada linea
##      este en disco ANTES de cerrar el archivo -- no al final.
##   B. La ZONA con fisica real, porque `in_ledge_zone` sale de senales de
##      Area3D y un mock no probaria nada de lo que puede romperse.
##   C. El DERIVADOR contra CSV fabricados. Verificar el umbral de T>=20 s no
##      puede depender de esperar veinte segundos reales, ni el veredicto de
##      "2 de 3" de conseguir tres personas.

const TA = preload("res://tools/telemetry_analysis.gd")
const TelemetryScript = preload("res://scripts/telemetry.gd")
const LedgeZoneScript = preload("res://scripts/ledge_zone.gd")
const BondDriverScript = preload("res://scripts/bond_driver.gd")

const OUT_DIR := "user://test_telemetry"

var _fails: int = 0
var _checks: int = 0


func _initialize() -> void:
	_clean_dir()
	_test_scripts_compile()
	await _test_recorder()
	await _test_ledge_zone_physics()
	await _test_driver_phases()
	_test_analysis()
	_test_verdict()

	print("\n" + "=".repeat(66))
	if _fails == 0:
		print("ALL_PASS — %d verificaciones" % _checks)
	else:
		print("FAIL — %d de %d verificaciones" % [_fails, _checks])
	print("=".repeat(66))
	quit(1 if _fails > 0 else 0)


# ==========================================================================
# A0. Que los scripts COMPILEN
# ==========================================================================

## Esto existe porque el test ya mintio una vez: `ledge_zone.gd` no compilaba,
## el bloque B murio en el `.new()`, y el test igual imprimio ALL_PASS. Un
## error de script no incrementa el contador de fallas por su cuenta.
## Regla: todo script que el test instancia se verifica ANTES de usarlo.
func _test_scripts_compile() -> void:
	print("\n--- A0. compilacion ---")
	for entry in [
		["res://scripts/telemetry.gd", TelemetryScript],
		["res://scripts/ledge_zone.gd", LedgeZoneScript],
		["res://scripts/bond_driver.gd", BondDriverScript],
	]:
		var path: String = entry[0]
		var s: GDScript = entry[1]
		_check(s != null and s.can_instantiate(), "compila e instancia: %s" % path)


# ==========================================================================
# A. Grabador
# ==========================================================================

func _test_recorder() -> void:
	print("\n--- A. grabador ---")
	var tel = TelemetryScript.new()
	tel.output_dir = OUT_DIR
	tel.build_hash = "testhash"
	root.add_child(tel)

	var path: String = tel.start_session("Diego", "sesion-A")
	_check(path != "", "start_session devuelve la ruta")
	_check(FileAccess.file_exists(path), "el CSV existe apenas arranca la sesion")

	# El flush por linea es un requisito, no una optimizacion: si el build se
	# cuelga en el minuto 9, los 9 minutos tienen que estar en disco.
	var early: Array = TA.read_csv(path)
	_check(early.size() == 1, "session_start ya esta en disco con el archivo abierto")

	tel.set_phase(TelemetryScript.PHASE_CON)
	tel.bond_press(true, Vector3(1, 0, 2))
	tel.bond_press(true, Vector3(1, 0, 2))
	_check(not tel.in_ledge_zone(), "arranca fuera de la zona")

	tel.ledge_zone_enter("cornisa_01")
	_check(tel.in_ledge_zone(), "entrar a la zona se registra en el estado")
	tel.bond_press(true, Vector3(3, 0, 4))
	tel.set_phase(TelemetryScript.PHASE_SIN)
	tel.bond_press(false, Vector3(3, 0, 4))
	tel.bond_press(false, Vector3(3, 0, 4))
	tel.ledge_zone_exit("cornisa_01")
	tel.bond_press(false, Vector3(9, 0, 9))
	tel.end_session(TelemetryScript.REASON_COMPLETA)

	var rows: Array = TA.read_csv(path)
	var by_event: Dictionary = {}
	for r in rows:
		var e: String = str(r.get("event", ""))
		by_event[e] = int(by_event.get(e, 0)) + 1

	_check(by_event.get("session_start", 0) == 1, "un session_start")
	_check(by_event.get("phase_change", 0) == 2, "dos phase_change")
	_check(by_event.get("ledge_zone_enter", 0) == 1, "un ledge_zone_enter")
	_check(by_event.get("ledge_zone_exit", 0) == 1, "un ledge_zone_exit")
	_check(by_event.get("bond_press", 0) == 6, "seis bond_press (todas, vivas y muertas)")
	_check(by_event.get("session_end", 0) == 1, "un session_end")

	var presses: Array = []
	for r in rows:
		if str(r.get("event", "")) == "bond_press":
			presses.append(r)

	_check(str(presses[2].get("in_ledge_zone", "")) == "true",
		"la pulsacion dentro de la zona queda marcada")
	_check(str(presses[5].get("in_ledge_zone", "")) == "false",
		"la pulsacion despues de salir queda fuera")
	_check(str(presses[5].get("button_alive", "")) == "false",
		"button_alive refleja el estado del boton, no el efecto")
	_check(int(str(presses[0].get("press_index", "0"))) == 1
		and int(str(presses[5].get("press_index", "0"))) == 6,
		"press_index es correlativo y no se reinicia por fase")
	_check(str(presses[3].get("phase", "")) == "sin",
		"la fase viaja en cada pulsacion")
	_check(str(rows[0].get("build_hash", "")) == "testhash",
		"el build_hash queda en el CSV")
	_check(str(rows[0].get("tester_id", "")) == "Diego", "el tester_id queda en el CSV")

	# Nadie deberia poder confundir un cierre por fallo con uno completo.
	var t2 = TelemetryScript.new()
	t2.output_dir = OUT_DIR
	root.add_child(t2)
	var p2: String = t2.start_session("Santiago", "sesion-abortada")
	t2.set_phase(TelemetryScript.PHASE_CON)
	t2.bond_press(true, Vector3.ZERO)
	t2.end_session(TelemetryScript.REASON_FALLO)
	var a2: Dictionary = TA.analyze_file(p2)
	_check(str(a2.clase) == TA.R_DESCARTADA, "una sesion con fallo tecnico se descarta sola")

	tel.queue_free()
	t2.queue_free()
	await process_frame


# ==========================================================================
# B. Zona con fisica real
# ==========================================================================

func _test_ledge_zone_physics() -> void:
	print("\n--- B. zona de la cornisa (fisica real) ---")
	var world := Node3D.new()
	root.add_child(world)

	var tel = TelemetryScript.new()
	tel.output_dir = OUT_DIR
	world.add_child(tel)

	var zone = LedgeZoneScript.new()
	zone.ledge_id = "cornisa_01"
	zone.zone_width = 4.0
	zone.zone_depth = 3.0
	world.add_child(zone)
	zone.global_position = Vector3.ZERO

	var player := CharacterBody3D.new()
	player.add_to_group("player")
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.8
	cs.shape = cap
	cs.position = Vector3(0, 0.9, 0)
	player.add_child(cs)
	# La posicion se fija ANTES de entrar al arbol. Si se spawnea en el
	# origen y se teletransporta despues, el cuerpo queda registrado en el
	# servidor de fisica encima de la zona y sale un enter/exit fantasma en
	# el CSV. No ensucia P ni T ni U --- se calculan de `in_ledge_zone` de
	# cada pulsacion, no de los eventos de zona --- pero ensucia la lectura
	# a ojo del archivo, y la escena real tiene el mismo riesgo en cada
	# respawn. Regla para la escena gris: el jugador nace donde arranca.
	player.position = Vector3(50, 0, 50)
	world.add_child(player)

	var path: String = tel.start_session("Delmer", "sesion-zona")
	tel.set_phase(TelemetryScript.PHASE_CON)
	await physics_frame
	await physics_frame

	player.global_position = Vector3(0, 0, 0)     # adentro
	await physics_frame
	await physics_frame
	_check(tel.in_ledge_zone(), "el Area3D reporta entrada con fisica real")

	player.global_position = Vector3(50, 0, 50)   # afuera
	await physics_frame
	await physics_frame
	_check(not tel.in_ledge_zone(), "el Area3D reporta salida")

	tel.end_session(TelemetryScript.REASON_COMPLETA)
	var rows: Array = TA.read_csv(path)
	var enters: int = 0
	var exits: int = 0
	for r in rows:
		match str(r.get("event", "")):
			"ledge_zone_enter": enters += 1
			"ledge_zone_exit": exits += 1
	_check(enters == 1 and exits == 1, "un enter y un exit, sin rebotes")

	world.queue_free()
	await process_frame


# ==========================================================================
# D. Driver: el corte del minuto 5
# ==========================================================================

func _test_driver_phases() -> void:
	print("\n--- D. corte de fase ---")
	var world := Node3D.new()
	root.add_child(world)

	var tel = TelemetryScript.new()
	tel.output_dir = OUT_DIR
	world.add_child(tel)

	var driver = BondDriverScript.new()
	driver.con_phase_ms = 200
	driver.sin_phase_ms = 200
	driver.read_input = false
	world.add_child(driver)

	var path: String = tel.start_session("Diego", "sesion-driver")
	driver.begin()
	_check(driver.button_alive, "el boton arranca vivo")
	driver.press()

	var died: Array = [false]
	driver.button_died.connect(func(): died[0] = true)

	var guard: int = 0
	while driver.button_alive and guard < 600:
		guard += 1
		await process_frame
	_check(not driver.button_alive, "el boton muere al terminar la fase CON")
	_check(died[0], "emite button_died (para telemetria, no para el jugador)")
	driver.press()

	guard = 0
	while tel.is_recording() and guard < 600:
		guard += 1
		await process_frame
	_check(not tel.is_recording(), "la sesion cierra sola al terminar la fase SIN")

	var a: Dictionary = TA.analyze_file(path)
	_check(str(a.reason) == "completa", "cierra como 'completa'")

	var rows: Array = TA.read_csv(path)
	var alive_flags: Array = []
	for r in rows:
		if str(r.get("event", "")) == "bond_press":
			alive_flags.append(str(r.get("button_alive", "")))
	_check(alive_flags == ["true", "false"],
		"la pulsacion de antes queda viva y la de despues muerta")

	world.queue_free()
	await process_frame


# ==========================================================================
# C. Derivador
# ==========================================================================

func _test_analysis() -> void:
	print("\n--- C. derivador ---")

	# Verde: 4 pulsaciones muertas en zona, 24 s de span, U alto.
	var verde: Array = _fabricate(
		[[0, true, false], [10000, true, false], [20000, true, false],
		 [30000, true, false], [40000, true, false], [50000, true, false]],
		[[61000, false, true], [70000, false, true], [80000, false, true],
		 [85000, false, true]],
		60000, "completa")
	var a: Dictionary = TA.analyze_rows(verde)
	_check(a.P == 4, "P cuenta solo pulsaciones muertas DENTRO de la zona (P=%d)" % a.P)
	_check(absf(a.T - 24.0) < 0.01, "T = ultima menos primera muerta en zona (T=%.1f)" % a.T)
	_check(absf(a.U - 6.0) < 0.01, "U = vivas / minutos de fase CON (U=%.2f)" % a.U)
	_check(str(a.clase) == TA.R_VERDE, "verde con P>=3 y T>=20")

	# Las muertas FUERA de la zona no cuentan, y las vivas dentro tampoco
	# ensucian U -- U es "vivas", esten donde esten.
	var mixto: Array = _fabricate(
		[[0, true, true], [30000, true, false]],
		[[61000, false, false], [70000, false, false], [80000, false, false]],
		60000, "completa")
	var m: Dictionary = TA.analyze_rows(mixto)
	_check(m.P == 0, "las muertas fuera de la zona no cuentan como P")
	_check(absf(m.U - 2.0) < 0.01, "U cuenta las vivas esten dentro o fuera")

	# Rojo: una sola muerta en zona.
	var rojo: Array = _fabricate(
		[[0, true, false], [10000, true, false], [20000, true, false],
		 [30000, true, false], [40000, true, false]],
		[[61000, false, true]],
		60000, "completa")
	var r: Dictionary = TA.analyze_rows(rojo)
	_check(r.P == 1 and str(r.clase) == TA.R_ROJO, "rojo con P<=1")

	# Amarillo: dos muertas, ni verde ni rojo.
	var amarillo: Array = _fabricate(
		[[0, true, false], [10000, true, false], [20000, true, false],
		 [30000, true, false], [40000, true, false]],
		[[61000, false, true], [70000, false, true]],
		60000, "completa")
	_check(str(TA.analyze_rows(amarillo).clase) == TA.R_AMARILLO, "amarillo con P=2")

	# Invalida: el gate del Outsider. U=1/min, y NO importa que P sea alto.
	var invalida: Array = _fabricate(
		[[0, true, false]],
		[[61000, false, true], [70000, false, true], [80000, false, true],
		 [90000, false, true]],
		60000, "completa")
	var i: Dictionary = TA.analyze_rows(invalida)
	_check(absf(i.U - 1.0) < 0.01, "U por debajo del minimo")
	_check(str(i.clase) == TA.R_INVALIDA,
		"con U<2 la sesion NO tiene resultado aunque P y T den verde (§0.2)")

	# La bandera de sesion corta avisa, pero NO reclasifica.
	# Sesion de largo real: 5 min de CON, 20 pulsaciones vivas (U=4), 3
	# muertas en zona repartidas en 25 s.
	var alive_larga: Array = []
	for k in range(20):
		alive_larga.append([k * 15000, true, false])
	var larga: Dictionary = TA.analyze_rows(_fabricate(
		alive_larga,
		[[310000, false, true], [320000, false, true], [335000, false, true]],
		300000, "completa"))
	_check(not bool(larga.corta), "una fase CON de 300 s no levanta la bandera")
	_check(str(larga.clase) == TA.R_VERDE, "y clasifica verde con datos de largo real")

	var cortita: Array = _fabricate(
		[[0, true, false], [1000, true, false]],
		[[3000, false, true], [4000, false, true]],
		2000, "completa")
	var c: Dictionary = TA.analyze_rows(cortita)
	_check(bool(c.corta), "una fase CON de 2 s levanta la bandera")
	_check(str(c.clase) != TA.R_DESCARTADA,
		"la bandera avisa pero no reclasifica: los umbrales solo los mueve un commit")


func _test_verdict() -> void:
	print("\n--- C2. veredicto del conjunto ---")
	var v = {"clase": TA.R_VERDE}
	var rj = {"clase": TA.R_ROJO}
	var am = {"clase": TA.R_AMARILLO}
	var inv = {"clase": TA.R_INVALIDA}

	_check(str(TA.verdict([v, v, rj]).clase) == TA.R_VERDE, "2 de 3 verdes -> verde")
	_check(str(TA.verdict([rj, rj, v]).clase) == TA.R_ROJO, "2 de 3 rojos -> rojo")
	_check(str(TA.verdict([v, rj, am]).clase) == TA.R_AMARILLO, "sin mayoria -> amarillo")
	_check(str(TA.verdict([inv, inv, v]).clase) == "sin_datos",
		"las invalidas no cuentan como resultado: sin datos suficientes")
	_check(TA.verdict([inv, inv, v]).validas == 1, "solo 1 valida de 3")


# ==========================================================================
# Utilidades
# ==========================================================================

## Fabrica las filas de una sesion. `alive`/`dead` son [ts, viva, en_zona].
func _fabricate(alive: Array, dead: Array, sin_ts: int, reason: String) -> Array:
	var rows: Array = []
	rows.append({"event": "session_start", "timestamp_ms": "0",
		"tester_id": "fab", "build_hash": "fab"})
	rows.append({"event": "phase_change", "timestamp_ms": "0", "phase": "con"})
	for p in alive + dead:
		rows.append({
			"event": "bond_press",
			"timestamp_ms": str(int(p[0])),
			"button_alive": "true" if bool(p[1]) else "false",
			"in_ledge_zone": "true" if bool(p[2]) else "false",
		})
	rows.append({"event": "phase_change", "timestamp_ms": str(sin_ts), "phase": "sin"})
	rows.append({"event": "session_end", "timestamp_ms": str(sin_ts + 300000),
		"reason": reason})
	return rows


func _check(cond: bool, label: String) -> void:
	_checks += 1
	if cond:
		print("  ok   %s" % label)
	else:
		_fails += 1
		print("  FAIL %s" % label)


func _clean_dir() -> void:
	DirAccess.make_dir_recursive_absolute(OUT_DIR)
	var d := DirAccess.open(OUT_DIR)
	if d == null:
		return
	for f in d.get_files():
		d.remove(f)
