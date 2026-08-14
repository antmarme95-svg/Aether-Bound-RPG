extends Node
class_name BondTelemetry

## Hook de telemetria del Protocolo de Playtest, §4.1.
##
## Escribe UN CSV por sesion con todos los eventos, una linea por evento.
## De ese CSV salen los tres numeros del criterio de muerte (§0.1) sin
## trabajo manual: P, T y U. El derivador esta en tools/telemetry_report.gd.
##
## Reglas que vienen del documento y NO son detalles de implementacion:
##
##   - `in_ledge_zone` es "el jugador esta adentro del volumen", y nada mas.
##     NO se filtra por orientacion de camara: filtrar agrega criterio
##     interpretable justo donde el protocolo promete conteo (§4.1).
##   - Se registra CADA pulsacion, viva o muerta, dentro o fuera de la zona.
##     El filtrado es del derivador. Si el hook filtra, el dato se pierde y
##     no hay como recuperarlo despues de la sesion.
##   - Cada linea se escribe y se hace flush en el momento. Una sesion de
##     playtest no se puede repetir: si el build se cuelga en el minuto 9,
##     los 9 minutos tienen que estar en disco.
##
## `scene_id` existe desde ya aunque el Protocolo A no lo use: el Protocolo
## B lo necesita para partir los inputs por minuto en tres tramos (§9.2), y
## agregarlo despues obligaria a re-verificar el hook contra sesiones ya
## corridas.

signal session_started(session_id: String)
signal phase_changed(phase: String)
signal session_ended(reason: String)

const PHASE_PRE := "pre"
const PHASE_CON := "con"
const PHASE_SIN := "sin"

const REASON_COMPLETA := "completa"
const REASON_FALLO := "fallo_tecnico"
const REASON_ABORTADA := "abortada"

const COLUMNS: PackedStringArray = [
	"event", "session_id", "timestamp_ms", "wall_clock", "tester_id",
	"build_hash", "phase", "ms_since_phase_start", "button_alive",
	"in_ledge_zone", "ledge_id", "scene_id",
	"player_x", "player_y", "player_z", "press_index", "reason",
]

## Carpeta de salida. `user://` sobrevive al build congelado y no depende de
## permisos de escritura en la carpeta del ejecutable.
@export var output_dir: String = "user://telemetry"
## Si esta vacio, se lee de res://build_hash.txt y si tampoco existe queda
## "desconocido" -- que es dato, no error: avisa que el build no se congelo
## como manda §4.2.
@export var build_hash: String = ""

var session_id: String = ""
var tester_id: String = ""
var phase: String = PHASE_PRE

var _file: FileAccess = null
var _path: String = ""
var _phase_start_ms: int = 0
var _press_index: int = 0
var _zones_inside: Dictionary = {}

func _ready() -> void:
	add_to_group("bond_telemetry")


# --------------------------------------------------------------------------
# Ciclo de sesion
# --------------------------------------------------------------------------

func start_session(p_tester_id: String, p_session_id: String = "") -> String:
	if _file != null:
		push_warning("BondTelemetry: ya hay una sesion abierta; se cierra como abortada")
		end_session(REASON_ABORTADA)

	tester_id = p_tester_id
	session_id = p_session_id if p_session_id != "" else _make_session_id(p_tester_id)
	phase = PHASE_PRE
	_press_index = 0
	_zones_inside.clear()

	if build_hash == "":
		build_hash = _read_build_hash()

	DirAccess.make_dir_recursive_absolute(output_dir)
	_path = output_dir.path_join("%s.csv" % session_id)
	_file = FileAccess.open(_path, FileAccess.WRITE)
	if _file == null:
		push_error("BondTelemetry: no se pudo abrir %s (error %d)" % [_path, FileAccess.get_open_error()])
		return ""

	_file.store_line(",".join(COLUMNS))
	_phase_start_ms = Time.get_ticks_msec()
	_write({"event": "session_start"})
	session_started.emit(session_id)
	return _path


## Cambia de fase. El `timestamp_ms` de este evento es el cero contra el que
## se mide `ms_since_phase_start` de las pulsaciones siguientes.
func set_phase(p_phase: String) -> void:
	if _file == null:
		return
	phase = p_phase
	_phase_start_ms = Time.get_ticks_msec()
	_write({"event": "phase_change"})
	phase_changed.emit(p_phase)


func end_session(reason: String = REASON_COMPLETA) -> void:
	if _file == null:
		return
	_write({"event": "session_end", "reason": reason})
	_file.flush()
	_file.close()
	_file = null
	session_ended.emit(reason)


func is_recording() -> bool:
	return _file != null


func current_path() -> String:
	return _path


# --------------------------------------------------------------------------
# Eventos de juego
# --------------------------------------------------------------------------

func ledge_zone_enter(ledge_id: String) -> void:
	_zones_inside[ledge_id] = true
	_write({"event": "ledge_zone_enter", "ledge_id": ledge_id})


func ledge_zone_exit(ledge_id: String) -> void:
	_zones_inside.erase(ledge_id)
	_write({"event": "ledge_zone_exit", "ledge_id": ledge_id})


## Se llama en CADA pulsacion del boton de Bond, viva o muerta.
## `button_alive` es el estado real del boton, no si produjo movimiento.
func bond_press(button_alive: bool, player_pos: Vector3, scene_id: String = "") -> void:
	_press_index += 1
	var inside: bool = not _zones_inside.is_empty()
	_write({
		"event": "bond_press",
		"button_alive": button_alive,
		"in_ledge_zone": inside,
		"ledge_id": _first_zone(),
		"scene_id": scene_id,
		"player_x": player_pos.x,
		"player_y": player_pos.y,
		"player_z": player_pos.z,
		"press_index": _press_index,
	})


func in_ledge_zone() -> bool:
	return not _zones_inside.is_empty()


# --------------------------------------------------------------------------
# Interno
# --------------------------------------------------------------------------

func _write(fields: Dictionary) -> void:
	if _file == null:
		return
	var now: int = Time.get_ticks_msec()
	var row: Dictionary = {
		"session_id": session_id,
		"timestamp_ms": now,
		"wall_clock": Time.get_datetime_string_from_system(false, true),
		"tester_id": tester_id,
		"build_hash": build_hash,
		"phase": phase,
		"ms_since_phase_start": now - _phase_start_ms,
	}
	row.merge(fields, true)

	var out: PackedStringArray = PackedStringArray()
	for col in COLUMNS:
		out.append(_csv_cell(row.get(col, "")))
	_file.store_line(",".join(out))
	# Flush por linea: una sesion de playtest no se puede repetir.
	_file.flush()


func _csv_cell(v: Variant) -> String:
	var s: String
	if v is bool:
		s = "true" if v else "false"
	elif v is float:
		s = "%.4f" % v
	else:
		s = str(v)
	if s.contains(",") or s.contains("\"") or s.contains("\n"):
		return "\"%s\"" % s.replace("\"", "\"\"")
	return s


func _first_zone() -> String:
	for k in _zones_inside:
		return str(k)
	return ""


func _make_session_id(p_tester: String) -> String:
	var safe: String = p_tester.to_lower().replace(" ", "-")
	var t: Dictionary = Time.get_datetime_dict_from_system()
	return "%04d%02d%02d-%02d%02d%02d-%s" % [
		t.year, t.month, t.day, t.hour, t.minute, t.second, safe,
	]


func _read_build_hash() -> String:
	if not FileAccess.file_exists("res://build_hash.txt"):
		return "desconocido"
	var f := FileAccess.open("res://build_hash.txt", FileAccess.READ)
	if f == null:
		return "desconocido"
	var h: String = f.get_as_text().strip_edges()
	f.close()
	return h if h != "" else "desconocido"
