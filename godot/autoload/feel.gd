# feel.gd — autoload "Feel" (PRD-006 alcance 4): fachada de los canales 1–2
# de la Game Feel Bible, reutilizable por PRD-007.
#   Canal 1 (tiempo): combat/time_feel.gd — este nodo aplica el
#     Engine.time_scale devuelto, UNA vez por frame, con dt REAL (los
#     relojes internos no pueden depender del time_scale que ellos mismos
#     congelan).
#   Canal 2 (shake): combat/trauma_shake.gd — la cámara del dueño lee
#     shake_offset()/shake_roll() tras posicionarse. El shake corre en el
#     reloj del JUEGO: el hit-stop congela TODO el frame (B15).
#   Sting del parry: dos notas ascendentes sintetizadas al vuelo (la
#     gramática del Bond invade el combate — GFB principio 4). Placeholder
#     hasta B8 (sonido real).
#
# process_mode ALWAYS + guard de pausa: el freeze no debe quedar pegado si
# alguien pausa el árbol a mitad de un hit-stop.
extends Node

const _TimeFeel = preload("res://combat/time_feel.gd")
const _Trauma = preload("res://combat/trauma_shake.gd")

var time_feel: RefCounted = _TimeFeel.new()
var shake: RefCounted = _Trauma.new()

var _last_ms: int = 0
var _sting: AudioStreamPlayer = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_last_ms = Time.get_ticks_usec()
	_sting = AudioStreamPlayer.new()
	_sting.stream = _build_sting()
	_sting.volume_db = -6.0
	add_child(_sting)

func _process(_delta: float) -> void:
	# usec, no msec: a >1000 fps un frame mide 0 ms y los relojes reales
	# dejarían de decaer (la dilation se quedaría pegada).
	var now: int = Time.get_ticks_usec()
	var real_dt: float = clampf(float(now - _last_ms) / 1000000.0, 0.0, 0.1)
	_last_ms = now
	if get_tree().paused:
		Engine.time_scale = 1.0
		return
	var ts: float = time_feel.tick_frame(real_dt)
	Engine.time_scale = ts
	# El shake vive en el reloj del juego: freeze congela el frame entero.
	shake.tick(real_dt * ts)

# ---- API de gameplay (canales 1–2) ----

## Golpe PROPIO conectado: hit-stop por masa de arma + trauma (masa ajena
## no aplica: el shake acá comunica el impacto que TÚ provocaste cerca).
func hit_landed(weapon_mass: float, death_blow: bool = false) -> void:
	time_feel.request_hit_stop(weapon_mass, death_blow)
	shake.add(shake.HIT_HEAVY if weapon_mass >= time_feel.HEAVY_MASS else shake.HIT_LIGHT)

## Golpe RECIBIDO: hit-stop al 50% (GFB); el shake solo si lo que pega es
## pesado (masa ajena) — el impacto propio ya habla por thump/tinte.
func hit_received(weapon_mass: float) -> void:
	time_feel.request_receive_stop(weapon_mass)
	if weapon_mass >= time_feel.HEAVY_MASS:
		shake.add(shake.RECEIVE_HEAVY)

## Parry Roba: clang 3 f + dilation 0.2×0.35 s + sting de dos notas.
func parry() -> void:
	time_feel.request_parry()
	if _sting != null:
		_sting.play()

## PRD-007 alcance 2: despegue del Seismic Springboard. El lanzamiento merece su
## lenguaje de tiempo (GFB): un freeze pesado (el "pop" de la curva de subida) +
## trauma pesado (la tierra te avienta). Sin sting: el premio del Bond aquí es la
## altura, no el clang.
func springboard_launch() -> void:
	time_feel.request_hit_stop(time_feel.HEAVY_MASS)
	shake.add(shake.HIT_HEAVY)

func shake_offset() -> Vector3:
	return shake.offset()

func shake_roll() -> float:
	return shake.roll()

# ---- sting de dos notas (E5 → B5, ascendente: el Roba premia) ----
func _build_sting() -> AudioStreamWAV:
	var rate: int = 44100
	var notes: Array = [[659.25, 0.10], [987.77, 0.24]]
	var data := PackedByteArray()
	for n in notes:
		var freq: float = n[0]
		var dur: float = n[1]
		var count: int = int(rate * dur)
		for i in count:
			var t: float = float(i) / float(rate)
			var env: float = exp(-5.0 * t / dur) * minf(t / 0.004, 1.0)
			var v: float = sin(TAU * freq * t) * env * 0.38
			var s: int = int(clampf(v, -1.0, 1.0) * 32767.0)
			data.append(s & 0xFF)
			data.append((s >> 8) & 0xFF)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = data
	return wav
