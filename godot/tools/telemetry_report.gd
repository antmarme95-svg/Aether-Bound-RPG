extends SceneTree

## Derivador del Protocolo A. Lee los CSV de sesion y saca P, T y U.
##
##   godot --headless --path godot --script res://tools/telemetry_report.gd \
##       -- --dir=user://telemetry
##
## El documento (§4.1) promete que los derivados salen del CSV "sin trabajo
## manual". Esto es eso. La aritmetica vive en tools/telemetry_analysis.gd;
## aca solo se imprime.
##
## Los umbrales NO se pueden pasar por linea de comandos, a proposito. §0.3
## dice que se firman antes de correr nada y §6 dice que si aparece la
## tentacion de moverlos, el impulso se anota en el LOG y no se ejecuta.
## Cambiarlos es un commit, con fecha y autor.

const TA = preload("res://tools/telemetry_analysis.gd")

func _initialize() -> void:
	var dir_path: String = "user://telemetry"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--dir="):
			dir_path = a.substr(6)

	var files: PackedStringArray = _list_csv(dir_path)
	if files.is_empty():
		print("No hay CSV de sesion en %s" % dir_path)
		quit(1)
		return

	print("=".repeat(74))
	print("PROTOCOLO A — derivados por sesion   (%s)" % dir_path)
	print("umbrales: verde P>=%d y T>=%.0fs | rojo P<=%d | validez U>=%.1f/min"
		% [TA.P_VERDE, TA.T_VERDE_S, TA.P_ROJO, TA.U_MINIMO])
	print("§0 firmado por Boris el 2026-08-13, antes de que existiera un dato.")
	print("=".repeat(74))

	var analyses: Array = []
	for f in files:
		var r: Dictionary = TA.analyze_file(dir_path.path_join(f))
		analyses.append(r)
		_print_session(f, r)

	var v: Dictionary = TA.verdict(analyses)
	print("\n" + "=".repeat(74))
	match str(v.clase):
		"sin_datos":
			print("VEREDICTO: sin datos suficientes — %d sesion(es) valida(s)." % v.validas)
			print("No se concluye nada. Se corren mas sesiones.")
		TA.R_VERDE:
			print("VEREDICTO: 🟢 el reflejo existe (%d/%d). Se procede al Protocolo B."
				% [v.verdes, v.validas])
			print("Recordatorio §0.4: un verde NO prueba el pilar. Es permiso para")
			print("gastar en B, nada mas.")
		TA.R_ROJO:
			print("VEREDICTO: 🔴 el reflejo no aparece (%d/%d)." % [v.rojos, v.validas])
			print("Rama EJECUCION mecanica. Se itera feel / legibilidad / espacio y")
			print("se vuelve a correr A.")
			print("PROHIBIDO (§0.4): usar esto para replantear el pilar, recortar")
			print("alcance o abandonar el proyecto. Un cubo sin vinculo mide un")
			print("reflejo motor, no duelo.")
		_:
			print("VEREDICTO: 🟡 no concluye. Rama INSTRUMENTO.")
			print("Se rehace el guion de sesion o se suma gente. NO se toca el")
			print("diseno ni el alcance.")
	print("=".repeat(74))
	quit(0)


func _print_session(fname: String, r: Dictionary) -> void:
	var clase: String = str(r.get("clase", TA.R_ILEGIBLE))
	if clase == TA.R_ILEGIBLE:
		print("\n%s\n  ILEGIBLE — se descarta" % fname)
		return

	print("\n%s   tester=%s   build=%s" % [fname, r.tester_id, r.build_hash])

	if clase == TA.R_DESCARTADA:
		print("  sesion terminada como '%s' — SE DESCARTA (§3.3)" % r.reason)
		return

	print("  U = %.2f pulsaciones/min con el boton vivo   (fase CON: %.1f s)"
		% [r.U, r.con_seconds])

	if bool(r.get("corta", false)):
		print("  ⚠ FASE CON DE %.1f s CONTRA %.0f s DE DISENO."
			% [r.con_seconds, TA.CON_ESPERADO_S])
		print("    La sesion se corto y nadie la marco como fallo tecnico.")
		print("    Revisar antes de darle valor a lo que sigue (§3.3).")

	if clase == TA.R_INVALIDA:
		print("  ⚠ NO TIENE RESULTADO — U < %.1f (§0.2)." % TA.U_MINIMO)
		print("    La fase SIN no se interpreta. Hallazgo valido y barato:")
		print("    la habilidad no engancho. Es sobre la fase CON.")
		return

	print("  P = %d pulsaciones muertas en la zona de la cornisa" % r.P)
	print("  T = %.1f s entre la primera y la ultima" % r.T)
	match clase:
		TA.R_VERDE: print("  → 🟢")
		TA.R_ROJO: print("  → 🔴")
		_: print("  → 🟡")


func _list_csv(dir_path: String) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	var d := DirAccess.open(dir_path)
	if d == null:
		return out
	for f in d.get_files():
		if f.ends_with(".csv"):
			out.append(f)
	out.sort()
	return out
