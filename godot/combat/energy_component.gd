# energy_component.gd — PRD-006 alcance 1 (Combate §A): pool de Aether.
# Placeholder de coste en Fase 1 (las habilidades reales y los puentes de
# Speck §B.6 llegan con sus PRDs); la interfaz spend/regen es la canónica.
#
# Loaded via preload (never class_name — see Lecciones).
extends RefCounted

const REGEN_PER_S: float = 6.0
const REGEN_DELAY: float = 0.8

var max_aether: float = 100.0
var aether: float = 100.0
var _regen_hold: float = 0.0

func setup(p_max: float) -> void:
	max_aether = p_max
	aether = p_max

func tick(delta: float) -> void:
	if _regen_hold > 0.0:
		_regen_hold -= delta
	elif aether < max_aether:
		aether = minf(aether + REGEN_PER_S * delta, max_aether)

func can_spend(cost: float) -> bool:
	return aether >= cost

func spend(cost: float) -> bool:
	if not can_spend(cost):
		return false
	aether -= cost
	_regen_hold = REGEN_DELAY
	return true
