extends RefCounted
class_name TelemetryAnalysis

## Derivacion de P, T y U desde un CSV de sesion, y el veredicto de §0.3.
##
## Vive aparte del reporte para que el test pueda ejercitarlo con CSV
## fabricados: verificar el umbral de T>=20 s no puede depender de esperar
## veinte segundos reales, y verificar el veredicto de "2 de 3" no puede
## depender de conseguir tres personas.

# --- §0.3, propuesta pendiente de firma de Boris -------------------------
const P_VERDE: int = 3
const T_VERDE_S: float = 20.0
const P_ROJO: int = 1
const MAYORIA: int = 2          # "2 de 3"
# --- §0.2, condicion de validez ------------------------------------------
const U_MINIMO: float = 2.0     # pulsaciones/min con el boton vivo
# -------------------------------------------------------------------------
## Duracion de la fase CON segun §2 (5 minutos). NO es un umbral de
## clasificacion: solo sirve para levantar la bandera `corta`.
const CON_ESPERADO_S: float = 300.0

const R_VERDE := "verde"
const R_AMARILLO := "amarillo"
const R_ROJO := "rojo"
const R_INVALIDA := "invalida"      # U < U_MINIMO: no tiene resultado
const R_DESCARTADA := "descartada"  # no cerro como "completa"
const R_ILEGIBLE := "ilegible"


static func analyze_file(path: String) -> Dictionary:
	return analyze_rows(read_csv(path))


static func analyze_rows(rows: Array) -> Dictionary:
	if rows.is_empty():
		return {"clase": R_ILEGIBLE}

	var tester_id: String = ""
	var build_hash: String = ""
	var reason: String = "sin_cierre"
	var con_start: int = -1
	var con_end: int = -1
	var last_ts: int = 0

	var dead_in_zone: Array[int] = []
	var alive_presses: int = 0

	for r in rows:
		var ts: int = int(str(r.get("timestamp_ms", "0")))
		last_ts = maxi(last_ts, ts)
		match str(r.get("event", "")):
			"session_start":
				tester_id = str(r.get("tester_id", ""))
				build_hash = str(r.get("build_hash", ""))
			"phase_change":
				var ph: String = str(r.get("phase", ""))
				if ph == "con":
					con_start = ts
				elif ph == "sin":
					con_end = ts
			"session_end":
				reason = str(r.get("reason", "sin_cierre"))
			"bond_press":
				var alive: bool = str(r.get("button_alive", "")) == "true"
				var inside: bool = str(r.get("in_ledge_zone", "")) == "true"
				if alive:
					alive_presses += 1
				elif inside:
					dead_in_zone.append(ts)

	if con_start < 0:
		return {"clase": R_ILEGIBLE}
	if con_end < 0:
		con_end = last_ts

	var con_seconds: float = maxf(0.001, float(con_end - con_start) / 1000.0)
	var u: float = float(alive_presses) / (con_seconds / 60.0)

	var t_span: float = 0.0
	if dead_in_zone.size() >= 2:
		t_span = float(dead_in_zone[dead_in_zone.size() - 1] - dead_in_zone[0]) / 1000.0

	var out: Dictionary = {
		"tester_id": tester_id,
		"build_hash": build_hash,
		"reason": reason,
		"con_seconds": con_seconds,
		"U": u,
		"P": dead_in_zone.size(),
		"T": t_span,
		# Una fase CON mucho mas corta que la disenada quiere decir que la
		# sesion se corto y NADIE la marco como fallo tecnico. El protocolo
		# depende de que el facilitador se acuerde (§3.3); esto lo hace
		# visible sin depender de eso.
		#
		# Es una BANDERA, no un umbral: no reclasifica nada. Mover la
		# clasificacion por un criterio que Boris no firmo seria hacer
		# exactamente lo que §6 prohibe.
		"corta": con_seconds < CON_ESPERADO_S * 0.5,
	}

	# El orden importa y es el del documento: primero se descarta la sesion
	# rota, despues se evalua la VALIDEZ (§0.2), y recien despues el
	# resultado (§0.3). Evaluar el resultado antes de la validez es
	# exactamente el autoengano que §12 prohibe.
	if reason != "completa":
		out["clase"] = R_DESCARTADA
	elif u < U_MINIMO:
		out["clase"] = R_INVALIDA
	elif out.P >= P_VERDE and out.T >= T_VERDE_S:
		out["clase"] = R_VERDE
	elif out.P <= P_ROJO:
		out["clase"] = R_ROJO
	else:
		out["clase"] = R_AMARILLO
	return out


## Veredicto del conjunto (§6). Devuelve la clase agregada y los conteos.
static func verdict(analyses: Array) -> Dictionary:
	var verdes: int = 0
	var rojos: int = 0
	var validas: int = 0
	for a in analyses:
		match str(a.get("clase", "")):
			R_VERDE:
				verdes += 1
				validas += 1
			R_ROJO:
				rojos += 1
				validas += 1
			R_AMARILLO:
				validas += 1
	var clase: String
	if validas < MAYORIA:
		clase = "sin_datos"
	elif verdes >= MAYORIA:
		clase = R_VERDE
	elif rojos >= MAYORIA:
		clase = R_ROJO
	else:
		clase = R_AMARILLO
	return {"clase": clase, "verdes": verdes, "rojos": rojos, "validas": validas}


static func read_csv(path: String) -> Array:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return []
	var header: PackedStringArray = PackedStringArray()
	var rows: Array = []
	while not f.eof_reached():
		var line: String = f.get_line()
		if line.strip_edges() == "":
			continue
		var cells: PackedStringArray = split_csv(line)
		if header.is_empty():
			header = cells
			continue
		var d: Dictionary = {}
		for i in range(mini(header.size(), cells.size())):
			d[header[i]] = cells[i]
		rows.append(d)
	f.close()
	return rows


static func split_csv(line: String) -> PackedStringArray:
	var out: PackedStringArray = PackedStringArray()
	var cur: String = ""
	var in_q: bool = false
	var i: int = 0
	while i < line.length():
		var c: String = line[i]
		if in_q:
			if c == "\"":
				if i + 1 < line.length() and line[i + 1] == "\"":
					cur += "\""
					i += 1
				else:
					in_q = false
			else:
				cur += c
		elif c == "\"":
			in_q = true
		elif c == ",":
			out.append(cur)
			cur = ""
		else:
			cur += c
		i += 1
	out.append(cur)
	return out
