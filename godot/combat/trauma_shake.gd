# trauma_shake.gd — PRD-006 alcance 4 (Game Feel Bible canal 2): screen
# shake por modelo TRAUMA — shake efectivo = trauma² sobre Perlin, nunca
# jitter random. La sopa de screen-shake es la anti-referencia.
#
# Reglas GFB:
#   - trauma ∈ [0,1], decae 1.2/s lineal; cap 0.6 en gameplay (1.0 queda
#     reservado a beats scriptados — la traición).
#   - amplitud máxima 0.25 m de traslación + 2° de roll.
#   - el shake comunica MASA AJENA (lo que te golpea o golpea cerca);
#     el impacto propio habla por thump/stutter (canal ya vivo, no se toca).
#
# Lógica pura (RefCounted, headless-safe); el dueño la tickea y aplica
# offset()/roll() a la cámara DESPUÉS de posicionarla.
#
# Loaded via preload (never class_name — see Lecciones).
extends RefCounted

const DECAY_PER_S: float = 1.2
const MAX_OFFSET_M: float = 0.25
const MAX_ROLL_DEG: float = 2.0
const CAP_GAMEPLAY: float = 0.6
const NOISE_SPEED: float = 14.0   # Hz del recorrido Perlin (suave, no jitter)

# Aportes canon (GFB canal 2):
const HIT_LIGHT: float = 0.15
const HIT_HEAVY: float = 0.30
const RECEIVE_HEAVY: float = 0.25
const GROUND_POUND: float = 0.50   # Dagna (PRD-007)
const SPRINGBOARD: float = 0.35    # lanzamiento del link (PRD-007)

var trauma: float = 0.0
var _t: float = 0.0
var _noise: FastNoiseLite = null

func _init() -> void:
	_noise = FastNoiseLite.new()
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.seed = 7
	_noise.frequency = 1.0

## Aporte de gameplay: SIEMPRE bajo el cap 0.6.
func add(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, CAP_GAMEPLAY)

## Beats scriptados (la traición): único camino a trauma > 0.6.
func add_scripted(amount: float) -> void:
	trauma = clampf(trauma + amount, 0.0, 1.0)

func tick(dt: float) -> void:
	trauma = maxf(0.0, trauma - DECAY_PER_S * dt)
	_t += dt * NOISE_SPEED

## Intensidad efectiva: trauma² (GFB).
func shake() -> float:
	return trauma * trauma

func offset() -> Vector3:
	var s: float = shake()
	if s <= 0.0001:
		return Vector3.ZERO
	return Vector3(
		_noise.get_noise_2d(_t, 13.7),
		_noise.get_noise_2d(_t, 47.3),
		_noise.get_noise_2d(_t, 91.1)) * (MAX_OFFSET_M * s)

func roll() -> float:
	if trauma <= 0.001:
		return 0.0
	return _noise.get_noise_2d(_t, 133.7) * deg_to_rad(MAX_ROLL_DEG) * shake()
