# hit_payload.gd — PRD-006 alcance 1: resolución canónica de TODO golpe
# (Combate §A). Cuatro campos canon + MarkMultiplier (§B.1: las marcas son
# datos — fijo 1.0 en Fase 1, fuera de alcance del PRD).
#
# El payload es DUMB DATA: quien lo construye (CombatComponent) aplica la
# física corporal (momentum §4.3); quien lo recibe (GuardComponent) decide
# la reacción. Nada más vive acá.
#
# Loaded via preload (never class_name — see Lecciones).
extends RefCounted

var damage: float = 0.0            # Daño
var balance_damage: float = 0.0    # DañoEquilibrio
var force: Vector3 = Vector3.ZERO  # VectorFuerza (dirección × magnitud)
var interrupt: bool = false        # Interrupción (fuerza flinch aunque no rompa)
var mark_multiplier: float = 1.0   # §B.1 — co-dependencia como dato

# Contexto de momentum (§4.3: masa × velocidad al conectar — el golpe
# saliendo del slide pega más porque el cuerpo TRAE el peso).
var source_mass: float = 1.0
var source_speed: float = 0.0

func scaled_damage() -> float:
	return damage * mark_multiplier

func scaled_balance_damage() -> float:
	return balance_damage * mark_multiplier
