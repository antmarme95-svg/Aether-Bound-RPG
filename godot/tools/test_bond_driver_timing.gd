extends SceneTree

## Regresion del reloj de fases (Protocolo A §2).
##
##   godot --headless --path godot --script res://tools/test_bond_driver_timing.gd
##
## POR QUE EXISTE. Las dos primeras sesiones reales mataron el boton antes de
## tiempo: la fase CON duro 208.8 s en una y 224.1 s en la otra, contra los
## 300 s de diseno. La causa era `_elapsed_ms += int(round(delta * 1000.0))`
## en `_process`: con la escena gris vacia y el FPS sin tope, delta ronda los
## 0.7 ms y redondea a 1, asi que el contador corria ~45% rapido. El error
## depende del FPS de la maquina, o sea que cada tester recibia un test
## distinto -- y el minuto 5 es el experimento entero.
##
## El test mide el corte contra Time.get_ticks_msec(), que es la misma base
## de tiempo que estampa la telemetria. Con el codigo viejo falla.

const DriverScript = preload("res://scripts/bond_driver.gd")

var _fails: int = 0
var _checks: int = 0
## Miembros y no locales: en GDScript las lambdas capturan por VALOR, asi que
## asignarle a una local desde dentro de la senal escribe en una copia y el
## test se queda esperando para siempre.
var _t_kill: int = -1
var _frames: int = 0


func _initialize() -> void:
	_run()


func _run() -> void:
	print("\n--- reloj de fases del BondDriver ---")

	var drv = DriverScript.new()
	drv.con_phase_ms = 600
	drv.sin_phase_ms = 600
	drv.read_input = false
	root.add_child(drv)
	# Un frame antes de arrancar: en `_initialize` los nodos recien agregados
	# todavia no estan inside_tree y `get_tree()` devuelve null adentro del
	# driver.
	await process_frame

	var t0: int = Time.get_ticks_msec()
	var t_end: int = -1
	drv.button_died.connect(_on_died)

	drv.begin()
	# Se deja correr con margen; el bucle sale cuando el driver deja de
	# procesar, que es como marca el fin de la fase SIN.
	while t_end < 0 and Time.get_ticks_msec() - t0 < 6000:
		await process_frame
		_frames += 1
		if _t_kill > 0 and not drv.is_processing():
			t_end = Time.get_ticks_msec()

	var real_con: int = _t_kill - t0
	var real_total: int = t_end - t0
	print("  (frames corridos: %d)" % _frames)

	_check(_t_kill > 0, "el boton murio")
	# 5% de tolerancia. Con un reloj real el error es de un frame; el margen
	# ancho no sirve: a 300 FPS el bug daba 10% y se colaba, y solo explotaba
	# a 1400 FPS, o sea justo en la maquina donde se corre el playtest.
	_check(absf(float(real_con) - 600.0) < 30.0,
		"la fase CON duro %d ms de reloj real contra 600 de diseno (%.0f%%)"
		% [real_con, 100.0 * real_con / 600.0])
	_check(t_end > 0 and absf(float(real_total) - 1200.0) < 60.0,
		"la sesion completa duro %d ms de reloj real contra 1200 de diseno" % real_total)

	print("\n" + "=".repeat(66))
	if _fails == 0:
		print("ALL_PASS — %d verificaciones" % _checks)
	else:
		print("FAIL — %d de %d verificaciones" % [_fails, _checks])
	print("=".repeat(66))
	quit(1 if _fails > 0 else 0)


func _on_died() -> void:
	_t_kill = Time.get_ticks_msec()


func _check(cond: bool, label: String) -> void:
	_checks += 1
	if cond:
		print("  ok   %s" % label)
	else:
		_fails += 1
		print("  FAIL %s" % label)
