# time_feel.gd — PRD-006 alcance 4 (Game Feel Bible canal 1): hit-stop y
# time-dilation como PRESUPUESTO temporal, no acumulación.
#
# Números MEDIDOS (Benchmark Biomecánico B15/B15b, ratificado):
#   - golpe normal: 2 f congelado GLOBAL (33 ms) · pesado: 3 f (50 ms)
#   - parry: el clang lleva el freeze más gordo (3 f) + dilation 0.2×0.35 s
#   - reglas GFB: la dilation del parry ANULA hit-stops simultáneos;
#     máximo UN hit-stop por ventana de 100 ms (los combos del Duelist no
#     deben sentirse stop-motion); golpe de muerte ×1.5; recibir daño = 50%.
#
# Lógica pura (RefCounted, headless-safe): el dueño (autoload Feel) llama
# tick_frame() UNA vez por frame renderizado con dt real (sin escalar) y
# aplica el time_scale devuelto. El freeze se cuenta en FRAMES porque así
# está medido el benchmark (2 f / 3 f @60).
#
# Loaded via preload (never class_name — see Lecciones).
extends RefCounted

const STOP_FRAMES_NORMAL: int = 2     # B15: golpe normal, congelado global
const STOP_FRAMES_HEAVY: int = 3      # B15: golpe pesado / clang de parry
const HEAVY_MASS: float = 1.5         # masa de arma >= esto → pesado
const DEATH_BLOW_MULT: float = 1.5    # GFB: último enemigo del encuentro
const RECEIVE_FACTOR: float = 0.5     # GFB: recibir daño = 50% del arma enemiga
const STOP_WINDOW: float = 0.10       # GFB: máx 1 hit-stop por 100 ms
const PARRY_DILATION: float = 0.2     # GFB §4.2.B.4
const PARRY_DILATION_T: float = 0.35

var _freeze_frames: int = 0
var _dilation_t: float = 0.0
var _window_t: float = 0.0

func frames_for_mass(weapon_mass: float) -> int:
	return STOP_FRAMES_HEAVY if weapon_mass >= HEAVY_MASS else STOP_FRAMES_NORMAL

## Hit-stop por golpe CONECTADO (quien pega llama). Devuelve si entró.
func request_hit_stop(weapon_mass: float, death_blow: bool = false) -> bool:
	var frames: int = frames_for_mass(weapon_mass)
	if death_blow:
		frames = int(ceil(float(frames) * DEATH_BLOW_MULT))
	return _request(frames)

## Hit-stop por golpe RECIBIDO: 50% del valor del arma enemiga (GFB).
func request_receive_stop(weapon_mass: float) -> bool:
	var frames: int = maxi(1, int(round(float(frames_for_mass(weapon_mass)) * RECEIVE_FACTOR)))
	return _request(frames)

## Parry Roba: clang 3 f (B15b — el premio se siente en el freeze) y abre
## la dilation 0.2×0.35 s. Ignora la ventana: el parry siempre paga.
func request_parry() -> void:
	_freeze_frames = STOP_FRAMES_HEAVY
	_dilation_t = PARRY_DILATION_T
	_window_t = STOP_WINDOW

func is_active() -> bool:
	return _freeze_frames > 0 or _dilation_t > 0.0

func _request(frames: int) -> bool:
	if _dilation_t > 0.0:      # la dilation del parry anula hit-stops (GFB)
		return false
	if _window_t > 0.0:        # presupuesto: 1 congelado por ventana
		return false
	_freeze_frames = frames
	_window_t = STOP_WINDOW
	return true

## UNA llamada por frame renderizado, con dt REAL (sin escalar).
## Devuelve el time_scale global a aplicar este frame.
func tick_frame(real_dt: float) -> float:
	if _window_t > 0.0:
		_window_t = maxf(0.0, _window_t - real_dt)
	if _freeze_frames > 0:
		_freeze_frames -= 1
		return 0.0
	if _dilation_t > 0.0:
		_dilation_t = maxf(0.0, _dilation_t - real_dt)
		return PARRY_DILATION
	return 1.0
